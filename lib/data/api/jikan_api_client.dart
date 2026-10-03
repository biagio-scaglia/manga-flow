import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/rate_limiter.dart';
import '../cache/http_cache_manager.dart';

class ApiResponse<T> {
  final T data;
  final bool isFromCache;
  final bool isStale;

  const ApiResponse({
    required this.data,
    this.isFromCache = false,
    this.isStale = false,
  });
}

class JikanApiClient {
  final http.Client _client;
  final RateLimiter _rateLimiter;
  final HttpCacheManager _cacheManager;
  final String baseUrl;

  JikanApiClient({
    http.Client? client,
    RateLimiter? rateLimiter,
    HttpCacheManager? cacheManager,
    this.baseUrl = AppConstants.apiBaseUrl,
  })  : _client = client ?? http.Client(),
        _rateLimiter = rateLimiter ?? RateLimiter(),
        _cacheManager = cacheManager ?? HttpCacheManager();

  Future<ApiResponse<Map<String, dynamic>>> postGraphQL({
    required String query,
    Map<String, dynamic>? variables,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final payload = {
      'query': query,
      'variables': variables ?? {},
    };
    final cacheKey = '$baseUrl:${jsonEncode(payload)}';

    // 1. Controlla la cache
    if (!forceRefresh) {
      final cached = await _cacheManager.get(cacheKey);
      if (cached != null && !cached.isStale) {
        if (kDebugMode) {
          debugPrint('[ApiClient] Cache HIT: $cacheKey');
        }
        return ApiResponse(
          data: cached.data as Map<String, dynamic>,
          isFromCache: true,
          isStale: false,
        );
      }
    }

    // 2. Chiamata con retry
    int attempt = 0;
    Duration delay = AppConstants.baseRetryDelay;

    while (attempt < AppConstants.maxRetries) {
      attempt++;
      try {
        await _rateLimiter.acquire();

        if (kDebugMode) {
          debugPrint('[ApiClient] Richiesta API (tentativo $attempt): $variables');
        }

        final response = await _client.post(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(payload),
        ).timeout(AppConstants.apiTimeout);

        if (response.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
          await _cacheManager.put(cacheKey, body, ttl: cacheTtl);

          return ApiResponse(
            data: body,
            isFromCache: false,
            isStale: false,
          );
        } else if (response.statusCode == 429) {
          _rateLimiter.blockFor(const Duration(seconds: 2));
          if (attempt >= AppConstants.maxRetries) {
            final fallback = await _cacheManager.get(cacheKey);
            if (fallback != null) {
              return ApiResponse(
                data: fallback.data as Map<String, dynamic>,
                isFromCache: true,
                isStale: true,
              );
            }
            throw RateLimitException('Hai effettuato troppe richieste. Attendi qualche istante.');
          }
          await Future.delayed(const Duration(seconds: 2));
          continue;
        } else if (response.statusCode >= 500) {
          if (attempt < AppConstants.maxRetries) {
            await Future.delayed(delay);
            delay *= 2;
            continue;
          }
          throw ServerException('Il server dei manga è temporaneamente non disponibile.', response.statusCode);
        } else {
          throw ServerException('Errore nella richiesta (${response.statusCode}).', response.statusCode);
        }
      } on SocketException catch (_) {
        final fallback = await _cacheManager.get(cacheKey);
        if (fallback != null) {
          return ApiResponse(
            data: fallback.data as Map<String, dynamic>,
            isFromCache: true,
            isStale: true,
          );
        }
        throw NetworkException('Nessuna connessione a internet disponibile.');
      } on TimeoutException catch (_) {
        if (attempt < AppConstants.maxRetries) {
          await Future.delayed(delay);
          delay *= 2;
          continue;
        }
        final fallback = await _cacheManager.get(cacheKey);
        if (fallback != null) {
          return ApiResponse(
            data: fallback.data as Map<String, dynamic>,
            isFromCache: true,
            isStale: true,
          );
        }
        throw NetworkException('La richiesta ha impiegato troppo tempo.');
      } catch (e) {
        if (e is ServerException || e is RateLimitException || e is NetworkException) {
          rethrow;
        }
        final fallback = await _cacheManager.get(cacheKey);
        if (fallback != null) {
          return ApiResponse(
            data: fallback.data as Map<String, dynamic>,
            isFromCache: true,
            isStale: true,
          );
        }
        throw ServerException('Errore di comunicazione: $e');
      }
    }

    throw ServerException('Impossibile completare la richiesta dopo diversi tentativi.');
  }

  void dispose() {
    _client.close();
  }
}
