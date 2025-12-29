// import 'package:flutter/foundation.dart';
// import '../models/visit_request_model.dart';
// import '../models/order_model.dart';
// import '../services/shop_service.dart';

// class SellerHomeViewModel with ChangeNotifier {
//   final ShopService shopService;

//   List<VisitRequest> _pendingRequests = [];
//   List<VisitRequest> _acceptedRequests = [];
//   List<Order> _orders = [];
//   bool _isLoading = false;
//   String? _error;
//   int _currentTabIndex = 0;
//   OrderStatus _selectedOrderStatus = OrderStatus.active;

//   SellerHomeViewModel(this.shopService);

//   List<VisitRequest> get pendingRequests => _pendingRequests;
//   List<VisitRequest> get acceptedRequests => _acceptedRequests;
//   List<Order> get orders => _orders;
//   List<Order> get filteredOrders =>
//       _orders.where((order) => order.status == _selectedOrderStatus).toList();
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   int get currentTabIndex => _currentTabIndex;
//   OrderStatus get selectedOrderStatus => _selectedOrderStatus;

//   void setTabIndex(int index) {
//     _currentTabIndex = index;
//     notifyListeners();
//   }

//   void setOrderStatus(OrderStatus status) {
//     _selectedOrderStatus = status;
//     notifyListeners();
//   }

//   Future<void> loadVisitRequests() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final requests = await shopService.getVisitRequests();
//       _pendingRequests = requests
//           .where((r) => r.status == VisitStatus.pending)
//           .toList();
//       _acceptedRequests = requests
//           .where((r) => r.status == VisitStatus.accepted)
//           .toList();
//       _error = null;
//     } catch (e) {
//       _error = 'Failed to load visit requests';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadOrders() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _orders = await shopService.getOrders();
//       _error = null;
//     } catch (e) {
//       _error = 'Failed to load orders';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> acceptVisitRequest(String requestId) async {
//     try {
//       await shopService.updateVisitRequestStatus(
//         requestId,
//         VisitStatus.accepted,
//       );
//       await loadVisitRequests();
//     } catch (e) {
//       _error = 'Failed to accept request';
//       notifyListeners();
//     }
//   }

//   Future<void> cancelVisitRequest(String requestId) async {
//     try {
//       await shopService.updateVisitRequestStatus(
//         requestId,
//         VisitStatus.cancelled,
//       );
//       await loadVisitRequests();
//     } catch (e) {
//       _error = 'Failed to cancel request';
//       notifyListeners();
//     }
//   }
// }
