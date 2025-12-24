// // lib/core/services/buyer_local_storage_service.dart
// import 'dart:convert';
// import 'dart:developer';

// import 'package:shared_preferences/shared_preferences.dart';

// abstract class BuyerLocalStorageService {
//   // Core methods
//   Future<void> saveString(String key, String value);
//   Future<String?> getString(String key);
//   Future<void> saveBool(String key, bool value);
//   Future<bool?> getBool(String key);
//   Future<void> saveInt(String key, int value);
//   Future<int?> getInt(String key);
//   Future<void> saveDouble(String key, double value);
//   Future<double?> getDouble(String key);
//   Future<void> saveStringList(String key, List<String> value);
//   Future<List<String>?> getStringList(String key);
//   Future<void> delete(String key);
//   Future<void> clearAll();

//   // Buyer-specific methods
//   Future<void> saveBuyerToken(String token);
//   Future<String?> getBuyerToken();
//   Future<void> deleteBuyerToken();

//   Future<void> saveBuyerData(Map<String, dynamic> buyerData);
//   Future<Map<String, dynamic>?> getBuyerData();
//   Future<void> deleteBuyerData();

//   Future<void> saveBuyerLoginStatus(bool isLoggedIn);
//   Future<bool?> getBuyerLoginStatus();
//   Future<void> deleteBuyerLoginStatus();

//   // Cart and buyer preferences
//   Future<void> saveCartItems(List<Map<String, dynamic>> cartItems);
//   Future<List<Map<String, dynamic>>?> getCartItems();
//   Future<void> clearCart();

//   Future<void> saveBuyerPreferences(Map<String, dynamic> preferences);
//   Future<Map<String, dynamic>?> getBuyerPreferences();

//   // Additional buyer methods
//   Future<void> saveBuyerLanguage(String languageCode);
//   Future<String?> getBuyerLanguage();

//   Future<void> saveBuyerCurrency(String currencyCode);
//   Future<String?> getBuyerCurrency();

//   Future<void> saveBuyerNotificationsEnabled(bool enabled);
//   Future<bool?> getBuyerNotificationsEnabled();

//   Future<void> saveBuyerLastLogin();
//   Future<String?> getBuyerLastLogin();

//   // Complete buyer logout (clears all buyer data)
//   Future<void> buyerLogout();

//   // Check if buyer is logged in
//   Future<bool> isBuyerLoggedIn();

//   // Get complete buyer profile
//   Future<Map<String, dynamic>?> getBuyerProfile();

//   // Helper methods
//   Future<bool> containsKey(String key);
//   Future<Set<String>> getAllKeys();
//   Future<Map<String, dynamic>> getAllData();
// }

// class BuyerLocalStorageServiceImpl implements BuyerLocalStorageService {
//   // Buyer-specific keys
//   static const String _buyerTokenKey = 'buyer_auth_token';
//   static const String _buyerDataKey = 'buyer_data';
//   static const String _buyerLoginStatusKey = 'buyer_login_status';
//   static const String _buyerCartKey = 'buyer_cart_items';
//   static const String _buyerPreferencesKey = 'buyer_preferences';
//   static const String _buyerLastLoginKey = 'buyer_last_login';
//   static const String _buyerNotificationsKey = 'buyer_notifications_enabled';
//   static const String _buyerLanguageKey = 'buyer_language';
//   static const String _buyerCurrencyKey = 'buyer_currency';

//   static BuyerLocalStorageServiceImpl? _instance;
//   SharedPreferences? _prefs;

//   // Private constructor
//   BuyerLocalStorageServiceImpl._internal();

//   // Factory constructor
//   factory BuyerLocalStorageServiceImpl() {
//     return _instance ??= BuyerLocalStorageServiceImpl._internal();
//   }

//   // Get instance with initialization
//   static Future<BuyerLocalStorageServiceImpl> getInstance() async {
//     final instance = BuyerLocalStorageServiceImpl();
//     await instance.initialize();
//     return instance;
//   }

//   // Initialize method
//   Future<void> initialize() async {
//     if (_prefs == null) {
//       _prefs = await SharedPreferences.getInstance();
//       log('📱 BuyerLocalStorage initialized');
//     }
//   }

//   // Ensure SharedPreferences is initialized
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
//     try {
//       await initialize();
//       await _prefs!.setBool(key, value);
//     } catch (e) {
//       throw Exception('Failed to save bool: $e');
//     }
//   }

