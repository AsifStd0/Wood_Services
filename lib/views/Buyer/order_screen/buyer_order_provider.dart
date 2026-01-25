import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wood_service/chats/Buyer/buyer_chating.dart';
import 'package:wood_service/views/Buyer/Cart/cart_screen.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_repository.dart';

class BuyerOrderProvider with ChangeNotifier {
  final BuyerOrderRepository _repository;

  List<BuyerOrder> _orders = [];
  List<BuyerOrder> get orders => _orders;

  Map<String, int> _summary = {
    'pending': 0,
    'accepted': 0,
    'declined': 0,
    'completed': 0,
    'total': 0,
  };
  Map<String, int> get summary => _summary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  OrderStatusBuyer? _currentFilter;
  OrderStatusBuyer? get currentFilter => _currentFilter;

  BuyerOrderProvider(this._repository);

  Future<void> loadOrders({OrderStatusBuyer? status}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      log('🔄 Loading orders with filter: $status');

      String? statusParam;
      if (status != null) {
        statusParam = status.toString().split('.').last;
      }
      log('1111');
      _orders = await _repository.getOrders(status: statusParam);
      _currentFilter = status;

      // Load summary if not already loaded
      if (_summary['total'] == 0) {
        await loadOrderSummary();
      }

      log('✅ Loaded ${_orders.length} orders');
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
      log('❌ Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderSummary() async {
    try {
      _summary = await _repository.getOrderSummary();
      log('📊 Order summary loaded: $_summary');
    } catch (e) {
      log('❌ Error loading order summary: $e');
    }
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.cancelOrder(orderId, reason);

      // Remove the cancelled order from the current list
      // Use order.orderId instead of order.id
      _orders.removeWhere((order) => order.orderId == orderId);

      // Refresh the summary counts
      await loadOrderSummary();

      _isLoading = false;
      notifyListeners();

      log('✅ Order cancelled: $orderId');
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to cancel order: $e';
      notifyListeners();

      log('❌ Error cancelling order: $e');
      return false;
    }
  }

  Future<void> markAsReceived(String orderId) async {
    try {
      await _repository.markAsReceived(orderId);
      log('✅ Order marked as received: $orderId');
    } catch (e) {
      log('❌ Error marking order as received: $e');
      rethrow;
    }
  }

  Future<void> submitReview(
    String orderId, {
    required int rating,
    String? comment,
    List<Map<String, dynamic>>? itemReviews,
  }) async {
    try {
      log('orders ----- 00000 ');

      await _repository.submitReview(
        orderId,
        rating: rating,
        comment: comment,
        itemReviews: itemReviews,
      );
      log('orders -----');
      // Update local order
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        // In a real app, you would fetch the updated order
        notifyListeners();
      }

      log('✅ Review submitted for order: $orderId');
    } catch (e) {
      log('❌ Error submitting review: $e');
      rethrow;
    }
  }

  // Add this method to filter orders by status
  List<BuyerOrder> getFilteredOrders(OrderStatusBuyer status) {
    return _orders.where((order) => order.status == status).toList();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  //   final String sellerId;
  // final String sellerName;
  // final String? productId;
  // final String? productName;
  // final String? orderId;
  void startChat(BuildContext context, BuyerOrder order) {
    log('order.items.first.sellerName: ${order.items.first.sellerName}');
    log('order.items.first.productId: ${order.items.first.productId}');
    log('order.items.first.productName: ${order.items.first.productName}');
    log('order.orderId: ${order.orderId}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyerChatScreen(
          sellerId: order.id,
          sellerName: order.items.first.sellerName,
          productId: order.items.first.productId,
          productName: order.items.first.productName,
          orderId: order.orderId,
        ),
      ),
    );
  }
}
