import 'package:flutter/foundation.dart';
import '../models/shop_model.dart';
import '../services/shop_service.dart';

class SellerSettingsViewModel with ChangeNotifier {
  final ShopService _shopService;

  ShopSeller _shop;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  SellerSettingsViewModel(this._shopService, this._shop);

  ShopSeller get shop => _shop;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> loadShopData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _shop = await _shopService.getShopData();
      _error = null;
    } catch (e) {
      _error = 'Failed to load shop data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateShopData(ShopSeller updatedShop) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _shopService.updateShopData(updatedShop);
      _shop = updatedShop;
      _error = null;
    } catch (e) {
      _error = 'Failed to update shop data';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void updateDescription(String description) {
    _shop = _shop.copyWith(description: description);
    notifyListeners();
  }
}
