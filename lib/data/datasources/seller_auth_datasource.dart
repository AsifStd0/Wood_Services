// // data/datasources/seller_auth_datasource.dart
// import 'package:dio/dio.dart';
// import 'package:http/http.dart';
// // import 'package:wood_service/app/index.dart';
// import 'package:wood_service/core/error/exceptions.dart';

// class SellerAuthDataSource {
//   final Dio _dio;

//   SellerAuthDataSource(this._dio);

//   Future<Map<String, dynamic>> registerSeller({
//     required Map<String, dynamic> data,
//     required List<MultipartFile> files,
//   }) async {
//     try {
//       // Create FormData for multipart request
//       final formData = FormData.fromMap(data);

//       // Add files to formData
//       for (var file in files) {
//         formData.files.add(
//           MapEntry(
//             file.field,
//             await MultipartFile.fromFile(
//               file.file.path,
//               filename: file.file.path.split('/').last,
//             ),
//           ),
//         );
//       }

//       final response = await _dio.post(
//         '/api/seller/auth/register',
//         data: formData,
//         options: Options(headers: {'Content-Type': 'multipart/form-data'}),
//       );

//       return response.data;
//     } on DioException catch (e) {
//       throw ServerException(e.message ?? 'Registration failed');
//     }
//   }
// }