//   @override
//   Future<bool?> getBool(String key) async {
//     try {
//       await initialize();
//       return _prefs!.getBool(key);
//     } catch (e) {
//       log('Error getting bool for key $key: $e');
//       return null;
//     }
//   }

//   @override
//   Future<void> saveInt(String key, int value) async {
//     final prefs = await _sharedPrefs;
//     await prefs.setInt(key, value);
//   }

//   @override
//   Future<int?> getInt(String key) async {
//     final prefs = await _sharedPrefs;
//     return prefs.getInt(key);
//   }

//   @override
//   Future<void> saveDouble(String key, double value) async {
//     final prefs = await _sharedPrefs;
//     await prefs.setDouble(key, value);
//   }

//   @override
//   Future<double?> getDouble(String key) async {
//     final prefs = await _sharedPrefs;
//     return prefs.getDouble(key);
//   }

//   @override
//   Future<void> saveStringList(String key, List<String> value) async {
//     try {
//       await initialize();
//       await _prefs!.setStringList(key, value);
//     } catch (e) {
//       throw Exception('Failed to save string list: $e');
//     }
//   }

//   @override
//   Future<List<String>?> getStringList(String key) async {
//     try {
//       await initialize();
//       return _prefs!.getStringList(key);
//     } catch (e) {
//       log('Error getting string list for key $key: $e');
//       return null;
//     }
//   }

//   @override
//   Future<void> delete(String key) async {
//     try {
//       await initialize();
//       await _prefs!.remove(key);
//     } catch (e) {
//       throw Exception('Failed to delete key $key: $e');
//     }
//   }

//   @override
//   Future<void> clearAll() async {
//     try {
//       await initialize();
//       await _prefs!.clear();
//     } catch (e) {
//       throw Exception('Failed to clear storage: $e');
//     }
//   }

//   // ========== BUYER-SPECIFIC METHODS ==========

//   @override
//   Future<void> saveBuyerToken(String token) async {
//     await saveString(_buyerTokenKey, token);
//     log('🔐 Buyer token saved');
//   }

//   @override
//   Future<String?> getBuyerToken() async {
//     final token = await getString(_buyerTokenKey);
//     if (token != null && token.isNotEmpty) {
//       log('🔐 Buyer token retrieved: ${token.substring}...');
//     }
//     return token;
//   }

//   @override
//   Future<void> deleteBuyerToken() async {
//     await delete(_buyerTokenKey);
//     log('🔐 Buyer token deleted');
//   }

//   @override
//   Future<void> saveBuyerData(Map<String, dynamic> buyerData) async {
//     await saveString(_buyerDataKey, jsonEncode(buyerData));
//     log('📝 Buyer data saved: ${buyerData['fullName'] ?? 'Unknown'}');
//   }

//   @override
//   Future<Map<String, dynamic>?> getBuyerData() async {
//     final buyerJson = await getString(_buyerDataKey);
//     if (buyerJson != null && buyerJson.isNotEmpty) {
//       try {
//         return jsonDecode(buyerJson);
//       } catch (e) {
//         log('Error decoding buyer data: $e');
//         return null;
//       }
//     }
//     return null;
//   }

//   @override
//   Future<void> deleteBuyerData() async {
//     await delete(_buyerDataKey);
//     log('📝 Buyer data deleted');
//   }

//   @override
//   Future<void> saveBuyerLoginStatus(bool isLoggedIn) async {
//     await saveBool(_buyerLoginStatusKey, isLoggedIn);
//     log('🔐 Buyer login status saved: $isLoggedIn');
//   }

//   @override
//   Future<bool?> getBuyerLoginStatus() async {
//     return await getBool(_buyerLoginStatusKey);
//   }

//   @override
//   Future<void> deleteBuyerLoginStatus() async {
//     await delete(_buyerLoginStatusKey);
//     log('🔐 Buyer login status deleted');
//   }

//   // ========== CART MANAGEMENT ==========

//   @override
//   Future<void> saveCartItems(List<Map<String, dynamic>> cartItems) async {
//     final cartJson = jsonEncode(cartItems);
//     await saveString(_buyerCartKey, cartJson);
//     log('🛒 Cart items saved: ${cartItems.length} items');
//   }

