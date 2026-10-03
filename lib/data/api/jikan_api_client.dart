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

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParams?.map((k, v) => MapEntry(k, v.trim())),
    );
    final cacheKey = uri.toString();

    // 1. Controlla la cache
    if (!forceRefresh) {
      final cached = await _cacheManager.get(cacheKey);
      if (cached != null && !cached.isStale) {
        if (kDebugMode) {
          debugPrint('[JikanApiClient] Cache HIT fresca: $cacheKey');
        }
        return ApiResponse(
          data: cached.data as Map<String, dynamic>,
          isFromCache: true,
          isStale: false,
        );
      }
    }

    // 2. Chiamata di rete con retry controllato ed exponential backoff
    int attempt = 0;
    Duration delay = AppConstants.baseRetryDelay;

    while (attempt < AppConstants.maxRetries) {
      attempt++;
      try {
        await _rateLimiter.acquire();

        if (kDebugMode) {
          debugPrint('[JikanApiClient] Richiesta HTTP (tentativo $attempt): $uri');
        }

        final response = await _client.get(
          uri,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'MangaFlowApp/1.0',
          },
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
          // Gestione Rate Limit 429
          int waitSeconds = 2;
          final retryAfterHeader = response.headers['retry-after'];
          if (retryAfterHeader != null) {
            waitSeconds = int.tryParse(retryAfterHeader) ?? 2;
          }
          _rateLimiter.blockFor(Duration(seconds: waitSeconds));

          if (kDebugMode) {
            debugPrint('[JikanApiClient] Ricevuto HTTP 429. Blocco per $waitSeconds sec e riprovo.');
          }

          if (attempt >= AppConstants.maxRetries) {
            final fallback = await _cacheManager.get(cacheKey);
            if (fallback != null) {
              return ApiResponse(
                data: fallback.data as Map<String, dynamic>,
                isFromCache: true,
                isStale: true,
              );
            }
            throw RateLimitException(
              'Hai effettuato troppe richieste in poco tempo. Attendi qualche istante e riprova.',
              waitSeconds,
            );
          }

          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        } else if (response.statusCode >= 500) {
          if (attempt < AppConstants.maxRetries) {
            await Future.delayed(delay);
            delay *= 2;
            continue;
          }
          throw ServerException('Il server dei manga non risponde. Riprova più tardi.', response.statusCode);
        } else if (response.statusCode == 404) {
          throw ServerException('Risorsa non trovata.', 404);
        } else {
          throw ServerException('Errore imprevisto dal server (${response.statusCode}).', response.statusCode);
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
        throw NetworkException('La richiesta ha impiegato troppo tempo. Controlla la connessione.');
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
