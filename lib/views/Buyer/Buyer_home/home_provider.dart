// view_models/buyer_home_viewmodel.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_product_service.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';

class BuyerHomeViewModel extends ChangeNotifier {
  final BuyerProductService _productService = BuyerProductService();
  final FavoriteProvider _favoriteProvider;

  // Authentication
  String? _authToken;
  String? get authToken => _authToken;
  bool get isLoggedIn => _authToken != null && _authToken!.isNotEmpty;

  // Product State
  List<BuyerProductModel> _products = [];
  List<BuyerProductModel> get products => _products;

  // Loading & Error State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;
  bool get hasError => _error != null;

  // UI State
  int _currentSliderIndex = 0;
  int get currentSliderIndex => _currentSliderIndex;

  String? _selectedOption;
  String? get selectedOption => _selectedOption;

  // ========== CATEGORIES & FILTERS DATA ==========
  final List<Category> _categories = [
    Category(name: "Living Room", isSelected: false),
    Category(name: "Dining Room", isSelected: false),
    Category(name: "Bedroom", isSelected: false),
    Category(name: "Entryway", isSelected: false),
  ];

  final List<Category> _filter = [
    Category(name: "Sofa", isSelected: false),
    Category(name: "Tv Table", isSelected: false),
    Category(name: "Lights", isSelected: false),
    Category(name: "Bed", isSelected: false),
  ];

  final List<String> _allOptions = [
    "Indoor",
    "Outdoor",
    "Ready Product",
    "Customize Product",
  ];

  // Getters for UI data
  List<Category> get categories => _categories;
  List<Category> get filter => _filter;
  List<String> get allOptions => _allOptions;

  // ========== ADVANCED FILTERS ==========
  bool _showMoreFilters = false;
  String? _selectedCity;
  double _minPrice = 0;
  double _maxPrice = 10000;
  bool _freeDelivery = false;
  bool _onSale = false;
  String? _selectedProvider;
  String? _selectedColor;

  bool get showMoreFilters => _showMoreFilters;
  String? get selectedCity => _selectedCity;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get freeDelivery => _freeDelivery;
  bool get onSale => _onSale;
  String? get selectedProvider => _selectedProvider;
  String? get selectedColor => _selectedColor;

  // ========== CONSTRUCTOR ==========
  BuyerHomeViewModel(this._favoriteProvider);

  // ========== AUTH METHODS ==========
  void setAuthToken(String token) {
    _authToken = token;
    _favoriteProvider.setToken(token);
    notifyListeners();
  }

  void clearAuthToken() {
    _authToken = null;
    _favoriteProvider.setToken(null);
    notifyListeners();
  }

  // ========== PRODUCT METHODS ==========
  Future<void> loadProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();

