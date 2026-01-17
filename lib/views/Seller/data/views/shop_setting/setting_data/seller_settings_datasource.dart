// features/seller_settings/data/datasources/seller_settings_datasource.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

class SellerSettingsDataSource {
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();
  final Dio _dio = locator<Dio>();

  Future<UserModel?> getSellerProfile() async {
    try {
      final user = _storage.getUserModel();
      return (user != null && user.role == 'seller') ? user : null;
    } catch (e) {
      log('❌ Error getting seller profile: $e');
      return null;
    }
  }

  Future<UserModel> updateSellerProfile({
    required Map<String, dynamic> updates,
    List<Map<String, dynamic>>? files,
  }) async {
    try {
      final token = _storage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final formData = FormData();

      // Add text fields
      updates.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add files
      if (files != null) {
        for (final file in files) {
          formData.files.add(
            MapEntry(
              file['field'],
              await MultipartFile.fromFile(
                file['path'],
                filename: file['filename'],
              ),
            ),
          );
        }
      }

      final response = await _dio.put(
        '/auth/profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData;
        if (response.data['data'] != null &&
            response.data['data']['user'] != null) {
          userData = response.data['data']['user'] as Map<String, dynamic>;
        } else if (response.data['user'] != null) {
          userData = response.data['user'] as Map<String, dynamic>;
        } else {
          userData = response.data as Map<String, dynamic>;
        }

        final user = UserModel.fromJson(userData);
        await _storage.saveUserData(user.toJson());
        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
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

  Future<UserModel> refreshProfile() async {
    try {
      final token = _storage.getToken();
      if (token == null) throw Exception('Not authenticated');

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
        } else {
          userData = response.data as Map<String, dynamic>;
        }

        log('✅ Profile data refreshed: $userData');
        final user = UserModel.fromJson(userData);
        await _storage.saveUserData(user.toJson());
        return user;
      } else {
        throw Exception('Failed to refresh profile');
      }
    } catch (e) {
      log('❌ Error refreshing profile: $e');
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      await _storage.logout();
      return true;
    } catch (e) {
      log('❌ Error during logout: $e');
      return false;
    }
  }
}