//   @override
//   Future<List<Map<String, dynamic>>?> getCartItems() async {
//     final cartJson = await getString(_buyerCartKey);
//     if (cartJson != null && cartJson.isNotEmpty) {
//       try {
//         final List<dynamic> cartList = jsonDecode(cartJson);
//         return cartList.map((item) => Map<String, dynamic>.from(item)).toList();
//       } catch (e) {
//         log('Error decoding cart items: $e');
//         return null;
//       }
//     }
//     return null;
//   }

//   @override
//   Future<void> clearCart() async {
//     await delete(_buyerCartKey);
//     log('🛒 Cart cleared');
//   }

//   // ========== BUYER PREFERENCES ==========

//   @override
//   Future<void> saveBuyerPreferences(Map<String, dynamic> preferences) async {
//     await saveString(_buyerPreferencesKey, jsonEncode(preferences));
//     log('⚙️ Buyer preferences saved');
//   }

//   @override
//   Future<Map<String, dynamic>?> getBuyerPreferences() async {
//     final prefsJson = await getString(_buyerPreferencesKey);
//     if (prefsJson != null && prefsJson.isNotEmpty) {
//       try {
//         return jsonDecode(prefsJson);
//       } catch (e) {
//         log('Error decoding buyer preferences: $e');
//         return null;
//       }
//     }
//     return null;
//   }

//   // ========== HELPER METHODS ==========

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

//   @override
//   Future<Map<String, dynamic>> getAllData() async {
//     await initialize();
//     final keys = _prefs!.getKeys();
//     final data = <String, dynamic>{};

//     for (final key in keys) {
//       final value = _prefs!.get(key);
//       data[key] = value;
//     }

//     return data;
//   }

//   // ========== ADDITIONAL BUYER METHODS ==========

//   @override
//   Future<void> saveBuyerLanguage(String languageCode) async {
//     await saveString(_buyerLanguageKey, languageCode);
//     log('🌐 Buyer language saved: $languageCode');
//   }

//   @override
//   Future<String?> getBuyerLanguage() async {
//     return await getString(_buyerLanguageKey);
//   }

//   @override
//   Future<void> saveBuyerCurrency(String currencyCode) async {
//     await saveString(_buyerCurrencyKey, currencyCode);
//     log('💰 Buyer currency saved: $currencyCode');
//   }

//   @override
//   Future<String?> getBuyerCurrency() async {
//     return await getString(_buyerCurrencyKey);
//   }

//   @override
//   Future<void> saveBuyerNotificationsEnabled(bool enabled) async {
//     await saveBool(_buyerNotificationsKey, enabled);
//     log('🔔 Buyer notifications: $enabled');
//   }

//   @override
//   Future<bool?> getBuyerNotificationsEnabled() async {
//     return await getBool(_buyerNotificationsKey);
//   }

//   @override
//   Future<void> saveBuyerLastLogin() async {
//     final now = DateTime.now().toIso8601String();
//     await saveString(_buyerLastLoginKey, now);
//     log('⏰ Buyer last login saved: $now');
//   }

//   @override
//   Future<String?> getBuyerLastLogin() async {
//     return await getString(_buyerLastLoginKey);
//   }

//   // ========== BUYER AUTH MANAGEMENT ==========

//   @override
//   Future<void> buyerLogout() async {
//     log('🚪 Performing buyer logout...');

//     await deleteBuyerToken();
//     await deleteBuyerData();
//     await deleteBuyerLoginStatus();

//     // Optional: Clear cart on logout
//     // await clearCart();

//     log('✅ Buyer logout completed');
//   }

//   @override
//   Future<bool> isBuyerLoggedIn() async {
//     final token = await getBuyerToken();
//     final loginStatus = await getBuyerLoginStatus();

//     return token != null && token.isNotEmpty && (loginStatus == true);
//   }

//   @override
//   Future<Map<String, dynamic>?> getBuyerProfile() async {
//     final buyerData = await getBuyerData();
//     if (buyerData != null) {
//       final token = await getBuyerToken();
//       final preferences = await getBuyerPreferences();

//       return {
//         ...buyerData,
//         'token': token,
//         'preferences': preferences,
//         'lastLogin': await getBuyerLastLogin(),
//         'language': await getBuyerLanguage(),
//         'currency': await getBuyerCurrency(),
//         'notifications': await getBuyerNotificationsEnabled(),
//       };
//     }
//     return null;
//   }
// }
