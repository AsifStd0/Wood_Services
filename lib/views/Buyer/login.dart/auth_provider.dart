// lib/providers/buyer_auth_provider.dart
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_auth_services.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_model.dart';

class BuyerAuthProvider extends ChangeNotifier {
  final BuyerAuthService _authService = locator<BuyerAuthService>();

  // Login state
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  BuyerModel? _currentBuyer;

  // Getters
  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BuyerModel? get currentBuyer => _currentBuyer;

  // Setters
  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Login
  Future<Map<String, dynamic>> login() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    log('done');
    try {
      // Validate
      if (_email.isEmpty || _password.isEmpty) {
        throw Exception('Please enter email and password');
      }

      if (!_email.contains('@')) {
        throw Exception('Please enter a valid email');
      }

      // Call service
      final result = await _authService.loginBuyer(
        email: _email,
        password: _password,
      );

      if (result['success'] == true) {
        _currentBuyer = result['buyer'];
        _isLoading = false;
        notifyListeners();

        return {
          'success': true,
          'message': result['message'],
          'buyer': _currentBuyer,
          'token': result['token'],
        };
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      return {'success': false, 'message': _errorMessage};
    }
  }

  // // Check login status
  // Future<bool> checkLoginStatus() async {
  //   final isLoggedIn = await _authService.isBuyerLoggedIn();
  //   if (isLoggedIn) {
  //     final buyer = await _authService.getCurrentBuyerData();
  //     _currentBuyer = buyer;
  //     notifyListeners();
  //   }
  //   return isLoggedIn;
  // }

  // Get profile
  Future<void> getProfile() async {
    final result = await _authService.getBuyerProfile();
    if (result['success'] == true) {
      _currentBuyer = result['buyer'];
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentBuyer = null;
    _email = '';
    _password = '';
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
