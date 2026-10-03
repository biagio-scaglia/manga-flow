import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/core/errors/exceptions.dart';
import 'package:manga_library/core/network/rate_limiter.dart';

void main() {
  test('RateLimiter permette richieste sotto il limite consentito', () async {
    final limiter = RateLimiter(
      maxRequests: 3,
      window: const Duration(seconds: 1),
      minInterval: const Duration(milliseconds: 50),
    );

    // Esegui 3 richieste
    await limiter.acquire();
    await limiter.acquire();
    await limiter.acquire();

    expect(limiter.isBlocked, isFalse);
  });

  test('RateLimiter blocca e solleva eccezione quando forzato in blocco', () async {
    final limiter = RateLimiter(
      maxRequests: 3,
      window: const Duration(seconds: 1),
      minInterval: const Duration(milliseconds: 50),
    );

    limiter.blockFor(const Duration(seconds: 5));
    expect(limiter.isBlocked, isTrue);

    expect(() => limiter.acquire(), throwsA(isA<RateLimitException>()));
  });
}
