// lib/providers/cart_provider.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/views/Buyer/payment/cart_data/cart_item_model.dart';
import 'package:wood_service/core/services/buyer_local_storage_service_impl.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModelData> _cartItems = [];
  Map<String, dynamic> _cartSummary = {
    'subtotal': 0.0,
    'shippingFee': 0.0,
    'tax': 0.0,
    'total': 0.0,
    'pendingRequests': 0,
  };
  bool _isLoading = false;
  String _errorMessage = '';

  List<CartItemModelData> get cartItems => _cartItems;
  Map<String, dynamic> get cartSummary => _cartSummary;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final BuyerLocalStorageServiceImpl _storage = BuyerLocalStorageServiceImpl();
  static const String baseUrl = 'http://192.168.18.107:5001/api';

  String? _cachedToken;

  Future<void> initialize() async {
    await _storage.initialize();
    _cachedToken = await _storage.getBuyerToken();
    print(
      '🛒 CartProvider initialized. Token: ${_cachedToken != null ? "EXISTS" : "NULL"}',
    );
  }

  Future<String?> _getToken() async {
    if (_cachedToken == null) {
      _cachedToken = await _storage.getBuyerToken();
    }
    return _cachedToken;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _handleApiError(dynamic e, String operation) async {
    _errorMessage = 'Error $operation: ${e.toString()}';
    _isLoading = false;
    notifyListeners();

    // Check if token expired
    if (e.toString().contains('401') || e.toString().contains('token')) {
      await _clearTokenCache();
    }
  }

  Future<void> _clearTokenCache() async {
    _cachedToken = null;
    await _storage.buyerLogout();
  }

  // ========== CART OPERATIONS ==========

  Future<void> fetchCart() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/buyer/cart'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (data['cart'] != null && data['cart']['items'] != null) {
            _cartItems = (data['cart']['items'] as List)
                .map((item) => CartItemModelData.fromJson(item))
                .toList();

            // Update cart summary
            _cartSummary = {
              'subtotal': data['cart']['subtotal'] ?? 0.0,
              'shippingFee': data['cart']['shippingFee'] ?? 0.0,
              'tax': data['cart']['tax'] ?? 0.0,
              'total': data['cart']['total'] ?? 0.0,
              'pendingRequests': data['cart']['pendingRequests'] ?? 0,
            };
          } else {
            _cartItems = [];
            _cartSummary = {
              'subtotal': 0.0,
              'shippingFee': 0.0,
              'tax': 0.0,
              'total': 0.0,
              'pendingRequests': 0,
            };
          }
        }
      } else {
        _errorMessage = 'Failed to fetch cart: ${response.statusCode}';
      }
    } catch (e) {
      await _handleApiError(e, 'fetching cart');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
    String? selectedVariant,
    String? selectedSize,
  }) async {
    try {
      log('message');
      _isLoading = true;
      notifyListeners();

      final headers = await _getHeaders();
      log('message $headers');
      final response = await http.post(
        Uri.parse('$baseUrl/buyer/cart/add'),
        headers: headers,
        body: json.encode({
          'productId': productId,
          'quantity': quantity,
          'selectedVariant': selectedVariant,
          'selectedSize': selectedSize,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        log('status code ${response.body}');
        // Refresh cart after adding
        await fetchCart();
        return {'success': true, 'message': data['message'], 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add to cart',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      await _handleApiError(e, 'adding to cart');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/buyer/cart/update/$itemId'),
        headers: headers,
        body: json.encode({'quantity': newQuantity}),
      );

      if (response.statusCode == 200) {
        await fetchCart();
      } else {
        _errorMessage = 'Failed to update quantity';
        notifyListeners();
      }
    } catch (e) {
      await _handleApiError(e, 'updating quantity');
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/buyer/cart/remove/$itemId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await fetchCart();
      } else {
        _errorMessage = 'Failed to remove item';
        notifyListeners();
      }
    } catch (e) {
      await _handleApiError(e, 'removing item');
    }
  }

  Future<void> clearCart() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/buyer/cart/clear'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        _cartItems.clear();
        _cartSummary = {
          'subtotal': 0.0,
          'shippingFee': 0.0,
          'tax': 0.0,
          'total': 0.0,
          'pendingRequests': 0,
        };
        notifyListeners();
      } else {
        _errorMessage = 'Failed to clear cart';
        notifyListeners();
      }
    } catch (e) {
      await _handleApiError(e, 'clearing cart');
    }
  }

  // ========== REQUEST OPERATIONS ==========

  Future<Map<String, dynamic>> requestBuy({
    required List<String> itemIds,
    String? buyerNotes,
    String? deliveryAddress,
    String paymentMethod = 'cod',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/buyer/cart/request/buy'),
        headers: headers,
        body: json.encode({
          'itemIds': itemIds,
          'buyerNotes': buyerNotes,
          'deliveryAddress': deliveryAddress,
          'paymentMethod': paymentMethod,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await fetchCart();
        return {
          'success': true,
          'message': data['message'],
          'orders': data['orders'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to process request',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      await _handleApiError(e, 'requesting buy');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== HELPER METHODS ==========
  // ========== ORDER DETAILS ==========

  Future<Map<String, dynamic>> getRequestDetails(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/buyer/cart/requests/$orderId'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'request': data['request'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch order details',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      await _handleApiError(e, 'fetching order details');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCartItems(List<CartItemModelData> items) {
    _cartItems = items;
    notifyListeners();
  }

  void setCartSummary(Map<String, dynamic> summary) {
    _cartSummary = summary;
    notifyListeners();
  }

  void markItemAsRequested(String itemId) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _cartItems[index].isRequested = true;
      notifyListeners();
    }
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // Refresh token
  Future<void> refreshToken(String newToken) async {
    _cachedToken = newToken;
    await _storage.saveBuyerToken(newToken);
  }

  // Logout
  Future<void> logout() async {
    await _clearTokenCache();
    _cartItems.clear();
    _cartSummary = {
      'subtotal': 0.0,
      'shippingFee': 0.0,
      'tax': 0.0,
      'total': 0.0,
      'pendingRequests': 0,
    };
    notifyListeners();
  }

  // Get cart item count
  int get cartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get total amount
  double get cartTotal {
    return _cartSummary['total'] ?? 0.0;
  }

  // // Find item by product ID
  // CartItemModelData? findItemByProductId(String productId) {
  //   return _cartItems.firstWhere(
  //     (item) => item.productId == productId,
  //     orElse: () => null,
  //   );
  // }

  // Check if product is in cart
  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  // Update cart summary
  void updateCartSummary(Map<String, dynamic> newSummary) {
    _cartSummary.addAll(newSummary);
    notifyListeners();
  }
}
