// locator.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wood_service/core/network/interceptors.dart';
import 'package:wood_service/core/services/shared_local_storage_service.dart';
import 'package:wood_service/data/repositories/image_upload_service.dart';
import 'package:wood_service/data/repositories/auth_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Setup Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://your-api-base-url.com/api', // REPLACE WITH ACTUAL URL
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Register LocalStorageService FIRST
  locator.registerLazySingleton<LocalStorageService>(
    () => LocalStorageServiceImpl(),
  );

  // Add interceptors
  dio.interceptors.addAll([
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ),
    AuthInterceptor(locator<LocalStorageService>()),
  ]);

  // Register Dio instance
  locator.registerLazySingleton<Dio>(() => dio);

  // Register AuthService with both dependencies
  locator.registerLazySingleton<AuthService>(
    () => AuthServiceImplementation(
      locator<Dio>(),
      locator<LocalStorageService>(),
    ),
  );

  // Register ImageUploadService
  locator.registerLazySingleton<ImageUploadService>(
    () => ImageUploadServiceImpl(locator<Dio>()),
  );
}
