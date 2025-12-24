// core/services/seller_local_storage_service_impl.dart
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'seller_local_storage_service.dart';

class SellerLocalStorageServiceImpl implements SellerLocalStorageService {
  // Seller-specific keys
  static const String _sellerTokenKey = 'seller_auth_token';
  static const String _sellerDataKey = 'seller_auth_data';
  static const String _sellerLoginStatusKey = 'seller_is_logged_in';

  SharedPreferences? _prefs;

  // ========== INITIALIZATION ==========
  @override
  Future<void> initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      log('📱 Seller Storage initialized');
    }
  }

  Future<SharedPreferences> get _sharedPrefs async {
    await initialize();
    return _prefs!;
  }

  // ========== CORE METHODS ==========
  @override
  Future<void> saveString(String key, String value) async {
    final prefs = await _sharedPrefs;
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getString(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await initialize();
    await _prefs!.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    await initialize();
    return _prefs!.getBool(key);
  }

  @override
  Future<void> delete(String key) async {
    await initialize();
    await _prefs!.remove(key);
  }

  @override
  Future<void> clearAll() async {
    await initialize();
    await _prefs!.clear();
    log('🧹 Cleared ALL Seller storage');
  }

  @override
  Future<bool> containsKey(String key) async {
    await initialize();
    return _prefs!.containsKey(key);
  }

  @override
  Future<Set<String>> getAllKeys() async {
    await initialize();
    return _prefs!.getKeys();
  }

  // ========== SELLER-SPECIFIC METHODS ==========
  @override
  Future<void> saveSellerToken(String token) async {
    log('💾 Seller: Saving token');
    await saveString(_sellerTokenKey, token);
  }

  @override
  Future<String?> getSellerToken() async {
    final token = await getString(_sellerTokenKey);
    log('🔍 Seller token: ${token != null ? "EXISTS" : "NULL"}');
    return token;
  }

  // ✅ UPDATED: Save Map<String, dynamic> instead of String
  @override
  Future<void> saveSellerData(Map<String, dynamic> sellerData) async {
    log('💾 Seller: Saving data');
    final sellerJson = jsonEncode(sellerData);
    await saveString(_sellerDataKey, sellerJson);
  }

  // ✅ UPDATED: Return Map<String, dynamic> instead of String
  @override
  Future<Map<String, dynamic>?> getSellerData() async {
    final data = await getString(_sellerDataKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  @override
  Future<void> saveSellerLoginStatus(bool isLoggedIn) async {
    log('💾 Seller: Login status: $isLoggedIn');
    await saveBool(_sellerLoginStatusKey, isLoggedIn);
  }

  @override
  Future<bool?> getSellerLoginStatus() async {
    final status = await getBool(_sellerLoginStatusKey);
    log('🔍 Seller login status: $status');
    return status;
  }

  @override
  Future<void> deleteSellerAuth() async {
    log('🗑️ Seller: Deleting auth data');
    await delete(_sellerTokenKey);
    await delete(_sellerDataKey);
    await delete(_sellerLoginStatusKey);
    log('✅ Seller auth data deleted');
  }

  // ✅ ADD these missing methods if needed:
  @override
  Future<bool> isSellerLoggedIn() async {
    final token = await getSellerToken();
    final data = await getSellerData();
    return token != null && token.isNotEmpty && data != null;
  }

  @override
  Future<void> sellerLogout() async {
    await deleteSellerAuth();
  }
}
