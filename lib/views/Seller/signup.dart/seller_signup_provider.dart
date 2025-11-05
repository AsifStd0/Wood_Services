// view_models/seller_signup_viewmodel.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/views/Seller/signup.dart/eller_signup_service.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_model.dart';

class SellerSignupViewModel extends ChangeNotifier {
  final SellerSignupService _service;

  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();

  // State variables
  String _countryCode = '+1';
  File? _shopLogo;
  File? _shopBanner;
  List<String> _categories = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  SellerSignupViewModel({SellerSignupService? service})
    : _service = service ?? SellerSignupService();

  // Getters
  String get countryCode => _countryCode;
  File? get shopLogo => _shopLogo;
  File? get shopBanner => _shopBanner;
  List<String> get categories => _categories;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters with notifyListeners
  set countryCode(String value) {
    _countryCode = value;
    notifyListeners();
  }

  set shopLogo(File? value) {
    _shopLogo = value;
    notifyListeners();
  }

  set shopBanner(File? value) {
    _shopBanner = value;
    notifyListeners();
  }

  void setObscurePassword(bool value) {
    _obscurePassword = value;
    notifyListeners();
  }

  void setObscureConfirmPassword(bool value) {
    _obscureConfirmPassword = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Business logic methods
  void addCategory(String category) {
    if (category.isNotEmpty && !_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  void removeCategory(String category) {
    _categories.remove(category);
    notifyListeners();
  }

  void clearCategories() {
    _categories.clear();
    notifyListeners();
  }

  Future<void> pickShopLogo() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        shopLogo = File(image.path);
      }
    } catch (e) {
      setError('Error picking shop logo: $e');
    }
  }

  Future<void> pickShopBanner() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image != null) {
        shopBanner = File(image.path);
      }
    } catch (e) {
      setError('Error picking shop banner: $e');
    }
  }

  bool validateForm() {
    if (passwordController.text != confirmPasswordController.text) {
      setError('Passwords do not match');
      return false;
    }

    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        businessNameController.text.isEmpty ||
        shopNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        addressController.text.isEmpty ||
        bankNameController.text.isEmpty ||
        accountNumberController.text.isEmpty) {
      setError('Please fill all required fields');
      return false;
    }

    setError(null);
    return true;
  }

  SellerModel _collectFormData() {
    final completePhoneNumber = '$_countryCode${phoneController.text}';

    return SellerModel(
      personalInfo: PersonalInfo(
        fullName: fullNameController.text,
        email: emailController.text,
        phone: completePhoneNumber,
        countryCode: _countryCode,
        password: passwordController.text,
      ),
      businessInfo: BusinessInfo(
        businessName: businessNameController.text,
        shopName: shopNameController.text,
        description: descriptionController.text,
        address: addressController.text,
        categories: _categories,
      ),
      bankDetails: BankDetails(
        bankName: bankNameController.text,
        accountNumber: accountNumberController.text,
        iban: ibanController.text,
      ),
      shopBranding: ShopBranding(shopLogo: _shopLogo, shopBanner: _shopBanner),
    );
  }

  Future<bool> submitApplication() async {
    if (!validateForm()) {
      return false;
    }

    setLoading(true);
    try {
      final sellerData = _collectFormData();
      final success = await _service.registerSeller(sellerData);

      if (success) {
        setError(null);
        return true;
      } else {
        setError('Registration failed. Please try again.');
        return false;
      }
    } catch (e) {
      setError('An error occurred: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  void clearForm() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    businessNameController.clear();
    shopNameController.clear();
    descriptionController.clear();
    addressController.clear();
    bankNameController.clear();
    ibanController.clear();
    accountNumberController.clear();

    _countryCode = '+1';
    _shopLogo = null;
    _shopBanner = null;
    _categories.clear();
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    _errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    shopNameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    bankNameController.dispose();
    ibanController.dispose();
    accountNumberController.dispose();
    super.dispose();
  }
}
