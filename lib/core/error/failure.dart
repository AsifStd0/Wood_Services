abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => 'Failure: $message';
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
