// core/services/seller_local_storage_service_impl.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'seller_local_storage_service.dart';

class SellerLocalStorageServiceImpl implements SellerLocalStorageService {
  // Seller-specific keys
  static const String _sellerTokenKey = 'seller_auth_token';
  static const String _sellerDataKey = 'seller_auth_data';
  static const String _sellerLoginStatusKey = 'seller_is_logged_in';

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  final Completer<void> _initializationCompleter = Completer<void>();

  // ========== INITIALIZATION ==========
  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      _initializationCompleter.complete();
      log('📱 Seller Storage initialized');
    }
    return _initializationCompleter.future;
  }

  // Ensure storage is always initialized before use
  Future<SharedPreferences> get _sharedPrefs async {
    if (!_isInitialized) {
      await initialize();
    }
    return _prefs;
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
    final prefs = await _sharedPrefs;
    await prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getBool(key);
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
    log('🧹 Cleared ALL Seller storage');
  }

  @override
  Future<bool> containsKey(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.containsKey(key);
  }

  @override
  Future<Set<String>> getAllKeys() async {
    final prefs = await _sharedPrefs;
    return prefs.getKeys();
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

  @override
  Future<void> saveSellerData(Map<String, dynamic> sellerData) async {
    log('💾 Seller: Saving data');
    final sellerJson = jsonEncode(sellerData);
    await saveString(_sellerDataKey, sellerJson);
  }

  @override
  Future<Map<String, dynamic>?> getSellerData() async {
    final data = await getString(_sellerDataKey);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      log('❌ Error parsing seller data: $e');
      return null;
    }
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

    final prefs = await _sharedPrefs;
    await Future.wait([
      if (prefs.containsKey(_sellerTokenKey)) delete(_sellerTokenKey),
      if (prefs.containsKey(_sellerDataKey)) delete(_sellerDataKey),
      if (prefs.containsKey(_sellerLoginStatusKey))
        delete(_sellerLoginStatusKey),
    ]);

    log('✅ Seller auth data deleted');
  }

  @override
  Future<bool> isSellerLoggedIn() async {
    final token = await getSellerToken();
    final data = await getSellerData();
    final status = await getSellerLoginStatus();

    // Check all possible indicators
    final bool isLoggedIn =
        token != null &&
        token.isNotEmpty &&
        data != null &&
        data.isNotEmpty &&
        (status ?? false);

    log('🔐 Seller logged in check: $isLoggedIn');
    return isLoggedIn;
  }

  @override
  Future<void> sellerLogout() async {
    await deleteSellerAuth();
  }
}
// class SellerLocalStorageServiceImpl implements SellerLocalStorageService {
//   // Seller-specific keys
//   static const String _sellerTokenKey = 'seller_auth_token';
//   static const String _sellerDataKey = 'seller_auth_data';
//   static const String _sellerLoginStatusKey = 'seller_is_logged_in';

//   SharedPreferences? _prefs;

//   // ========== INITIALIZATION ==========
//   @override
//   Future<void> initialize() async {
//     if (_prefs == null) {
//       _prefs = await SharedPreferences.getInstance();
//       log('📱 Seller Storage initialized');
//     }
//   }

//   Future<SharedPreferences> get _sharedPrefs async {
//     await initialize();
//     return _prefs!;
//   }

//   // ========== CORE METHODS ==========
//   @override
//   Future<void> saveString(String key, String value) async {
//     final prefs = await _sharedPrefs;
//     await prefs.setString(key, value);
//   }

//   @override
//   Future<String?> getString(String key) async {
//     final prefs = await _sharedPrefs;
//     return prefs.getString(key);
//   }

//   @override
//   Future<void> saveBool(String key, bool value) async {
//     await initialize();
//     await _prefs!.setBool(key, value);
//   }

//   @override
//   Future<bool?> getBool(String key) async {
//     await initialize();
//     return _prefs!.getBool(key);
//   }

//   @override
//   Future<void> delete(String key) async {
//     await initialize();
//     await _prefs!.remove(key);
//   }

//   @override
//   Future<void> clearAll() async {
//     await initialize();
//     await _prefs!.clear();
//     log('🧹 Cleared ALL Seller storage');
//   }

//   @override
//   Future<bool> containsKey(String key) async {
//     await initialize();
//     return _prefs!.containsKey(key);
//   }

//   @override
//   Future<Set<String>> getAllKeys() async {
//     await initialize();
//     return _prefs!.getKeys();
//   }

//   // ========== SELLER-SPECIFIC METHODS ==========
//   @override
//   Future<void> saveSellerToken(String token) async {
//     log('💾 Seller: Saving token');
//     await saveString(_sellerTokenKey, token);
//   }

//   @override
//   Future<String?> getSellerToken() async {
//     final token = await getString(_sellerTokenKey);
//     log('🔍 Seller token: ${token != null ? "EXISTS" : "NULL"}');
//     return token;
//   }

//   // ✅ UPDATED: Save Map<String, dynamic> instead of String
//   @override
//   Future<void> saveSellerData(Map<String, dynamic> sellerData) async {
//     log('💾 Seller: Saving data');
//     final sellerJson = jsonEncode(sellerData);
//     await saveString(_sellerDataKey, sellerJson);
//   }

//   // ✅ UPDATED: Return Map<String, dynamic> instead of String
//   @override
//   Future<Map<String, dynamic>?> getSellerData() async {
//     final data = await getString(_sellerDataKey);
//     if (data == null) return null;
//     return jsonDecode(data) as Map<String, dynamic>;
//   }

//   @override
//   Future<void> saveSellerLoginStatus(bool isLoggedIn) async {
//     log('💾 Seller: Login status: $isLoggedIn');
//     await saveBool(_sellerLoginStatusKey, isLoggedIn);
//   }

//   @override
//   Future<bool?> getSellerLoginStatus() async {
//     final status = await getBool(_sellerLoginStatusKey);
//     log('🔍 Seller login status: $status');
//     return status;
//   }

//   @override
//   Future<void> deleteSellerAuth() async {
//     log('🗑️ Seller: Deleting auth data');
//     await delete(_sellerTokenKey);
//     await delete(_sellerDataKey);
//     await delete(_sellerLoginStatusKey);
//     log('✅ Seller auth data deleted');
//   }

//   // ✅ ADD these missing methods if needed:
//   @override
//   Future<bool> isSellerLoggedIn() async {
//     final token = await getSellerToken();
//     final data = await getSellerData();
//     return token != null && token.isNotEmpty && data != null;
//   }

//   @override
//   Future<void> sellerLogout() async {
//     await deleteSellerAuth();
//   }
// }
