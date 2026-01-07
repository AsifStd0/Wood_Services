// ! services/seller_auth_service.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:wood_service/app/buyer_config.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/core/error/failure.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/views/Seller/data/models/seller_signup_model.dart';

import 'package:path/path.dart' as path;

class SellerAuthService {
  final Dio _dio;
  final SellerLocalStorageService _localStorageService;

  SellerAuthService(this._dio, this._localStorageService);

  // ========== AUTH STATUS ==========
  Future<bool> isLoggedIn() async {
    try {
      final token = await _localStorageService.getSellerToken();
      final sellerData = await _localStorageService.getSellerData();

      return token != null &&
          token.isNotEmpty &&
          sellerData != null &&
          sellerData.isNotEmpty;
    } catch (e) {
      log('Error checking login status: $e');
      return false;
    }
  }

  // ========== GET CURRENT SELLER ==========
  Future<SellerModel?> getCurrentSeller() async {
    try {
      final sellerData = await _localStorageService.getSellerData();
      return sellerData != null ? SellerModel.fromJson(sellerData) : null;
    } catch (e) {
      log('Error getting current seller: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    return await _localStorageService.getSellerToken();
  }

  // ========== AUTH HELPERS ==========
  Future<void> _saveAuthData(String token, SellerModel seller) async {
    await _localStorageService.saveSellerToken(token);
    await _localStorageService.saveSellerData(seller.toJson());
    await _localStorageService.saveSellerLoginStatus(true);
  }

  String? _extractIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      payload = payload.padRight((payload.length + 3) & ~3, '=');

      final decoded = utf8.decode(base64Url.decode(payload));
      final payloadMap = jsonDecode(decoded);
      return payloadMap['id']?.toString();
    } catch (e) {
      log('Failed to extract ID from token: $e');
      return null;
    }
  }

  SellerModel _ensureSellerHasId(
    String token,
    Map<String, dynamic> sellerJson,
  ) {
    final id = _extractIdFromToken(token);
    if (id != null &&
        !sellerJson.containsKey('_id') &&
        !sellerJson.containsKey('id')) {
      sellerJson['_id'] = id;
      sellerJson['id'] = id;
    }
    return SellerModel.fromJson(sellerJson);
  }

  // ========== REGISTER ==========
  Future<Either<Failure, SellerAuthData>> register({
    required SellerModel seller,
  }) async {
    try {
      final formData = await _buildRegistrationFormData(seller);
      final response = await _dio.post(
        Endpoints.sellerRegister,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['token'];
        final sellerJson = data['seller'];

        if (token == null || sellerJson == null) {
          return Left(ServerFailure('Invalid response from server'));
        }

        final registeredSeller = _ensureSellerHasId(token, sellerJson);
        await _saveAuthData(token, registeredSeller);

        return Right(SellerAuthData(seller: registeredSeller, token: token));
      }

      final message = response.data['message'] ?? 'Registration failed';
      return Left(ServerFailure(message));
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return Left(
          ValidationFailure(e.response?.data['message'] ?? 'Invalid data'),
        );
      }
      if (e.response?.statusCode == 409) {
        return Left(AuthFailure('Seller already exists with this email'));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  Future<FormData> _buildRegistrationFormData(SellerModel seller) async {
    final formData = FormData.fromMap({
      'fullName': seller.personalInfo.fullName,
      'email': seller.personalInfo.email,
      'password': seller.personalInfo.password,
      'confirmPassword': seller.personalInfo.password,
      'phone': jsonEncode({
        'countryCode': seller.personalInfo.countryCode,
        'number': seller.personalInfo.phone.replaceFirst(
          seller.personalInfo.countryCode,
          '',
        ),
      }),
      'businessName': seller.businessInfo.businessName,
      'shopName': seller.businessInfo.shopName,
      'businessDescription': seller.businessInfo.description,
      'businessAddress': seller.businessInfo.address,
      'categories': jsonEncode(seller.businessInfo.categories),
      'bankName': seller.bankDetails.bankName,
      'accountNumber': seller.bankDetails.accountNumber,
      'iban': seller.bankDetails.iban,
    });

    // Add files
    await _addFileToFormData(
      formData,
      'shopLogo',
      seller.shopBrandingImages.shopLogo,
    );
    await _addFileToFormData(
      formData,
      'shopBanner',
      seller.shopBrandingImages.shopBanner,
    );
    await _addFileToFormData(
      formData,
      'businessLicense',
      seller.documentsImage.businessLicense,
    );
    await _addFileToFormData(
      formData,
      'taxCertificate',
      seller.documentsImage.taxCertificate,
    );
    await _addFileToFormData(
      formData,
      'identityProof',
      seller.documentsImage.identityProof,
    );

    return formData;
  }

  Future<void> _addFileToFormData(
    FormData formData,
    String fieldName,
    File? file,
  ) async {
    if (file == null) return;

    formData.files.add(
      MapEntry(
        fieldName,
        await MultipartFile.fromFile(
          file.path,
          filename: path.basename(file.path),
        ),
      ),
    );
  }

  // ========== LOGIN ==========
  Future<Either<Failure, SellerAuthData>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.sellerLogin,
        data: {'email': email.trim(), 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final sellerJson = data['seller'];

        if (token == null || sellerJson == null) {
          return Left(AuthFailure('Invalid server response'));
        }

        final seller = _ensureSellerHasId(token, sellerJson);
        await _saveAuthData(token, seller);

        return Right(SellerAuthData(seller: seller, token: token));
      }

      if (response.statusCode == 401) {
        return Left(AuthFailure('Invalid email or password'));
      }

      final message = response.data['message'] ?? 'Login failed';
      return Left(ServerFailure(message));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Invalid email or password'));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  // ========== LOGOUT ==========
  Future<void> logout() async {
    await _localStorageService.sellerLogout();
  }

  // ========== GET PROFILE ==========
  Future<Either<Failure, SellerModel>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return Left(AuthFailure('Not authenticated'));

      final response = await _dio.get(
        Endpoints.sellerProfile,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final sellerJson = response.data['seller'];
        if (sellerJson == null) {
          return Left(ServerFailure('Invalid response'));
        }

        final seller = SellerModel.fromJson(sellerJson);
        await _localStorageService.saveSellerData(seller.toJson());

        return Right(seller);
      }

      return Left(ServerFailure('Failed to fetch profile'));
    } on DioException catch (e) {
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  // ========== UPDATE PROFILE ==========
  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> updates,
    File? shopLogo,
    File? shopBanner,
    File? businessLicense,
    File? taxCertificate,
    File? identityProof,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final formData = FormData.fromMap(updates);
      await _addFileToFormData(formData, 'shopLogo', shopLogo);
      await _addFileToFormData(formData, 'shopBanner', shopBanner);
      await _addFileToFormData(formData, 'businessLicense', businessLicense);
      await _addFileToFormData(formData, 'taxCertificate', taxCertificate);
      await _addFileToFormData(formData, 'identityProof', identityProof);

      final response = await _dio.put(
        '${Config.apiBaseUrl}/api/seller/auth/profileUpdate',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['seller'] != null) {
          final updatedSeller = SellerModel.fromJson(data['seller']);
          await _saveAuthData(token, updatedSeller);
        }

        return {
          'success': true,
          'message': 'Profile updated successfully',
          'data': data,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Update failed',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error',
      };
    } catch (e) {
      return {'success': false, 'message': 'Update failed: $e'};
    }
  }
}

