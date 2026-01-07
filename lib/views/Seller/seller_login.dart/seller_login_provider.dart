// providers/seller_auth_provider.dart
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/core/error/failure.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';

class SellerAuthProvider extends ChangeNotifier {
  final SellerAuthService _authService;

  // Auth State
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Login Form State
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  SellerAuthProvider(this._authService) {
    _initialize();
  }

  Future<void> _initialize() async {
    await checkAuthStatus();
  }

  // ========== AUTH STATE MANAGEMENT ==========
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      log(
        _isLoggedIn ? '✅ Seller is logged in' : '🔐 No active seller session',
      );
    } catch (e) {
      log('❌ Error checking auth status: $e');
      _isLoggedIn = false;
      _setError('Failed to check auth status');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _isLoggedIn = false;
      _setSuccess('Logged out successfully');
      log('🚪 Seller logged out');
    } catch (e) {
      log('❌ Error during logout: $e');
      _setError('Failed to logout');
    } finally {
      _setLoading(false);
    }
  }

  // ========== LOGIN FORM MANAGEMENT ==========
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value.trim()) ? null : 'Enter a valid email';
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return value.length >= 6 ? null : 'Minimum 6 characters required';
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ========== AUTH OPERATIONS ==========
  Future<Either<Failure, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    clearMessages();
    log('🔐 Attempting login for: $email');

    try {
      final result = await _authService.login(
        email: email.trim(),
        password: password,
      );

      _handleLoginResult(result);
      return result;
    } catch (e) {
      log('❌ Login error: $e');
      _setError('Login failed: $e');
      return Left(UnknownFailure('Unexpected error: $e'));
    } finally {
      _setLoading(false);
    }
  }

  void _handleLoginResult(Either<Failure, dynamic> result) {
    result.fold(
      (failure) {
        log('❌ Login failed: ${failure.message}');
        _setError(_getUserFriendlyError(failure));
      },
      (authData) {
        log('✅ Login successful');
        _isLoggedIn = true;
        _setSuccess('Login successful!');
      },
    );
  }

  // ✅ FIX 1: Add this method for checking existing login
  Future<bool> checkExistingLogin() async {
    try {
      return await _authService.isLoggedIn();
    } catch (e) {
      log('❌ Error checking existing login: $e');
      return false;
    }
  }

  String _getUserFriendlyError(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure:
        return 'Invalid email or password';
      case NetworkFailure:
        return 'Network error. Please check your connection';
      case ValidationFailure:
        return 'Please check your input and try again';
      default:
        return 'Something went wrong. Please try again';
    }
  }

  // ========== PRIVATE HELPERS ==========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }
}

// // view_models/seller_login_viewmodel.dart
// import 'dart:async';
// import 'dart:developer';
// import 'package:dartz/dartz.dart';
// import 'package:flutter/material.dart';
// import 'package:wood_service/core/error/failure.dart';
// import 'package:wood_service/views/Seller/data/services/seller_auth.dart';

// class SellerLoginViewModel extends ChangeNotifier {
//   final SellerAuthService _sellerAuthService;

//   SellerLoginViewModel({required SellerAuthService sellerAuthService})
//     : _sellerAuthService = sellerAuthService {
//     log('🔄 SellerLoginViewModel initialized');
//   }

//   // State variables
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   String? _errorMessage;
//   String? _successMessage;

//   // Getters
//   bool get isLoading => _isLoading;
//   bool get obscurePassword => _obscurePassword;
//   String? get errorMessage => _errorMessage;
//   String? get successMessage => _successMessage;

//   // Setters
//   void setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   void setObscurePassword(bool value) {
//     _obscurePassword = value;
//     notifyListeners();
//   }

//   void setError(String? message) {
//     _errorMessage = message;
//     _successMessage = null;
//     notifyListeners();
//   }

//   void setSuccess(String? message) {
//     _successMessage = message;
//     _errorMessage = null;
//     notifyListeners();
//   }

//   void clearMessages() {
//     _errorMessage = null;
//     _successMessage = null;
//     notifyListeners();
//   }

//   // Validation
//   String? validateEmail(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter your email';
//     }
//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     if (!emailRegex.hasMatch(value.trim())) {
//       return 'Enter a valid email address';
//     }
//     return null;
//   }

//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter password';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }

//   // Login method
//   login({required String email, required String password}) async {
//     setLoading(true);
//     clearMessages();
//     log('🔐 Attempting login for: $email');

//     try {
//       final result = await _sellerAuthService.login(
//         email: email.trim(),
//         password: password,
//       );

//       setLoading(false);
//       return result;
//     } catch (e) {
//       setLoading(false);
//       setError('Login failed: $e');
//       log('❌ Login error in ViewModel: $e');
//       return Left(UnknownFailure('Unexpected error: $e'));
//     }
//   }

//   // Check if seller is already logged in
//   Future<bool> checkExistingLogin() async {
//     try {
//       return await _sellerAuthService.isLoggedIn();
//     } catch (e) {
//       log('❌ Error checking login status: $e');
//       return false;
//     }
//   }
// }
