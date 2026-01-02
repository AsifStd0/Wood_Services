// // lib/domain/models/order.dart
// import 'package:flutter/material.dart';

// class OrderDataModel {
//   final String id;
//   final String orderNumber;
//   final String customerName;
//   final int itemCount;
//   final double totalAmount;
//   final OrderStatus status;
//   final DateTime orderDate;

//   OrderDataModel({
//     required this.id,
//     required this.orderNumber,
//     required this.customerName,
//     required this.itemCount,
//     required this.totalAmount,
//     required this.status,
//     required this.orderDate,
//   });

//   String get itemCountText => itemCount == 1 ? '1 item' : '$itemCount items';
//   String get formattedAmount => '\$${totalAmount.toStringAsFixed(2)}';
// }

// enum OrderStatus { processing, shipped, completed, cancelled }

// extension OrderStatusExtension on OrderStatus {
//   String get displayName {
//     switch (this) {
//       case OrderStatus.processing:
//         return 'Processing';
//       case OrderStatus.shipped:
//         return 'Shipped';
//       case OrderStatus.completed:
//         return 'Completed';
//       case OrderStatus.cancelled:
//         return 'Cancelled';
//     }
//   }

//   Color get color {
//     switch (this) {
//       case OrderStatus.processing:
//         return Colors.orange;
//       case OrderStatus.shipped:
//         return Colors.blue;
//       case OrderStatus.completed:
//         return Colors.green;
//       case OrderStatus.cancelled:
//         return Colors.red;
//     }
//   }
// }
