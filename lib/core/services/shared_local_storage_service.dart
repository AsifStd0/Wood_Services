import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager {
  static late SharedPreferences _prefs;

  // Initialize once in main.dart
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== BASIC CRUD OPERATIONS ==========
  static Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<bool> saveStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  static Future<bool> delete(String key) async {
    return await _prefs.remove(key);
  }

  static Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // ========== TOKEN MANAGEMENT ==========
  static const String _tokenKey = 'auth_token';

  static Future<bool> saveToken(String token) async {
    return await saveString(_tokenKey, token);
  }

  static String? getToken() {
    return getString(_tokenKey);
  }

  static Future<bool> deleteToken() async {
    return await delete(_tokenKey);
  }
}
