import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';

class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  const CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().isAfter(timestamp.add(ttl));

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'ttl_ms': ttl.inMilliseconds,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'] as T,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: Duration(
        milliseconds:
            json['ttl_ms'] as int? ?? AppConstants.cacheTtl.inMilliseconds,
      ),
    );
  }
}

class CacheLookupResult<T> {
  final T data;
  final bool isStale;
  final DateTime cachedAt;

  const CacheLookupResult({
    required this.data,
    required this.isStale,
    required this.cachedAt,
  });
}

class HttpCacheManager {
  final Map<String, CacheEntry<dynamic>> _memoryCache = {};
  final String cacheFileName;
  final Duration defaultTtl;
  final Directory? customDirectory;
  bool _isInitialized = false;

  HttpCacheManager({
    this.cacheFileName = AppConstants.cacheFileName,
    this.defaultTtl = AppConstants.cacheTtl,
    this.customDirectory,
  });

  Future<File> _getCacheFile() async {
    final dir = customDirectory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/$cacheFileName');
  }

  Future<void> init() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final Map<String, dynamic> decoded =
              jsonDecode(content) as Map<String, dynamic>;
          for (final entry in decoded.entries) {
            if (entry.value is Map<String, dynamic>) {
              try {
                final cacheEntry = CacheEntry<dynamic>.fromJson(
                  entry.value as Map<String, dynamic>,
                );
                _memoryCache[entry.key] = cacheEntry;
              } catch (_) {}
            }
          }
        }
      }
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[HttpCacheManager] Inizializzazione cache su disco non disponibile: $e',
        );
      }
      _isInitialized = true;
    }
  }

  Future<CacheLookupResult<dynamic>?> get(String key) async {
    await init();
    final entry = _memoryCache[key];
    if (entry == null) return null;

    return CacheLookupResult(
      data: entry.data,
      isStale: entry.isExpired,
      cachedAt: entry.timestamp,
    );
  }

  Future<void> put(String key, dynamic data, {Duration? ttl}) async {
    await init();
    final entry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? defaultTtl,
    );
    _memoryCache[key] = entry;

    if (!kIsWeb) {
      _saveToDisk();
    }
  }

  Future<void> _saveToDisk() async {
    if (kIsWeb) return;
    try {
      final file = await _getCacheFile();
      final Map<String, dynamic> exportMap = {};
      final now = DateTime.now();

      _memoryCache.removeWhere(
        (key, entry) => now.difference(entry.timestamp).inDays > 7,
      );

      for (final entry in _memoryCache.entries) {
        exportMap[entry.key] = entry.value.toJson();
      }

      await file.writeAsString(jsonEncode(exportMap), flush: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HttpCacheManager] Errore salvataggio cache su disco: $e');
      }
    }
  }

  Future<void> clear() async {
    _memoryCache.clear();
    if (kIsWeb) return;
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<int> getSizeBytes() async {
    if (kIsWeb) {
      return jsonEncode(_memoryCache).length;
    }
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
