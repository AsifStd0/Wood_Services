// lib/view_models/add_product_view_model.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product.dart';

class AddProductViewModel with ChangeNotifier {
  final ProductRepository _productRepository;

  AddProductViewModel(this._productRepository);

  SellerProduct _product = SellerProduct(
    title: '',
    shortDescription: '',
    longDescription: '',
    tags: [],
  );

  SellerProduct get product => _product;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // Setters for product properties
  void setTitle(String title) {
    _product = _product.copyWith(title: title);
    notifyListeners();
  }

  void setShortDescription(String description) {
    _product = _product.copyWith(shortDescription: description);
    notifyListeners();
  }

  void setLongDescription(String description) {
    _product = _product.copyWith(longDescription: description);
    notifyListeners();
  }

  void setCategory(String category) {
    _product = _product.copyWith(category: category);
    notifyListeners();
  }

  void setTags(List<String> tags) {
    _product = _product.copyWith(tags: tags);
    notifyListeners();
  }

  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Validation
  bool get isFormValid {
    return _product.title.isNotEmpty &&
        _product.shortDescription.isNotEmpty &&
        _product.longDescription.isNotEmpty;
  }

  // Actions
  Future<bool> saveDraft() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productRepository.saveProduct(
        _product.copyWith(isPublished: false, updatedAt: DateTime.now()),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save draft: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> publishProduct() async {
    if (!isFormValid) {
      _errorMessage = 'Please fill all required fields';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productRepository.saveProduct(
        _product.copyWith(
          isPublished: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to publish product: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
