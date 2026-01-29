import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/models/order_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_repository_seller.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_requests_service.dart';

class OrdersViewModel with ChangeNotifier {
  final SellerOrderRepository _repository;

  OrdersViewModel(this._repository);

  final VisitRequestsService _service = locator<VisitRequestsService>();

  // Stats data
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> get stats => _stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Getters for easy access to stats
  int get totalServices => _stats['services']?['total'] ?? 0;
  int get activeServices => _stats['services']?['active'] ?? 0;
  int get acceptedOrders => _acceptedOrders;

  // ! *****
  int get totalOrders => _stats['orders']?['total'] ?? 0;
  int get pendingOrders => _stats['orders']?['pending'] ?? 0;
  int get inProgressOrders => _stats['orders']?['inProgress'] ?? 0;
  int get completedOrders => _stats['orders']?['completed'] ?? 0;
  // ! ******
  double get averageRating => (_stats['averageRating'] ?? 0).toDouble();
  double get totalRevenue => (_stats['totalRevenue'] ?? 0).toDouble();

  /// Load seller statistics
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📊 Loading seller stats...');
      _stats = await _service.getVisitRequests();
      log('✅ Stats loaded successfully: $_stats');
      _errorMessage = null;
    } catch (e) {
      log('❌ Error loading stats: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh stats
  Future<void> refresh() async {
    await loadStats();
  }

  List<OrderModelSeller> _orders = [];
  List<OrderModelSeller> get orders => _orders;

  List<OrderModelSeller> _filteredOrders = [];
  List<OrderModelSeller> get filteredOrders => _filteredOrders;

  OrderStatus? _selectedStatus;
  OrderStatus? get selectedStatus => _selectedStatus;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Statistics
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _acceptedOrders = 0;
  int _completedOrders = 0;

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

      // Find the order - orderId can be either MongoDB _id or custom orderId
      final order = _orders.firstWhere(
        (order) => order.id == orderId || order.orderId == orderId,
        orElse: () => throw Exception('Order not found locally'),
      );

      // Use MongoDB _id for API calls
      final apiOrderId = order.id;
      log('🔍 Using order ID: $apiOrderId');

      // Update via API
      await _repository.updateOrderStatus(apiOrderId, newStatus.value);

      // Update local order
      final index = _orders.indexWhere((o) => o.id == order.id);
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

  /// Add note to order
  Future<void> addOrderNote(String orderId, String message) async {
    try {
      log('📝 Adding note to order: $orderId');

      // Find the order
      final order = _orders.firstWhere(
        (order) => order.id == orderId || order.orderId == orderId,
        orElse: () => throw Exception('Order not found locally'),
      );
      log('order.id ${order.id}');
      await _repository.addOrderNote(order.id, message);
      log('✅ Note added successfully');
    } catch (e) {
      _errorMessage = 'Failed to add note: $e';
      log('❌ Error adding note: $e');
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
