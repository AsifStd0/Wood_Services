// services/seller_auth_service.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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

  // Login Seller
  Future<Either<Failure, SellerAuthResponse>> loginSeller({
    required String email,
    required String password,
  }) async {
    try {
      log('🔐 Attempting login for: $email');

      final response = await _dio.post(
        '/api/seller/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        log('✅ Login successful! Response: $data');

        final token = data['token'];
        final sellerJson = data['seller'];

        if (token == null || sellerJson == null) {
          return Left(ServerFailure('Invalid response from server'));
        }

        final seller = SellerModel.fromJson(sellerJson);

        //  !  *********     // Save to local storage
        await _saveSellerAuthData(token, seller);

        final authResponse = SellerAuthResponse(seller: seller, token: token);

        return Right(authResponse);
      } else {
        return Left(ServerFailure('Login failed: ${response.data['message']}'));
      }
    } on DioException catch (e) {
      log('❌ Login error: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Invalid credentials'));
      }
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      log('❌ Unexpected login error: $e');
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  // ! Save auth data to local storage
  Future<void> _saveSellerAuthData(String token, SellerModel seller) async {
    try {
      await _localStorageService.saveString(_sellerTokenKey, token);
      await _localStorageService.saveString(
        _sellerDataKey,
        jsonEncode(seller.toJson()),
      );
      await _localStorageService.saveBool(_sellerLoginStatusKey, true);

      log(
        '✅ Seller auth data saved successfully -------------------------------------------------------------------------------------------- \n ${seller.toString()}',
      );
      log('💾 Token: ${token.substring(0, 20)}...');
    } catch (e) {
      log('❌ Error saving seller auth data: $e');
      throw Exception('Failed to save auth data');
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

  Future<SellerModel?> getStoredSeller() async {
    try {
      final jsonString = await _localStorageService.getString(_sellerDataKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;

        // Debug: Print what's in storage
        print('🔍 Raw stored seller data:');
        json.forEach((key, value) {
          print('  $key: $value');
        });

        final seller = SellerModel.fromJson(json);

        log('👤 Retrieved stored seller: $seller');
        return seller;
      }
      return null;
    } catch (e) {
      log('❌ Error retrieving stored seller: $e');
      return null;
    }
  }

  // Check if seller is logged in
  Future<bool> isSellerLoggedIn() async {
    try {
      final token = await getSellerToken();
      final status = await _localStorageService.getBool(_sellerLoginStatusKey);

      final isLoggedIn = token != null && token.isNotEmpty && (status ?? false);
      log('🔍 Seller login status: $isLoggedIn');

      return isLoggedIn;
    } catch (e) {
      log('❌ Error checking login status: $e');
      return false;
    }
  }

  //  !  *********   updateProfile
  Future<Either<Failure, SellerModel>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? businessName,
    String? shopName,
    String? description,
    String? address,
    List<String>? categories,
    String? bankName,
    String? accountNumber,
    String? iban,
    File? shopLogo,
    File? shopBanner,
    File? businessLicense,
    File? taxCertificate,
    File? identityProof,
  }) async {
    try {
      log('🔄 Preparing profile update...');

      // Get token properly
      final token = await getSellerToken(); // Use your existing method
      if (token == null) {
        return Left(AuthFailure('Not authenticated. Please login again.'));
      }

      log('🔑 Using token: ${token.substring(0, 20)}...');

      final formData = FormData.fromMap({
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (businessName != null) 'businessName': businessName,
        if (shopName != null) 'shopName': shopName,
        if (description != null) 'businessDescription': description,
        if (address != null) 'businessAddress': address,
        if (categories != null) 'categories': jsonEncode(categories),
        if (bankName != null) 'bankName': bankName,
        if (accountNumber != null) 'accountNumber': accountNumber,
        if (iban != null) 'iban': iban,
      });

      // Add files if provided
      if (shopLogo != null) {
        formData.files.add(
          MapEntry(
            'shopLogo',
            await MultipartFile.fromFile(
              shopLogo.path,
              filename: shopLogo.path.split('/').last,
            ),
          ),
        );
        log('📸 Adding shop logo for update');
      }

      if (shopBanner != null) {
        formData.files.add(
          MapEntry(
            'shopBanner',
            await MultipartFile.fromFile(
              shopBanner.path,
              filename: shopBanner.path.split('/').last,
            ),
          ),
        );
        log('📸 Adding shop banner for update');
      }

      // Add other document files if needed
      if (businessLicense != null) {
        formData.files.add(
          MapEntry(
            'businessLicense',
            await MultipartFile.fromFile(
              businessLicense.path,
              filename: businessLicense.path.split('/').last,
            ),
          ),
        );
        log('📄 Adding business license for update');
      }

      if (taxCertificate != null) {
        formData.files.add(
          MapEntry(
            'taxCertificate',
            await MultipartFile.fromFile(
              taxCertificate.path,
              filename: taxCertificate.path.split('/').last,
            ),
          ),
        );
        log('📄 Adding tax certificate for update');
      }

      if (identityProof != null) {
        formData.files.add(
          MapEntry(
            'identityProof',
            await MultipartFile.fromFile(
              identityProof.path,
              filename: identityProof.path.split('/').last,
            ),
          ),
        );
        log('📄 Adding identity proof for update');
      }

      log('🚀 Sending update request to: /api/seller/auth/profile');
      log('📊 Form data fields: ${formData.fields.length}');
      log('📊 Form data files: ${formData.files.length}');

      final response = await _dio.put(
        '/api/seller/auth/profile', // ✅ CORRECT PATH
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('✅ Update response status: ${response.statusCode}');
      log('✅ Update response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        log('✅ Profile updated successfully: ${data['seller']}');

        // Convert response to SellerModel
        final sellerJson = data['seller'];
        final seller = SellerModel.fromJson(sellerJson);

        // Save updated data to local storage
        await _saveSellerAuthData(data['token'] ?? token, seller);

        return Right(seller);
      } else {
        return Left(
          ServerFailure('Update failed: ${response.data['message']}'),
        );
      }
    } on DioException catch (e) {
      log('❌ Dio error updating profile: ${e.message}');
      log('❌ Response: ${e.response?.data}');
      log('❌ Status code: ${e.response?.statusCode}');
      log('❌ Headers: ${e.response?.headers}');

      if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Session expired. Please login a.kkk,gain.'));
      }
      if (e.response?.statusCode == 404) {
        return Left(ServerFailure('Endpoint not found. Check server routes.'));
      }
      return Left(ServerFailure('Update error: ${e.message}'));
    } catch (e) {
      log('❌ Unexpected error updating profile: $e');
      return Left(UnknownFailure('Unexpected error: $e'));
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
