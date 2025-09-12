import 'dart:io';

import 'package:dio/dio.dart';
// services/image_upload_service.dart
import 'package:dartz/dartz.dart';
import 'package:wood_service/core/error/failure.dart';

abstract class ImageUploadService {
  Future<Either<Failure, String>> uploadImage(File image, String path);
}

class ImageUploadServiceImpl implements ImageUploadService {
  final Dio _dio;

  ImageUploadServiceImpl(this._dio);

  @override
  Future<Either<Failure, String>> uploadImage(File image, String path) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

      final FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
        'path': path,
      });

      final response = await _dio.post(
        '/upload/image',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return Right(response.data['imageUrl'] ?? response.data['url']);
      } else {
        return Left(
          ServerFailure('Failed to upload image: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(NetworkFailure('Image upload timeout. Please try again.'));
      }
      return Left(ServerFailure('Failed to upload image: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('Failed to upload image: ${e.toString()}'));
    }
  }
}
