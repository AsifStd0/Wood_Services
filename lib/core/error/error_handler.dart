import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:wood_service/core/error/app_exception.dart';

/// Centralized error handler for the application
/// Converts various error types to AppException
class ErrorHandler {
  /// Handle and convert errors to AppException
  static AppException handleError(dynamic error) {
    log('🔴 ErrorHandler: Handling error - ${error.runtimeType}');

    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is FormatException) {
      return AppException(
        'Invalid data format',
        code: 400,
        originalError: error,
      );
    }

    if (error is TypeError) {
      return AppException(
        'Type error occurred',
        code: 400,
        originalError: error,
      );
    }

    // Generic exception
    return UnknownException(
      error.toString(),
    );
  }

  /// Handle Dio-specific errors
  static AppException _handleDioError(DioException error) {
    log('🔴 DioError: ${error.type} - ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);
        return ApiException.fromStatusCode(
          statusCode ?? 500,
          message,
        );

      case DioExceptionType.cancel:
        return AppException(
          'Request cancelled',
          code: -1,
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');

      case DioExceptionType.badCertificate:
        return AppException(
          'SSL certificate error',
          code: 495,
          originalError: error,
        );

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Failed host lookup') == true) {
          return NetworkException('No internet connection');
        }
        return UnknownException(error.message);
    }
  }

  /// Extract error message from API response
  static String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return 'Unknown error';

    if (responseData is Map) {
      // Try common error message fields
      return responseData['message'] as String? ??
          responseData['error'] as String? ??
          responseData['errors']?.toString() ??
          'An error occurred';
    }

    if (responseData is String) {
      return responseData;
    }

    return 'An error occurred';
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(AppException exception) {
    if (exception is NetworkException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (exception is UnauthorizedException) {
      return 'Your session has expired. Please login again.';
    }

    if (exception is NotFoundException) {
      return 'The requested resource was not found.';
    }

    if (exception is ServerException) {
      return 'Server error. Please try again later.';
    }

    if (exception is ValidationException) {
      return exception.message;
    }

    // Return the exception message as fallback
    return exception.message;
  }

  /// Check if error is network-related
  static bool isNetworkError(AppException exception) {
    return exception is NetworkException;
  }

  /// Check if error is authentication-related
  static bool isAuthError(AppException exception) {
    return exception is UnauthorizedException ||
        exception is AuthenticationException ||
        exception is ForbiddenException;
  }

  /// Check if error is server-related
  static bool isServerError(AppException exception) {
    return exception is ServerException ||
        (exception is ApiException && exception.statusCode != null && exception.statusCode! >= 500);
  }
}
