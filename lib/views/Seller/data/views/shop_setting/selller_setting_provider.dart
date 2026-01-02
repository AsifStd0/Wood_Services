import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:wood_service/views/Seller/data/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';

// import 'package:wood_service/views/Buyer/Service/profile_service.dart';
class SelllerSettingProvider extends ChangeNotifier {
  final SellerAuthService _authService;
  final SellerLocalStorageService localStorageService;

  // Profile data
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _shopName = '';
  String _businessName = '';
  String _description = '';
  String _address = '';
  String _bankName = '';
  String _accountNumber = '';
  String _iban = '';
  List<String> _categories = [];

  // Text Editing Controllers for ALL fields
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController shopNameController;
  late TextEditingController businessNameController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController bankNameController;
  late TextEditingController accountNumberController;
  late TextEditingController ibanController;

  // Images
  File? _shopLogo;
  File? _shopBanner;
  File? _businessLicense;
  File? _taxCertificate;
  File? _identityProof;

  // State
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isVerified = false;
  bool _hasData = false;
  String? _errorMessage;

  // Getters
  String get fullName => _fullName;
  String get email => _email;
  String get phone => _phone;
  String get shopName => _shopName;
  String get businessName => _businessName;
  String get description => _description;
  String get address => _address;
  String get bankName => _bankName;
  String get accountNumber => _accountNumber;
  String get iban => _iban;
  List<String> get categories => _categories;
  File? get shopLogo => _shopLogo;
  File? get shopBanner => _shopBanner;
  File? get businessLicense => _businessLicense;
  File? get taxCertificate => _taxCertificate;
  File? get identityProof => _identityProof;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  bool get isVerified => _isVerified;
  bool get hasData => _hasData;
  String? get errorMessage => _errorMessage;

  // Constructor
  SelllerSettingProvider({
    required SellerAuthService authService,
    required SellerLocalStorageService localStorageService,
  }) : _authService = authService,
       localStorageService = localStorageService {
    // Initialize all controllers
    _initializeControllers();
  }

  void _initializeControllers() {
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    shopNameController = TextEditingController();
    businessNameController = TextEditingController();
    descriptionController = TextEditingController();
    addressController = TextEditingController();
    bankNameController = TextEditingController();
    accountNumberController = TextEditingController();
    ibanController = TextEditingController();
  }

  void _updateControllersFromData() {
    // Update all controllers with current data
    fullNameController.text = _fullName;
    emailController.text = _email;
    phoneController.text = _phone;
    shopNameController.text = _shopName;
    businessNameController.text = _businessName;
    descriptionController.text = _description;
    addressController.text = _address;
    bankNameController.text = _bankName;
    accountNumberController.text = _accountNumber;
    ibanController.text = _iban;
  }

  // ========== LOAD SELLER DATA ==========
  Future<void> loadSellerData() async {
    _isLoading = true;
    _hasData = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isSellerLoggedIn();

      if (!isLoggedIn) {
        log('⚠️ Seller not logged in');
        _hasData = false;
        return;
      }

      final seller = await _authService.getCurrentSeller();
      log('seller. seller seller seller ----- ${seller.toString()}');

      if (seller != null) {
        // Extract data from seller model
        _fullName = seller.personalInfo.fullName;
        _email = seller.personalInfo.email;
        _phone = seller.personalInfo.phone;
        _businessName = seller.businessInfo.businessName;
        _shopName = seller.businessInfo.shopName;
        _description = seller.businessInfo.description;
        _address = seller.businessInfo.address;
        _categories = seller.businessInfo.categories;
        _bankName = seller.bankDetails.bankName;
        _accountNumber = seller.bankDetails.accountNumber;
        _iban = seller.bankDetails.iban;

        // Update controllers with loaded data
        _updateControllersFromData();

        // Load images if paths exist
        if (seller.shopBrandingImages.shopLogo != null) {
          final logoPath = seller.shopBrandingImages.shopLogo.toString();
          if (await File(logoPath).exists()) {
            _shopLogo = File(logoPath);
          }
        }

        _hasData = true;
        log('✅ Seller profile data loaded successfully!');
      } else {
        log('❌ No seller data found');
        _hasData = false;
      }
    } catch (e) {
      log('❌ Error loading seller data: $e');
      _errorMessage = 'Error loading profile: $e';
      _hasData = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== SETTERS ==========
  void setFullName(String value) {
    _fullName = value;
    fullNameController.text = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    emailController.text = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    phoneController.text = value;
    notifyListeners();
  }

  void setShopName(String value) {
    _shopName = value;
    shopNameController.text = value;
    notifyListeners();
  }

  void setBusinessName(String value) {
    _businessName = value;
    businessNameController.text = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    descriptionController.text = value;
    notifyListeners();
  }

  void setAddress(String value) {
    _address = value;
    addressController.text = value;
    notifyListeners();
  }

  void setBankName(String value) {
    _bankName = value;
    bankNameController.text = value;
    notifyListeners();
  }

  void setAccountNumber(String value) {
    _accountNumber = value;
    accountNumberController.text = value;
    notifyListeners();
  }

  void setIban(String value) {
    _iban = value;
    ibanController.text = value;
    notifyListeners();
  }

  // ========== SAVE CHANGES ==========
  Future<bool> saveChanges() async {
    // Get current values from ALL controllers
    return await updateProfile(
      fullName: fullNameController.text,
      email: emailController.text,
      phone: phoneController.text,
      shopName: shopNameController.text,
      businessName: businessNameController.text,
      description: descriptionController.text,
      address: addressController.text,
      bankName: bankNameController.text,
      accountNumber: accountNumberController.text,
      iban: ibanController.text,
      categories: _categories,
      shopLogo: _shopLogo,
      shopBanner: _shopBanner,
      businessLicense: _businessLicense,
      taxCertificate: _taxCertificate,
      identityProof: _identityProof,
    );
  }

  // ========== EDITING STATE ==========
  void setEditing(bool value) {
    _isEditing = value;

    if (!value) {
      // If turning off editing, revert controllers to saved values
      _updateControllersFromData();
    }

    notifyListeners();
  }

  // ========== DISPOSE ==========
  void disposeControllers() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    shopNameController.dispose();
    businessNameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ibanController.dispose();
  }

