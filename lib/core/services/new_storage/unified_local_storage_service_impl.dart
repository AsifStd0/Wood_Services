// unified_local_storage_service_impl.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wood_service/core/services/new_storage/base_local_storage_service.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

class UnifiedLocalStorageServiceImpl implements BaseLocalStorageService {
  static const String _userDataKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _selectedRoleKey = 'selected_role';
  static const String _appLanguageKey = 'app_language';

  late SharedPreferences _prefs;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clearAllData() async {
    await _prefs.clear();
  }

  // Save user data from API response
  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final userModel = UserModel.fromJson(userData);
    final jsonString = json.encode(userModel.toJson());

    await _prefs.setString(_userDataKey, jsonString);
    await _prefs.setString(_selectedRoleKey, userModel.role);
    await _prefs.setBool(_isLoggedInKey, true);
  }

  // Save UserModel directly
  Future<void> saveUserModel(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await _prefs.setString(_userDataKey, jsonString);
    await _prefs.setString(_selectedRoleKey, user.role);
    await _prefs.setBool(_isLoggedInKey, true);
  }

  // Get UserModel
  UserModel? getUserModel() {
    final jsonString = _prefs.getString(_userDataKey);
    if (jsonString != null) {
      try {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Map<String, dynamic>? getUserData() {
    final jsonString = _prefs.getString(_userDataKey);
    if (jsonString != null) {
      try {
        return json.decode(jsonString);
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  @override
  String? getUserRole() {
    return _prefs.getString(_selectedRoleKey);
  }

  @override
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  @override
  Future<void> logout() async {
    // Clear user data but keep app settings
    await _prefs.remove(_userDataKey);
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_isLoggedInKey);
    await _prefs.remove(_selectedRoleKey);
    // Keep _appLanguageKey
  }

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> saveSelectedRole(String role) async {
    await _prefs.setString(_selectedRoleKey, role);
  }

  @override
  String? getSelectedRole() {
    return _prefs.getString(_selectedRoleKey);
  }

  // Update specific user fields
  Future<void> updateUserField(String key, dynamic value) async {
    final userModel = getUserModel();
    if (userModel != null) {
      final updatedData = userModel.toJson();
      updatedData[key] = value;
      await saveUserData(updatedData);
    }
  }

  // Update profile image URL
  Future<void> updateProfileImage(String imageUrl) async {
    await updateUserField('profileImage', imageUrl);
  }

  // Update shop logo URL (for sellers)
  Future<void> updateShopLogo(String logoUrl) async {
    await updateUserField('shopLogo', logoUrl);
  }

  // Check if user has seller documents
  bool hasSellerDocuments() {
    final user = getUserModel();
    if (user == null || !user.isSeller) return false;

    return user.businessLicense != null &&
        user.taxCertificate != null &&
        user.identityProof != null;
  }

  // Get user display name
  String? getDisplayName() {
    final user = getUserModel();
    if (user == null) return null;

    if (user.isSeller && user.shopName != null && user.shopName!.isNotEmpty) {
      return user.shopName;
    }
    return user.name;
  }

  // Save app language
  Future<void> saveAppLanguage(String languageCode) async {
    await _prefs.setString(_appLanguageKey, languageCode);
  }

  // Get app language
  String getAppLanguage() {
    return _prefs.getString(_appLanguageKey) ?? 'en';
  }
}
