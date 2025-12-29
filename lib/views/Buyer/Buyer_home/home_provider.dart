import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_product_service.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';

class BuyerHomeViewModel with ChangeNotifier {
  final BuyerProductService _productService = BuyerProductService();
  final FavoriteProvider _favoriteProvider;

  String? _authToken;
  String get authToken => _authToken ?? '';
  bool get isLoggedIn => _authToken != null && _authToken!.isNotEmpty;

  int _currentSliderIndex = 0;
  String? _selectedOption;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // API Products
  List<BuyerProductModel> _apiProducts = [];

  // Getters for API data
  List<BuyerProductModel> get apiProducts => _apiProducts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // ✅ Get favorite count from FavoriteProvider
  int get favoriteCount => _favoriteProvider.favoriteCount;

  int get currentSliderIndex => _currentSliderIndex;

  String? get selectedOption => _selectedOption;

  // Constructor with FavoriteProvider
  BuyerHomeViewModel(this._favoriteProvider);

  // Set auth token (call this after login)
  void setAuthToken(String token) {
    _authToken = token;
    log('✅ Auth token set in ViewModel');

    // Also set token in favorite provider
    _favoriteProvider.setToken(token);

    // Load favorite status for products if we have products
    if (_apiProducts.isNotEmpty) {
      final productIds = _apiProducts.map((p) => p.id).toList();
      _favoriteProvider.loadFavoriteStatusForProducts(productIds);
    }

    notifyListeners();
  }

  void clearAuthToken() {
    _authToken = null;
    _favoriteProvider.setToken(null);
    notifyListeners();
  }

  // API Methods
  Future<void> loadProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      log('load products message ----- 1111 2222');
      // Call your API
      _apiProducts = await _productService.getProducts();
      log('✅ Success! Loaded ${_apiProducts.length} products');

      // Load favorite status for these products
      if (_authToken != null && _authToken!.isNotEmpty) {
        final productIds = _apiProducts.map((p) => p.id).toList();
        await _favoriteProvider.loadFavoriteStatusForProducts(productIds);
      }

      _hasError = false;
    } catch (error) {
      _hasError = true;
      _errorMessage = 'Failed to load products: $error';
      print('❌ API Error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ SIMPLIFIED: Toggle favorite using FavoriteProvider
  Future<void> toggleFavorite(String productId) async {
    try {
      await _favoriteProvider.toggleFavorite(productId);

      // Update product in local list with new favorite status
      final index = _apiProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final isFavorited = _favoriteProvider.isProductFavorited(productId);
        final favoriteId = _favoriteProvider.getFavoriteId(productId);

        _apiProducts[index] = _apiProducts[index].copyWith(
          isFavorited: isFavorited,
          favoriteId: favoriteId,
        );

        log('✅ Product $productId favorite status updated to: $isFavorited');
        notifyListeners();
      }
    } catch (error) {
      log('❌ Toggle favorite error in ViewModel: $error');
      rethrow;
    }
  }

  // ✅ Use FavoriteProvider's methods
  bool isProductFavorited(String productId) {
    return _favoriteProvider.isProductFavorited(productId);
  }

  // Get favorite products
  Future<List<BuyerProductModel>> getFavoriteProducts() async {
    try {
      final favoriteProducts = await _favoriteProvider.getFavoriteProducts();

      // Convert FavoriteProduct to BuyerProductModel
      return favoriteProducts.map((fav) {
        return BuyerProductModel(
          id: fav.productId,
          title: fav.title,
          shortDescription: fav.shortDescription,
          longDescription: fav.longDescription ?? '',
          category: fav.category,
          tags: [],
          basePrice: fav.basePrice,
          salePrice: fav.salePrice,
          costPrice: null,
          taxRate: null,
          currency: 'USD',
          hasDiscount: fav.discountPercentage > 0,
          sku: '',
          stockQuantity: fav.stockQuantity,
          lowStockAlert: null,
          weight: null,
          dimensions: null,
          variants: [],
          featuredImage: fav.featuredImage,
          imageGallery: fav.imageGallery,
          status: 'published',
          isActive: true,
          views: fav.views,
          salesCount: fav.salesCount,
          inStock: fav.inStock,
          finalPrice: fav.finalPrice,
          discountPercentage: fav.discountPercentage,
          rating: fav.rating,
          reviewCount: fav.views,
          isFavorited: true,
          favoriteId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          // sellerName : '',
        );
      }).toList();
    } catch (error) {
      log('❌ Get favorite products error: $error');
      return [];
    }
  }

  // ! above favorite ....
  // ....
  // ....
  // ....
  // ....
  // ....
  // ....
  Future<void> refreshProducts() async {
    await loadProducts();
  }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  bool isSelected(String option) => _selectedOption == option;

  void updateSliderIndex(int index) {
    _currentSliderIndex = index;
    notifyListeners();
  }

  void selectCategory(int index) {
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(isSelected: false);
    }
    _categories[index] = _categories[index].copyWith(isSelected: true);
    notifyListeners();
  }

  void selectFilter(int index) {
    for (int i = 0; i < _filter.length; i++) {
      _filter[i] = _filter[i].copyWith(isSelected: false);
    }
    _filter[index] = _filter[index].copyWith(isSelected: true);
    notifyListeners();
  }

  void selectOption(String option) {
    _selectedOption = option;
    notifyListeners();
  }

  // ! ********
  // ! ********
  // ! ********
  // ! ********
  // ! ********
  // ! ********
  // Filter methods
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

  // Your existing categories and filters
  List<Category> _categories = [
    Category(name: "Living Room", isSelected: false),
    Category(name: "Dining Room", isSelected: false),
    Category(name: "Bedroom", isSelected: false),
    Category(name: "Entryway", isSelected: false),
  ];

  List<Category> _filter = [
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

  // Your existing getters
  List<Category> get categories => _categories;
  List<Category> get filter => _filter;
  List<String> get allOptions => _allOptions;

  void resetAllFilters() {
    _selectedCity = null;
    _minPrice = 0;
    _maxPrice = 10000;
    _freeDelivery = false;
    _onSale = false;
    _selectedProvider = null;
    _selectedColor = null;
    notifyListeners();
  }
}
