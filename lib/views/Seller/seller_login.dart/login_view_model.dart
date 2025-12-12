// view_models/seller_login_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/core/error/failure.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';

class SellerLoginViewModel extends ChangeNotifier {
  final SellerAuthService _sellerAuthService;

  SellerLoginViewModel({required SellerAuthService sellerAuthService})
    : _sellerAuthService = sellerAuthService {
    log('🔄 SellerLoginViewModel initialized');
  }

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Setters
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setObscurePassword(bool value) {
    _obscurePassword = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Validation
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Login method
  Future<Either<Failure, SellerAuthResponse>> login({
    required String email,
    required String password,
  }) async {
    setLoading(true);
    clearMessages();
    log('🔐 Attempting login for: $email');

    try {
      final result = await _sellerAuthService.loginSeller(
        email: email.trim(),
        password: password,
      );

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError('Login failed: $e');
      log('❌ Login error in ViewModel: $e');
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  // Check if seller is already logged in
  Future<bool> checkExistingLogin() async {
    try {
      return await _sellerAuthService.isSellerLoggedIn();
    } catch (e) {
      log('❌ Error checking login status: $e');
      return false;
    }
  }
}
