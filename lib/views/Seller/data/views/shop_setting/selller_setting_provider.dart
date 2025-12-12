import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/core/services/local_storage_service.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keep your LocalStorageService abstract class and implementation as is

class ProfileViewModel extends ChangeNotifier {
  final SellerAuthService _authService;
  final LocalStorageService localStorageService;

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
  ProfileViewModel({
    required SellerAuthService authService,
    required LocalStorageService localStorageService,
  }) : _authService = authService,
       localStorageService = localStorageService;

  // ========== LOAD SELLER DATA FROM SIGNUP ==========
  Future<void> loadSellerDataFromSignup() async {
    _isLoading = true;
    _hasData = false;
    notifyListeners();

    try {
      // Check if seller is logged in
      final isLoggedIn = await _authService.isSellerLoggedIn();

      if (!isLoggedIn) {
        log('⚠️ Seller not logged in');
        _hasData = false;
        return;
      }

      // Get seller data
      final seller = await _authService.getStoredSeller();

      if (seller != null) {
        // Set data from model
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

        // ✅ IMPORTANT: Load images from paths
        if (seller.shopBrandingImages.shopLogo != null) {
          try {
            final logoPath = seller.shopBrandingImages.shopLogo!.path;
            if (await File(logoPath).exists()) {
              _shopLogo = File(logoPath);
              log('✅ Loaded shop logo from: $logoPath');
            } else {
              log('⚠️ Shop logo file not found at: $logoPath');
            }
          } catch (e) {
            log('❌ Error loading shop logo: $e');
          }
        }

        if (seller.shopBrandingImages.shopBanner != null) {
          try {
            final bannerPath = seller.shopBrandingImages.shopBanner!.path;
            if (await File(bannerPath).exists()) {
              _shopBanner = File(bannerPath);
              log('✅ Loaded shop banner from: $bannerPath');
            } else {
              log('⚠️ Shop banner file not found at: $bannerPath');
            }
          } catch (e) {
            log('❌ Error loading shop banner: $e');
          }
        }
        // ✅ Load document files from paths
        if (seller.documentsImage.businessLicense != null) {
          try {
            final licensePath = seller.documentsImage.businessLicense!.path;
            if (await File(licensePath).exists()) {
              _businessLicense = File(licensePath);
              log('✅ Loaded business license from: $licensePath');
            } else {
              log('⚠️ Business license file not found at: $licensePath');
            }
          } catch (e) {
            log('❌ Error loading business license: $e');
          }
        }

        if (seller.documentsImage.taxCertificate != null) {
          try {
            final taxPath = seller.documentsImage.taxCertificate!.path;
            if (await File(taxPath).exists()) {
              _taxCertificate = File(taxPath);
              log('✅ Loaded tax certificate from: $taxPath');
            } else {
              log('⚠️ Tax certificate file not found at: $taxPath');
            }
          } catch (e) {
            log('❌ Error loading tax certificate: $e');
          }
        }

        if (seller.documentsImage.identityProof != null) {
          try {
            final idPath = seller.documentsImage.identityProof!.path;
            if (await File(idPath).exists()) {
              _identityProof = File(idPath);
              log('✅ Loaded identity proof from: $idPath');
            } else {
              log('⚠️ Identity proof file not found at: $idPath');
            }
          } catch (e) {
            log('❌ Error loading identity proof: $e');
          }
        }

        _hasData = true;
        log(
          '✅ Profile data loaded successfully! ===  Name: $_fullName. ---- $_email.   ---- $_shopName',
        );
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

      if (fullName != null) {
        updateData['fullName'] = fullName;
        _fullName = fullName;
      }
      if (email != null) {
        updateData['email'] = email;
        _email = email;
      }
      if (phone != null) {
        updateData['phone'] = phone;
        _phone = phone;
      }
      if (shopName != null) {
        updateData['shopName'] = shopName;
        _shopName = shopName;
      }
      if (businessName != null) {
        updateData['businessName'] = businessName;
        _businessName = businessName;
      }
      if (description != null) {
        updateData['description'] = description;
        _description = description;
      }
      if (address != null) {
        updateData['address'] = address;
        _address = address;
      }
      if (bankName != null) {
        updateData['bankName'] = bankName;
        _bankName = bankName;
      }
      if (accountNumber != null) {
        updateData['accountNumber'] = accountNumber;
        _accountNumber = accountNumber;
      }
      if (iban != null) {
        updateData['iban'] = iban;
        _iban = iban;
      }
      if (categories != null) {
        updateData['categories'] = categories;
        _categories = categories;
      }

      // Call API to update
      final result = await _authService.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        businessName: businessName,
        shopName: shopName,
        description: description,
        address: address,
        categories: categories,
        bankName: bankName,
        accountNumber: accountNumber,
        iban: iban,
      );

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          log('❌ Update failed: ${failure.message}');
          return false;
        },
        (seller) {
          // Update images locally if provided
          if (shopLogo != null) _shopLogo = shopLogo;
          if (shopBanner != null) _shopBanner = shopBanner;
          // ✅ Update documents locally
          if (businessLicense != null) _businessLicense = businessLicense;
          if (taxCertificate != null) _taxCertificate = taxCertificate;
          if (identityProof != null) _identityProof = identityProof;

          _isEditing = false;
          log('✅ Profile updated successfully');
          notifyListeners();
          return true;
        },
      );
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
  // In ProfileViewModel class, update the logout method:

  Future<bool> logout() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.clear();

      // Clear local state
      clearLocalState();

      log('✅ Seller logged out successfully - all data cleared');
      return true; // Return success
    } catch (e) {
      log('❌ Error during logout: $e');
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
      return false; // Return failure
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
