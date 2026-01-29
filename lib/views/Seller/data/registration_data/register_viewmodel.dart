// view_models/register_viewmodel.dart
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/buyer_main/buyer_main.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';
import 'package:wood_service/views/Seller/data/services/auth_service.dart';
import 'package:wood_service/views/Seller/main_seller_screen.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController businessDescriptionController =
      TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();

  final TextEditingController ibanController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // State variables
  String _role = 'buyer';
  File? _profileImage;
  File? _shopLogo;
  File? _shopBanner;
  File? _businessLicense;
  File? _taxCertificate;
  File? _identityProof;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _countryCode = '+1';
  final List<String> _categories = [];
  final Map<String, File?> _documents = {
    'businessLicense': null,
    'taxCertificate': null,
    'identityProof': null,
  };

  RegisterViewModel(this._authService);

  // Getters
  String get role => _role;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  String get countryCode => _countryCode;
  File? get shopLogo => _shopLogo;
  File? get shopBanner => _shopBanner;
  List<String> get categories => _categories;
  Map<String, File?> get documents => _documents;
  File? get businessLicense => _businessLicense;
  File? get taxCertificate => _taxCertificate;
  File? get identityProof => _identityProof;
  File? get profileImage => _profileImage;

  // Setters
  set role(String value) {
    _role = value;
    notifyListeners();
  }

  set countryCode(String value) {
    _countryCode = value;
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

  // Category methods
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

  /// Compress image file to reduce size before upload
  /// Returns compressed file path
  Future<File?> _compressImage(File imageFile) async {
    try {
      log('🗜️ Compressing image: ${imageFile.path}');
      log('   Original size: ${await imageFile.length()} bytes');

      // Get temporary directory for compressed image
      final tempDir = await path_provider.getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final extension = path.extension(imageFile.path);
      final targetPath =
          '${tempDir.path}/${fileName}_compressed_$timestamp$extension';

      // Compress image
      // Quality: 70 (0-100, lower = smaller file size)
      // Min width/height: 1920 (max dimensions to maintain quality)
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 70, // 70% quality - good balance
        minWidth: 1920, // Max width
        minHeight: 1920, // Max height
        keepExif: false, // Remove EXIF data to reduce size
      );

      if (compressedFile != null) {
        final compressedFileObj = File(compressedFile.path);
        final compressedSize = await compressedFileObj.length();
        final originalSize = await imageFile.length();
        final compressionRatio = ((1 - compressedSize / originalSize) * 100)
            .toStringAsFixed(1);
        log('   ✅ Compressed size: $compressedSize bytes');
        log('   📊 Compression ratio: $compressionRatio% reduction');
        return compressedFileObj;
      } else {
        log('   ⚠️ Compression returned null, using original');
        return imageFile;
      }
    } catch (e) {
      log('   ❌ Compression error: $e, using original file');
      return imageFile; // Return original if compression fails
    }
  }

  // Image picking methods
  Future<void> pickImage(String type) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Initial quality from picker (optional)
      );
      if (pickedFile != null) {
        final originalFile = File(pickedFile.path);

        // Compress the image before storing
        log('🖼️ Picking image for type: $type');
        final compressedFile = await _compressImage(originalFile);
        final file = compressedFile ?? originalFile;

        switch (type) {
          case 'profile':
            _profileImage = file;
            break;
          case 'shopLogo':
            _shopLogo = file;
            break;
          case 'shopBanner':
            _shopBanner = file;
            break;
          case 'businessLicense':
            _businessLicense = file;
            _documents['businessLicense'] = file;
            break;
          case 'taxCertificate':
            _taxCertificate = file;
            _documents['taxCertificate'] = file;
            break;
          case 'identityProof':
            _identityProof = file;
            _documents['identityProof'] = file;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking image: $e';
      notifyListeners();
    }
  }

  // Alias methods for compatibility
  Future<void> pickShopLogo() async => await pickImage('shopLogo');
  Future<void> pickShopBanner() async => await pickImage('shopBanner');

  // Clear image methods
  void clearShopLogo() {
    _shopLogo = null;
    notifyListeners();
  }

  void clearShopBanner() {
    _shopBanner = null;
    notifyListeners();
  }

  void clearDocument(String documentType) {
    _documents[documentType] = null;
    switch (documentType) {
      case 'businessLicense':
        _businessLicense = null;
        break;
      case 'taxCertificate':
        _taxCertificate = null;
        break;
      case 'identityProof':
        _identityProof = null;
        break;
    }
    notifyListeners();
  }

  // Document picking
  Future<void> pickDocument(String documentType) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Initial quality from picker
      );
      if (pickedFile != null) {
        final originalFile = File(pickedFile.path);

        // Compress the document image before storing
        log('📄 Picking document: $documentType');
        final compressedFile = await _compressImage(originalFile);
        final file = compressedFile ?? originalFile;

        _documents[documentType] = file;

        // Also update individual properties
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
      }
    } catch (e) {
      _errorMessage = 'Error picking $documentType: $e';
      notifyListeners();
    }
  }

  // Validation
  bool validateForm() {
    if (nameController.text.trim().isEmpty) {
      _errorMessage = 'Full name is required';
      notifyListeners();
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _errorMessage = 'Email address is required';
      notifyListeners();
      return false;
    }

    if (!emailController.text.trim().contains('@') ||
        !emailController.text.trim().contains('.')) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    if (passwordController.text.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    // In RegisterViewModel validateForm() method

    // Phone validation - must be numeric
    if (phoneController.text.trim().isEmpty) {
      _errorMessage = 'Contact number is required';
      notifyListeners();
      return false;
    }

    // Check if phone contains only digits (after removing non-numeric characters)
    final phoneDigits = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.isEmpty) {
      _errorMessage = 'Please enter a valid phone number';
      notifyListeners();
      return false;
    }

    // Check phone length (at least 10 digits)
    if (phoneDigits.length < 10) {
      _errorMessage = 'Phone number must be at least 10 digits';
      notifyListeners();
      return false;
    }

    // Buyer specific validation
    if (_role == 'buyer') {
      if (bankNameController.text.trim().isEmpty) {
        _errorMessage = 'Bank name is required';
        notifyListeners();
        return false;
      }

      if (accountNumberController.text.trim().isEmpty) {
        _errorMessage = 'Account number is required';
        notifyListeners();
        return false;
      }
      // Note: IBAN is optional for buyers
      // Business Name, Address, and Description are also optional for buyers
    }

    // Seller specific validation
    if (_role == 'seller') {
      if (businessNameController.text.trim().isEmpty) {
        _errorMessage = 'Business name is required';
        notifyListeners();
        return false;
      }

      if (shopNameController.text.trim().isEmpty) {
        _errorMessage = 'Shop name is required';
        notifyListeners();
        return false;
      }

      if (businessDescriptionController.text.trim().isEmpty) {
        _errorMessage = 'Business description is required';
        notifyListeners();
        return false;
      }

      if (addressController.text.trim().isEmpty) {
        _errorMessage = 'Business address is required';
        notifyListeners();
        return false;
      }

      if (bankNameController.text.trim().isEmpty) {
        _errorMessage = 'Bank name is required';
        notifyListeners();
        return false;
      }

      if (accountNumberController.text.trim().isEmpty) {
        _errorMessage = 'Account number is required';
        notifyListeners();
        return false;
      }

      if (_categories.isEmpty) {
        _errorMessage = 'At least one business category is required';
        notifyListeners();
        return false;
      }

      if (_businessLicense == null) {
        _errorMessage = 'Business license document is required';
        notifyListeners();
        return false;
      }

      if (_taxCertificate == null) {
        _errorMessage = 'Tax certificate document is required';
        notifyListeners();
        return false;
      }

      if (_identityProof == null) {
        _errorMessage = 'Identity proof document is required';
        notifyListeners();
        return false;
      }
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // Helper method to create UserModel
  // view_models/register_viewmodel.dart - Update _createUserModel method

  UserModel _createUserModel(String role) {
    // Parse phone to int (remove non-numeric characters)
    final phoneDigits = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneNumber = int.tryParse('$_countryCode$phoneDigits') ?? 0;

    return UserModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      phone: phoneNumber, // Now int
      role: role,

      address: addressController.text.trim().isNotEmpty
          ? addressController.text.trim()
          : null,
      businessName: businessNameController.text.trim().isNotEmpty
          ? businessNameController.text.trim()
          : null,
      shopName: shopNameController.text.trim().isNotEmpty
          ? shopNameController.text.trim()
          : null,
      businessDescription: businessDescriptionController.text.trim().isNotEmpty
          ? businessDescriptionController.text.trim()
          : null,
      businessAddress: businessAddressController.text.trim().isNotEmpty
          ? businessAddressController.text.trim()
          : null,
      iban: ibanController.text.trim().isNotEmpty
          ? ibanController.text.trim()
          : null,
    );
  }

  // Prepare files for upload
  Map<String, File?> _prepareFiles() {
    final files = <String, File?>{};

    if (_profileImage != null) files['profileImage'] = _profileImage;
    if (_shopLogo != null) files['shopLogo'] = _shopLogo;
    if (_shopBanner != null) files['shopBanner'] = _shopBanner;
    if (_businessLicense != null) files['businessLicense'] = _businessLicense;
    if (_taxCertificate != null) files['taxCertificate'] = _taxCertificate;
    if (_identityProof != null) files['identityProof'] = _identityProof;

    return files;
  }

  // Submit registration
  Future<Map<String, dynamic>?> submitRegistration({
    required String role,
  }) async {
    log('🚀 ========== REGISTRATION STARTED ==========');
    log('👤 Role: $role');
    log('🔍 Validating form...');

    if (!validateForm()) {
      log('❌ Form validation failed: $_errorMessage');
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create UserModel
      final user = _createUserModel(role);

      final files = _prepareFiles();

      files.forEach((key, value) {
        log('   $key: ${value?.path ?? "No file"}');
      });

      log('   Role: $role');

      // Call API
      final response = await _authService.register(user, files, role);

      // ✅ SUCCESS: Save user data and token to storage
      log('💾 Saving user data to storage... ${response.toString()}');
      await _saveUserData(response);
      log('✅ UserModel created:');
      log('   ID: ${user.id}');
      log('   Name: ${user.name}');
      log('   Email: ${user.email}');
      log('   Address --------------------------------------: ${user.address}');
      log(
        '   Phone: ${user.phone} (Type: ${user.phone.runtimeType})',
      ); // Should show int
      log('   Role: ${user.role}');
      _isLoading = false;

      // ✅ Clear the form after successful registration
      clearForm();
      log('🎉 ========== REGISTRATION COMPLETED SUCCESSFULLY ==========');

      notifyListeners();
      return response;
    } catch (e) {
      log('❌11111 ========== REGISTRATION FAILED ==========');
      log('   Error: $e');
      _isLoading = false;
      _errorMessage = e.toString();

      log('❌ Registration failed with error: $_errorMessage');
      log('===========================================');

      notifyListeners();
      return null;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> response) async {
    try {
      log('💾 ========== SAVING USER DATA TO STORAGE ==========');

      final storage = locator<UnifiedLocalStorageServiceImpl>();

      // Debug the response structure
      log('📄 Full response structure:');
      log('   Response keys: ${response.keys.toList()}');

      if (response['data'] != null) {
        log('   Data keys: ${(response['data'] as Map).keys.toList()}');
      }

      // // Extract user data from response
      // Map<String, dynamic> userData =
      //     response['data']['user'] as Map<String, dynamic>;
      Map<String, dynamic> userData =
          response['data']['user'] as Map<String, dynamic>;
      final token = response['data']['token'] as String;

      // ✅ FIX: Ensure shopLogo and other image fields are strings, not arrays
      const imageFields = [
        'profileImage',
        'shopLogo',
        'shopBanner',
        'businessLicense',
        'taxCertificate',
        'identityProof',
      ];

      for (final field in imageFields) {
        if (userData[field] is List) {
          final list = userData[field] as List;
          if (list.isNotEmpty) {
            userData[field] = list[0].toString();
            log('   ✅ Fixed $field: Array converted to string');
          } else {
            userData[field] = null;
            log('   ✅ Fixed $field: Empty array set to null');
          }
        }
      }

      log('👤 User data extracted (after fixing arrays):');
      userData.forEach((key, value) {
        log('   $key: $value (Type: ${value.runtimeType})');
      });

      // Create UserModel from API response
      log('🔄 Creating UserModel...');
      final user = UserModel.fromJson(userData);

      log('✅ UserModel created:');
      log('   ID: ${user.id}');
      log('   Name: ${user.name}');
      log('   Email: ${user.email}');
      log('   Role: ${user.role}');
      log(
        '   Profile Image: ${user.profileImage} (Type: ${user.profileImage.runtimeType})',
      );
      log(
        '   Shop Logo: ${user.shopLogo} (Type: ${user.shopLogo.runtimeType})',
      );
      log('   Business Name: ${user.businessName}');

      // Save user data
      log('💾 Saving UserModel to storage...');
      await storage.saveUserModel(user);

      // Save token
      log('💾 Saving token to storage...');
      await storage.saveToken(token);

      // Verify save
      log('🔍 Verifying storage save...');
      final savedUser = storage.getUserModel();
      final savedToken = storage.getToken();

      log('✅ Storage verification:');
      log('   Is logged in: ${storage.isLoggedIn()}');
      log('   User role from storage: ${storage.getUserRole()}');
      log('   User ID from storage: ${savedUser?.id}');
      log('   User name from storage: ${savedUser?.name}');
      log(
        '   Shop logo from storage: ${savedUser?.shopLogo} (Type: ${savedUser?.shopLogo.runtimeType})',
      );
      log('   Token exists: ${savedToken != null}');
      log('   Token length: ${savedToken?.length ?? 0}');

      log('🎉 User data saved successfully to storage!');
      log('💾 ============================================');
    } catch (e) {
      log('❌ ========== ERROR SAVING USER DATA ==========');
      log('   Error: $e');
      log('   Error type: ${e.runtimeType}');
      log('   Stack trace: ${e.toString()}');

      if (e is TypeError) {
        log('   ⚠️ This is a type casting error!');
        log(
          '   ⚠️ Likely cause: Field expecting String but got something else',
        );
      }

      log('❌ ============================================');
      rethrow;
    }
  }

  // Helper function
  Future<void> handleSubmission(BuildContext context, String role) async {
    final viewModel = context.read<RegisterViewModel>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await viewModel.submitRegistration(role: role);

      Navigator.of(context).pop(); // Close loading

      if (result == null) {
        // Show error from viewModel
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Failed'),
            content: Text(viewModel.errorMessage ?? 'Unknown error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // ✅ SUCCESS: Data is already saved in storage
      // Now navigate based on role
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      // ✅ Clear the form BEFORE navigation
      viewModel.clearForm();

      // Navigate based on role
      if (role == 'seller') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainSellerScreen()),
        );
      } else if (role == 'buyer') {
        Navigator.of(
          // ignore: use_build_context_synchronously
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => BuyerMainScreen()));
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainSellerScreen()),
        );
      }
    } catch (error) {
      Navigator.of(context).pop(); // Close loading
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Login state
  bool _isLoginLoading = false;
  String? _loginErrorMessage;

  bool get isLoginLoading => _isLoginLoading;
  String? get loginErrorMessage => _loginErrorMessage;

  // Email and password for login (simpler than registration)
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  String _loginRole = 'buyer'; // Default login role

  String get loginRole => _loginRole;
  set loginRole(String value) {
    _loginRole = value;
    notifyListeners();
  }

  // Login validation
  bool validateLoginForm() {
    if (loginEmailController.text.isEmpty ||
        !loginEmailController.text.contains('@')) {
      _loginErrorMessage = 'Valid email is required';
      notifyListeners();
      return false;
    }

    if (loginPasswordController.text.isEmpty) {
      _loginErrorMessage = 'Password is required';
      notifyListeners();
      return false;
    }

    if (loginPasswordController.text.length < 6) {
      _loginErrorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    _loginErrorMessage = null;
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>?> login() async {
    log('🔐 ========== LOGIN STARTED ==========');
    log('👤 Login role: $_loginRole');
    log('📧 Email: ${loginEmailController.text}');

    if (!validateLoginForm()) {
      log('❌ Login validation failed: $_loginErrorMessage');
      return null;
    }

    _isLoginLoading = true;
    _loginErrorMessage = null;
    notifyListeners();

    try {
      log('🌐 Calling login API...');

      // Call AuthService login
      final response = await _authService.login(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
        role: _loginRole,
      );

      log('✅ Login API response:');
      log('   Success: ${response['success']}');
      log('   Message: ${response['message']}');

      if (response['data'] != null && response['data']['user'] != null) {
        final userData = response['data']['user'];
        log('👤 User data from login:');
        log('   ID: ${userData['id'] ?? userData['_id']}');
        log('   Name: ${userData['name']}');
        log('   Email: ${userData['email']}');
        log('   Role: ${userData['roles']?[0] ?? userData['role']}');
      }

      // ✅ SUCCESS: Save user data and token to storage
      await _saveUserData(response);

      _isLoginLoading = false;

      // Clear login form
      loginEmailController.clear();
      loginPasswordController.clear();

      log('✅ Login completed successfully');
      log('🔐 =================================');

      notifyListeners();
      return response;
    } on DioException catch (e) {
      log('❌ Login DioException: $e');
      _isLoginLoading = false;
      // Extract error message from DioException
      String errorMsg = 'Login failed';
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          errorMsg =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'Login failed';
        } else if (errorData is String) {
          errorMsg = errorData;
        }
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
      _loginErrorMessage = errorMsg;
      log('📝 Extracted error message: $_loginErrorMessage');
      notifyListeners();
      return null;
    } catch (e) {
      log('❌ Login failed: $e');
      _isLoginLoading = false;
      // Handle String errors or other types
      String errorMsg = e.toString();
      // Remove "Exception: " prefix if present
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _loginErrorMessage = errorMsg;
      log('📝 Error message: $_loginErrorMessage');
      notifyListeners();
      return null;
    }
  }

  // Handle login submission (similar to registration)
  Future<void> handleLogin(BuildContext context) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await login();

      // Wait a tiny bit to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 100));

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      if (result == null) {
        // Get error message after login completes
        final errorMessage = _loginErrorMessage?.isNotEmpty == true
            ? _loginErrorMessage!
            : 'Unknown error occurred';
        log('🚨 Showing error dialog: $errorMessage');
        log('🚨 _loginErrorMessage value: $_loginErrorMessage');

        if (!context.mounted) return;

        // Show SnackBar for immediate feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        // Also show dialog for better visibility
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('Login Failed'),
              ],
            ),
            content: Text(errorMessage, style: const TextStyle(fontSize: 16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // ✅ SUCCESS
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!context.mounted) return;

      // Navigate based on login role
      if (_loginRole == 'seller') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainSellerScreen()),
        );
      } else if (_loginRole == 'buyer') {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => BuyerMainScreen()));
      }
    } catch (error) {
      if (!context.mounted) return;

      // Close loading dialog if still open
      try {
        Navigator.of(context).pop();
      } catch (e) {
        // Dialog might already be closed
      }

      String errorMessage = error.toString();
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      log('🚨 Login handleLogin catch error: $errorMessage');

      if (!context.mounted) return;

      // Show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );

      // Show dialog
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Login Error'),
            ],
          ),
          content: Text(errorMessage, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // view_models/register_viewmodel.dart - Update _createUserModel method

  // Clear login form
  void clearLoginForm() {
    loginEmailController.clear();
    loginPasswordController.clear();
    _loginRole = 'buyer';
    _loginErrorMessage = null;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    try {
      final storage = locator<UnifiedLocalStorageServiceImpl>();
      await storage.logout();

      clearForm();
      clearLoginForm();

      _isLoading = false;
      _isLoginLoading = false;
      _errorMessage = null;
      _loginErrorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
    }
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    addressController.clear();
    businessNameController.clear();
    shopNameController.clear();
    businessDescriptionController.clear();
    businessAddressController.clear();
    ibanController.clear();
    accountNumberController.clear();
    bankNameController.clear();

    _role = 'buyer';
    _profileImage = null;
    _shopLogo = null;
    _shopBanner = null;
    _businessLicense = null;
    _taxCertificate = null;
    _identityProof = null;
    _errorMessage = null;
    _countryCode = '+1';
    _categories.clear();
    _documents.clear();
    _documents['businessLicense'] = null;
    _documents['taxCertificate'] = null;
    _documents['identityProof'] = null;

    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    businessNameController.dispose();
    shopNameController.dispose();
    businessDescriptionController.dispose();
    businessAddressController.dispose();
    ibanController.dispose();
    accountNumberController.dispose();
    bankNameController.dispose();
    super.dispose();
  }
}
