import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

/// Buyer Profile Service
/// Handles all API calls for buyer profile operations
class BuyerProfileService {
  final Dio _dio;
  final UnifiedLocalStorageServiceImpl _storage;

  BuyerProfileService({Dio? dio, UnifiedLocalStorageServiceImpl? storage})
    : _dio = dio ?? locator<Dio>(),
      _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>();

  /// Get current user profile from API
  Future<UserModel> getProfile() async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }

      log('🔄 Fetching profile from API...');

      final response = await _dio.get(
        '/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData;

        if (response.data['data'] != null &&
            response.data['data']['user'] != null) {
          userData = response.data['data']['user'] as Map<String, dynamic>;
        } else if (response.data['user'] != null) {
          userData = response.data['user'] as Map<String, dynamic>;
        } else if (response.data['success'] == true &&
            response.data['buyer'] != null) {
          userData = response.data['buyer'] as Map<String, dynamic>;
        } else {
          userData = response.data as Map<String, dynamic>;
        }

        final user = UserModel.fromJson(userData);
        log('✅ Profile fetched successfully: ${user.name}');
        return user;
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error fetching profile: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Network error: ${e.message}',
      );
    } catch (e) {
      log('❌ Error fetching profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? countryCode,
    String? businessName,
    String? address,
    String? businessDescription,
    String? iban,
    String? profileImagePath,
  }) async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }

      log('🔄 Updating profile...');

      final updates = <String, dynamic>{};
      if (name != null && name.isNotEmpty) updates['name'] = name;
      if (email != null && email.isNotEmpty) updates['email'] = email;
      if (phone != null) updates['phone'] = phone;
      if (countryCode != null && countryCode.isNotEmpty) updates['countryCode'] = countryCode;
      if (businessName != null) updates['businessName'] = businessName;
      if (address != null) updates['address'] = address;
      if (businessDescription != null) {
        updates['businessDescription'] = businessDescription;
      }
      if (iban != null) updates['iban'] = iban;

      FormData formData;
      if (profileImagePath != null) {
        formData = FormData.fromMap({
          ...updates,
          'profileImage': await MultipartFile.fromFile(
            profileImagePath,
            filename: 'profile-${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        });
      } else {
        formData = FormData.fromMap(updates);
      }

      final response = await _dio.put(
        '/auth/profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: profileImagePath != null
              ? 'multipart/form-data'
              : 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData;
        if (response.data['data'] != null &&
            response.data['data']['user'] != null) {
          userData = response.data['data']['user'] as Map<String, dynamic>;
        } else if (response.data['user'] != null) {
          userData = response.data['user'] as Map<String, dynamic>;
        } else if (response.data['success'] == true &&
            response.data['buyer'] != null) {
          userData = response.data['buyer'] as Map<String, dynamic>;
        } else {
          userData = response.data as Map<String, dynamic>;
        }

        final user = UserModel.fromJson(userData);
        log('✅ Profile updated successfully: ${user.name}');
        return user;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error updating profile: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Network error: ${e.message}',
      );
    } catch (e) {
      log('❌ Error updating profile: $e');
      rethrow;
    }
  }
}