  // ========== UPDATE PROFILE ==========
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? shopName,
    String? businessName,
    String? description,
    String? address,
    String? bankName,
    String? accountNumber,
    String? iban,
    List<String>? categories,
    File? shopLogo,
    File? shopBanner,
    File? businessLicense,
    File? taxCertificate,
    File? identityProof,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Prepare update data
      final updateData = <String, dynamic>{};

      if (fullName != null) updateData['fullName'] = fullName;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (shopName != null) updateData['shopName'] = shopName;
      if (businessName != null) updateData['businessName'] = businessName;
      if (description != null) updateData['description'] = description;
      if (address != null) updateData['address'] = address;
      if (bankName != null) updateData['bankName'] = bankName;
      if (accountNumber != null) updateData['accountNumber'] = accountNumber;
      if (iban != null) updateData['iban'] = iban;
      if (categories != null) updateData['categories'] = categories;

      // Call updateProfile method (you need to implement this in SellerAuthService)
      final result = await _authService.updateProfile(updates: updateData);

      if (result['success'] == true) {
        // Update local state
        if (fullName != null) _fullName = fullName;
        if (email != null) _email = email;
        if (phone != null) _phone = phone;
        if (shopName != null) _shopName = shopName;
        if (businessName != null) _businessName = businessName;
        if (description != null) _description = description;
        if (address != null) _address = address;
        if (bankName != null) _bankName = bankName;
        if (accountNumber != null) _accountNumber = accountNumber;
        if (iban != null) _iban = iban;
        if (categories != null) _categories = categories;
        if (shopLogo != null) _shopLogo = shopLogo;
        if (shopBanner != null) _shopBanner = shopBanner;
        if (businessLicense != null) _businessLicense = businessLicense;
        if (taxCertificate != null) _taxCertificate = taxCertificate;
        if (identityProof != null) _identityProof = identityProof;

        _isEditing = false;
        log('✅ Profile updated successfully');
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Update failed';
        log('❌ Update failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Update error: $e';
      log('❌ Update error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== IMAGE PICKERS ==========
  Future<void> pickShopLogo() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        _shopLogo = File(image.path);
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
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image != null) {
        _shopBanner = File(image.path);
        log('📷 Shop banner selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking shop banner: $e';
      log('❌ Error picking shop banner: $e');
      notifyListeners();
    }
  }

  // ! ******/
  // Add document picker methods
  Future<void> pickBusinessLicense() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _businessLicense = File(image.path);
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
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _taxCertificate = File(image.path);
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
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _identityProof = File(image.path);
        log('📄 Identity proof selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking identity proof: $e';
      log('❌ Error picking identity proof: $e');
      notifyListeners();
    }
  }

  // ========== Enhanced logout with navigation ==========
  Future<bool> logoutAndNavigate(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await logout();

      // After successful logout, navigate to login
      // Note: This method requires BuildContext
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/seller_login', // Your login route
          (route) => false,
        );
      });

      return true;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    try {
      // Clear all storage
      await localStorageService.deleteSellerAuth();
      await localStorageService.clearAll();

      // Double-check everything is cleared
      final token = await localStorageService.getSellerToken();
      final loginStatus = await localStorageService.getSellerLoginStatus();

      if (token == null && (loginStatus == null || loginStatus == false)) {
        log('✅ Seller logged out successfully - Verified');
        return true;
      } else {
        log('⚠️ Logout incomplete - retrying...');
        // Retry once
        await localStorageService.clearAll();
        return true;
      }
    } catch (e) {
      log('❌ Logout error: $e');
      return false;
    }
  }

  void setShopLogoFile(File? file) {
    _shopLogo = file;
    notifyListeners();
  }

  void setShopBannerFile(File? file) {
    _shopBanner = file;
    notifyListeners();
  }

  // ! Add setters
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
  // ! ****

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

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========== CLEAR FORM ==========
  void clearForm() {
    _fullName = '';
    _email = '';
    _phone = '';
    _shopName = '';
    _businessName = '';
    _description = '';
    _address = '';
    _bankName = '';
    _accountNumber = '';
    _iban = '';
    _categories.clear();
    _shopLogo = null;
    _shopBanner = null;
    _isEditing = false;
    _errorMessage = null;

    notifyListeners();
    log('🧹 Form cleared');
  }

  // Clear local ViewModel state
  void clearLocalState() {
    _fullName = '';
    _email = '';
    _phone = '';
    _shopName = '';
    _businessName = '';
    _description = '';
    _address = '';
    _bankName = '';
    _accountNumber = '';
    _iban = '';
    _categories.clear();
    _shopLogo = null;
    _shopBanner = null;
    _isEditing = false;
    _isVerified = false;
    _hasData = false;
    _errorMessage = null;
    _isLoading = false;
    _businessLicense = null;
    _taxCertificate = null;
    _identityProof = null;
    notifyListeners();
    log('🧹 Local state cleared');
  }
}
