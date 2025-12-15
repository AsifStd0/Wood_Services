// // services/seller_storage_service.dart
// import 'dart:convert';

// import 'package:wood_service/core/services/local_storage_service.dart';
// import 'package:wood_service/views/Seller/data/models/seller_signup_model.dart';

// class SellerStorageService {
//   final LocalStorageService _storage;
  
//   static const String _tokenKey = 'seller_auth_token';
//   static const String _dataKey = 'seller_auth_data';
//   static const String _loginStatusKey = 'seller_is_logged_in';
  
//   SellerStorageService(this._storage);
  
//   Future<void> saveAuthData(String token, SellerModel seller) async {
//     await Future.wait([
//       _storage.saveString(_tokenKey, token),
//       _storage.saveString(_dataKey, jsonEncode(seller.toJson())),
//       _storage.saveBool(_loginStatusKey, true),
//     ]);
//   }
  
//   Future<String?> getToken() => _storage.getString(_tokenKey);
  
//   Future<SellerModel?> getSeller() async {
//     final jsonString = await _storage.getString(_dataKey);
//     return jsonString != null 
//         ? SellerModel.fromLocalStorage(jsonDecode(jsonString))
//         : null;
//   }
  
//   Future<bool> isLoggedIn() async {
//     final token = await getToken();
//     final status = await _storage.getBool(_loginStatusKey);
//     return token != null && token.isNotEmpty && (status ?? false);
//   }
  
//   Future<void> clear() async {
//     await Future.wait([
//       _storage.remove(_tokenKey),
//       _storage.remove(_dataKey),
//       _storage.remove(_loginStatusKey),
//     ]);
//   }
// }