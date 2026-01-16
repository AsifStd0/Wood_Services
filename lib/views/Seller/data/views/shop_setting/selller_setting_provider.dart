// lib/providers/selller_setting_provider.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

class SelllerSettingProvider extends ChangeNotifier {
  final UnifiedLocalStorageServiceImpl _storage;
  final Dio _dio;

  // Profile data from UserModel
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isVerified = false;
  String? _errorMessage;
  String? _successMessage;

  // For image updates (new images selected by user)
  File? _newShopLogo;
  File? _newShopBanner;
  File? _newBusinessLicense;
  File? _newTaxCertificate;
  File? _newIdentityProof;
  final ImagePicker _imagePicker = ImagePicker();

  // Text Editing Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController shopNameController;
  late TextEditingController businessNameController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController ibanController;
  late TextEditingController bankNameController;
  late TextEditingController accountNumberController;

  // Categories (not in UserModel, but used in UI)
  List<String> _categories = [];

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  bool get isVerified => _isVerified;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasData => _currentUser != null;
  List<String> get categories => _categories;

  // Image getters (show new image if selected, otherwise show URL from user model)
  File? get shopLogo => _newShopLogo;
  File? get shopBanner => _newShopBanner;
  File? get businessLicense => _newBusinessLicense;
  File? get taxCertificate => _newTaxCertificate;
  File? get identityProof => _newIdentityProof;

  // Convenience getters from UserModel
  String get fullName => _currentUser?.name ?? '';
  String get email => _currentUser?.email ?? '';
  String get phone => _currentUser?.phone?.toString() ?? '';
  String get shopName => _currentUser?.shopName ?? '';
  String get businessName => _currentUser?.businessName ?? '';
  String get description => _currentUser?.businessDescription ?? '';
  String get address => _currentUser?.address ?? '';
  String get iban => _currentUser?.iban ?? '';
  String? get shopLogoUrl => _currentUser?.shopLogo;
  String? get shopBannerUrl => _currentUser?.shopBanner;

  // Note: bankName and accountNumber are not in UserModel, but kept for UI compatibility
  String get bankName => bankNameController.text;
  String get accountNumber => accountNumberController.text;

  // Constructor
  SelllerSettingProvider({UnifiedLocalStorageServiceImpl? storage, Dio? dio})
    : _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>(),
      _dio = dio ?? locator<Dio>() {
    _initializeControllers();
    loadSellerData();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    shopNameController = TextEditingController();
    businessNameController = TextEditingController();
    descriptionController = TextEditingController();
    addressController = TextEditingController();
    ibanController = TextEditingController();
    bankNameController = TextEditingController();
    accountNumberController = TextEditingController();
  }

  void _updateControllersFromUser() {
    if (_currentUser != null) {
      nameController.text = _currentUser!.name;
      emailController.text = _currentUser!.email;
      phoneController.text = _currentUser!.phone?.toString() ?? '';
      shopNameController.text = _currentUser!.shopName ?? '';
      businessNameController.text = _currentUser!.businessName ?? '';
      descriptionController.text = _currentUser!.businessDescription ?? '';
      addressController.text = _currentUser!.address ?? '';
      ibanController.text = _currentUser!.iban ?? '';
      // Note: bankName and accountNumber not in UserModel, keep existing values
    }
  }

  // Load profile data from storage
  Future<void> loadSellerData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _storage.getUserModel();

