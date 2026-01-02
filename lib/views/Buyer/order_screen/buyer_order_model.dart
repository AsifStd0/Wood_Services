import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuyerOrder {
  final String id;
  final String orderId;
  final List<OrderItem> items;
  final int itemsCount;
  final double subtotal;
  final double shippingFee;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final OrderStatusBuyer status;
  final String requestType;
  final bool isVisitRequest;
  final bool isQuotationRequest;
  final Map<String, dynamic>? deliveryAddress;
  final String? deliveryInstructions;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? processedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? rejectedAt;
  final DateTime? receivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool reviewed;
  final Map<String, dynamic>? review;

  BuyerOrder({
    required this.id,
    required this.orderId,
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.shippingFee,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.requestType,
    required this.isVisitRequest,
    required this.isQuotationRequest,
    this.deliveryAddress,
    this.deliveryInstructions,
    required this.requestedAt,
    this.acceptedAt,
    this.processedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.rejectedAt,
    this.receivedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.reviewed,
    this.review,
  });

  factory BuyerOrder.fromJson(Map<String, dynamic> json) {
    return BuyerOrder(
      id: json['_id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? 'N/A',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      itemsCount: (json['itemsCount'] ?? 0).toInt(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'cod',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      status: _parseOrderStatus(json['status']?.toString()),
      requestType: json['requestType']?.toString() ?? 'buy_now',
      isVisitRequest: json['isVisitRequest'] ?? false,
      isQuotationRequest: json['isQuotationRequest'] ?? false,
      deliveryAddress: json['deliveryAddress'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['deliveryAddress'])
          : null,
      deliveryInstructions: json['deliveryInstructions']?.toString(),
      requestedAt: DateTime.parse(json['requestedAt'] ?? json['createdAt']),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      shippedAt: json['shippedAt'] != null
          ? DateTime.parse(json['shippedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['createdAt']),
      reviewed: json['reviewed'] ?? false,
      review: json['review'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['review'])
          : null,
    );
  }

  static OrderStatusBuyer _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'requested':
      case 'pending':
        return OrderStatusBuyer.pending;
      case 'accepted':
      case 'processing':
      case 'shipped':
        return OrderStatusBuyer.accepted;
      case 'rejected':
      case 'cancelled':
        return OrderStatusBuyer.declined;
      case 'delivered':
        return OrderStatusBuyer.completed;
      default:
        return OrderStatusBuyer.pending;
    }
  }

  // Helper methods
  String get formattedDate => DateFormat('MMM dd, yyyy').format(requestedAt);
  String get formattedTotal => '₹${totalAmount.toStringAsFixed(2)}';

  String get statusText {
    switch (status) {
      case OrderStatusBuyer.pending:
        return 'Pending';
      case OrderStatusBuyer.accepted:
        if (shippedAt != null) return 'Shipped';
        if (processedAt != null) return 'Processing';
        return 'Accepted';
      case OrderStatusBuyer.declined:
        return cancelledAt != null ? 'Cancelled' : 'Rejected';
      case OrderStatusBuyer.completed:
        return 'Delivered';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatusBuyer.pending:
        return Colors.orange;
      case OrderStatusBuyer.accepted:
        return Colors.blue;
      case OrderStatusBuyer.declined:
        return Colors.red;
      case OrderStatusBuyer.completed:
        return Colors.green;
    }
  }

  bool get canCancel => status == OrderStatusBuyer.pending;
  bool get canReview => status == OrderStatusBuyer.completed && !reviewed;
}

class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final String sellerId;
  final String sellerName;
  final String? sellerEmail;
  final String? sellerPhone;
  final double sellerRating;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final bool reviewed;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.sellerId,
    required this.sellerName,
    this.sellerEmail,
    this.sellerPhone,
    this.sellerRating = 0,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.reviewed,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Unknown Product',
      productImage: json['productImage']?.toString(),
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? 'Unknown Seller',
      sellerEmail: json['sellerEmail']?.toString(),
      sellerPhone: json['sellerPhone']?.toString(),
      sellerRating: (json['sellerRating'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      reviewed: json['reviewed'] ?? false,
    );
  }

  String get formattedUnitPrice => '₹${unitPrice.toStringAsFixed(2)}';
  String get formattedSubtotal => '₹${subtotal.toStringAsFixed(2)}';
}

enum OrderStatusBuyer { pending, accepted, declined, completed }
