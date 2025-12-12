// services/seller_data_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:wood_service/core/services/local_storage_service.dart';
import 'package:wood_service/views/Seller/data/models/seller_signup_model.dart';

class SellerDataService {
  // Keys for storage
  static const String _sellerCompleteDataKey = 'seller_complete_data';
  static const String _sellerModelKey = 'seller_model_data';
  static const String _shopLogoKey = 'shop_logo_base64';
  static const String _shopBannerKey = 'shop_banner_base64';
  static const String _categoriesKey = 'seller_categories';

  final LocalStorageService _storage;

  SellerDataService(this._storage);

  // ========== 1. SAVE COMPLETE SELLER DATA AFTER SIGNUP ==========
  Future<void> saveCompleteSellerData({
    required SellerModel sellerModel,
    required String token,
    required Map<String, dynamic> apiResponse,
  }) async {
    try {
      log('💾 Saving complete seller data...');

      // 1. Save SellerModel (structured data)
      await _saveSellerModel(sellerModel);

      // 2. Save raw API response (for reference)
      await _storage.saveString(
        _sellerCompleteDataKey,
        jsonEncode(apiResponse),
      );

      // 3. Save token using your existing method
      await _storage.saveToken(token);

      // 4. Save images as base64
      await _saveSellerImages(sellerModel);

      // 5. Save categories
      await _storage.saveStringList(
        _categoriesKey,
        sellerModel.businessInfo.categories,
      );

      log('✅ Complete seller data saved successfully!');
      log('👤 Seller: ${sellerModel.personalInfo.fullName}');
      log('🏪 Shop: ${sellerModel.businessInfo.shopName}');
      log('🔑 Token saved: ${token.substring(0, 20)}...');
    } catch (e) {
      log('❌ Error saving seller data: $e');
      throw Exception('Failed to save seller data');
    }
  }

  // ========== 2. SAVE SELLER MODEL ==========
  Future<void> _saveSellerModel(SellerModel seller) async {
    final sellerJson = seller.toJson();
    await _storage.saveString(_sellerModelKey, jsonEncode(sellerJson));
  }

  // ========== 3. SAVE IMAGES ==========
  Future<void> _saveSellerImages(SellerModel seller) async {
    try {
      // Save shop logo
      if (seller.shopBrandingImages.shopLogo != null) {
        final bytes = await seller.shopBrandingImages.shopLogo!.readAsBytes();
        final base64Image = base64Encode(bytes);
        await _storage.saveString(_shopLogoKey, base64Image);
        log('✅ Shop logo saved (${bytes.length} bytes)');
      }

      // Save shop banner
      if (seller.shopBrandingImages.shopBanner != null) {
        final bytes = await seller.shopBrandingImages.shopBanner!.readAsBytes();
        final base64Image = base64Encode(bytes);
        await _storage.saveString(_shopBannerKey, base64Image);
        log('✅ Shop banner saved (${bytes.length} bytes)');
      }
    } catch (e) {
      log('⚠️ Could not save images: $e');
    }
  }

