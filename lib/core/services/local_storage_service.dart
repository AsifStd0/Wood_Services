import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  // Core methods
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);
  Future<void> delete(String key); // ✅ This is the correct name
  Future<void> clearAll();

  // Auth-specific methods
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  // Helper methods
  Future<bool> containsKey(String key);
  Future<Set<String>> getAllKeys();
}

class LocalStorageServiceImpl implements LocalStorageService {
  static const String _sellerTokenKey = 'seller_auth_token';
  static const String _sellerDataKey = 'seller_auth_data';
  static const String _sellerLoginStatusKey = 'seller_is_logged_in';
  static const String _serverUrlKey = 'working_server_url';

  static const String _tokenKey = 'auth_token';

  static LocalStorageServiceImpl? _instance;
  SharedPreferences? _prefs;

  // Private constructor
  LocalStorageServiceImpl._internal();

  // ✅ Factory constructor
  factory LocalStorageServiceImpl() {
    return _instance ??= LocalStorageServiceImpl._internal();
  }

  // ✅ Static getInstance method (optional, for backward compatibility)
  static Future<LocalStorageServiceImpl> getInstance() async {
    final instance = LocalStorageServiceImpl();
    await instance.initialize();
    return instance;
  }

  // ✅ Initialize method
  Future<void> initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      log('📱 SharedPreferences initialized');
    }
  }

  // Ensure SharedPreferences is initialized
  Future<SharedPreferences> get _sharedPrefs async {
    await initialize();
    return _prefs!;
  }

  // All other methods remain the same...
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

  // Initialize SharedPreferences
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setBool(key, value);
    } catch (e) {
      throw Exception('Failed to save bool: $e');
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      await _ensureInitialized();
      return _prefs!.getBool(key);
    } catch (e) {
      log('Error getting bool for key $key: $e');
      return null;
    }
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setStringList(key, value);
    } catch (e) {
      throw Exception('Failed to save string list: $e');
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      await _ensureInitialized();
      return _prefs!.getStringList(key);
    } catch (e) {
      log('Error getting string list for key $key: $e');
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(key);
    } catch (e) {
      throw Exception('Failed to delete key $key: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _ensureInitialized();
      await _prefs!.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await saveString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return await getString(_tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await delete(_tokenKey);
  }

  // ✅ Seller-specific methods
  Future<void> saveSellerToken(String token) async {
    await saveString(_sellerTokenKey, token);
  }

  Future<String?> getSellerToken() async {
    return await getString(_sellerTokenKey);
  }

  Future<void> deleteSellerToken() async {
    await delete(_sellerTokenKey);
  }

  Future<void> saveSellerData(String sellerJson) async {
    await saveString(_sellerDataKey, sellerJson);
  }

  Future<String?> getSellerData() async {
    return await getString(_sellerDataKey);
  }

  Future<void> saveSellerLoginStatus(bool isLoggedIn) async {
    await saveBool(_sellerLoginStatusKey, isLoggedIn);
  }

  Future<bool?> getSellerLoginStatus() async {
    return await getBool(_sellerLoginStatusKey);
  }

  Future<void> saveServerUrl(String url) async {
    await saveString(_serverUrlKey, url);
  }

  Future<String?> getServerUrl() async {
    return await getString(_serverUrlKey);
  }

  // ✅ New helper methods
  @override
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  @override
  Future<Set<String>> getAllKeys() async {
    await _ensureInitialized();
    return _prefs!.getKeys();
  }

  // Get all stored data (for debugging)
  Future<Map<String, dynamic>> getAllData() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys();
    final data = <String, dynamic>{};

    for (final key in keys) {
      final value = _prefs!.get(key);
      data[key] = value;
    }

    return data;
  }
}
