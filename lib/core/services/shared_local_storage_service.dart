import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> remove(String key);
  Future<void> clear();

  // Token-specific methods
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

class LocalStorageServiceImpl implements LocalStorageService {
  static const String _tokenKey = 'auth_token';

  @override
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Token methods
  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
