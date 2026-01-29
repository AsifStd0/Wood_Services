// providers/uploaded_product_provider.dart
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_services.dart';

class UploadedProductProvider extends ChangeNotifier {
  final UploadedProductService _service;

  // State
  List<UploadedProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _statusFilter; // 'active', 'inactive', null for all

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalProducts = 0;
  final int _limit = 10;
  bool _hasMore = true;

  // Getters
  List<UploadedProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalProducts => _totalProducts;
  bool get hasMore => _hasMore;
  bool get isEmpty => _products.isEmpty && !_isLoading;

  UploadedProductProvider({UploadedProductService? service})
    : _service = service ?? locator<UploadedProductService>();

  /// Load products (first page or refresh)
  Future<void> loadProducts({String? status, bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    _statusFilter = status;

    if (refresh) {
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
    }

    notifyListeners();

    try {
      log('📦 Loading products (Page: $_currentPage, Status: $status)');

      final result = await _service.getUploadedProducts(
        page: _currentPage,
        limit: _limit,
        status: status,
      );

      if (result['success'] == true) {
        final newProducts = result['services'] as List<UploadedProductModel>;
        final pagination = result['pagination'] as Map<String, dynamic>;

        if (refresh) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        _totalProducts = pagination['total'] ?? 0;
        _totalPages = pagination['totalPages'] ?? 1;
        _currentPage = pagination['currentPage'] ?? 1;
        _hasMore = _currentPage < _totalPages;

        log('✅ Loaded ${_products.length} products (Total: $_totalProducts)');
        _errorMessage = null;
      } else {
        throw Exception(result['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      log('❌ Error loading products: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more products (pagination)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _currentPage++;
    await loadProducts(status: _statusFilter);
  }

  /// Refresh products
  Future<void> refresh() async {
    await loadProducts(status: _statusFilter, refresh: true);
  }

  /// Filter by status
  Future<void> filterByStatus(String? status) async {
    await loadProducts(status: status, refresh: true);
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      log('🗑️ Deleting product: $productId');

      final success = await _service.deleteProduct(productId);

      if (success) {
        // Remove from list
        _products.removeWhere((p) => p.id == productId);
        _totalProducts--;
        log('✅ Product deleted. Remaining: ${_products.length}');
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      log('❌ Error deleting product: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete product image
  Future<bool> deleteProductImage(String productId, String imageUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      log('🗑️ Deleting product image: $imageUrl');

      final success = await _service.deleteProductImage(productId, imageUrl);

      if (success) {
        // Update the product in the list
        final productIndex = _products.indexWhere((p) => p.id == productId);
        if (productIndex != -1) {
          // Note: We would need to reload the product to get updated images
          // For now, just refresh the list
          await refresh();
        }
        log('✅ Image deleted successfully');
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to delete image');
      }
    } catch (e) {
      log('❌ Error deleting image: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