      if (_authToken != null) {
        final productIds = _products.map((p) => p.id).toList();
        await _favoriteProvider.loadFavoriteStatusForProducts(productIds);
      }
      log('✅ Loaded ${_products.toString()} products');
    } catch (e) {
      _error = 'Failed to load products: $e';
      log('❌ Product loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }

  // ========== FAVORITE METHODS ==========
  bool isProductFavorited(String productId) {
    return _favoriteProvider.isProductFavorited(productId);
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      await _favoriteProvider.toggleFavorite(productId);

      // Update local product
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final isFavorited = _favoriteProvider.isProductFavorited(productId);
        _products[index] = _products[index].copyWith(isFavorited: isFavorited);
        notifyListeners();
      }
    } catch (e) {
      log('❌ Toggle favorite error: $e');
      rethrow;
    }
  }

  // ========== CATEGORY & FILTER SELECTION ==========
  void selectCategory(int index) {
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(isSelected: i == index);
    }
    notifyListeners();
  }

  void selectFilter(int index) {
    for (int i = 0; i < _filter.length; i++) {
      _filter[i] = _filter[i].copyWith(isSelected: i == index);
    }
    notifyListeners();
  }

  void selectOption(String option) {
    _selectedOption = option;
    notifyListeners();
  }

  bool isSelected(String option) => _selectedOption == option;

  // ========== UI STATE METHODS ==========
  void updateSliderIndex(int index) {
    _currentSliderIndex = index;
    notifyListeners();
  }

  // ========== ADVANCED FILTER METHODS ==========
  void toggleMoreFilters() {
    _showMoreFilters = !_showMoreFilters;
    notifyListeners();
  }

  void setCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setFreeDelivery(bool value) {
    _freeDelivery = value;
    notifyListeners();
  }

  void setOnSale(bool value) {
    _onSale = value;
    notifyListeners();
  }

  void setProvider(String? provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  void setColor(String? color) {
    _selectedColor = color;
    notifyListeners();
  }

  void resetAllFilters() {
    // Reset categories
    for (var category in _categories) {
      category = category.copyWith(isSelected: false);
    }

    // Reset filter
    for (var filterItem in _filter) {
      filterItem = filterItem.copyWith(isSelected: false);
    }

    // Reset advanced filters
    _selectedOption = null;
    _selectedCity = null;
    _minPrice = 0;
    _maxPrice = 10000;
    _freeDelivery = false;
    _onSale = false;
    _selectedProvider = null;
    _selectedColor = null;

    notifyListeners();
  }

  // ========== FILTERED PRODUCTS ==========
  List<BuyerProductModel> get filteredProducts {
    return _products.where((product) {
      // Price filter
      if (product.finalPrice < _minPrice || product.finalPrice > _maxPrice) {
        return false;
      }

      // Sale filter
      if (_onSale && !product.hasDiscount) {
        return false;
      }

      // City filter
      if (_selectedCity != null) {
        return false;
      }

      // Color filter
      if (_selectedColor != null) {
        // You need to add color property to your BuyerProductModel
        // if (product.color != _selectedColor) return false;
      }

      // Provider filter
      if (_selectedProvider != null && _selectedProvider != 'All Providers') {
        // You need to add provider/seller property to your BuyerProductModel
        // if (product.provider != _selectedProvider) return false;
      }

      return true;
    }).toList();
  }

  // ! *********
  // ! *********
  // ! *********
  // ! *********
  // ! *********
  // Add visit request state
  Map<String, String> _visitRequestStatus = {}; // sellerId -> status
  bool _isRequestingVisit = false;
  String? _visitRequestError;
  // Getter for visit request status
  String? getVisitStatusForSeller(String sellerId) {
    return _visitRequestStatus[sellerId];
  }

  bool get isRequestingVisit => _isRequestingVisit;
  String? get visitRequestError => _visitRequestError;

  // In your BuyerHomeViewModel

  Future<Map<String, dynamic>> requestVisitToShop({
    required String sellerId,
    required String shopName,
    String? message,
    String? preferredDate,
    String? preferredTime,
    BuildContext? context,
  }) async {
    try {
      _isRequestingVisit = true;
      _visitRequestError = null;
      notifyListeners();

      final response = await _productService.requestVisit(
        sellerId: sellerId,
        message: message,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
      );

      // Check if response indicates existing request
      if (response.containsKey('hasExistingRequest') &&
          response['hasExistingRequest'] == true) {
        return {'hasExistingRequest': true, 'message': response['message']};
      }

      // Update status
      _visitRequestStatus[sellerId] = 'pending';

      // Show success message
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Visit request sent!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return response;
    } catch (error) {
      _visitRequestError = error.toString();

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      rethrow;
    } finally {
      _isRequestingVisit = false;
      notifyListeners();
    }
  }

  // Cancel visit request
  Future<void> cancelShopVisit({
    required String sellerId,
    required String requestId,
    BuildContext? context,
  }) async {
    try {
      final response = await _productService.cancelVisitRequest(
        sellerId: sellerId,
        requestId: requestId,
      );

      // Remove status
      _visitRequestStatus.remove(sellerId);

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Visit request cancelled'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Load existing visit requests
  Future<void> loadMyVisitRequests() async {
    try {
      final requests = await _productService.getMyVisitRequests();

      // Update status for each seller
      for (final request in requests) {
        final sellerId = request['seller']?['id']?.toString();
        final status = request['status']?.toString();
        if (sellerId != null && status != null) {
          _visitRequestStatus[sellerId] = status;
        }
      }

      notifyListeners();
    } catch (error) {
      print('Error loading visit requests: $error');
    }
  }
  // In your BuyerHomeViewModel class, add this method:

  Future<List<Map<String, dynamic>>> getMyVisitRequests() async {
    try {
      // If you already have this method in your product service, call it:
      return await _productService.getMyVisitRequests();
    } catch (error) {
      print('Error getting visit requests: $error');
      return [];
    }
  }
}

// ========== CATEGORY MODEL ==========
class Category {
  final String name;
  bool isSelected;

  Category({required this.name, required this.isSelected});

  Category copyWith({String? name, bool? isSelected}) {
    return Category(
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
