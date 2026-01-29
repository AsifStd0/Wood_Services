import 'dart:developer';

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
    // Extract pricing info from new structure
    final pricing = json['pricing'] is Map
        ? json['pricing']
        : <String, dynamic>{};
    final orderDetails = json['orderDetails'] is Map
        ? json['orderDetails']
        : <String, dynamic>{};
    final timeline = json['timeline'] is Map
        ? json['timeline']
        : <String, dynamic>{};

    // Extract seller info
    final sellerIdObj = json['sellerId'];
    String sellerId = '';
    String sellerName = '';
    String? sellerEmail;
    String? sellerPhone;

    if (sellerIdObj is Map) {
      sellerId = sellerIdObj['_id']?.toString() ?? '';
      sellerName =
          sellerIdObj['name']?.toString() ??
          sellerIdObj['businessName']?.toString() ??
          sellerIdObj['shopName']?.toString() ??
          'Unknown Seller';
      sellerEmail = sellerIdObj['email']?.toString();
      sellerPhone = sellerIdObj['phone']?.toString();
    } else {
      sellerId = sellerIdObj?.toString() ?? '';
    }

    // Extract service/product info
    final serviceIdObj = json['serviceId'];
    String productId = '';
    String productName = '';
    String? productImage;

    if (serviceIdObj is Map) {
      productId = serviceIdObj['_id']?.toString() ?? '';
      productName = serviceIdObj['title']?.toString() ?? 'Unknown Product';
      final images = serviceIdObj['images'];
      if (images is List && images.isNotEmpty) {
        productImage = images.first?.toString();
      }
    } else {
      productId = serviceIdObj?.toString() ?? '';
    }

    // Build order items from the order data
    final items = <OrderItem>[];
    if (productId.isNotEmpty) {
      items.add(
        OrderItem(
          productId: productId,
          productName: productName,
          productImage: productImage,
          sellerId: sellerId,
          sellerName: sellerName,
          sellerEmail: sellerEmail,
          sellerPhone: sellerPhone,
          quantity: (json['quantity'] ?? 1).toInt(),
          unitPrice: (pricing['unitPrice'] ?? pricing['basePrice'] ?? 0)
              .toDouble(),
          subtotal: (pricing['finalAmount'] ?? pricing['basePrice'] ?? 0)
              .toDouble(),
          reviewed: json['reviewed'] ?? false,
        ),
      );
    }

    // Parse dates from timeline
    final orderedAt =
        timeline['orderedAt']?.toString() ??
        json['createdAt']?.toString() ??
        DateTime.now().toIso8601String();
    final status = _parseOrderStatus(json);

    return BuyerOrder(
      id: json['_id']?.toString() ?? '',
      orderId: json['_id']?.toString() ?? json['orderId']?.toString() ?? 'N/A',
      items: items,
      itemsCount: items.length,
      subtotal: (pricing['basePrice'] ?? 0).toDouble(),
      shippingFee: 0.0, // Not in new API structure
      taxAmount: (pricing['taxAmount'] ?? 0).toDouble(),
      totalAmount: (pricing['finalAmount'] ?? pricing['basePrice'] ?? 0)
          .toDouble(),
      paymentMethod:
          pricing['paymentMethod']?.toString() ??
          json['paymentMethod']?.toString() ??
          'card',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      status: status, // Use the parsed status
      requestType: json['requestType']?.toString() ?? 'buy_now',
      isVisitRequest: json['isVisitRequest'] ?? false,
      isQuotationRequest: json['isQuotationRequest'] ?? false,
      deliveryAddress: orderDetails['location'] != null
          ? {'address': orderDetails['location']}
          : (json['deliveryAddress'] is Map<String, dynamic>
                ? Map<String, dynamic>.from(json['deliveryAddress'])
                : null),
      deliveryInstructions:
          orderDetails['specialRequirements']?.toString() ??
          json['deliveryInstructions']?.toString(),
      requestedAt: DateTime.parse(orderedAt),
      acceptedAt: timeline['acceptedAt'] != null
          ? DateTime.parse(timeline['acceptedAt'])
          : null,
      processedAt: timeline['processedAt'] != null
          ? DateTime.parse(timeline['processedAt'])
          : null,
      shippedAt: timeline['shippedAt'] != null
          ? DateTime.parse(timeline['shippedAt'])
          : null,
      deliveredAt: timeline['deliveredAt'] != null
          ? DateTime.parse(timeline['deliveredAt'])
          : null,
      cancelledAt: timeline['cancelledAt'] != null
          ? DateTime.parse(timeline['cancelledAt'])
          : null,
      rejectedAt: timeline['rejectedAt'] != null
          ? DateTime.parse(timeline['rejectedAt'])
          : null,
      receivedAt: timeline['receivedAt'] != null
          ? DateTime.parse(timeline['receivedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? orderedAt),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? json['createdAt'] ?? orderedAt,
      ),
      reviewed: json['reviewed'] ?? false,
      review: json['review'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['review'])
          : null,
    );
  }

  // print all data  ???
  static OrderStatusBuyer _parseOrderStatus(Map<String, dynamic> json) {
    final status = json['status']?.toString().toLowerCase() ?? '';
    final timeline = json['timeline'] is Map
        ? json['timeline']
        : <String, dynamic>{};

    // log('🔍 Parsing order status:');
    // log('   Raw status: $status');
    // log('   Timeline: $timeline');

    // Check timeline dates to determine actual status
    if (timeline['deliveredAt'] != null) {
      // log(
      //   '   → Has deliveredAt: ${timeline['deliveredAt']} → OrderStatusBuyer.completed',
      // );
      return OrderStatusBuyer.completed;
    }

    if (timeline['shippedAt'] != null) {
      // log(
      //   '   → Has shippedAt: ${timeline['shippedAt']} → OrderStatusBuyer.accepted',
      // );
      return OrderStatusBuyer.accepted;
    }

    if (timeline['acceptedAt'] != null) {
      // log(
      //   '   → Has acceptedAt: ${timeline['acceptedAt']} → OrderStatusBuyer.accepted',
      // );
      return OrderStatusBuyer.accepted;
    }

    if (timeline['cancelledAt'] != null || timeline['rejectedAt'] != null) {
      // log('   → Has cancelledAt/rejectedAt → OrderStatusBuyer.declined');
      return OrderStatusBuyer.declined;
    }

    // Default based on status string
    switch (status) {
      case 'accepted':
      case 'processing':
      case 'shipped':
        log('   → Status "$status" → OrderStatusBuyer.accepted');
        return OrderStatusBuyer.accepted;
      case 'rejected':
      case 'cancelled':
      case 'declined':
        log('   → Status "$status" → OrderStatusBuyer.declined');
        return OrderStatusBuyer.declined;
      case 'delivered':
      case 'completed':
      case 'fulfilled':
        log('   → Status "$status" → OrderStatusBuyer.completed');
        return OrderStatusBuyer.completed;
      case 'pending':
      case 'requested':
      default:
        log('   → Status "$status" → OrderStatusBuyer.pending');
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
      case OrderStatusBuyer.cancelled:
        return 'Cancelled';
      case OrderStatusBuyer.rejected:
        return 'Rejected';
      default:
        return 'Pending';
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
      case OrderStatusBuyer.cancelled:
        return Colors.red;
      case OrderStatusBuyer.rejected:
        return Colors.red;
      default:
        return Colors.grey;
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

enum OrderStatusBuyer {
  pending,
  accepted,
  declined,
  completed,
  cancelled,
  rejected,
}