  // ========== 4. LOAD SELLER MODEL ==========
  Future<SellerModel?> loadSellerModel() async {
    try {
      final jsonString = await _storage.getString(_sellerModelKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final json = jsonDecode(jsonString);
      return SellerModel.fromJson(json);
    } catch (e) {
      log('❌ Error loading seller model: $e');
      return null;
    }
  }

  // ========== 5. LOAD COMPLETE API RESPONSE ==========
  Future<Map<String, dynamic>?> loadCompleteData() async {
    try {
      final jsonString = await _storage.getString(_sellerCompleteDataKey);

      if (jsonString == null) return null;

      return jsonDecode(jsonString);
    } catch (e) {
      log('❌ Error loading complete data: $e');
      return null;
    }
  }

  // ========== 6. GET SPECIFIC FIELDS (QUICK ACCESS) ==========
  Future<String> getFullName() async {
    final seller = await loadSellerModel();
    return seller?.personalInfo.fullName ?? '';
  }

  Future<String> getEmail() async {
    final seller = await loadSellerModel();
    return seller?.personalInfo.email ?? '';
  }

  Future<String> getPhone() async {
    final seller = await loadSellerModel();
    return seller?.personalInfo.phone ?? '';
  }

  Future<String> getShopName() async {
    final seller = await loadSellerModel();
    return seller?.businessInfo.shopName ?? '';
  }

  Future<String> getBusinessName() async {
    final seller = await loadSellerModel();
    return seller?.businessInfo.businessName ?? '';
  }

  Future<String> getDescription() async {
    final seller = await loadSellerModel();
    return seller?.businessInfo.description ?? '';
  }

  Future<String> getAddress() async {
    final seller = await loadSellerModel();
    return seller?.businessInfo.address ?? '';
  }

  Future<String> getBankName() async {
    final seller = await loadSellerModel();
    return seller?.bankDetails.bankName ?? '';
  }

  Future<String> getIBAN() async {
    final seller = await loadSellerModel();
    return seller?.bankDetails.iban ?? '';
  }

  Future<String> getAccountNumber() async {
    final seller = await loadSellerModel();
    return seller?.bankDetails.accountNumber ?? '';
  }

  Future<List<String>> getCategories() async {
    final categories = await _storage.getStringList(_categoriesKey);
    return categories ?? [];
  }

  // ========== 7. LOAD IMAGES ==========
  Future<String?> getShopLogoBase64() async {
    return await _storage.getString(_shopLogoKey);
  }

  Future<String?> getShopBannerBase64() async {
    return await _storage.getString(_shopBannerKey);
  }

  // ========== 8. UPDATE SPECIFIC FIELDS ==========
  Future<void> updatePersonalInfo({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    final seller = await loadSellerModel();
    if (seller == null) return;

    final updatedSeller = seller.copyWith(
      personalInfo: seller.personalInfo.copyWith(
        fullName: fullName ?? seller.personalInfo.fullName,
        email: email ?? seller.personalInfo.email,
        phone: phone ?? seller.personalInfo.phone,
      ),
    );

    await _saveSellerModel(updatedSeller);
  }

  Future<void> updateBusinessInfo({
    String? shopName,
    String? businessName,
    String? description,
    String? address,
    List<String>? categories,
  }) async {
    final seller = await loadSellerModel();
    if (seller == null) return;

    final updatedSeller = seller.copyWith(
      businessInfo: seller.businessInfo.copyWith(
        shopName: shopName ?? seller.businessInfo.shopName,
        businessName: businessName ?? seller.businessInfo.businessName,
        description: description ?? seller.businessInfo.description,
        address: address ?? seller.businessInfo.address,
        categories: categories ?? seller.businessInfo.categories,
      ),
    );

    await _saveSellerModel(updatedSeller);

    // Also update categories list
    if (categories != null) {
      await _storage.saveStringList(_categoriesKey, categories);
    }
  }

  Future<void> updateBankDetails({
    String? bankName,
    String? accountNumber,
    String? iban,
  }) async {
    final seller = await loadSellerModel();
    if (seller == null) return;

    final updatedSeller = seller.copyWith(
      bankDetails: seller.bankDetails.copyWith(
        bankName: bankName ?? seller.bankDetails.bankName,
        accountNumber: accountNumber ?? seller.bankDetails.accountNumber,
        iban: iban ?? seller.bankDetails.iban,
      ),
    );

    await _saveSellerModel(updatedSeller);
  }

  Future<void> updateShopLogo(String base64Image) async {
    await _storage.saveString(_shopLogoKey, base64Image);
  }

  Future<void> updateShopBanner(String base64Image) async {
    await _storage.saveString(_shopBannerKey, base64Image);
  }

  // ========== 9. CHECK IF SELLER EXISTS ==========
  Future<bool> sellerExists() async {
    final token = await _storage.getToken();
    final sellerModel = await loadSellerModel();
    return token != null && sellerModel != null;
  }

  // ========== 10. DELETE ALL SELLER DATA ==========
  Future<void> deleteAllSellerData() async {
    await _storage.delete(_sellerModelKey);
    await _storage.delete(_sellerCompleteDataKey);
    await _storage.delete(_shopLogoKey);
    await _storage.delete(_shopBannerKey);
    await _storage.delete(_categoriesKey);
    await _storage.deleteToken();

    log('🧹 All seller data deleted');
  }

  // ========== 11. DEBUG/LOG METHODS ==========
  Future<void> printStoredData() async {
    log('📋 SELLER DATA IN STORAGE:');
    log('==========================');

    // Check token
    final token = await _storage.getToken();
    log(
      '🔑 Token: ${token != null ? "Exists (${token.length} chars)" : "None"}',
    );

    // Check seller model
    final seller = await loadSellerModel();
    if (seller != null) {
      log('👤 Seller Model Loaded:');
      log('   Name: ${seller.personalInfo.fullName}');
      log('   Email: ${seller.personalInfo.email}');
      log('   Shop: ${seller.businessInfo.shopName}');
      log('   Business: ${seller.businessInfo.businessName}');
    } else {
      log('❌ No seller model found');
    }

    // Check images
    final logo = await getShopLogoBase64();
    final banner = await getShopBannerBase64();
    log('🖼️ Logo: ${logo != null ? "Exists" : "None"}');
    log('🎨 Banner: ${banner != null ? "Exists" : "None"}');

    // Check categories
    final categories = await getCategories();
    log('🏷️ Categories: ${categories.length} items');
    categories.forEach((cat) => log('   - $cat'));
  }

  // ******! Splash

  Future<bool> isSellerLoggedIn() async {
    try {
      final token = await _storage.getToken();
      final sellerModel = await loadSellerModel();

      // Check both token and seller data
      final isLoggedIn = token != null && sellerModel != null;

      log('🔐 Auth Check:');
      log('   Token exists: ${token != null}');
      log('   Seller model exists: ${sellerModel != null}');
      log('   Result: $isLoggedIn');

      return isLoggedIn;
    } catch (e) {
      log('❌ Error checking auth status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAuthState() async {
    try {
      final token = await _storage.getToken();
      final seller = await loadSellerModel();

      return {
        'isAuthenticated': token != null && seller != null,
        'hasToken': token != null,
        'hasSellerData': seller != null,
        'seller': seller?.toJson(),
        'tokenLength': token?.length ?? 0,
      };
    } catch (e) {
      return null;
    }
  }

  // Clear all auth data (logout)
  Future<void> logout() async {
    await deleteAllSellerData();
    log('👋 Seller logged out');
  }

  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******

  Future<bool> checkAuthServiceStorage() async {
    try {
      // Check if SellerAuthService saved data
      final authToken = await _storage.getString('seller_auth_token');
      final authData = await _storage.getString('seller_auth_data');
      final authStatus = await _storage.getBool('seller_is_logged_in');

      log('🔍 Checking SellerAuthService storage:');
      log('   Auth token: ${authToken != null ? "Exists" : "None"}');
      log('   Auth data: ${authData != null ? "Exists" : "None"}');
      log('   Auth status: $authStatus');

      return authToken != null && authData != null;
    } catch (e) {
      log('❌ Error checking auth service storage: $e');
      return false;
    }
  }

  Future<void> migrateFromAuthService() async {
    try {
      log('🔄 Migrating data from SellerAuthService to SellerDataService...');

      // Get data from auth service storage
      final authToken = await _storage.getString('seller_auth_token');
      final authDataJson = await _storage.getString('seller_auth_data');

      if (authToken == null || authDataJson == null) {
        log('⚠️ No auth service data to migrate');
        return;
      }

      // Parse auth data
      final authData = jsonDecode(authDataJson);

      // Create SellerModel from auth data
      final sellerModel = SellerModel.fromJson(authData);

      // Save to SellerDataService storage
      await _saveSellerModel(sellerModel);
      await _storage.saveToken(authToken);
      await _storage.saveBool('seller_auth_state', true);

      // Save categories if they exist
      if (sellerModel.businessInfo.categories.isNotEmpty) {
        await _storage.saveStringList(
          _categoriesKey,
          sellerModel.businessInfo.categories,
        );
      }

      log('✅ Data migrated successfully!');
      log('   Seller: ${sellerModel.personalInfo.fullName}');
      log('   Email: ${sellerModel.personalInfo.email}');
    } catch (e) {
      log('❌ Error migrating auth service data: $e');
    }
  }

  // ========== UNIFIED LOAD METHOD ==========

  Future<SellerModel?> loadSellerModelUnified() async {
    try {
      log('🔍 Loading seller model from all sources...');

      // First try SellerDataService storage
      var seller = await loadSellerModel();

      if (seller == null) {
        log('⚠️ No data in SellerDataService, checking SellerAuthService...');

        // Check if auth service has data
        final hasAuthData = await checkAuthServiceStorage();
        if (hasAuthData) {
          // Migrate and load
          await migrateFromAuthService();
          seller = await loadSellerModel();
        }
      }

      if (seller != null) {
        log('✅ Seller model loaded: ${seller.personalInfo.fullName}');
      } else {
        log('❌ No seller model found in any storage');
      }

      return seller;
    } catch (e) {
      log('❌ Error loading unified seller model: $e');
      return null;
    }
  }

  // ========== UNIFIED SELLER EXISTS ==========

  Future<bool> sellerExistsUnified() async {
    try {
      final token = await _storage.getToken();

      // Check SellerDataService first
      var seller = await loadSellerModel();

      // If not found, check SellerAuthService
      if (seller == null) {
        final authToken = await _storage.getString('seller_auth_token');
        final authData = await _storage.getString('seller_auth_data');

        return (authToken != null && authData != null) || token != null;
      }

      return token != null && seller != null;
    } catch (e) {
      return false;
    }
  }
}
