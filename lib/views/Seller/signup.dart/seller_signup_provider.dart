// view_models/seller_signup_viewmodel.dart
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/core/error/failure.dart';
import 'package:wood_service/views/Seller/data/models/seller_signup_model.dart'; // Your model
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';

class SellerSignupViewModel extends ChangeNotifier {
  final SellerAuthService _sellerAuthService;

  SellerSignupViewModel({required SellerAuthService sellerAuthService})
    : _sellerAuthService = sellerAuthService {
    log('🔄 SellerSignupViewModel initialized with correct dependencies');
  }

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
  final List<String> _categories = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Document files
  File? _businessLicense;
  File? _taxCertificate;
  File? _identityProof;

  // Map storage - KEEP THIS TOO
  final Map<String, File?> _documents = {
    'businessLicense': null,
    'taxCertificate': null,
    'identityProof': null,
  };

  // Getters
  File? get businessLicense => _businessLicense;
  File? get taxCertificate => _taxCertificate;
  File? get identityProof => _identityProof;
  String get countryCode => _countryCode;
  File? get shopLogo => _shopLogo;
  File? get shopBanner => _shopBanner;
  List<String> get categories => _categories;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // ! ********

  set businessLicense(File? value) {
    _businessLicense = value;
    notifyListeners();
  }

  set taxCertificate(File? value) {
    _taxCertificate = value;
    notifyListeners();
  }

  set identityProof(File? value) {
    _identityProof = value;
    notifyListeners();
  }

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
        log('📸 Shop logo selected: ${image.path}');
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
        log('📸 Shop banner selected: ${image.path}');
      }
    } catch (e) {
      setError('Error picking shop banner: $e');
    }
  }

  submitApplication() async {
    if (!validateForm()) {
      return Left(ValidationFailure(_errorMessage ?? 'Form validation failed'));
    }

    setLoading(true);
    log('🚀 Starting registration process...');

    try {
      final sellerData = _collectFormData();
      log('   👤 Name: ${sellerData.toString()}');

      final result = await _sellerAuthService.register(seller: sellerData);

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError('An error occurred: $e');
      log('❌ Registration error in ViewModel: $e');
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  Map<String, File?> get documents => _documents;

  // Update pickDocument to sync BOTH systems
  Future<void> pickDocument(String documentType) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);

        // Update Map
        _documents[documentType] = file;

        // Update individual properties
        switch (documentType) {
          case 'businessLicense':
            _businessLicense = file;
            break;
          case 'taxCertificate':
            _taxCertificate = file;
            break;
          case 'identityProof':
            _identityProof = file;
            break;
        }

        notifyListeners();
        log('📄 $documentType selected: ${image.path}');

        log(
          '🔄 DEBUG - After picking $documentType:   Map value: ${_documents[documentType]?.path}',
        );
        log('  Property value: ${_getPropertyForDocument(documentType)?.path}');
      }
    } catch (e) {
      setError('Error picking $documentType: $e');
    }
  }

  // Helper to get property for debug
  File? _getPropertyForDocument(String documentType) {
    switch (documentType) {
      case 'businessLicense':
        return _businessLicense;
      case 'taxCertificate':
        return _taxCertificate;
      case 'identityProof':
        return _identityProof;
      default:
        return null;
    }
  }

  // Update _collectFormData to add debug logs
  SellerModel _collectFormData() {
    final completePhoneNumber = '$_countryCode${phoneController.text}';
    final seller = SellerModel(
      id: '',
      personalInfo: PersonalInfo(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: completePhoneNumber.trim(),
        countryCode: _countryCode,
        password: passwordController.text,
      ),
      businessInfo: BusinessInfo(
        businessName: businessNameController.text.trim(),
        shopName: shopNameController.text.trim(),
        description: descriptionController.text.trim(),
        address: addressController.text.trim(),
        categories: _categories,
      ),
      bankDetails: BankDetails(
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        iban: ibanController.text.trim(),
      ),
      shopBrandingImages: ShopBrandingImages(
        shopLogo: _shopLogo,
        shopBanner: _shopBanner,
      ),
      documentsImage: SellerDocuments(
        businessLicense: _businessLicense ?? _documents['businessLicense'],
        taxCertificate: _taxCertificate ?? _documents['taxCertificate'],
        identityProof: _identityProof ?? _documents['identityProof'],
      ),
    );
    return seller;
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
    _businessLicense = null;
    _taxCertificate = null;
    _identityProof = null;
    notifyListeners();
    log('🧹 Form cleared');
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

  // Enhanced validation
  bool validateForm() {
    log('🔍 Validating form...');

    // Password validation
    if (passwordController.text != confirmPasswordController.text) {
      setError('Passwords do not match');
      return false;
    }

    if (passwordController.text.length < 6) {
      setError('Password must be at least 6 characters');
      return false;
    }

    // Email validation
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      setError('Please enter a valid email address');
      return false;
    }

    // Required fields validation
    final requiredFields = [
      fullNameController.text,
      emailController.text,
      passwordController.text,
      confirmPasswordController.text,
      phoneController.text,
      businessNameController.text,
      shopNameController.text,
      descriptionController.text,
      addressController.text,
      bankNameController.text,
      accountNumberController.text,
    ];

    for (var field in requiredFields) {
      if (field.trim().isEmpty) {
        setError('Please fill all required fields (*)');
        return false;
      }
    }

    setError(null);
    log('✅ Form validation passed');
    return true;
  }
}
