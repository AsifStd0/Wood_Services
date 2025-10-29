import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/models/order.dart';

import '../../repository/order_repo.dart';

// lib/presentation/view_models/orders_view_model.dart
class OrdersViewModel with ChangeNotifier {
  final OrderRepository _repository;
  int amount = 20;

  OrdersViewModel(this._repository);

  List<OrderDataModel> _orders = [];
  List<OrderDataModel> get orders => _orders;

  List<OrderDataModel> _filteredOrders = [];
  List<OrderDataModel> get filteredOrders => _filteredOrders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  OrderStatus? _statusFilter;
  OrderStatus? get statusFilter => _statusFilter;

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _orders = await _repository.getOrders();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchOrders(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByStatus(OrderStatus? status) {
    _statusFilter = status;
    _applyFilters();
  }

  void _applyFilters() {
    List<OrderDataModel> result = _orders;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((order) {
        return order.orderNumber.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            order.customerName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      result = result.where((order) => order.status == _statusFilter).toList();
    }

    _filteredOrders = result;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _repository.updateOrderStatus(orderId, newStatus);
      await loadOrders(); // Reload to get updated data
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
      notifyListeners();
    }
  }
}
// class OrdersViewModel with ChangeNotifier {
//   final OrderRepository _orderRepository;

//   OrdersViewModel(this._orderRepository);

//   List<OrderDataModel> _orders = [];
//   List<OrderDataModel> get orders => _orders;

//   OrderStatus? _selectedFilter;
//   OrderStatus? get selectedFilter => _selectedFilter;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _errorMessage = '';
//   String get errorMessage => _errorMessage;

//   // Load orders
//   Future<void> loadOrders() async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       _orders = await _orderRepository.getOrders();
//     } catch (e) {
//       _errorMessage = 'Failed to load orders: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Filter orders by status
//   void filterOrders(OrderStatus? status) {
//     _selectedFilter = status;
//     notifyListeners();
//   }

//   // Update order status
//   Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
//     try {
//       await _orderRepository.updateOrderStatus(orderId, newStatus);
//       // Refresh orders after update
//       await loadOrders();
//     } catch (e) {
//       _errorMessage = 'Failed to update order status: $e';
//       notifyListeners();
//     }
//   }

//   // Get filtered orders based on selected filter
//   List<OrderDataModel> get filteredOrders {
//     if (_selectedFilter == null) {
//       return _orders;
//     }
//     return _orders.where((order) => order.status == _selectedFilter).toList();
//   }

//   // Get orders count by status
//   Map<OrderStatus, int> get ordersCountByStatus {
//     final Map<OrderStatus, int> count = {};
//     for (final order in _orders) {
//       count[order.status] = (count[order.status] ?? 0) + 1;
//     }
//     return count;
//   }
// }
