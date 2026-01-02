import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum OrderStatus {
  requested('requested'),
  pending('pending'),
  accepted('accepted'),
  processing('processing'),
  shipped('shipped'),
  delivered('delivered'),
  cancelled('cancelled'),
  rejected('rejected');

  final String value;
  const OrderStatus(this.value);

  factory OrderStatus.fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.requested,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.requested:
        return 'Requested';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.requested:
      case OrderStatus.pending:
        return const Color(0xFFFFA726);
      case OrderStatus.accepted:
      case OrderStatus.processing:
        return const Color(0xFF29B6F6);
      case OrderStatus.shipped:
        return const Color(0xFF7E57C2);
      case OrderStatus.delivered:
        return const Color(0xFF66BB6A);
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return const Color(0xFFEF5350);
    }
  }
}

class OrderModelSeller {
  final String id;
  final String orderId;
  final String buyerId;
  final String buyerName;
  final String buyerEmail;
  final String? buyerPhone;
  final String? buyerAddress;
  final List<OrderItem> items;
  final int itemsCount;
  final double subtotal;
  final double shippingFee;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final OrderStatus status;
  final String requestType;
  final bool isVisitRequest;
  final bool isQuotationRequest;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? processedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? rejectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModelSeller({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerEmail,
    this.buyerPhone,
    this.buyerAddress,
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
    required this.requestedAt,
    this.acceptedAt,
    this.processedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.rejectedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  factory OrderModelSeller.fromJson(Map<String, dynamic> json) {
    log('📦 Parsing order JSON: ${json['orderId']}');

    try {
      // Parse buyer info carefully
      dynamic buyerData = json['buyerId'];
      String buyerId = '';
      String buyerName = '';
      String buyerEmail = '';

      if (buyerData is Map<String, dynamic>) {
        buyerId = buyerData['_id']?.toString() ?? '';
        buyerName = buyerData['fullName']?.toString() ?? 'Unknown Buyer';
        buyerEmail = buyerData['email']?.toString() ?? 'No Email';
      } else if (buyerData is String) {
        buyerId = buyerData;
        buyerName = json['buyerName']?.toString() ?? 'Unknown Buyer';
        buyerEmail = json['buyerEmail']?.toString() ?? 'No Email';
      }

      // Parse items
      List<OrderItem> items = [];
      if (json['items'] is List) {
        items = (json['items'] as List)
            .where((item) => item is Map<String, dynamic>)
            .map<OrderItem>((item) {
              try {
                return OrderItem.fromJson(Map<String, dynamic>.from(item));
              } catch (e) {
                log('❌ Error parsing item: $e');
                return OrderItem(
                  productId: '',
                  productName: 'Unknown Product',
                  sellerId: '',
                  sellerName: 'Unknown Seller',
                  quantity: 1,
                  unitPrice: 0,
                  subtotal: 0,
                );
              }
            })
            .toList();
      }

      // Parse numeric fields safely
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is int) return value.toDouble();
        if (value is double) return value;
        if (value is String) {
          try {
            return double.parse(value);
          } catch (e) {
            return 0.0;
          }
        }
        return 0.0;
      }

      int parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          try {
            return int.parse(value);
          } catch (e) {
            return 0;
          }
        }
        return 0;
      }

