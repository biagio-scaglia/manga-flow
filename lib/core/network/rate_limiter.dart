import 'dart:async';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Duration minInterval;

  final List<DateTime> _requestTimestamps = [];
  DateTime? _lastRequestTime;
  DateTime? _blockedUntil;

  RateLimiter({
    this.maxRequests = AppConstants.rateLimitRequests,
    this.window = AppConstants.rateLimitWindow,
    this.minInterval = AppConstants.minRequestInterval,
  });

  bool get isBlocked {
    if (_blockedUntil != null) {
      if (DateTime.now().isBefore(_blockedUntil!)) {
        return true;
      }
      _blockedUntil = null;
    }
    return false;
  }

  void blockFor(Duration duration) {
    _blockedUntil = DateTime.now().add(duration);
    if (kDebugMode) {
      debugPrint(
        '[RateLimiter] Bloccato per ${duration.inSeconds} secondi fino a $_blockedUntil',
      );
    }
  }

  Future<void> acquire() async {
    final now = DateTime.now();

    if (isBlocked) {
      final remaining = _blockedUntil!.difference(now);
      throw RateLimitException(
        'Limite richieste superato. Attendi prima di riprovare.',
        remaining.inSeconds,
      );
    }

    // Pulisci i timestamp più vecchi della finestra temporale
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > window,
    );

    // Controlla il limite per finestra temporale
    if (_requestTimestamps.length >= maxRequests) {
      final oldestInWindow = _requestTimestamps.first;
      final waitTime = window - now.difference(oldestInWindow);
      if (waitTime > Duration.zero) {
        if (kDebugMode) {
          debugPrint(
            '[RateLimiter] Finestra piena. Attesa di ${waitTime.inMilliseconds}ms',
          );
        }
        await Future.delayed(waitTime);
      }
    }

    // Controlla l'intervallo minimo tra richieste consecutive
    if (_lastRequestTime != null) {
      final elapsedSinceLast = DateTime.now().difference(_lastRequestTime!);
      if (elapsedSinceLast < minInterval) {
        final waitInterval = minInterval - elapsedSinceLast;
        await Future.delayed(waitInterval);
      }
    }

    final executionTime = DateTime.now();
    _requestTimestamps.add(executionTime);
    _lastRequestTime = executionTime;
  }

  void reset() {
    _requestTimestamps.clear();
    _lastRequestTime = null;
    _blockedUntil = null;
  }
}
