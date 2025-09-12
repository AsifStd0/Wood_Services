abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => 'Failure: $message';
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
