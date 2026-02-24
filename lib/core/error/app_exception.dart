/// Base exception class for all application exceptions
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException([String? message])
      : super(
          message ?? 'No internet connection',
          code: 1000,
        );
}

/// API-related exceptions
class ApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  const ApiException(
    String message, {
    this.statusCode,
    this.responseData,
    int? code,
  }) : super(message, code: code ?? statusCode);

  factory ApiException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 500:
      case 502:
      case 503:
        return ServerException(message);
      default:
        return ApiException(
          message ?? 'API Error',
          statusCode: statusCode,
          code: statusCode,
        );
    }
  }
}

/// Specific API exceptions
class BadRequestException extends ApiException {
  const BadRequestException([String? message])
      : super(
          message ?? 'Bad request',
          statusCode: 400,
          code: 400,
        );
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String? message])
      : super(
          message ?? 'Unauthorized',
          statusCode: 401,
          code: 401,
        );
}

class ForbiddenException extends ApiException {
  const ForbiddenException([String? message])
      : super(
          message ?? 'Forbidden',
          statusCode: 403,
          code: 403,
        );
}

class NotFoundException extends ApiException {
  const NotFoundException([String? message])
      : super(
          message ?? 'Not found',
          statusCode: 404,
          code: 404,
        );
}

class ServerException extends ApiException {
  const ServerException([String? message])
      : super(
          message ?? 'Server error',
          statusCode: 500,
          code: 500,
        );
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException(
    String message, {
    this.errors,
  }) : super(message, code: 422);
}

/// Authentication exceptions
class AuthenticationException extends AppException {
  const AuthenticationException([String? message])
      : super(
          message ?? 'Authentication failed',
          code: 401,
        );
}

/// Unknown/Generic exceptions
class UnknownException extends AppException {
  const UnknownException([String? message])
      : super(
          message ?? 'Unknown error occurred',
          code: 0,
        );
}
