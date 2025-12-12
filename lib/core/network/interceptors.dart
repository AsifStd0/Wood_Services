// auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:wood_service/core/services/local_storage_service.dart';
import 'package:wood_service/core/services/shared_local_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorageService localStorageService;

  AuthInterceptor(this.localStorageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get the token from storage
    final token = await localStorageService.getToken();

    // Add authorization header if token exists
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 unauthorized errors
    if (err.response?.statusCode == 401) {
      // Clear token and redirect to login
      await localStorageService.deleteToken();
      // You might want to add navigation logic here
    }
    return super.onError(err, handler);
  }
}
