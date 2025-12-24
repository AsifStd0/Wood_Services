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

  // Images
  File? _shopLogo;
  File? _shopBanner;
  // Document files - ADD THESE
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

  // Add getters
  File? get businessLicense => _businessLicense;
  File? get taxCertificate => _taxCertificate;
  File? get identityProof => _identityProof;
  // !
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  bool get isVerified => _isVerified;
  bool get hasData => _hasData;
  String? get errorMessage => _errorMessage;

  // Constructor - FIXED
  SelllerSettingProvider({
    required SellerAuthService authService,
    required SellerLocalStorageService localStorageService,
  }) : _authService = authService,
       localStorageService = localStorageService;

  // ========== LOAD SELLER DATA FROM SIGNUP ==========

  // ========== LOAD SELLER DATA ==========
  Future<void> loadSellerData() async {
    _isLoading = true;
    _hasData = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Use correct method names from SellerAuthService
      final isLoggedIn = await _authService.isSellerLoggedIn();

      if (!isLoggedIn) {
        log('⚠️ Seller not logged in');
        _hasData = false;
        return;
      }

      // ✅ Use correct method name
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

        // Note: Images are stored as paths in the model
        // You might need to load them as Files if needed
        if (seller.shopBrandingImages.shopLogo != null) {
          _shopLogo = File(seller.shopBrandingImages.shopLogo.toString());
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

  // ========== SAVE CHANGES ==========
  Future<bool> saveChanges() async {
    return await updateProfile(
      fullName: _fullName,
      email: _email,
      phone: _phone,
      shopName: _shopName,
      businessName: _businessName,
      description: _description,
      address: _address,
      bankName: _bankName,
      accountNumber: _accountNumber,
      iban: _iban,
      categories: _categories,
      shopLogo: _shopLogo,
      shopBanner: _shopBanner,
      // ✅ ADD DOCUMENTS
      businessLicense: _businessLicense,
      taxCertificate: _taxCertificate,
      identityProof: _identityProof,
    );
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
  // ========== LOGOUT ==========
  // In SelllerSettingProvider class, update the logout method:

  // In SellerSettingProvider class
  // In SellerAuthService class - Make sure it returns Future<bool>
  Future<bool> logout() async {
    // Should return Future<bool>
    try {
      // Clear all storage
      await localStorageService.deleteSellerAuth();
      await localStorageService.clearAll();

      log('✅ Seller logged out successfully');
      return true; // Return true on success
    } catch (e) {
      log('❌ Logout error: $e');
      return false; // Return false on error
    }
  }

  // ========== SETTERS ==========
  void setFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setShopName(String value) {
    _shopName = value;
    notifyListeners();
  }

  void setBusinessName(String value) {
    _businessName = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  void setBankName(String value) {
    _bankName = value;
    notifyListeners();
  }

  void setAccountNumber(String value) {
    _accountNumber = value;
    notifyListeners();
  }

  void setIban(String value) {
    _iban = value;
    notifyListeners();
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

  void setEditing(bool value) {
    _isEditing = value;
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
