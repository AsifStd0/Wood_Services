// core/services/buyer_local_storage_service_impl.dart
import 'dart:convert'; // Add this import
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'buyer_local_storage_service.dart';

class BuyerLocalStorageServiceImpl implements BuyerLocalStorageService {
  // Buyer-specific keys
  static const String _buyerTokenKey = 'buyer_auth_token';
  static const String _buyerDataKey = 'buyer_auth_data';
  static const String _buyerLoginStatusKey = 'buyer_is_logged_in';
  static const String _buyerLastLoginKey = 'buyer_last_login';

  SharedPreferences? _prefs;

  // ========== INITIALIZATION ==========
  @override
  Future<void> initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      log('📱 Buyer Storage initialized');
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
    log('🧹 Cleared ALL Buyer storage');
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

  // ========== BUYER-SPECIFIC METHODS ==========
  @override
  Future<void> saveBuyerToken(String token) async {
    log('💾 Buyer: Saving token');
    await saveString(_buyerTokenKey, token);
  }

  @override
  Future<String?> getBuyerToken() async {
    final token = await getString(_buyerTokenKey);
    log('🔍 Buyer token: ${token != null ? "EXISTS" : "NULL"}');
    return token;
  }

  // ✅ UPDATED: Save Map<String, dynamic> instead of String
  @override
  Future<void> saveBuyerData(Map<String, dynamic> buyerData) async {
    log('💾 Buyer: Saving data');
    final buyerJson = jsonEncode(buyerData);
    await saveString(_buyerDataKey, buyerJson);
  }

  // ✅ UPDATED: Return Map<String, dynamic> instead of String
  @override
  Future<Map<String, dynamic>?> getBuyerData() async {
    final data = await getString(_buyerDataKey);
    if (data == null) {
      log('🔍 Buyer data: NULL');
      return null;
    }
    try {
      final decodedData = jsonDecode(data) as Map<String, dynamic>;
      return decodedData;
    } catch (e) {
      log('❌ Error decoding buyer data: $e');
      return null;
    }
  }

  @override
  Future<void> saveBuyerLoginStatus(bool isLoggedIn) async {
    log('💾 Buyer: Login status: $isLoggedIn');
    await saveBool(_buyerLoginStatusKey, isLoggedIn);
  }

  @override
  Future<bool?> getBuyerLoginStatus() async {
    final status = await getBool(_buyerLoginStatusKey);
    log('🔍 Buyer login status: $status');
    return status;
  }

  @override
  Future<void> saveBuyerLastLogin() async {
    final now = DateTime.now().toIso8601String();
    await saveString(_buyerLastLoginKey, now);
    log('💾 Buyer: Last login saved: $now');
  }

  // ✅ NEW: Check if buyer is logged in
  @override
  Future<bool> isBuyerLoggedIn() async {
    try {
      final token = await getBuyerToken();
      final data = await getBuyerData();
      // final status = await getBuyerLoginStatus();

      log('🔍 Checking buyer login:');
      log('$token   Token: ${token != null ? "EXISTS" : "NULL"}');
      log('   Data: ${data != null ? "EXISTS" : "NULL"}');

      // Consider logged in if we have token AND data
      final isLoggedIn = token != null && token.isNotEmpty && data != null;
      log('   Is logged in: $isLoggedIn');

      return isLoggedIn;
    } catch (e) {
      log('❌ Error checking buyer login: $e');
      return false;
    }
  }

  // ✅ NEW: Buyer-specific logout
  @override
  Future<void> buyerLogout() async {
    log('🗑️ Buyer: Starting logout...');
    await delete(_buyerTokenKey);
    await delete(_buyerDataKey);
    await delete(_buyerLoginStatusKey);
    await delete(_buyerLastLoginKey);
    log('✅ Buyer auth data deleted');
  }

  @override
  Future<void> deleteBuyerAuth() async {
    await buyerLogout(); // Same as buyerLogout
  }

  // Helper method to save/retrieve string list
  @override
  Future<void> saveStringList(String key, List<String> value) async {
    await initialize();
    await _prefs!.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    await initialize();
    return _prefs!.getStringList(key);
  }
}