      if (user != null && user.role == 'seller') {
        _currentUser = user;
        _updateControllersFromUser();
        log('✅ Seller profile data loaded successfully!');
      } else {
        log('⚠️ No seller profile found');
      }
    } catch (e) {
      log('❌ Error loading seller data: $e');
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'No token available';
        return;
      }

      final response = await _dio.get(
        '/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData;

        if (response.data['data'] != null &&
            response.data['data']['user'] != null) {
          userData = response.data['data']['user'] as Map<String, dynamic>;
        } else if (response.data['user'] != null) {
          userData = response.data['user'] as Map<String, dynamic>;
        } else {
          userData = response.data as Map<String, dynamic>;
        }

        log('''
================ USER DATA =================
${const JsonEncoder.withIndent('  ').convert(userData)}
==========================================
''');

        final user = UserModel.fromJson(userData);

        await _storage.saveUserData(user.toJson());
        _currentUser = user;
        _updateControllersFromUser();
        _successMessage = 'Profile refreshed successfully';

        log('✅ Profile refreshed successfully');
      } else {
        _errorMessage = 'Failed to refresh profile';
      }
    } catch (e, s) {
      log('❌ Error refreshing profile', error: e, stackTrace: s);
      _errorMessage = 'Failed to refresh profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile with text data and images
  Future<bool> saveChanges() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final token = _storage.getToken();
      if (token == null) {
        _errorMessage = 'Not authenticated';
        return false;
      }

      log('🔄 Starting profile update...');

      final updates = <String, dynamic>{};
      if (nameController.text.isNotEmpty) {
        updates['name'] = nameController.text.trim();
      }
      if (emailController.text.isNotEmpty) {
        updates['email'] = emailController.text.trim();
      }
      if (phoneController.text.isNotEmpty) {
        final phoneDigits = phoneController.text.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        if (phoneDigits.isNotEmpty) {
          updates['phone'] = int.tryParse(phoneDigits);
        }
      }
      if (shopNameController.text.isNotEmpty) {
        updates['shopName'] = shopNameController.text.trim();
      }
      if (businessNameController.text.isNotEmpty) {
        updates['businessName'] = businessNameController.text.trim();
      }
      if (descriptionController.text.isNotEmpty) {
        updates['businessDescription'] = descriptionController.text.trim();
      }
      if (addressController.text.isNotEmpty) {
        updates['address'] = addressController.text.trim();
      }
      if (ibanController.text.isNotEmpty) {
        updates['iban'] = ibanController.text.trim();
      }
      // Note: bankName and accountNumber not in UserModel, but send if needed by API
      if (bankNameController.text.isNotEmpty) {
        updates['bankName'] = bankNameController.text.trim();
      }
      if (accountNumberController.text.isNotEmpty) {
        updates['accountNumber'] = accountNumberController.text.trim();
      }

      // Build FormData with files
      final formData = FormData();

      // Add text fields
      updates.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add image files
      if (_newShopLogo != null) {
        formData.files.add(
          MapEntry(
            'shopLogo',
            await MultipartFile.fromFile(
              _newShopLogo!.path,
              filename: 'shopLogo-${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }
      if (_newShopBanner != null) {
        formData.files.add(
          MapEntry(
            'shopBanner',
            await MultipartFile.fromFile(
              _newShopBanner!.path,
              filename:
                  'shopBanner-${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }
      if (_newBusinessLicense != null) {
        formData.files.add(
          MapEntry(
            'businessLicense',
            await MultipartFile.fromFile(
              _newBusinessLicense!.path,
              filename:
                  'businessLicense-${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }
      if (_newTaxCertificate != null) {
        formData.files.add(
          MapEntry(
            'taxCertificate',
            await MultipartFile.fromFile(
              _newTaxCertificate!.path,
              filename:
                  'taxCertificate-${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }
      if (_newIdentityProof != null) {
        formData.files.add(
          MapEntry(
            'identityProof',
            await MultipartFile.fromFile(
              _newIdentityProof!.path,
              filename:
                  'identityProof-${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }

      final response = await _dio.put(
        '/auth/profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData;
        if (response.data['data'] != null &&
            response.data['data']['user'] != null) {
          userData = response.data['data']['user'] as Map<String, dynamic>;
        } else if (response.data['user'] != null) {
          userData = response.data['user'] as Map<String, dynamic>;
        } else {
          userData = response.data as Map<String, dynamic>;
        }
        final user = UserModel.fromJson(userData);

        await _storage.saveUserData(user.toJson());
        _currentUser = user;
        _updateControllersFromUser();
        _successMessage =
            response.data['message'] ?? 'Profile updated successfully';
        _isEditing = false;
        _clearNewImages();

        log('✅ Profile updated successfully: ${_currentUser?.name}');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to update profile';
        return false;
      }
    } on DioException catch (e) {
      log('❌ Dio error updating profile: ${e.message}');
      _errorMessage =
          e.response?.data['message'] ?? 'Network error: ${e.message}';
      return false;
    } catch (e) {
      log('❌ Error updating profile: $e');
      _errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Image pickers
  Future<void> pickShopLogo() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        _newShopLogo = File(image.path);
        log('📷 Shop logo selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking shop logo: $e';
      log('❌ Error picking shop logo: $e');
      notifyListeners();
    }
  }

  Future<void> pickShopBanner() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image != null) {
        _newShopBanner = File(image.path);
        log('📷 Shop banner selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking shop banner: $e';
      log('❌ Error picking shop banner: $e');
      notifyListeners();
    }
  }

  Future<void> pickBusinessLicense() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _newBusinessLicense = File(image.path);
        log('📄 Business license selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking business license: $e';
      log('❌ Error picking business license: $e');
      notifyListeners();
    }
  }

  Future<void> pickTaxCertificate() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _newTaxCertificate = File(image.path);
        log('📄 Tax certificate selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking tax certificate: $e';
      log('❌ Error picking tax certificate: $e');
      notifyListeners();
    }
  }

  Future<void> pickIdentityProof() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _newIdentityProof = File(image.path);
        log('📄 Identity proof selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking identity proof: $e';
      log('❌ Error picking identity proof: $e');
      notifyListeners();
    }
  }

  // Clear new images
  void _clearNewImages() {
    _newShopLogo = null;
    _newShopBanner = null;
    _newBusinessLicense = null;
    _newTaxCertificate = null;
    _newIdentityProof = null;
  }

  void clearShopLogo() {
    _newShopLogo = null;
    notifyListeners();
  }

  void clearShopBanner() {
    _newShopBanner = null;
    notifyListeners();
  }

  void clearBusinessLicense() {
    _newBusinessLicense = null;
    notifyListeners();
  }

  void clearTaxCertificate() {
    _newTaxCertificate = null;
    notifyListeners();
  }

  void clearIdentityProof() {
    _newIdentityProof = null;
    notifyListeners();
  }

  // Setters (for compatibility with existing widgets)
  void setFullName(String value) {
    nameController.text = value;
    notifyListeners();
  }

  void setEmail(String value) {
    emailController.text = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phoneController.text = value;
    notifyListeners();
  }

  void setShopName(String value) {
    shopNameController.text = value;
    notifyListeners();
  }

  void setBusinessName(String value) {
    businessNameController.text = value;
    notifyListeners();
  }

  void setDescription(String value) {
    descriptionController.text = value;
    notifyListeners();
  }

  void setAddress(String value) {
    addressController.text = value;
    notifyListeners();
  }

  void setBankName(String value) {
    bankNameController.text = value;
    notifyListeners();
  }

  void setAccountNumber(String value) {
    accountNumberController.text = value;
    notifyListeners();
  }

  void setIban(String value) {
    ibanController.text = value;
    notifyListeners();
  }

  // Categories (not in UserModel, but used in UI)
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

  // Logout
  Future<bool> logout() async {
    try {
      log('🔄 Starting logout...');
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // Verify user data exists before logout
      final userBeforeLogout = _storage.getUserModel();
      final tokenBeforeLogout = _storage.getToken();
      log(
        '📊 Before logout - User: ${userBeforeLogout?.email}, Token: ${tokenBeforeLogout?.substring(0, 10)}...',
      );

      // Clear storage first
      await _storage.logout();
      log('🗑️ Storage cleared');

      // Verify storage is cleared
      final userAfterLogout = _storage.getUserModel();
      final tokenAfterLogout = _storage.getToken();
      final isLoggedInAfterLogout = _storage.isLoggedIn();
      log(
        '📊 After logout - User: ${userAfterLogout?.email ?? "null"}, Token: ${tokenAfterLogout ?? "null"}, IsLoggedIn: $isLoggedInAfterLogout',
      );

      // Clear local state
      _currentUser = null;
      _clearNewImages();
      log('🗑️ Local state cleared');

      _isLoading = false;
      notifyListeners();

      log('✅ Logout completed successfully');
      return true;
    } catch (e, stackTrace) {
      log('❌ Error during logout: $e', error: e, stackTrace: stackTrace);
      _errorMessage = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set editing mode
  void setEditing(bool value) {
    _isEditing = value;
    if (!value) {
      // If turning off editing, revert controllers to saved values
      _updateControllersFromUser();
      _clearNewImages();
    }
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Legacy methods for compatibility
  void setShopLogoFile(File? file) {
    _newShopLogo = file;
    notifyListeners();
  }

  void setShopBannerFile(File? file) {
    _newShopBanner = file;
    notifyListeners();
  }

  set businessLicense(File? value) {
    _newBusinessLicense = value;
    notifyListeners();
  }

  set taxCertificate(File? value) {
    _newTaxCertificate = value;
    notifyListeners();
  }

  set identityProof(File? value) {
    _newIdentityProof = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    shopNameController.dispose();
    businessNameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    ibanController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    super.dispose();
  }
}
