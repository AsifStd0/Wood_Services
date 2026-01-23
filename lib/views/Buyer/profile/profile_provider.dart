// lib/providers/buyer_profile_viewmodel.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

class BuyerProfileViewProvider extends ChangeNotifier {
  final UnifiedLocalStorageServiceImpl _storage;
  final Dio _dio;

  // Profile data from UserModel
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  String? _successMessage;

  // For image updates
  File? _newProfileImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  File? get newProfileImage => _newProfileImage;
  // Convenience getters
  String get fullName => _currentUser?.name ?? '';
  String get email => _currentUser?.email ?? '';
  String get businessName => _currentUser?.businessName ?? '';
  String get address => _currentUser?.address ?? '';
  String get description => _currentUser?.businessDescription ?? '';
  String get iban => _currentUser?.iban ?? '';
  String? get profileImagePath => _currentUser?.profileImage;
  bool get hasData => _currentUser != null;
  bool get isLoggedIn => hasData;
  // add address

  // Constructor
  BuyerProfileViewProvider({UnifiedLocalStorageServiceImpl? storage, Dio? dio})
    : _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>(),
      _dio = dio ?? locator<Dio>() {
    loadProfile();
  }

  // Load profile data
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _storage.getUserModel();

      if (user != null) {
        _currentUser = user;
      } else {
        log('⚠️ No profile found');
      }
    } catch (e) {
      log('❌ Error loading profile: $e');
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'No token available';
        return;
      }

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

        log('''
================ USER DATA =================
${const JsonEncoder.withIndent('  ').convert(userData)}
==========================================
''');

        final user = UserModel.fromJson(userData);

        await _storage.saveUserData(userData);
        _currentUser = user;
        _successMessage = 'Profile refreshed successfully';

        log('✅ Profile refreshed successfully');
      } else {
        _errorMessage = 'Failed to refresh profile';
      }
    } catch (e, s) {
      log('❌ Error refreshing profile', error: e, stackTrace: s);
      _errorMessage = 'Failed to refresh profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add this method to set new profile image
  void setNewProfileImage(File image) {
    _newProfileImage = image;
    notifyListeners();
    log('📸 Profile image set for update');
  }

  // Update profile with text data
  Future<bool> updateProfileData({
    String? fullName,
    String? email,
    String? contactName,
    String? businessName,
    String? address,
    String? description,
    String? bankName,
    String? iban,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final token = _storage.getToken();
      if (token == null) {
        _errorMessage = 'Not authenticated';
        return false;
      }

      print('🔄 Starting profile update...');

      final updates = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) {
        updates['name'] = fullName;
      }
      if (email != null && email.isNotEmpty) {
        updates['email'] = email;
      }
      if (businessName != null) {
        updates['businessName'] = businessName;
      }
      if (address != null) {
        updates['address'] = address;
      }
      if (description != null) {
        updates['businessDescription'] = description;
      }
      if (iban != null) {
        updates['iban'] = iban;
      }

      FormData formData;
      if (_newProfileImage != null) {
        formData = FormData.fromMap({
          ...updates,
          'profileImage': await MultipartFile.fromFile(
            _newProfileImage!.path,
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
          contentType: _newProfileImage != null
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

        await _storage.saveUserData(userData);
        _currentUser = user;
        _successMessage =
            response.data['message'] ?? 'Profile updated successfully';
        _isEditing = false;
        _newProfileImage = null;

        print('✅ Profile updated successfully: ${_currentUser?.name}');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to update profile';
        return false;
      }
    } on DioException catch (e) {
      print('❌ Dio error updating profile: ${e.message}');
      _errorMessage =
          e.response?.data['message'] ?? 'Network error: ${e.message}';
      return false;
    } catch (e) {
      print('❌ Error updating profile: $e');
      _errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pick new profile image
  Future<void> pickProfileImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        _newProfileImage = File(image.path);
        log('📸 New profile image selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking image: $e';
      log('❌ Error picking profile image: $e');
      notifyListeners();
    }
  }

  // Clear new profile image
  void clearNewProfileImage() {
    _newProfileImage = null;
    notifyListeners();
  }

  // Logout
  Future<bool> logout() async {
    try {
      log('🔄 Starting logout...');
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // Clear storage first
      await _storage.logout();

      // Clear local state
      _currentUser = null;
      _newProfileImage = null;

      _isLoading = false;
      notifyListeners();

      log('✅ Logout completed');
      return true;
    } catch (e) {
      log('❌ Error during logout: $e');
      _errorMessage = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set editing mode
  void setEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // // Update individual fields
  // void updateField(String field, String value) {
  //   if (_currentUser != null) {
  //     final updatedUser = _currentUser!.copyWith(
  //       name: field == 'fullName' || field == 'name'
  //           ? value
  //           : _currentUser!.name,
  //       email: field == 'email' ? value : _currentUser!.email,
  //       businessName: field == 'businessName'
  //           ? value
  //           : _currentUser!.businessName,
  //       address: field == 'address' ? value : _currentUser!.address,
  //       businessDescription:
  //           field == 'description' || field == 'businessDescription'
  //           ? value
  //           : _currentUser!.businessDescription,
  //       iban: field == 'iban' ? value : _currentUser!.iban,
  //     );

  //     _currentUser = updatedUser;
  //     notifyListeners();
  //   }
  // }
}
