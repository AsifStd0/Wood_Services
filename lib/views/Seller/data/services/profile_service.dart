// services/seller_auth_service.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:wood_service/core/error/failure.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import '../../../../core/services/local_storage_service.dart';
import 'package:wood_service/views/Seller/data/models/seller_signup_model.dart'; // Your model

class ProfileService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  ProfileService({
    required Dio dio,
    required LocalStorageService localStorageService,
  }) : _dio = dio,
       _localStorageService = localStorageService;

  // Storage keys
  static const String _sellerTokenKey = 'seller_auth_token';
  static const String _sellerDataKey = 'seller_auth_data';
  static const String _sellerLoginStatusKey = 'seller_is_logged_in';

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
}