// Simplified auth response class
class SellerAuthData {
  final SellerModel seller;
  final String token;
  final DateTime? expiresAt;

  SellerAuthData({required this.seller, required this.token, this.expiresAt});
}



  // // ========== FORGOT PASSWORD ==========
  // Future<Either<Failure, void>> forgotPassword(String email) async {
  //   try {
  //     log('🔐 Sending password reset request for: $email');

  //     final response = await _dio.post(
  //       '/api/seller/auth/forgot-password',
  //       data: {'email': email.trim()},
  //     );

  //     if (response.statusCode == 200) {
  //       log('✅ Password reset email sent to: $email');
  //       return const Right(null);
  //     } else {
  //       return Left(ServerFailure('Failed to send reset email'));
  //     }
  //   } on DioException catch (e) {
  //     log('❌ Dio error during password reset: ${e.message}');
  //     return Left(NetworkFailure('Network error: ${e.message}'));
  //   } catch (e) {
  //     log('❌ Unexpected error: $e');
  //     return Left(UnknownFailure('Unexpected error: $e'));
  //   }
  // }

  // // ========== RESET PASSWORD ==========
  // Future<Either<Failure, void>> resetPassword({
  //   required String token,
  //   required String newPassword,
  // }) async {
  //   try {
  //     log('🔐 Resetting password...');

  //     final response = await _dio.post(
  //       '/api/seller/auth/reset-password',
  //       data: {'token': token, 'newPassword': newPassword},
  //     );

  //     if (response.statusCode == 200) {
  //       log('✅ Password reset successfully');
  //       return const Right(null);
  //     } else {
  //       return Left(ServerFailure('Failed to reset password'));
  //     }
  //   } on DioException catch (e) {
  //     log('❌ Dio error during password reset: ${e.message}');
  //     return Left(NetworkFailure('Network error: ${e.message}'));
  //   } catch (e) {
  //     log('❌ Unexpected error: $e');
  //     return Left(UnknownFailure('Unexpected error: $e'));
  //   }
  // }

  // // ========== REFRESH TOKEN ==========
  // Future<Either<Failure, String>> refreshToken() async {
  //   try {
  //     log('🔄 Refreshing token...');

  //     final currentToken = await _localStorageService.getSellerToken();
  //     if (currentToken == null) {
  //       return Left(AuthFailure('No token found'));
  //     }

  //     final response = await _dio.post(
  //       '/api/seller/auth/refresh-token',
  //       data: {'token': currentToken},
  //     );

  //     if (response.statusCode == 200) {
  //       final newToken = response.data['token'];
  //       if (newToken == null) {
  //         return Left(AuthFailure('Invalid response from server'));
  //       }

  //       // Save new token
  //       await _localStorageService.saveSellerToken(newToken);
  //       log('✅ Token refreshed successfully');

  //       return Right(newToken);
  //     } else {
  //       return Left(AuthFailure('Failed to refresh token'));
  //     }
  //   } on DioException catch (e) {
  //     log('❌ Dio error during token refresh: ${e.message}');
  //     return Left(NetworkFailure('Network error: ${e.message}'));
  //   } catch (e) {
  //     log('❌ Unexpected error: $e');
  //     return Left(UnknownFailure('Unexpected error: $e'));
  //   }
  // }

