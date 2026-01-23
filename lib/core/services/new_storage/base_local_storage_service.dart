// base_local_storage_service.dart

import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

abstract class BaseLocalStorageService {
  Future<void> initialize();
  Future<void> clearAllData();

  // User data methods
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<void> saveUserModel(UserModel user);
  UserModel? getUserModel();
  Map<String, dynamic>? getUserData();
  String? getUserRole();

  // Auth methods
  bool isLoggedIn();
  Future<void> logout();
  Future<void> saveToken(String token);
  String? getToken();

  // Role methods
  Future<void> saveSelectedRole(String role);
  String? getSelectedRole();

  // Update methods
  Future<void> updateUserField(String key, dynamic value);
  Future<void> updateProfileImage(String imageUrl);
  Future<void> updateShopLogo(String logoUrl);

  // Check methods
  bool hasSellerDocuments();
  String? getDisplayName();

  // App settings
  Future<void> saveAppLanguage(String languageCode);
  String getAppLanguage();
}
