// features/seller_settings/presentation/providers/seller_settings_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/setting_data/seller_settings_repository.dart';

class SellerSettingsProvider extends ChangeNotifier {
  final SellerSettingsRepository _repository;

  // State
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  String? _successMessage;

  // Categories
  final List<String> _categories = [];

  // Image files
  File? _newShopLogo;
  File? _newShopBanner;
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController shopNameController;
  late TextEditingController businessNameController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController ibanController;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasData => _currentUser != null;

  File? get shopLogo => _newShopLogo;
  File? get shopBanner => _newShopBanner;
  String? get shopLogoUrl => _currentUser?.shopLogo;
  String? get shopBannerUrl => _currentUser?.shopBanner;
  List<String> get categories => List.unmodifiable(_categories);

  // Initialize
  // SellerSettingsProvider(SellerSettingsRepository repository) : _repository = repository {
  //   _initializeControllers();
  //   loadSellerData();
  // }
  SellerSettingsProvider(this._repository) {
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
      // TODO: Load categories from API if available in user model
      // For now, categories are managed locally
    }
  }

  // Load data
  Future<void> loadSellerData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _repository.getSellerProfile();
      if (_currentUser != null) {
        _updateControllersFromUser();
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> saveChanges() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final updates = <String, dynamic>{};
      if (nameController.text.isNotEmpty)
        updates['name'] = nameController.text.trim();
      if (emailController.text.isNotEmpty)
        updates['email'] = emailController.text.trim();
      if (phoneController.text.isNotEmpty) {
        final phoneDigits = phoneController.text.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        if (phoneDigits.isNotEmpty)
          updates['phone'] = int.tryParse(phoneDigits);
      }
      if (shopNameController.text.isNotEmpty)
        updates['shopName'] = shopNameController.text.trim();
      if (businessNameController.text.isNotEmpty)
        updates['businessName'] = businessNameController.text.trim();
      if (descriptionController.text.isNotEmpty)
        updates['businessDescription'] = descriptionController.text.trim();
      if (addressController.text.isNotEmpty)
        updates['address'] = addressController.text.trim();
      if (ibanController.text.isNotEmpty)
        updates['iban'] = ibanController.text.trim();

      final files = <Map<String, dynamic>>[];
      if (_newShopLogo != null) {
        files.add({
          'field': 'shopLogo',
          'path': _newShopLogo!.path,
          'filename': 'shopLogo-${DateTime.now().millisecondsSinceEpoch}.jpg',
        });
      }
      if (_newShopBanner != null) {
        files.add({
          'field': 'shopBanner',
          'path': _newShopBanner!.path,
          'filename': 'shopBanner-${DateTime.now().millisecondsSinceEpoch}.jpg',
        });
      }

      _currentUser = await _repository.updateSellerProfile(
        updates: updates,
        files: files.isNotEmpty ? files : null,
      );

      _updateControllersFromUser();
      _successMessage = 'Profile updated successfully!';
      _isEditing = false;
      _clearNewImages();

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Image picking
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
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking shop logo: $e';
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
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking shop banner: $e';
      notifyListeners();
    }
  }

  void _clearNewImages() {
    _newShopLogo = null;
    _newShopBanner = null;
  }

  // Refresh
  Future<void> refreshProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _repository.refreshProfile();
      _updateControllersFromUser();
      _successMessage = 'Profile refreshed!';

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh profile: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _repository.logout();

      _currentUser = null;
      _clearNewImages();

      _isLoading = false;
      notifyListeners();

      return success;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle editing
  void setEditing(bool value) {
    _isEditing = value;
    if (!value) {
      _updateControllersFromUser();
      _clearNewImages();
    }
    notifyListeners();
  }

  // Clear messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Category management
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
    super.dispose();
  }
}
