// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Model/cart_item_model.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/cart_services.dart';

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

  final CartServices _cartServices;

  CartProvider(this._cartServices);

  List<CartItemModelData> get cartItems => _cartItems;
  Map<String, dynamic> get cartSummary => _cartSummary;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _cartServices.initialize();
    await fetchCart();
  }

  Future<void> _handleApiError(dynamic e, String operation) async {
    _errorMessage = 'Error $operation: ${e.toString()}';
    _isLoading = false;
    notifyListeners();
  }

  // ========== CART OPERATIONS ==========
  Future<void> fetchCart() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final result = await _cartServices.fetchCart();

      if (result['success'] == true) {
        final data = result['data'];
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
      } else {
        _errorMessage = result['message'] ?? 'Failed to fetch cart';
      }
    } catch (e) {
      _handleApiError(e, 'fetching cart');
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
      _isLoading = true;
      notifyListeners();

      final result = await _cartServices.addToCart(
        productId: productId,
        quantity: quantity,
        selectedVariant: selectedVariant,
        selectedSize: selectedSize,
      );

      if (result['success'] == true) {
        await fetchCart();
      }

      return result;
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
      final result = await _cartServices.updateQuantity(itemId, newQuantity);

      if (result['success'] == true) {
        await fetchCart();
      } else {
        _errorMessage = result['message'] ?? 'Failed to update quantity';
        notifyListeners();
      }
    } catch (e) {
      await _handleApiError(e, 'updating quantity');
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final result = await _cartServices.removeItem(itemId);

      if (result['success'] == true) {
        await fetchCart();
      } else {
        _errorMessage = result['message'] ?? 'Failed to remove item';
        notifyListeners();
      }
    } catch (e) {
      await _handleApiError(e, 'removing item');
    }
  }

  Future<void> clearCart() async {
    try {
      final result = await _cartServices.clearCart();

      if (result['success'] == true) {
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
        _errorMessage = result['message'] ?? 'Failed to clear cart';
        notifyListeners();
      }
    } catch (e) {
      await _handleApiError(e, 'clearing cart');
    }
  }

  Future<Map<String, dynamic>> directBuy({
    required String productId,
    required int quantity,
    String? buyerNotes,
    Map<String, dynamic>? deliveryAddress,
    String paymentMethod = 'cod',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _cartServices.directBuy(
        productId: productId,
        quantity: quantity,
        buyerNotes: buyerNotes,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> requestBuy({
    required List<String> itemIds,
    String? buyerNotes,
    String? deliveryAddress,
    String paymentMethod = 'cod',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _cartServices.requestBuy(
        itemIds: itemIds,
        buyerNotes: buyerNotes,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      if (result['success'] == true) {
        await fetchCart();
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== ORDER DETAILS ==========

  Future<Map<String, dynamic>> getRequestDetails(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _cartServices.getRequestDetails(orderId);
      return result;
    } catch (e) {
      await _handleApiError(e, 'fetching order details');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== HELPER METHODS ==========

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
    return await _cartServices.isLoggedIn();
  }

  // Refresh token
  Future<void> refreshToken(String newToken) async {
    await _cartServices.refreshToken(newToken);
  }

  // Logout
  Future<void> logout() async {
    await _cartServices.logout();
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
