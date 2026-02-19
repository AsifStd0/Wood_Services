import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood_service/core/theme/app_colors.dart';

enum OrderStatus {
  pending('pending'),
  accepted('accepted'),
  inProgress('in-progress'),
  completed('completed'),
  cancelled('cancelled'),
  rejected('rejected');

  final String value;
  const OrderStatus(this.value);

  factory OrderStatus.fromString(String value) {
    // Handle both "in-progress" and "inProgress" formats
    final normalizedValue = value.toLowerCase().replaceAll('_', '-');
    return OrderStatus.values.firstWhere(
      (e) => e.value == normalizedValue,
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
        return AppColors.success;
      case OrderStatus.inProgress:
        return AppColors.info;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.textSecondary;
      case OrderStatus.rejected:
        return AppColors.error;
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

  // New fields from API
  final Map<String, dynamic>?
  orderDetails; // description, location, preferredDate, etc.
  final Map<String, dynamic>?
  pricing; // unitPrice, taxAmount, finalAmount, etc.
  final String? currency;

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
    this.orderDetails,
    this.pricing,
    this.currency,
  });
  factory OrderModelSeller.fromJson(Map<String, dynamic> json) {
    log('📦 Parsing order JSON: ${json['_id']}');

    try {
      // Parse buyer info - new structure has buyerId as object
      dynamic buyerData = json['buyerId'];
      String buyerId = '';
      String buyerName = '';
      String buyerEmail = '';
      String? buyerPhone;

      if (buyerData is Map<String, dynamic>) {
        buyerId = buyerData['_id']?.toString() ?? '';
        buyerName =
            buyerData['name']?.toString() ??
            buyerData['fullName']?.toString() ??
            'Unknown Buyer';
        buyerEmail = buyerData['email']?.toString() ?? 'No Email';
        buyerPhone = buyerData['phone']?.toString();
      } else if (buyerData is String) {
        buyerId = buyerData;
        buyerName = json['buyerName']?.toString() ?? 'Unknown Buyer';
        buyerEmail = json['buyerEmail']?.toString() ?? 'No Email';
        buyerPhone = json['buyerPhone']?.toString();
      }

      // Parse numeric fields safely - define first
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

      // Parse pricing and order details from new structure
      final pricing = json['pricing'] ?? {};
      final orderDetails = json['orderDetails'] ?? {};
      final timeline = json['timeline'] ?? {};

      // Parse serviceId to create order item - new structure
      List<OrderItem> items = [];
      final serviceId = json['serviceId'];
      final quantity = parseInt(json['quantity'] ?? 1);

      if (serviceId is Map<String, dynamic>) {
        final productId = serviceId['_id']?.toString() ?? '';
        final productName = serviceId['title']?.toString() ?? 'Unknown Product';
        final productImages = serviceId['images'] as List? ?? [];
        final productImage = productImages.isNotEmpty
            ? productImages[0].toString()
            : null;

        final unitPrice = parseDouble(
          pricing['unitPrice'] ?? pricing['salePrice'] ?? 0,
        );
        final subtotal = parseDouble(
          pricing['finalAmount'] ?? (unitPrice * quantity),
        );

        items.add(
          OrderItem(
            productId: productId,
            productName: productName,
            productImage: productImage,
            sellerId: json['sellerId']?.toString() ?? '',
            sellerName: 'Current Seller',
            quantity: quantity,
            unitPrice: unitPrice,
            subtotal: subtotal,
          ),
        );
      } else if (json['items'] is List) {
        // Fallback to old structure
        items = (json['items'] as List)
            .whereType<Map<String, dynamic>>()
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

      final subtotal = parseDouble(
        pricing['basePrice'] ?? pricing['subtotal'] ?? 0,
      );
      final taxAmount = parseDouble(pricing['taxAmount'] ?? 0);
      final totalAmount = parseDouble(
        pricing['finalAmount'] ??
            pricing['totalAmount'] ??
            subtotal + taxAmount,
      );
      final paymentMethod =
          pricing['paymentMethod']?.toString() ??
          json['paymentMethod']?.toString() ??
          'card';

      // Parse orderId - generate from _id if not present
      String orderId =
          json['orderId']?.toString() ?? json['_id']?.toString() ?? 'N/A';
      if (orderId.length > 12) {
        // MongoDB _id, use last 8 chars
        orderId = 'ORD-${orderId.substring(orderId.length - 8).toUpperCase()}';
      }

      return OrderModelSeller(
        id: json['_id']?.toString() ?? '',
        orderId: orderId,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
        buyerPhone: buyerPhone,
        buyerAddress:
            orderDetails['location']?.toString() ??
            json['buyerAddress']?.toString() ??
            json['deliveryAddress']?.toString(),
        items: items,
        itemsCount: items.isNotEmpty
            ? items.length
            : parseInt(json['quantity'] ?? 1),
        subtotal: subtotal,
        shippingFee: parseDouble(json['shippingFee'] ?? 0),
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
        status: OrderStatus.fromString(json['status']?.toString() ?? 'pending'),

        requestType: json['requestType']?.toString() ?? 'buy_now',
        isVisitRequest: json['isVisitRequest'] == true,
        isQuotationRequest: json['isQuotationRequest'] == true,
        requestedAt: parseDate(
          timeline['orderedAt'] ?? json['requestedAt'] ?? json['createdAt'],
        ),
        acceptedAt: timeline['acceptedAt'] != null
            ? parseDate(timeline['acceptedAt'])
            : (json['acceptedAt'] != null ? parseDate(json['acceptedAt']) : null),
        processedAt: timeline['startedAt'] != null
            ? parseDate(timeline['startedAt'])
            : (json['processedAt'] != null ? parseDate(json['processedAt']) : null),
        shippedAt: json['shippedAt'] != null
            ? parseDate(json['shippedAt'])
            : null,
        deliveredAt: timeline['completedAt'] != null
            ? parseDate(timeline['completedAt'])
            : (json['deliveredAt'] != null ? parseDate(json['deliveredAt']) : null),
        cancelledAt: json['cancelledAt'] != null
            ? parseDate(json['cancelledAt'])
            : null,
        rejectedAt: json['rejectedAt'] != null
            ? parseDate(json['rejectedAt'])
            : null,
        createdAt: parseDate(json['createdAt']),
        updatedAt: parseDate(json['updatedAt'] ?? json['createdAt']),
        orderDetails: orderDetails.isNotEmpty ? orderDetails : null,
        pricing: pricing.isNotEmpty ? pricing : null,
        currency:
            pricing['currency']?.toString() ??
            json['currency']?.toString() ??
            'USD',
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
        status: OrderStatus.pending,
        requestType: 'buy_now',
        isVisitRequest: false,
        isQuotationRequest: false,
        requestedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        orderDetails: null,
        pricing: null,
        currency: 'USD',
      );
    }
  }
  String get formattedDate {
    return DateFormat('MMM dd, yyyy hh:mm a').format(requestedAt);
  }

  String get formattedAmount {
    final currencySymbol = currency == 'USD' ? '\$' : '₹';
    return '$currencySymbol${totalAmount.toStringAsFixed(2)}';
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
      orderDetails: orderDetails ?? orderDetails,
      pricing: pricing ?? pricing,
      currency: currency ?? currency,
    );
  }

  // Helper getters for orderDetails
  String? get orderDescription => orderDetails?['description']?.toString();
  String? get orderLocation => orderDetails?['location']?.toString();
  String? get preferredDate => orderDetails?['preferredDate']?.toString();
  String? get estimatedDuration =>
      orderDetails?['estimatedDuration']?.toString();
  String? get specialRequirements =>
      orderDetails?['specialRequirements']?.toString();

  // Helper getters for pricing
  double? get unitPrice =>
      pricing?['unitPrice'] != null ? parseDouble(pricing!['unitPrice']) : null;
  double? get salePrice =>
      pricing?['salePrice'] != null ? parseDouble(pricing!['salePrice']) : null;
  bool get useSalePrice => pricing?['useSalePrice'] == true;

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
