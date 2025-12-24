// // auth_service.dart
// import 'package:dio/dio.dart';
// import 'package:dartz/dartz.dart';
// import 'package:wood_service/core/error/failure.dart';
// import 'package:wood_service/core/services/oldddddd_local_storage_service.dart';
// import 'package:wood_service/data/models/user_model.dart';

// abstract class AuthService {
//   Future<Either<Failure, UserModel>> login({
//     required String email,
//     required String password,
//   });

//   Future<Either<Failure, UserModel>> register({
//     required String email,
//     required String password,
//     required String name,
//     // String? phone,
//     // String? address,
//     String? image,
//   });

//   Future<Either<Failure, void>> logout();
//   Future<Either<Failure, bool>> isLoggedIn();
//   Future<Either<Failure, UserModel?>> getCurrentUser();
// }

// class AuthServiceImplementation implements AuthService {
//   final Dio _dio;
//   final LocalStorageServiceSeller _localStorageService;

//   AuthServiceImplementation(this._dio, this._localStorageService);

//   @override
//   Future<Either<Failure, UserModel>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/auth/login',
//         data: {'email': email, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         final user = UserModel.fromJson(response.data['user']);
//         final token = response.data['token']; // Get token from response

//         // Save token to local storage
//         if (token != null) {
//           await _localStorageService.saveToken(token);
//         }

//         return Right(user);
//       } else {
//         return Left(ServerFailure('Login failed'));
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) {
//         return Left(AuthFailure('Invalid credentials'));
//       }
//       return Left(ServerFailure('Network error: ${e.message}'));
//     } catch (e) {
//       return Left(UnknownFailure('Unexpected error: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, UserModel>> register({
//     required String email,
//     required String password,
//     required String name,
//     String? phone,
//     String? address,
//     String? image,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/auth/register',
//         data: {
//           'email': email,
//           'password': password,
//           'name': name,
//           // if (phone != null) 'phone': phone,
//           // if (address != null) 'address': address,
//           if (image != null) 'profileImage': image,
//         },
//       );

//       if (response.statusCode == 201) {
//         final user = UserModel.fromJson(response.data['user']);
//         final token = response.data['token']; // Get token from response

//         // Save token to local storage
//         if (token != null) {
//           await _localStorageService.saveToken(token);
//         }

//         return Right(user);
//       } else {
//         return Left(ServerFailure('Registration failed'));
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 400) {
//         return Left(ValidationFailure('Invalid data provided'));
//       }
//       if (e.response?.statusCode == 409) {
//         return Left(AuthFailure('User already exists'));
//       }
//       return Left(ServerFailure('Network error: ${e.message}'));
//     } catch (e) {
//       return Left(UnknownFailure('Unexpected error: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> logout() async {
//     try {
//       await _dio.post('/auth/logout');
//       await _localStorageService.deleteToken(); // Clear token on logout
//       return const Right(null);
//     } catch (e) {
//       return Left(UnknownFailure('Logout failed'));
//     }
//   }

//   @override
//   Future<Either<Failure, bool>> isLoggedIn() async {
//     try {
//       final token = await _localStorageService.getToken();
//       if (token == null) return const Right(false);

//       final response = await _dio.get('/auth/check');
//       return Right(response.statusCode == 200);
//     } catch (e) {
//       return Left(UnknownFailure('Check login failed'));
//     }
//   }

//   @override
//   Future<Either<Failure, UserModel?>> getCurrentUser() async {
//     try {
//       final response = await _dio.get('/auth/user');
//       if (response.statusCode == 200) {
//         return Right(UserModel.fromJson(response.data['user']));
//       }
//       return const Right(null);
//     } catch (e) {
//       return Left(UnknownFailure('Failed to get user'));
//     }
//   }
// }
