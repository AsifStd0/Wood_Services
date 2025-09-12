import 'dart:io';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      // Remove any non-digit characters
      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 10) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value != null && value.isNotEmpty && value.length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? confirmPassword,
    String? originalPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateProfileImage(File? image) {
    if (image == null) {
      return 'Profile image is required';
    }
    // Check file size (max 5MB)
    if (image.lengthSync() > 5 * 1024 * 1024) {
      return 'Image must be less than 5MB';
    }
    return null;
  }
}