      // Parse dates safely
      DateTime parseDate(dynamic dateValue) {
        if (dateValue == null) return DateTime.now();
        if (dateValue is DateTime) return dateValue;
        if (dateValue is String) {
          try {
            return DateTime.parse(dateValue);
          } catch (e) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      return OrderModelSeller(
        id: json['_id']?.toString() ?? '',
        orderId: json['orderId']?.toString() ?? 'N/A',
        buyerId: buyerId,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
        buyerPhone: json['buyerPhone']?.toString(),
        buyerAddress:
            json['buyerAddress']?.toString() ??
            json['deliveryAddress']?.toString(),
        items: items,
        itemsCount: parseInt(json['itemsCount']),
        subtotal: parseDouble(json['subtotal']),
        shippingFee: parseDouble(json['shippingFee']),
        taxAmount: parseDouble(json['taxAmount']),
        totalAmount: parseDouble(json['totalAmount']),
        paymentMethod: json['paymentMethod']?.toString() ?? 'cod',
        paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
        status: OrderStatus.fromString(
          json['status']?.toString() ?? 'requested',
        ),
        requestType: json['requestType']?.toString() ?? 'buy_now',
        isVisitRequest: json['isVisitRequest'] == true,
        isQuotationRequest: json['isQuotationRequest'] == true,
        requestedAt: parseDate(json['requestedAt'] ?? json['createdAt']),
        acceptedAt: json['acceptedAt'] != null
            ? parseDate(json['acceptedAt'])
            : null,
        processedAt: json['processedAt'] != null
            ? parseDate(json['processedAt'])
            : null,
        shippedAt: json['shippedAt'] != null
            ? parseDate(json['shippedAt'])
            : null,
        deliveredAt: json['deliveredAt'] != null
            ? parseDate(json['deliveredAt'])
            : null,
        cancelledAt: json['cancelledAt'] != null
            ? parseDate(json['cancelledAt'])
            : null,
        rejectedAt: json['rejectedAt'] != null
            ? parseDate(json['rejectedAt'])
            : null,
        createdAt: parseDate(json['createdAt']),
        updatedAt: parseDate(json['updatedAt'] ?? json['createdAt']),
      );
    } catch (e, stackTrace) {
      log('❌ Error parsing OrderModelSeller: $e');
      log('❌ Stack trace: $stackTrace');
      log('❌ Problematic JSON: $json');

      // Return a default order to prevent app crash
      return OrderModelSeller(
        id: json['_id']?.toString() ?? '',
        orderId: json['orderId']?.toString() ?? 'ERROR',
        buyerId: '',
        buyerName: 'Error Loading',
        buyerEmail: 'error@example.com',
        items: [],
        itemsCount: 0,
        subtotal: 0,
        shippingFee: 0,
        taxAmount: 0,
        totalAmount: 0,
        paymentMethod: 'cod',
        paymentStatus: 'error',
        status: OrderStatus.requested,
        requestType: 'buy_now',
        isVisitRequest: false,
        isQuotationRequest: false,
        requestedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }
  String get formattedDate {
    return DateFormat('MMM dd, yyyy hh:mm a').format(requestedAt);
  }

  String get formattedAmount {
    return '₹${totalAmount.toStringAsFixed(2)}';
  }

  String get itemCountText {
    return '$itemsCount item${itemsCount != 1 ? 's' : ''}';
  }

  OrderModelSeller copyWith({
    OrderStatus? status,
    DateTime? acceptedAt,
    DateTime? processedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    DateTime? rejectedAt,
  }) {
    return OrderModelSeller(
      id: id,
      orderId: orderId,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerEmail: buyerEmail,
      buyerPhone: buyerPhone,
      buyerAddress: buyerAddress,
      items: items,
      itemsCount: itemsCount,
      subtotal: subtotal,
      shippingFee: shippingFee,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status ?? this.status,
      requestType: requestType,
      isVisitRequest: isVisitRequest,
      isQuotationRequest: isQuotationRequest,
      requestedAt: requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      processedAt: processedAt ?? this.processedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final String sellerId;
  final String sellerName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.sellerId,
    required this.sellerName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      // Parse product info
      dynamic productData = json['productId'];
      String productId = '';
      String productName = '';
      String? productImage;

      if (productData is Map<String, dynamic>) {
        productId = productData['_id']?.toString() ?? '';
        productName = productData['title']?.toString() ?? 'Unknown Product';
        productImage =
            productData['featuredImage']?.toString() ??
            productData['featuredImageUrl']?.toString();
      } else if (productData is String) {
        productId = productData;
        productName = json['productName']?.toString() ?? 'Unknown Product';
        productImage = json['productImage']?.toString();
      }

      // Parse seller info
      dynamic sellerData = json['sellerId'];
      String sellerId = '';
      String sellerName = '';

      if (sellerData is Map<String, dynamic>) {
        sellerId = sellerData['_id']?.toString() ?? '';
        sellerName =
            sellerData['shopName']?.toString() ??
            sellerData['businessName']?.toString() ??
            'Unknown Seller';
      } else if (sellerData is String) {
        sellerId = sellerData;
        sellerName = json['sellerName']?.toString() ?? 'Unknown Seller';
      }

      // Parse numeric values
      int parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          try {
            return int.parse(value);
          } catch (e) {
            return 0;
          }
        }
        return 0;
      }

      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is int) return value.toDouble();
        if (value is double) return value;
        if (value is String) {
          try {
            return double.parse(value);
          } catch (e) {
            return 0.0;
          }
        }
        return 0.0;
      }

      return OrderItem(
        productId: productId,
        productName: productName,
        productImage: productImage,
        sellerId: sellerId,
        sellerName: sellerName,
        quantity: parseInt(json['quantity']),
        unitPrice: parseDouble(json['unitPrice']),
        subtotal: parseDouble(json['subtotal']),
      );
    } catch (e) {
      log('❌ Error parsing OrderItem: $e');
      log('❌ JSON: $json');

      // Return default item
      return OrderItem(
        productId: '',
        productName: 'Error Loading Item',
        sellerId: '',
        sellerName: 'Unknown',
        quantity: 1,
        unitPrice: 0,
        subtotal: 0,
      );
    }
  }
  String get formattedUnitPrice {
    return '₹${unitPrice.toStringAsFixed(2)}';
  }

  String get formattedSubtotal {
    return '₹${subtotal.toStringAsFixed(2)}';
  }
}
