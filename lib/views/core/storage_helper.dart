// lib/core/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save data
  Future<void> setString(String key, String value) async {
    await init();
    await _prefs.setString(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await init();
    await _prefs.setBool(key, value);
  }

  // Get data
  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);

  // Auth specific
  Future<void> saveUser(Map<String, dynamic> user) async {
    await setString('user', jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userString = getString('user');
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  Future<void> saveToken(String token) async {
    await setString('token', token);
    await setBool('isLoggedIn', true);
  }

  String? getToken() => getString('token');
  bool isLoggedIn() => getBool('isLoggedIn') ?? false;

  // Clear all
  Future<void> clearAll() async {
    await init();
    await _prefs.clear();
  }

  // Delete specific
  Future<void> delete(String key) async {
    await init();
    await _prefs.remove(key);
  }
}
