// services/seller_auth_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:wood_service/core/error/failure.dart';
import '../../../../core/services/local_storage_service.dart';
import 'package:wood_service/views/Seller/data/models/seller_signup_model.dart'; // Your model

class SellerAuthService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  // Storage keys
  static const String _sellerTokenKey = 'seller_auth_token';
  static const String _sellerDataKey = 'seller_auth_data';
  static const String _sellerLoginStatusKey = 'seller_is_logged_in';

  SellerAuthService(this._dio, this._localStorageService);

  //  !  *********     // Register Seller
  Future<Either<Failure, SellerAuthResponse>> registerSeller({
    required SellerModel seller,
  }) async {
    try {
      log('📤 Preparing seller registration...');

      // Create FormData using YOUR model structure
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

      int fileCount = 0;

      // Add shop logo file
      if (seller.shopBrandingImages.shopLogo != null) {
        formData.files.add(
          MapEntry(
            'shopLogo',
            await MultipartFile.fromFile(
              seller.shopBrandingImages.shopLogo!.path,
              filename: seller.shopBrandingImages.shopLogo!.path
                  .split('/')
                  .last,
            ),
          ),
        );
        fileCount++; // INCREMENT HERE
        log('📸 Added shop logo: ${seller.shopBrandingImages.shopLogo!.path}');
      }

      // Add shop banner file
      if (seller.shopBrandingImages.shopBanner != null) {
        formData.files.add(
          MapEntry(
            'shopBanner',
            await MultipartFile.fromFile(
              seller.shopBrandingImages.shopBanner!.path,
              filename: seller.shopBrandingImages.shopBanner!.path
                  .split('/')
                  .last,
            ),
          ),
        );
        fileCount++; // INCREMENT HERE
        log(
          '📸 Added shop banner: ${seller.shopBrandingImages.shopBanner!.path}',
        );
      }

      // ADD DOCUMENTS - Business License
      if (seller.documentsImage.businessLicense != null) {
        formData.files.add(
          MapEntry(
            'businessLicense',
            await MultipartFile.fromFile(
              seller.documentsImage.businessLicense!.path,
              filename: seller.documentsImage.businessLicense!.path
                  .split('/')
                  .last,
            ),
          ),
        );
        fileCount++;
        log(
          '📄 Added business license: ${seller.documentsImage.businessLicense!.path}',
        );
      }

      // ADD DOCUMENTS - Tax Certificate
      if (seller.documentsImage.taxCertificate != null) {
        formData.files.add(
          MapEntry(
            'taxCertificate',
            await MultipartFile.fromFile(
              seller.documentsImage.taxCertificate!.path,
              filename: seller.documentsImage.taxCertificate!.path
                  .split('/')
                  .last,
            ),
          ),
        );
        fileCount++;
        log(
          '📄 Added tax certificate: ${seller.documentsImage.taxCertificate!.path}',
        );
      }

      // ADD DOCUMENTS - Identity Proof
      if (seller.documentsImage.identityProof != null) {
        formData.files.add(
          MapEntry(
            'identityProof',
            await MultipartFile.fromFile(
              seller.documentsImage.identityProof!.path,
              filename: seller.documentsImage.identityProof!.path
                  .split('/')
                  .last,
            ),
          ),
        );
        fileCount++;
        log(
          '📄 Added identity proof: ${seller.documentsImage.identityProof!.path}',
        );
      }

      log('🚀 Sending registration request with $fileCount files...');

      final response = await _dio.post(
        '/api/seller/auth/register',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );
      log('message. ----- ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        log('✅ Registration successful! Response: $data');

        final token = data['token'];
        final sellerJson = data['seller'];

        if (token == null || sellerJson == null) {
          return Left(ServerFailure('Invalid response from server'));
        }

        // !!! FIX: Save the ORIGINAL seller, not fromJson !!!
        // The API response doesn't have all fields
        final registeredSeller = seller; // Use the original seller object

        // ! Save to local storage - THIS IS THE KEY FIX!
        await _saveSellerAuthData(token, registeredSeller);

        // Create response using the complete seller
        final authResponse = SellerAuthResponse(
          seller: registeredSeller,
          token: token,
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        );

        return Right(authResponse);
      } else {
        return Left(
          ServerFailure('Registration failed: ${response.data['message']}'),
        );
      }
    } on DioException catch (e) {
      log('❌ Dio error: ${e.message}');
      log('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        return Left(
          ValidationFailure(e.response?.data['message'] ?? 'Invalid data'),
        );
      }
      if (e.response?.statusCode == 409) {
        return Left(AuthFailure('Seller already exists with this email'));
      }
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      log('❌ Unexpected error: $e');
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  // ********* Login Seller *********
  Future<Either<Failure, SellerAuthResponse>> loginSeller({
    required String email,
    required String password,
  }) async {
    try {
      log('🔐 Attempting login for: $email');

      final response = await _dio.post(
        '/api/seller/auth/login',
        data: {'email': email.trim(), 'password': password},
        options: Options(
          contentType: 'application/json',
          // Don't throw on 401 - handle it gracefully
          validateStatus: (status) => status! < 500,
        ),
      );

      log('📥 Login response: ${response.statusCode}');
      log('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final sellerJson = data['seller'];

        if (token == null || sellerJson == null) {
          return Left(AuthFailure('Invalid server response'));
        }

        // Parse seller from JSON
        final seller = SellerModel.fromJson(sellerJson);

        // Save auth data
        await _saveSellerAuthData(token, seller);

        final authResponse = SellerAuthResponse(
          seller: seller,
          token: token,
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        );

        log('✅ Login successful for: ${seller.personalInfo.fullName}');
        return Right(authResponse);
      } else if (response.statusCode == 401) {
        // ✅ Properly handle invalid credentials
        final message = response.data['message'] ?? 'Invalid email or password';
        log('❌ Login failed: $message');
        return Left(AuthFailure(message));
      } else if (response.statusCode == 404) {
        return Left(AuthFailure('Seller not found'));
      } else {
        return Left(ServerFailure('Login failed: ${response.data['message']}'));
      }
    } on DioException catch (e) {
      log('❌ Dio error during login: ${e.message}');
      log('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Invalid email or password'));
      }

      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      log('❌ Unexpected login error: $e');
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  // ********* Check Login Status *********
  Future<bool> isSellerLoggedIn() async {
    try {
      // Check if token exists
      final token = await _localStorageService.getString(_sellerTokenKey);

      if (token == null || token.isEmpty) {
        log('🔐 No token found in storage');
        return false;
      }

      // Optional: Validate token with server
      try {
        final response = await _dio.get(
          '/api/seller/auth/verify',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

        if (response.statusCode == 200) {
          log('✅ Token is valid');
          return true;
        }
      } catch (e) {
        log('⚠️ Token validation failed, checking local data');
      }

      // Fallback: Check local seller data
      final sellerData = await _localStorageService.getString(_sellerDataKey);
      return sellerData != null && sellerData.isNotEmpty;
    } catch (e) {
      log('❌ Error checking login status: $e');
      return false;
    }
  }

  // ********* Save Auth Data *********
  Future<void> _saveSellerAuthData(String token, SellerModel seller) async {
    try {
      // Save token
      await _localStorageService.saveString(_sellerTokenKey, token);

      // Save seller data as JSON
      final sellerJson = seller.toJson();
      await _localStorageService.saveString(
        _sellerDataKey,
        jsonEncode(sellerJson),
      );

      // Save login status
      await _localStorageService.saveBool(_sellerLoginStatusKey, true);

      log('💾 Auth data saved successfully');
      log('   Token: ${token.substring(0, 20)}...');
      log('   Seller: ${seller.personalInfo.fullName}');
    } catch (e) {
      log('❌ Error saving auth data: $e');
      rethrow;
    }
  }

  // ********* Logout *********
  Future<void> logout() async {
    try {
      log('🚪 Logging out seller...');

      // ✅ Correct: Use delete() not remove()
      await _localStorageService.delete(_sellerTokenKey);
      await _localStorageService.delete(_sellerDataKey);
      await _localStorageService.delete(_sellerLoginStatusKey);

      // Also clear token from Dio headers
      _dio.options.headers.remove('Authorization');

      log('✅ Seller logged out successfully');
    } catch (e) {
      log('❌ Error during logout: $e');
      throw Exception('Logout failed: $e');
    }
  }

  // ********* Get Current Seller *********
  Future<SellerModel?> getCurrentSeller() async {
    try {
      final sellerData = await _localStorageService.getString(_sellerDataKey);
      if (sellerData == null) return null;

      final sellerJson = jsonDecode(sellerData);
      return SellerModel.fromJson(sellerJson);
    } catch (e) {
      log('❌ Error getting current seller: $e');
      return null;
    }
  }

  // Get stored token
  Future<String?> getSellerToken() async {
    try {
      final token = await _localStorageService.getString(_sellerTokenKey);
      if (token != null && token.isNotEmpty) {
        log('🔑 Retrieved token: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      log('❌ Error getting seller token: $e');
      return null;
    }
  }
}

class SellerAuthResponse {
  final SellerModel seller;
  final String token;
  final DateTime? expiresAt;

  SellerAuthResponse({
    required this.seller,
    required this.token,
    this.expiresAt,
  });
}
