import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);
  Future<void> delete(String key);
  Future<void> clearAll();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

class LocalStorageServiceImpl implements LocalStorageService {
  static const String _tokenKey = 'auth_token';

  // Singleton pattern
  static LocalStorageServiceImpl? _instance;

  // Factory constructor
  factory LocalStorageServiceImpl() {
    return _instance ??= LocalStorageServiceImpl._internal();
  }

  // Internal constructor
  LocalStorageServiceImpl._internal();

  // Static getInstance method
  static Future<LocalStorageServiceImpl> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageServiceImpl._internal();
      // Initialize SharedPreferences
      await _instance!._init();
    }
    return _instance!;
  }

  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _sharedPrefs async {
    if (_prefs == null) {
      await _init();
    }
    return _prefs!;
  }

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
    final prefs = await _sharedPrefs;
    await prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getBool(key);
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    final prefs = await _sharedPrefs;
    await prefs.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getStringList(key);
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await _sharedPrefs;
    await prefs.remove(key);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _sharedPrefs;
    await prefs.clear();
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
}
