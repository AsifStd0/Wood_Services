// lib/services/profile_service.dart
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_model.dart';

class BuyerProfileService {
  final Dio _dio;
  final BuyerLocalStorageService _localStorageService;

  BuyerProfileService({Dio? dio, BuyerLocalStorageService? localStorageService})
    : _dio = dio ?? locator<Dio>(),
      _localStorageService =
          localStorageService ?? locator<BuyerLocalStorageService>();

  // Get current buyer profile from local storage
  Future<BuyerModel?> getCurrentBuyer() async {
    try {
      final buyerData = await _localStorageService.getBuyerData();
      final token = await _localStorageService.getBuyerToken();

      log(
        '🔍 getCurrentBuyer - Raw buyerData from storage: token is here ??? $token',
      );
      if (buyerData != null) {
        buyerData.forEach((key, value) {
          log(
            '   $key: ${value is String && value.length > 50 ? '${value.substring(0, 50)}...' : value}',
          );
        });

        // Try to parse
        log('🔍 Attempting to parse BuyerModel...');
        try {
          final buyer = BuyerModel.fromJson(buyerData);
          log('✅ Successfully parsed buyer: ${buyer.fullName}');
          log('   Email: ${buyer.email}');
          log('   Business: ${buyer.businessName}');
          log('   Bank: ${buyer.bankName}');
          log('   IBAN: ${buyer.iban}');
          return buyer;
        } catch (e) {
          log('❌ Error parsing BuyerModel: $e');
          log('❌ Stack trace: ${e.toString()}');
          return null;
        }
      } else {
        log('❌ No buyerData in storage');
        return null;
      }
    } catch (e) {
      log('❌ Error getting current buyer: $e');
      return null;
    }
  }

  Future<BuyerModel?> fetchProfileFromApi() async {
    try {
      final token = await _localStorageService.getBuyerToken();

      if (token == null || token.isEmpty) {
        log('❌ No token available for API request');
        return null;
      }

      final response = await _dio.get(
        '/api/buyer/auth/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // ADD DEBUG LOGGING
        log('📊 API Response data: $data');
        log('📊 API Response data type: ${data.runtimeType}');

        if (data is Map) {
          log('📊 Keys in response: ${data.keys.toList()}');
          if (data['buyer'] != null) {
            log('📊 Buyer keys: ${(data['buyer'] as Map).keys.toList()}');
            log('📊 Has bankDetails: ${data['buyer']['bankDetails'] != null}');
            if (data['buyer']['bankDetails'] != null) {
              log(
                '📊 bankDetails keys: ${(data['buyer']['bankDetails'] as Map).keys.toList()}',
              );
              log('📊 bankName: ${data['buyer']['bankDetails']['bankName']}');
              log('📊 iban: ${data['buyer']['bankDetails']['iban']}');
            }
          }
        }

        if (data['success'] == true) {
          final buyerJson = data['buyer'];
          final buyer = BuyerModel.fromJson(buyerJson);

          // Save updated data to local storage
          await _localStorageService.saveBuyerData(buyerJson);
          log('✅ Profile fetched from API: ${buyer.fullName}');

          return buyer;
        }
      }

      log('❌ Failed to fetch profile: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      log('❌ Dio error fetching profile: ${e.message}');
      return null;
    } catch (e) {
      log('❌ Unexpected error fetching profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateProfileBuyer({
    required Map<String, dynamic> updates,
    File? profileImage,
  }) async {
    try {
      final token = await _localStorageService.getBuyerToken();

      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      FormData formData;

      if (profileImage != null) {
        // Multipart request for image upload
        formData = FormData.fromMap({
          ...updates,
          'profileImage': await MultipartFile.fromFile(
            profileImage.path,
            filename: 'profile-${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        });
        print('📤 Sending multipart request with profile image');
      } else {
        // Regular JSON request
        formData = FormData.fromMap(updates);
        print('📤 Sending regular update request');
      }

      print('🔄 Updates being sent: $updates');
      print('📄 Profile image: ${profileImage?.path}');
      print('🔑 Token: ${token.substring(0, 20)}...');

      final response = await _dio.put(
        '/api/buyer/auth/profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: profileImage != null
              ? 'multipart/form-data'
              : 'application/json',
        ),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          // Update local storage
          await _localStorageService.saveBuyerData(data['buyer']);

          return {
            'success': true,
            'message': data['message'] ?? 'Profile updated successfully',
            'buyer': BuyerModel.fromJson(data['buyer']),
          };
        }
      }

      return {'success': false, 'message': 'Failed to update profile'};
    } on DioException catch (e) {
      print('❌ Dio error updating profile: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Status: ${e.response?.statusCode}');
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      print('❌ Unexpected error updating profile: $e');
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      return await _localStorageService.isBuyerLoggedIn();
    } catch (e) {
      log('❌ Error checking login status: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _localStorageService.buyerLogout();

      // Clear Dio headers
      _dio.options.headers.remove('Authorization');

      log('✅ Logout successful');
    } catch (e) {
      log('❌ Error during logout: $e');
      throw Exception('Logout failed: $e');
    }
  }
}
