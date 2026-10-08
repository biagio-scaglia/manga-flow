class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message ($statusCode)';
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Errore di connessione di rete']);

  @override
  String toString() => 'NetworkException: $message';
}

class RateLimitException implements Exception {
  final String message;
  final int? retryAfterSeconds;
  RateLimitException([
    this.message = 'Limite di richieste superato',
    this.retryAfterSeconds,
  ]);

  @override
  String toString() =>
      'RateLimitException: $message (retryAfter: $retryAfterSeconds)';
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Errore cache']);

  @override
  String toString() => 'CacheException: $message';
}

class StorageException implements Exception {
  final String message;
  StorageException([this.message = 'Errore memoria locale']);

  @override
  String toString() => 'StorageException: $message';
}
