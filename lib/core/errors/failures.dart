abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Impossibile connettersi al server. Verifica la tua connessione internet.']);
}

class RateLimitFailure extends Failure {
  final int? retryAfterSeconds;
  const RateLimitFailure([
    super.message = 'Hai effettuato troppe richieste in poco tempo. Attendi qualche istante e riprova.',
    this.retryAfterSeconds,
  ]) : super(statusCode: 429);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Dati non disponibili nella cache locale.']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Errore durante la lettura o la scrittura della libreria locale.']);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Formato dei dati non valido o inatteso.']);
}
