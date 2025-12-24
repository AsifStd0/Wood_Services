// lib/providers/buyer_signup_provider.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_auth_services.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_model.dart';

class BuyerSignupProvider extends ChangeNotifier {
  // Services
  final BuyerAuthService _authService = locator<BuyerAuthService>();

  // Form controllers (not needed if using provider directly)
  String _fullName = '';
  String _businessName = '';
  String _contactName = '';
  String _address = '';
  String _description = '';
  String _bankName = '';
  String _iban = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  // File handling
  File? _profileImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // State management
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  String get fullName => _fullName;
  String get businessName => _businessName;
  String get contactName => _contactName;
  String get address => _address;
  String get description => _description;
  String get bankName => _bankName;
  String get iban => _iban;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  File? get profileImage => _profileImage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Setters
  void setFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  void setBusinessName(String value) {
    _businessName = value;
    notifyListeners();
  }

  void setContactName(String value) {
    _contactName = value;
    notifyListeners();
  }

  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setBankName(String value) {
    _bankName = value;
    notifyListeners();
  }

  void setIban(String value) {
    _iban = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Image picking
  Future<void> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        _profileImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking image: $e';
      notifyListeners();
    }
  }

  void removeProfileImage() {
    _profileImage = null;
    notifyListeners();
  }

  // Validation
  String? validateForm() {
    if (_fullName.isEmpty) return 'Full name is required';
    if (_email.isEmpty) return 'Email is required';
    if (!_email.contains('@')) return 'Please enter a valid email';
    if (_password.isEmpty) return 'Password is required';
    if (_password.length < 6) return 'Password must be at least 6 characters';
    if (_confirmPassword.isEmpty) return 'Please confirm your password';
    if (_password != _confirmPassword) return 'Passwords do not match';

    // Optional: Add more validations as needed
    return null;
  }

  // Add this method to validate password confirmation
  String? validatePasswordConfirmation() {
    if (_password != _confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Update the registerBuyer method to handle API response properly
  Future<Map<String, dynamic>> registerBuyer() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Validate form
      final validationError = validateForm();
      if (validationError != null) {
        throw Exception(validationError);
      }

      // Validate password confirmation
      final passwordConfirmError = validatePasswordConfirmation();
      if (passwordConfirmError != null) {
        throw Exception(passwordConfirmError);
      }

      // ✅ Create buyer WITHOUT password in constructor
      final buyer = BuyerModel(
        fullName: _fullName,
        email: _email,
        businessName: _businessName.isNotEmpty ? _businessName : '',
        contactName: _contactName.isNotEmpty ? _contactName : '',
        address: _address.isNotEmpty ? _address : null,
        description: _description.isNotEmpty ? _description : null,
        bankName: _bankName.isNotEmpty ? _bankName : null,
        iban: _iban.isNotEmpty ? _iban : null,
        profileImagePath: _profileImage?.path,
        profileCompleted: true,
        isActive: true,
      );

      // Print data for debugging
      print('=== SENDING TO NODE.JS API ===');
      print('Full Name: $_fullName');
      print('Email: $_email');
      print(
        'Password: $_password',
      ); // Don't print actual password in production
      print('Business Name: $_businessName');
      print('Profile Image: ${_profileImage?.path}');

      // ✅ Call service with separate password parameter
      final result = await _authService.registerBuyer(
        buyer: buyer,
        // password: _password, // ✅ Pass password separately
        profileImage: _profileImage,
      );

      // Check API response
      if (result['success'] == true) {
        _successMessage = result['message'] ?? 'Registration successful!';
        _isLoading = false;
        notifyListeners();

        return {
          'success': true,
          'message': _successMessage,
          'buyer': result['buyer'],
          'token': result['token'],
        };
      } else {
        throw Exception(result['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      return {'success': false, 'message': _errorMessage};
    }
  }

  // Clear form
  void clearForm() {
    _fullName = '';
    _businessName = '';
    _contactName = '';
    _address = '';
    _description = '';
    _bankName = '';
    _iban = '';
    _email = '';
    _password = '';
    _confirmPassword = '';
    _profileImage = null;
    _errorMessage = null;
    _successMessage = null;
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    notifyListeners();
  }

  // Clear errors
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Debug method
  void printFormData() {
    print('=== BUYER REGISTRATION DATA ===');
    print('Full Name: $_fullName');
    print('Email: $_email');
    print('Business Name: $_businessName');
    print('Contact Name: $_contactName');
    print('Address: $_address');
    print('Description: $_description');
    print('Bank Name: $_bankName');
    print('IBAN: $_iban');
    print('Profile Image: ${_profileImage?.path}');
    print('==============================');
  }
}
