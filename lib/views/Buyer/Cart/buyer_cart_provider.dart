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

  // In your ViewModel or ProductRepository
  Future<Map<String, dynamic>?> addToCart({
    required String serviceId,
    int? quantity,
    String? selectedVariant,
    String? selectedSize,
    required String productType, // Add productType parameter
  }) async {
    try {
      // Check product type before proceeding (handle both singular and plural)
      final normalizedProductType = productType.toLowerCase();
      if (normalizedProductType.contains('customize')) {
        throw Exception(
          'Customize Products require a visit request. Please use the "Request Visit" button.',
        );
      }

      final finalQuantity = quantity ?? _selectedQuantity;
      final finalVariant = selectedVariant ?? _selectedVariant;
      final finalSize = selectedSize ?? _selectedSize;

      log('🛒 Adding to cart:');
      log('   Service ID: $serviceId');
      log('   Product Type: $productType');
      log('   Quantity: $finalQuantity');

      final result = await _cartService.addToCartService(
        serviceId: serviceId,
        quantity: finalQuantity,
        selectedVariant: finalVariant,
        selectedSize: finalSize,
      );

      if (result['success'] == false) {
        final errorMessage = result['message'] ?? 'Failed to add to cart';
        log('❌ Add to cart failed: $errorMessage');
        throw Exception(errorMessage);
      }

      await loadCart();
      resetSelection();

      return result;
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

  Future<void> removeFromCart(String itemId) async {
    try {
      await _cartService.removeFromCart(itemId);

      // Reload cart
      await loadCart();
    } catch (error) {
      log('❌ Remove from cart error: $error');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();

      // Clear local cart
      _cart = null;
      _cartStreamController.add(null);
      notifyListeners();
    } catch (error) {
      log('❌ Clear cart error: $error');
      rethrow;
    }
  }

  Future<void> refreshCart() async {
    await loadCart();
  }

  // Buy Now - Direct purchase without adding to cart
  Future<Map<String, dynamic>> buyNow({
    required String serviceId,
    required int quantity,
    bool useSalePrice = false,
    String paymentMethod = 'card',
    List<Map<String, String>>? selectedVariants,
    Map<String, dynamic>? orderDetails,
    String? requirements, // For backward compatibility
  }) async {
    try {
      log('🛒 Buy Now: $serviceId, quantity: $quantity');
      final result = await _cartService.placeOrder(
        serviceId: serviceId,
        quantity: quantity,
        useSalePrice: useSalePrice,
        paymentMethod: paymentMethod,
        selectedVariants: selectedVariants,
        orderDetails: orderDetails,
        requirements: requirements,
      );
      return result;
    } catch (error) {
      log('❌ Buy Now error: $error');
      rethrow;
    }
  }

  List<Map<String, String>> _buildVariantsForCartItem(BuyerCartItem item) {
    // Prefer API-native selectedVariants if present
    final existing = item.selectedVariants ?? const <Map<String, String>>[];
    final cleaned = existing
        .where(
          (v) =>
              (v['type'] ?? '').trim().isNotEmpty &&
              (v['value'] ?? '').trim().isNotEmpty,
        )
        .map((v) => {'type': v['type']!.trim(), 'value': v['value']!.trim()})
        .toList();
    if (cleaned.isNotEmpty) return cleaned;

    // Backward compatibility: build from old single fields
    final variants = <Map<String, String>>[];
    if (item.selectedSize != null && item.selectedSize!.trim().isNotEmpty) {
      variants.add({'type': 'size', 'value': item.selectedSize!.trim()});
    }
    if (item.selectedVariant != null &&
        item.selectedVariant!.trim().isNotEmpty) {
      // If backend expects different types (finish/material/color), prefer sending "finish"
      // since that's what your Postman example uses.
      variants.add({'type': 'finish', 'value': item.selectedVariant!.trim()});
    }
    return variants;
  }

  /// Checkout Cart - place orders for ALL cart items (multi-product)
  ///
  /// This will call POST /api/buyer/orders (fallback to /api/orders) once per cart item.
  /// If all succeed, it clears the cart.
  Future<Map<String, dynamic>> checkoutCart({
    bool useSalePrice = false,
    String paymentMethod = 'card',
    Map<String, dynamic>? orderDetails,
  }) async {
    if (cartItems.isEmpty) {
      return {'success': false, 'message': 'Your cart is empty'};
    }

    // Validate stock again just in case
    final outOfStock = outOfStockItems;
    if (outOfStock.isNotEmpty) {
      return {
        'success': false,
        'message': 'Some items are out of stock',
        'outOfStockCount': outOfStock.length,
      };
    }

    final results = <Map<String, dynamic>>[];
    int successCount = 0;
    final totalCount = cartItems.length;

    for (final item in cartItems) {
      final sid = (item.serviceId ?? item.productId).toString();
      final variants = _buildVariantsForCartItem(item);

      try {
        final res = await _cartService.placeOrder(
          serviceId: sid,
          quantity: item.quantity,
          useSalePrice: useSalePrice,
          paymentMethod: paymentMethod,
          selectedVariants: variants.isEmpty ? null : variants,
          orderDetails: orderDetails,
        );
        results.add(res);
        if (res['success'] == true) successCount++;
      } catch (e) {
        results.add({
          'success': false,
          'message': e.toString(),
          'serviceId': sid,
        });
      }
    }

    final allSucceeded = successCount == totalCount;
    if (allSucceeded) {
      await clearCart();
    } else {
      // Keep cart items so user can retry; refresh local cart state.
      await loadCart();
    }

    return {
      'success': allSucceeded,
      'successCount': successCount,
      'totalCount': totalCount,
      'results': results,
      'message': allSucceeded
          ? 'Order placed for all items'
          : 'Order placed for $successCount of $totalCount items',
    };
  }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  bool isProductInCart(String serviceId) {
    // Changed from productId to serviceId
    log('Checking if product is in cart: $serviceId');
    log('Cart items: ${cartItems.map((item) => item.serviceId).toList()}');
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
