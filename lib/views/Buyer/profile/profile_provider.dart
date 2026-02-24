// lib/providers/buyer_profile_viewmodel.dart
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/profile/profile_service.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

class BuyerProfileViewProvider extends ChangeNotifier {
  final UnifiedLocalStorageServiceImpl _storage;
  final BuyerProfileService _profileService;

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
  BuyerProfileViewProvider({
    UnifiedLocalStorageServiceImpl? storage,
    BuyerProfileService? profileService,
  }) : _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>(),
       _profileService = profileService ?? BuyerProfileService() {
    loadProfile();
    initializeSettings();
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

      final user = await _profileService.getProfile();
      await _storage.saveUserData(user.toJson());
      _currentUser = user;
      _successMessage = 'Profile refreshed successfully';

      log('✅ Profile refreshed successfully');
    } catch (e) {
      log('❌ Error refreshing profile: $e');
      _errorMessage = e.toString();
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
    String? businessName,
    String? address,
    String? description,
    String? iban,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      log('🔄 Starting profile update...');

      final user = await _profileService.updateProfile(
        name: fullName,
        email: email,
        businessName: businessName,
        address: address,
        businessDescription: description,
        iban: iban,
        profileImagePath: _newProfileImage?.path,
      );

      await _storage.saveUserData(user.toJson());
      _currentUser = user;
      _successMessage = 'Profile updated successfully';
      _isEditing = false;
      _newProfileImage = null;

      log('✅ Profile updated successfully: ${_currentUser?.name}');
      notifyListeners();
      return true;
    } catch (e) {
      log('❌ Error updating profile: $e');
      _errorMessage = e.toString();
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

  // Language settings
  String _language = 'English';
  String get language => _language;

  Future<void> setLanguage(String language) async {
    _language = language;
    await _storage.saveString('user_language', language);
    notifyListeners();
    log('🌐 Language changed to: $language');
  }

  Future<void> loadLanguage() async {
    final savedLanguage = await _storage.getString('user_language');
    _language = savedLanguage ?? 'English';
    notifyListeners();
  }

  // Dark mode settings
  bool _darkMode = false;
  bool get darkMode => _darkMode;

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    await _storage.saveBool('dark_mode', enabled);
    notifyListeners();
    log('🌙 Dark mode ${enabled ? 'enabled' : 'disabled'}');
  }

  Future<void> loadDarkMode() async {
    final savedDarkMode = await _storage.getBool('dark_mode');
    _darkMode = savedDarkMode ?? false;
    notifyListeners();
  }

  // Initialize settings
  Future<void> initializeSettings() async {
    await loadLanguage();
    await loadDarkMode();
  }
}
