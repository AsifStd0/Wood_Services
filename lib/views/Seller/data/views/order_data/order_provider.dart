import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/models/order_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_repository_seller.dart';

class OrdersViewModel with ChangeNotifier {
  final OrderRepository _repository;

  OrdersViewModel(this._repository);

  List<OrderModelSeller> _orders = [];
  List<OrderModelSeller> get orders => _orders;

  List<OrderModelSeller> _filteredOrders = [];
  List<OrderModelSeller> get filteredOrders => _filteredOrders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  OrderStatus? _selectedStatus;
  OrderStatus? get selectedStatus => _selectedStatus;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Statistics
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _acceptedOrders = 0;
  int _completedOrders = 0;

  int get totalOrders => _totalOrders;
  int get pendingOrders => _pendingOrders;
  int get acceptedOrders => _acceptedOrders;
  int get completedOrders => _completedOrders;

  Future<void> loadOrders({String? status, String? type}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      log('🔄 Loading orders from API...');

      // Convert OrderStatus to string for API
      String? statusValue;
      if (_selectedStatus != null) {
        statusValue = _selectedStatus!.value;
      }

      _orders = await _repository.getOrders(status: statusValue, type: type);

      // Load statistics
      await _loadStatistics();

      _applyFilters();
      log('✅ Loaded ${_orders.length} orders');
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
      log('❌ Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _repository.getOrderStatistics();
      _totalOrders = stats['totalOrders'] ?? 0;
      _pendingOrders = stats['pendingOrders'] ?? 0;
      _acceptedOrders = stats['acceptedOrders'] ?? 0;
      _completedOrders = stats['completedOrders'] ?? 0;
    } catch (e) {
      log('❌ Error loading statistics: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      log('🔄 Updating order $orderId to ${newStatus.value}');

      // First, find the order to get the custom orderId
      final order = _orders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw Exception('Order not found locally'),
      );

      // Use the custom orderId (ORD-...) not the MongoDB _id
      final customOrderId = order.orderId;
      log(
        '🔍 Using custom orderId: $customOrderId (from MongoDB _id: $orderId)',
      );

      // Update via API using the CUSTOM orderId
      await _repository.updateOrderStatus(customOrderId, newStatus.value);

      // Update local order
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        _applyFilters();

        // Refresh statistics
        await _loadStatistics();

        notifyListeners();
      }

      log('✅ Order status updated successfully');
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
      log('❌ Error updating order status: $e');
      notifyListeners();
      rethrow;
    }
  }

  void setStatusFilter(OrderStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void searchOrders(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<OrderModelSeller> filtered = List.from(_orders);

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered
          .where((order) => order.status == _selectedStatus)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.orderId.toLowerCase().contains(_searchQuery) ||
            order.buyerName.toLowerCase().contains(_searchQuery) ||
            order.buyerEmail.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    _filteredOrders = filtered;
  }

  void clearFilters() {
    _selectedStatus = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Helper to get status counts
  int getStatusCount(OrderStatus status) {
    return _orders.where((order) => order.status == status).length;
  }
}
