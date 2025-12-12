// core/services/seller_auth_check_service.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/seller_storage_service.dart';

class SellerAuthCheckService extends ChangeNotifier {
  // SellerDataService? _sellerDataService;
  // bool _isChecking = false;
  // bool _isAuthenticated = false;
  // Map<String, dynamic>? _authState;

  // bool get isChecking => _isChecking;
  // bool get isAuthenticated => _isAuthenticated;
  // Map<String, dynamic>? get authState => _authState;

  // Future<void> initialize() async {
  //   _sellerDataService = locator.get<SellerDataService>();
  // }

  // Future<bool> checkAuthStatus() async {
  //   _isChecking = true;
  //   notifyListeners();

  //   try {
  //     if (_sellerDataService == null) {
  //       await initialize();
  //     }

  //     _isAuthenticated = await _sellerDataService!.isSellerLoggedIn();
  //     _authState = await _sellerDataService!.getAuthState();

  //     print('🔐 Auth Status Check Complete:');
  //     print('   Authenticated: $_isAuthenticated');
  //     print('   Auth State: $_authState');

  //     return _isAuthenticated;
  //   } catch (e) {
  //     print('❌ Error checking auth: $e');
  //     _isAuthenticated = false;
  //     return false;
  //   } finally {
  //     _isChecking = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> logout() async {
  //   if (_sellerDataService != null) {
  //     await _sellerDataService!.logout();
  //     _isAuthenticated = false;
  //     _authState = null;
  //     notifyListeners();
  //   }
  // }
}
