// view_models/buyer_home_viewmodel.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_product_service.dart';
import 'package:wood_service/views/Buyer/Buyer_home/product_filter_model.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';

class BuyerHomeViewProvider extends ChangeNotifier {
  final BuyerProductService _productService = locator<BuyerProductService>();
  final FavoriteProvider _favoriteProvider;

  BuyerHomeViewProvider({FavoriteProvider? favoriteProvider})
    : _favoriteProvider = favoriteProvider ?? FavoriteProvider();

  // Authentication
  String? _authToken;
  String? get authToken => _authToken;
  bool get isLoggedIn => _authToken != null && _authToken!.isNotEmpty;

  // Product State
  List<BuyerProductModel> _products = [];
  List<BuyerProductModel> get products => _products;

  // Store all products (unfiltered) for cascading filters
  List<BuyerProductModel> _allProducts = [];
  List<BuyerProductModel> get allProducts => _allProducts;

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

  // ========== FILTER STATE ==========
  ProductFilterModel _currentFilter = ProductFilterModel();

  ProductFilterModel get currentFilter => _currentFilter;

  // ========== EXTRACTED DATA FROM PRODUCTS ==========
  /// Get unique categories from ALL products (for initial category dropdown)
  List<String> getAllAvailableCategories() {
    // Use all products if available, otherwise use current products
    final productsToUse = _allProducts.isNotEmpty ? _allProducts : _products;
    final categories = productsToUse
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  /// Get unique categories from current products (filtered)
  List<String> get availableCategories {
    final categories = _products
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  /// Get unique tags from products in the selected category (cascading filter)
  List<String> getAvailableTagsForCategory(String? category) {
    // If no category selected, show tags from all products
    List<BuyerProductModel> productsToUse;
    if (category == null || category.isEmpty) {
      productsToUse = _allProducts.isNotEmpty ? _allProducts : _products;
    } else {
      // Filter products by category
      productsToUse = (_allProducts.isNotEmpty ? _allProducts : _products)
          .where((p) => p.category == category)
          .toList();
    }

    final allTags = <String>[];
    for (var product in productsToUse) {
      allTags.addAll(product.tags);
    }
    final uniqueTags = allTags.toSet().toList();
    uniqueTags.sort();
    return uniqueTags;
  }

  /// Get unique tags from current products
  List<String> get availableTags {
    final allTags = <String>[];
    for (var product in _products) {
      allTags.addAll(product.tags);
    }
    final uniqueTags = allTags.toSet().toList();
    uniqueTags.sort();
    return uniqueTags;
  }

  /// Get user location from storage
  String? get userLocation {
    try {
      final storage = locator<UnifiedLocalStorageServiceImpl>();
      final user = storage.getUserModel();
      if (user?.address != null) {
        // If address is a Map, extract city/state
        if (user!.address is Map) {
          final addressMap = user.address as Map;
          final city = addressMap['city']?.toString();
          final state = addressMap['state']?.toString();
          if (city != null && state != null) {
            return '$city, $state';
          } else if (city != null) {
            return city;
          }
        } else if (user.address is String) {
          return user.address as String;
        }
      }
    } catch (e) {
      log('Error getting user location: $e');
    }
    return null;
  }

  // ========== PRODUCT METHODS ==========
  Future<void> loadProducts({
    bool applyFilters = true,
    bool smartFallback = true,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<BuyerProductModel> products = [];

      // Apply filters if enabled
      if (applyFilters && _currentFilter.hasActiveFilters) {
        // Try with all filters first
        products = await _productService.getProducts(
          page: _currentFilter.page,
          limit: _currentFilter.limit,
          category: _currentFilter.category,
          search: _currentFilter.search,
          minPrice: _currentFilter.minPrice,
          maxPrice: _currentFilter.maxPrice,
          location: _currentFilter.location,
          tags: _currentFilter.tags,
          inStock: _currentFilter.inStock,
          sort: _currentFilter.sort,
        );

        // Smart fallback: If no results, try progressively removing filters
        if (smartFallback &&
            products.isEmpty &&
            _currentFilter.hasActiveFilters) {
          log('⚠️ No results with all filters. Trying smart fallback...');

          // Try without search (most restrictive)
          if (_currentFilter.search != null &&
              _currentFilter.search!.isNotEmpty) {
            log('   Trying without search filter...');
            products = await _productService.getProducts(
              page: _currentFilter.page,
              limit: _currentFilter.limit,
              category: _currentFilter.category,
              search: null, // Remove search
              minPrice: _currentFilter.minPrice,
              maxPrice: _currentFilter.maxPrice,
              location: _currentFilter.location,
              tags: _currentFilter.tags,
              inStock: _currentFilter.inStock,
              sort: _currentFilter.sort,
            );
            if (products.isNotEmpty) {
              log('✅ Found ${products.length} products without search filter');
              // Auto-remove search from filter
              _currentFilter = _currentFilter.copyWith(
                search: null,
                clearSearch: true,
              );
            }
          }

          // Try without tags
          if (products.isEmpty &&
              _currentFilter.tags != null &&
              _currentFilter.tags!.isNotEmpty) {
            log('   Trying without tags filter...');
            products = await _productService.getProducts(
              page: _currentFilter.page,
              limit: _currentFilter.limit,
              category: _currentFilter.category,
              search: _currentFilter.search,
              minPrice: _currentFilter.minPrice,
              maxPrice: _currentFilter.maxPrice,
              location: _currentFilter.location,
              tags: null, // Remove tags
              inStock: _currentFilter.inStock,
              sort: _currentFilter.sort,
            );
            if (products.isNotEmpty) {
              log('✅ Found ${products.length} products without tags filter');
              _currentFilter = _currentFilter.copyWith(
                tags: null,
                clearTags: true,
              );
            }
          }

          // Try without location
          if (products.isEmpty &&
              _currentFilter.location != null &&
              _currentFilter.location!.isNotEmpty) {
            log('   Trying without location filter...');
            products = await _productService.getProducts(
              page: _currentFilter.page,
              limit: _currentFilter.limit,
              category: _currentFilter.category,
              search: _currentFilter.search,
              minPrice: _currentFilter.minPrice,
              maxPrice: _currentFilter.maxPrice,
              location: null, // Remove location
              tags: _currentFilter.tags,
              inStock: _currentFilter.inStock,
              sort: _currentFilter.sort,
            );
            if (products.isNotEmpty) {
              log(
                '✅ Found ${products.length} products without location filter',
              );
              _currentFilter = _currentFilter.copyWith(
                location: null,
                clearLocation: true,
              );
            }
          }

          // Try without category
          if (products.isEmpty &&
              _currentFilter.category != null &&
              _currentFilter.category!.isNotEmpty) {
            log('   Trying without category filter...');
            products = await _productService.getProducts(
              page: _currentFilter.page,
              limit: _currentFilter.limit,
              category: null, // Remove category
              search: _currentFilter.search,
              minPrice: _currentFilter.minPrice,
              maxPrice: _currentFilter.maxPrice,
              location: _currentFilter.location,
              tags: _currentFilter.tags,
              inStock: _currentFilter.inStock,
              sort: _currentFilter.sort,
            );
            if (products.isNotEmpty) {
              log(
                '✅ Found ${products.length} products without category filter',
              );
              _currentFilter = _currentFilter.copyWith(
                category: null,
                clearCategory: true,
              );
            }
          }

          // Try without price range
          if (products.isEmpty &&
              (_currentFilter.minPrice != null ||
                  _currentFilter.maxPrice != null)) {
            log('   Trying without price filter...');
            products = await _productService.getProducts(
              page: _currentFilter.page,
              limit: _currentFilter.limit,
              category: _currentFilter.category,
              search: _currentFilter.search,
              minPrice: null, // Remove price filters
              maxPrice: null,
              location: _currentFilter.location,
              tags: _currentFilter.tags,
              inStock: _currentFilter.inStock,
              sort: _currentFilter.sort,
            );
            if (products.isNotEmpty) {
              log('✅ Found ${products.length} products without price filter');
              _currentFilter = _currentFilter.copyWith(
                minPrice: null,
                maxPrice: null,
                clearMinPrice: true,
                clearMaxPrice: true,
              );
            }
          }

          // Try without inStock
          if (products.isEmpty && _currentFilter.inStock != null) {
            log('   Trying without inStock filter...');
            products = await _productService.getProducts(
              page: _currentFilter.page,
              limit: _currentFilter.limit,
              category: _currentFilter.category,
              search: _currentFilter.search,
              minPrice: _currentFilter.minPrice,
              maxPrice: _currentFilter.maxPrice,
              location: _currentFilter.location,
              tags: _currentFilter.tags,
              inStock: null, // Remove inStock
              sort: _currentFilter.sort,
            );
            if (products.isNotEmpty) {
              log('✅ Found ${products.length} products without inStock filter');
              _currentFilter = _currentFilter.copyWith(
                inStock: null,
                clearInStock: true,
              );
            }
          }

          // Last resort: Try with only sort (if any)
          if (products.isEmpty &&
              _currentFilter.sort != null &&
              _currentFilter.sort!.isNotEmpty) {
            log('   Trying with only sort filter...');
            products = await _productService.getProducts(
              page: _currentFilter.page,
              limit: _currentFilter.limit,
              category: null,
              search: null,
              minPrice: null,
              maxPrice: null,
              location: null,
              tags: null,
              inStock: null,
              sort: _currentFilter.sort,
            );
          }

          // Final fallback: Load all products
          if (products.isEmpty) {
            log('   Final fallback: Loading all products without filters');
            products = await _productService.getProducts(
              page: _currentFilter.page,
              limit: _currentFilter.limit,
            );
          }
        }

        _products = products;
      } else {
        _products = await _productService.getProducts(
          page: _currentFilter.page,
          limit: _currentFilter.limit,
        );
      }

      // Store all products for cascading filters (only if no filters applied)
      if (!applyFilters || !_currentFilter.hasActiveFilters) {
        _allProducts = List.from(_products);
      }

      // Sync initial favorite status from product model
      for (var product in _products) {
        _favoriteProvider.syncInitialFavoriteStatus(
          product.id,
          product.isFavorited,
          favoriteId: product.favoriteId,
        );
      }

      // Load favorite status from server to ensure accuracy
      final storage = locator<UnifiedLocalStorageServiceImpl>();
      final token = storage.getToken();
      if (token != null && token.isNotEmpty) {
        final productIds = _products.map((p) => p.id).toList();
        await _favoriteProvider.loadFavoriteStatusForProducts(productIds);
      }
      log('✅ Loaded ${_products.length} products');
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

  // ========== FILTER METHODS ==========
  void updateFilter(ProductFilterModel filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void applyFilters() {
    _currentFilter = _currentFilter.copyWith(page: 1); // Reset to page 1
    loadProducts(applyFilters: true, smartFallback: true);
  }

  void resetFilters() {
    _currentFilter = ProductFilterModel();
    notifyListeners();
    loadProducts(applyFilters: false);
  }

  void setCategory(String? category) {
    _currentFilter = _currentFilter.copyWith(category: category);
    notifyListeners();
  }

  /// Called when category changes - resets dependent filters
  void onCategoryChanged(String? category) {
    // Reset tags when category changes (since tags are now category-specific)
    if (category != null) {
      _currentFilter = _currentFilter.copyWith(tags: null, clearTags: true);
    }
    notifyListeners();
  }

  void setSearch(String? search) {
    _currentFilter = _currentFilter.copyWith(search: search);
    // Don't notify listeners immediately - let debouncing handle it
  }

  /// Set search with debouncing (for real-time search)
  void setSearchDebounced(String? search) {
    _currentFilter = _currentFilter.copyWith(search: search);
    notifyListeners();
  }

  void setPriceRange(double minPrice, double maxPrice) {
    _currentFilter = _currentFilter.copyWith(
      minPrice: minPrice > 0 ? minPrice : null,
      maxPrice: maxPrice > 0 ? maxPrice : null,
    );
    notifyListeners();
  }

  void setLocation(String? location) {
    _currentFilter = _currentFilter.copyWith(location: location);
    notifyListeners();
  }

  void setTags(List<String>? tags) {
    _currentFilter = _currentFilter.copyWith(tags: tags);
    notifyListeners();
  }

  void setInStock(bool? inStock) {
    _currentFilter = _currentFilter.copyWith(inStock: inStock);
    notifyListeners();
  }

  void setSort(String? sort) {
    _currentFilter = _currentFilter.copyWith(sort: sort);
    notifyListeners();
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

    // Filter by productType when Ready Product or Customize Product is selected
    if (option == 'Ready Product' || option == 'Customize Product') {
      _currentFilter = _currentFilter.copyWith(
        // We'll use a custom field for productType filtering
        // Since API might not support productType filter, we'll filter locally
      );
      // Apply local filtering by productType
      notifyListeners();
    } else {
      // Reset productType filter
      notifyListeners();
    }
  }

  /// Filter products by productType (Ready Product or Customize Product)
  void filterByProductType(String? productType) {
    if (productType == null || productType.isEmpty) {
      // Reset filter
      notifyListeners();
      return;
    }

    // This will be handled in the filtered products getter
    _selectedOption = productType;
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

  void setAdvancedPriceRange(double min, double max) {
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
      // ProductType filter (Ready Product / Customize Product)
      if (_selectedOption != null) {
        if (_selectedOption == 'Ready Product' &&
            product.productType != 'Ready Product') {
          return false;
        }
        if (_selectedOption == 'Customize Product' &&
            product.productType != 'Customize Product') {
          return false;
        }
      }

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
  final Map<String, String> _visitRequestStatus = {}; // sellerId -> status
  bool _isRequestingVisit = false;
  String? _visitRequestError;
  // Getter for visit request status
  String? getVisitStatusForSeller(String sellerId) {
    return _visitRequestStatus[sellerId];
  }

  bool get isRequestingVisit => _isRequestingVisit;
  String? get visitRequestError => _visitRequestError;

  // Request visit to shop
  Future<Map<String, dynamic>> requestVisitToShop({
    required String serviceId, // Changed from sellerId to serviceId
    required String shopName,
    String? description, // Changed from message to description (optional)
    String? message, // Keep for backward compatibility, maps to description
    Map<String, dynamic>? address, // NEW: Optional address object
    String? preferredDate,
    String? preferredTime,
    String? specialRequirements, // NEW: Optional special requirements
    BuildContext? context,
  }) async {
    try {
      _isRequestingVisit = true;
      _visitRequestError = null;
      notifyListeners();

      // Use description if provided, otherwise use message (backward compatibility)
      final finalDescription = description ?? message;

      final response = await _productService.requestVisit(
        serviceId: serviceId,
        description: finalDescription,
        address: address,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        specialRequirements: specialRequirements,
      );

      // Check if response indicates existing request
      if (response.containsKey('hasExistingRequest') &&
          response['hasExistingRequest'] == true) {
        return {'hasExistingRequest': true, 'message': response['message']};
      }

      // Update status (use serviceId as key, but also support sellerId for backward compatibility)
      _visitRequestStatus[serviceId] = 'pending';

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
      // final response = await _productService.cancelVisitRequest(
      //   sellerId: sellerId,
      //   requestId: requestId,
      // );

      // Remove status
      _visitRequestStatus.remove(sellerId);

      // if (context != null && context.mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(response['message'] ?? 'Visit request cancelled'),
      //       backgroundColor: Colors.orange,
      //       duration: const Duration(seconds: 3),
      //     ),
      //   );
      // }
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
      // final requests = await _productService.getMyVisitRequests();

      // Update status for each seller
      // for (final request in requests) {
      //   final sellerId = request['seller']?['id']?.toString();
      //   final status = request['status']?.toString();
      //   if (sellerId != null && status != null) {
      //     _visitRequestStatus[sellerId] = status;
      //   }
      // }

      // notifyListeners();
    } catch (error) {
      print('Error loading visit requests: $error');
    }
  }

  // Alias method for backward compatibility (maps sellerId to serviceId)
  Future<Map<String, dynamic>> requestVisit({
    required String sellerId, // This is actually serviceId in the new API
    required String shopName,
    String? message, // Maps to description
    String? description, // NEW: Direct description parameter
    Map<String, dynamic>? address, // NEW: Optional address
    String? preferredDate,
    String? preferredTime,
    String? specialRequirements, // NEW: Optional special requirements
    BuildContext? context,
  }) async {
    // In the new API, sellerId is actually serviceId (product/service ID)
    return await requestVisitToShop(
      serviceId: sellerId, // Pass as serviceId
      shopName: shopName,
      description:
          description ?? message, // Use description if provided, else message
      address: address,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      specialRequirements: specialRequirements,
      context: context,
    );
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
