import 'package:dio/dio.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/core/error/error_handler.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

/// Centralized HTTP Client using Dio
/// All network requests should use this client
class DioClient {
  late final Dio _dio;
  final UnifiedLocalStorageServiceImpl _storage;

  DioClient({
    required UnifiedLocalStorageServiceImpl storage,
    Dio? dio,
  }) : _storage = storage {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: Config.apiBaseUrl,
            connectTimeout: Config.connectTimeout,
            receiveTimeout: Config.receiveTimeout,
            headers: Config.defaultHeaders,
            validateStatus: (status) => status != null && status < 500,
          ),
        );

    _setupInterceptors();
  }

  /// Setup request/response interceptors
  void _setupInterceptors() {
    // Request Interceptor - Add auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = _storage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            // Log error but don't block request
            print('⚠️ Error getting token in interceptor: $e');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - logout user
          if (error.response?.statusCode == 401) {
            try {
              await _storage.logout();
              // Navigation to login can be handled by app-level logic
            } catch (e) {
              print('⚠️ Error during logout: $e');
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor in development
    if (Config.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (object) => print(object),
        ),
      );
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fileKey: await MultipartFile.fromFile(filePath),
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Upload multiple files
  Future<Response<T>> uploadFiles<T>(
    String path,
    List<String> filePaths, {
    String fileKey = 'files',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final files = await Future.wait(
        filePaths.map((path) => MultipartFile.fromFile(path)),
      );

      final formData = FormData.fromMap({
        ...?data,
        fileKey: files,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Get the underlying Dio instance (for advanced usage)
  Dio get dio => _dio;
}
