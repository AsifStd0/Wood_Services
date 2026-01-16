import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_model.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_services.dart';

class BuyerCartViewModel with ChangeNotifier {
  final BuyerCartService _cartService = BuyerCartService();

  BuyerCartModel? _cart;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Stream controller for real-time updates
  final StreamController<BuyerCartModel?> _cartStreamController =
      StreamController<BuyerCartModel?>.broadcast();

  // Product selection state
  int _selectedQuantity = 1;
  String? _selectedSize;
  String? _selectedVariant;

  // ========== Getters ==========
  BuyerCartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  Stream<BuyerCartModel?>? get cartStream => _cartStreamController.stream;

  List<BuyerCartItem> get cartItems => _cart?.items ?? [];
  int get cartCount => _cart?.totalQuantity ?? 0;
  double get subtotal => _cart?.subtotal ?? 0;
  double get shipping => _cart?.shippingFee ?? 0;
  double get tax => _cart?.tax ?? 0;
  double get total => _cart?.total ?? 0;

  // Product selection getters
  int get selectedQuantity => _selectedQuantity;
  String? get selectedSize => _selectedSize;
  String? get selectedVariant => _selectedVariant;

  // ========== Product Selection Methods ==========
  void updateQuantity(int newQuantity) {
    _selectedQuantity = newQuantity;
    log('🔄 Quantity updated to: ----------- $_selectedQuantity');
    notifyListeners();
  }

  void updateSize(String? size) {
    _selectedSize = size;
    log('📏 Size updated to: $_selectedSize');
    notifyListeners();
  }

  void updateVariant(String? variant) {
    _selectedVariant = variant;
    log('🎨 Variant updated to: $_selectedVariant');
    notifyListeners();
  }

  void resetSelection() {
    _selectedQuantity = 1;
    _selectedSize = null;
    _selectedVariant = null;
    log('🔄 Selection reset');
    notifyListeners();
  }

  // ========== Cart Methods ==========
  Future<void> loadCart() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      log('Calling Cart getCart');
      _cart = await _cartService.getCart();
      _cartStreamController.add(_cart);
      _hasError = false;
    } catch (error) {
      _hasError = true;
      _errorMessage = 'Failed to load cart: $error';
      log('❌ Load cart error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> addToCart({
    required String serviceId, // Changed from productId to serviceId
    int? quantity,
    String? selectedVariant,
    String? selectedSize,
  }) async {
    try {
      final finalQuantity = quantity ?? _selectedQuantity;
      final finalVariant = selectedVariant ?? _selectedVariant;
      final finalSize = selectedSize ?? _selectedSize;

      log('🛒 Adding to cart:');
      log('   Service ID: $serviceId');
      log('   Quantity: $finalQuantity');
      log('   Size: $finalSize');
      log('   Variant: $finalVariant');

      final result = await _cartService.addToCartService(
        serviceId: serviceId, // Changed parameter name
        quantity: finalQuantity,
        selectedVariant: finalVariant,
        selectedSize: finalSize,
      );

      // Check if the result indicates failure
      if (result['success'] == false) {
        final errorMessage = result['message'] ?? 'Failed to add to cart';
        log('❌ Add to cart failed: $errorMessage');
        throw Exception(errorMessage);
      }

      await loadCart();
      resetSelection();

      return result; // Can return null
    } catch (error) {
      log('❌ Add to cart error in VM: $error');
      rethrow;
    }
  }

  Future<void> updateCartItem(String itemId, int newQuantity) async {
    try {
      await _cartService.updateCartItem(itemId: itemId, quantity: newQuantity);

      // Reload cart
      await loadCart();
    } catch (error) {
      log('❌ Update cart item error: $error');
      rethrow;
    }
  }

  // Future<void> removeFromCart(String itemId) async {
  //   try {
  //     await _cartService.removeFromCart(itemId);

  //     // Reload cart
  //     await loadCart();
  //   } catch (error) {
  //     log('❌ Remove from cart error: $error');
  //     rethrow;
  //   }
  // }

  // Future<void> clearCart() async {
  //   try {
  //     await _cartService.clearCart();

  //     // Clear local cart
  //     _cart = null;
  //     _cartStreamController.add(null);
  //     notifyListeners();
  //   } catch (error) {
  //     log('❌ Clear cart error: $error');
  //     rethrow;
  //   }
  // }

  // Future<void> refreshCart() async {
  //   await loadCart();
  // }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  bool isProductInCart(String serviceId) {
    // Changed from productId to serviceId
    return cartItems.any(
      (item) => item.serviceId == serviceId || item.productId == serviceId,
    );
  }

  int getProductQuantityInCart(String serviceId) {
    // Changed from productId to serviceId
    final item = cartItems.firstWhere(
      (item) => item.serviceId == serviceId || item.productId == serviceId,
      orElse: () => BuyerCartItem(
        id: '',
        productId: '',
        serviceId: null,
        quantity: 0,
        price: 0,
        subtotal: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  List<BuyerCartItem> get outOfStockItems {
    return cartItems.where((item) => !item.isInStock).toList();
  }

  bool get allItemsInStock {
    return cartItems.every((item) => item.isInStock);
  }

  void disposeStream() {
    _cartStreamController.close();
  }

  // *****
  double getCurrentProductTotal(BuyerProductModel product) {
    final unitPrice = product.finalPrice;
    final subtotal = unitPrice * _selectedQuantity;
    final taxAmount = (product.taxRate ?? 0) * subtotal / 100;
    return subtotal + taxAmount;
  }
}
