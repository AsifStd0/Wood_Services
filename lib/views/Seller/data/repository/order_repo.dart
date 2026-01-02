// // lib/data/repositories/order_repository.dart
// import 'package:wood_service/views/Seller/data/models/order.dart';

// abstract class OrderRepository {
//   Future<List<OrderDataModel>> getOrders();
//   Future<List<OrderDataModel>> searchOrders(String query);
//   Future<void> updateOrderStatus(String orderId, OrderStatus status);
// }

// class MockOrderRepository implements OrderRepository {
//   @override
//   Future<List<OrderDataModel>> getOrders() async {
//     await Future.delayed(const Duration(milliseconds: 500));

//     return [
//       OrderDataModel(
//         id: '1',
//         orderNumber: '123456',
//         customerName: 'Alice Johnson',
//         itemCount: 2,
//         totalAmount: 45.00,
//         status: OrderStatus.processing,
//         orderDate: DateTime(2024, 1, 15),
//       ),
//       OrderDataModel(
//         id: '2',
//         orderNumber: '123457',
//         customerName: 'Bob Smith',
//         itemCount: 1,
//         totalAmount: 20.00,
//         status: OrderStatus.processing,
//         orderDate: DateTime(2024, 1, 14),
//       ),
//       OrderDataModel(
//         id: '3',
//         orderNumber: '123458',
//         customerName: 'Charlie Brown',
//         itemCount: 3,
//         totalAmount: 75.00,
//         status: OrderStatus.shipped,
//         orderDate: DateTime(2024, 1, 13),
//       ),
//       OrderDataModel(
//         id: '4',
//         orderNumber: '123459',
//         customerName: 'Diana Prince',
//         itemCount: 1,
//         totalAmount: 15.00,
//         status: OrderStatus.completed,
//         orderDate: DateTime(2024, 1, 12),
//       ),
//     ];
//   }

//   @override
//   Future<List<OrderDataModel>> searchOrders(String query) async {
//     final orders = await getOrders();
//     if (query.isEmpty) return orders;

//     return orders.where((order) {
//       return order.orderNumber.toLowerCase().contains(query.toLowerCase()) ||
//           order.customerName.toLowerCase().contains(query.toLowerCase());
//     }).toList();
//   }

//   @override
//   Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     print('Updated order $orderId to status: $status');
//   }
// }
