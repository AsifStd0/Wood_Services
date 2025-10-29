// view_models/shop_settings_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/shop_model.dart';

class ShopSettingsViewModel with ChangeNotifier {
  ShopModel _shop = ShopModel(
    sellerId: '',
    shopName: 'Asif Khan',
    ownerName: 'Asif Khan',
    description: 'Description is here about ..... shop',
    categories: ['Handmade Jewelry'],
    phoneNumber: '+1234567890',
    email: 'asif@example.com',
    address: '123 Main Street, City, Country',
  );

  ShopModel get shop => _shop;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  // Setters
  void setShopName(String name) {
    _shop = _shop.copyWith(shopName: name);
    notifyListeners();
  }

  void setOwnerName(String name) {
    _shop = _shop.copyWith(ownerName: name);
    notifyListeners();
  }

  void setDescription(String description) {
    _shop = _shop.copyWith(description: description);
    notifyListeners();
  }

  void setBannerImage(String imageUrl) {
    _shop = _shop.copyWith(bannerImage: imageUrl);
    notifyListeners();
  }

  void setLogoImage(String imageUrl) {
    _shop = _shop.copyWith(logoImage: imageUrl);
    notifyListeners();
  }

  void setCategories(List<String> categories) {
    _shop = _shop.copyWith(categories: categories);
    notifyListeners();
  }

  void setDeliveryLeadTime(int days) {
    _shop = _shop.copyWith(deliveryLeadTime: days);
    notifyListeners();
  }

  void setReturnPolicy(String policy) {
    _shop = _shop.copyWith(returnPolicy: policy);
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    _shop = _shop.copyWith(phoneNumber: phone);
    notifyListeners();
  }

  void setEmail(String email) {
    _shop = _shop.copyWith(email: email);
    notifyListeners();
  }

  void setAddress(String address) {
    _shop = _shop.copyWith(address: address);
    notifyListeners();
  }

  void addDocument(ShopDocument document) {
    final updatedDocuments = List<ShopDocument>.from(_shop.documents)
      ..add(document);
    _shop = _shop.copyWith(documents: updatedDocuments);
    notifyListeners();
  }

  void removeDocument(String documentId) {
    final updatedDocuments = List<ShopDocument>.from(_shop.documents)
      ..removeWhere((doc) => doc.id == documentId);
    _shop = _shop.copyWith(documents: updatedDocuments);
    notifyListeners();
  }

  void setEditing(bool editing) {
    _isEditing = editing;
    notifyListeners();
  }

  // Validation
  bool get isFormValid {
    return _shop.shopName.isNotEmpty &&
        _shop.ownerName.isNotEmpty &&
        _shop.description.isNotEmpty &&
        _shop.phoneNumber.isNotEmpty &&
        _shop.email.isNotEmpty &&
        _shop.address.isNotEmpty;
  }

  // Actions
  Future<bool> saveChanges() async {
    if (!isFormValid) {
      _errorMessage = 'Please fill all required fields';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _shop = _shop.copyWith(updatedAt: DateTime.now());
      _isEditing = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save changes: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadShopData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call to load shop data
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API call
      _shop = ShopModel(
        sellerId: 'seller_123',
        shopName: 'Asif Khan Handmade',
        ownerName: 'Asif Khan',
        description:
            'Specializing in handmade jewelry and custom wood crafts. We create unique pieces with attention to detail and quality craftsmanship.',
        bannerImage: null,
        logoImage: null,
        rating: 4.5,
        reviewCount: 24,
        categories: ['Handmade Jewelry', 'Wood Crafts', 'Custom Orders'],
        deliveryLeadTime: 7,
        returnPolicy: '30 days',
        isVerified: true,
        phoneNumber: '+1 (555) 123-4567',
        email: 'asif@handmadecrafts.com',
        address: '123 Artisan Street, Craftville, CA 90210',
        documents: [
          ShopDocument(
            id: 'doc1',
            name: 'Business License',
            url: '',
            type: 'license',
            uploadDate: DateTime.now().subtract(const Duration(days: 30)),
            isVerified: true,
          ),
          ShopDocument(
            id: 'doc2',
            name: 'Tax Certificate',
            url: '',
            type: 'tax_certificate',
            uploadDate: DateTime.now().subtract(const Duration(days: 25)),
            isVerified: true,
          ),
        ],
      );
    } catch (e) {
      _errorMessage = 'Failed to load shop data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
