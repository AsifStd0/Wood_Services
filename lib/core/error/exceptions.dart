class AppException implements Exception {
  final String message;
  final int code;

  AppException(this.message, this.code);

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

class NetworkException extends AppException {
  NetworkException() : super('No internet connection', 1000);
}

class BadRequestException extends AppException {
  BadRequestException() : super('Bad request', 400);
}

class UnauthorizedException extends AppException {
  UnauthorizedException() : super('Unauthorized', 401);
}

class ForbiddenException extends AppException {
  ForbiddenException() : super('Forbidden', 403);
}

class NotFoundException extends AppException {
  NotFoundException() : super('Not found', 404);
}

class ServerException extends AppException {
  ServerException() : super('Server error', 500);
}

class UnknownException extends AppException {
  UnknownException() : super('Unknown error', 0);
}
