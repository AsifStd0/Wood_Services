// view_models/shop_settings_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/views/Seller/data/models/seller_setting_model.dart';

class ShopSettingsViewModel with ChangeNotifier {
  SellerShopModel _shop;
  bool _isLoading = false;
  String? _errorMessage;

  SellerShopModel get shop => _shop;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ShopSettingsViewModel()
    : _shop = SellerShopModel(
        shopName: "Crafty Creations",
        description: "Tell us about your shop...",
        rating: 4.8,
        reviewCount: 120,
        categories: ["Handmade Jewelry"],
        deliveryLeadTime: "1-3 Business Days",
        returnPolicy: "30-Day Returns",
        isVerified: true,
      );

  void updateShopName(String name) {
    _shop = _shop.copyWith(shopName: name);
    notifyListeners();
  }

  void updateDescription(String description) {
    _shop = _shop.copyWith(description: description);
    notifyListeners();
  }

  void updateBannerImage(String imagePath) {
    _shop = _shop.copyWith(bannerImage: imagePath);
    notifyListeners();
  }

  void updateDeliveryTime(String time) {
    _shop = _shop.copyWith(deliveryLeadTime: time);
    notifyListeners();
  }

  void updateReturnPolicy(String policy) {
    _shop = _shop.copyWith(returnPolicy: policy);
    notifyListeners();
  }

  Future<void> saveChanges() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Save logic here
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to save changes";
      notifyListeners();
    }
  }

  void uploadDocuments() {
    // Implement document upload logic
  }

  void previewShop() {
    // Implement shop preview logic
  }
}
