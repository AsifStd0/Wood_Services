import 'dart:developer';

import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';

class BuyerCartModel {
  final String id;
  final String buyerId;
  final List<BuyerCartItem> items;
  final int totalQuantity;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  final DateTime lastUpdated;

  BuyerCartModel({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.totalQuantity,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
    required this.lastUpdated,
  });

  factory BuyerCartModel.fromJson(Map<String, dynamic> json) {
    return BuyerCartModel(
      id: json['_id']?.toString() ?? '',
      buyerId: json['buyerId']?.toString() ?? '',
      items: (json['items'] as List? ?? []).map((item) {
        return BuyerCartItem.fromJson(item);
      }).toList(),
      totalQuantity: json['totalQuantity']?.toInt() ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buyerId': buyerId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  BuyerCartModel copyWith({
    String? id,
    String? buyerId,
    List<BuyerCartItem>? items,
    int? totalQuantity,
    double? subtotal,
    double? shippingFee,
    double? tax,
    double? total,
    DateTime? lastUpdated,
  }) {
    return BuyerCartModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      items: items ?? this.items,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class BuyerCartItem {
  final String id;
  final String
  productId; // Keep for backward compatibility, but API uses serviceId
  final String? serviceId; // NEW: API uses serviceId
  final int quantity;
  final String? selectedVariant;
  final String? selectedSize;
  final List<Map<String, String>>?
  selectedVariants; // NEW: API uses selectedVariants array
  final double price;
  final double subtotal;
  final BuyerProductModel? product; // Populated product details (service)
  final DateTime addedAt;

  BuyerCartItem({
    required this.id,
    required this.productId,
    this.serviceId,
    required this.quantity,
    this.selectedVariant,
    this.selectedSize,
    this.selectedVariants,
    required this.price,
    required this.subtotal,
    this.product,
    required this.addedAt,
  });

  factory BuyerCartItem.fromJson(Map<String, dynamic> json) {
    try {
      // Extract service/product data - handle both serviceId as object or string
      final dynamic serviceIdData = json['serviceId'];
      BuyerProductModel? productModel;
      String productIdValue = '';

      if (serviceIdData is Map) {
        // serviceId is an object with product details
        productModel = BuyerProductModel.fromJson(
          serviceIdData as Map<String, dynamic>,
        );
        productIdValue = serviceIdData['_id']?.toString() ?? '';
      } else if (serviceIdData != null) {
        // serviceId is a string ID
        productIdValue = serviceIdData.toString();
      } else {
        // Fallback to productId
        final productIdData = json['productId'];
        if (productIdData is Map) {
          productModel = BuyerProductModel.fromJson(
            productIdData as Map<String, dynamic>,
          );
          productIdValue = productIdData['_id']?.toString() ?? '';
        } else if (productIdData != null) {
          productIdValue = productIdData.toString();
        }
      }

      // Parse selectedVariants array if present
      List<Map<String, String>>? parsedVariants;
      if (json['selectedVariants'] != null &&
          json['selectedVariants'] is List) {
        parsedVariants = (json['selectedVariants'] as List).map((v) {
          if (v is Map) {
            return {
              'type': v['type']?.toString() ?? '',
              'value': v['value']?.toString() ?? '',
            };
          }
          return {'type': '', 'value': ''};
        }).toList();
      }

      // Calculate price
      double price = (json['price'] ?? 0).toDouble();
      if (price == 0 && productModel != null) {
        // Use sale price if available, otherwise regular price
        price = productModel.salePrice ?? productModel.basePrice ?? 0;
      }

      // Calculate subtotal
      double subtotalValue = (json['subtotal'] ?? 0).toDouble();
      if (subtotalValue == 0 && price > 0) {
        final quantity = json['quantity']?.toInt() ?? 1;
        subtotalValue = price * quantity;
      }

      // Extract selectedVariant and selectedSize from selectedVariants
      String? extractedVariant;
      String? extractedSize;
      if (parsedVariants != null) {
        for (var variant in parsedVariants) {
          if (variant['type']?.toLowerCase() == 'size') {
            extractedSize = variant['value'];
          } else {
            extractedVariant = variant['value'];
          }
        }
      }

      return BuyerCartItem(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        productId: productIdValue,
        serviceId: json['serviceId']?.toString() ?? productIdValue,
        quantity: json['quantity']?.toInt() ?? 1,
        selectedVariant:
            json['selectedVariant']?.toString() ?? extractedVariant,
        selectedSize: json['selectedSize']?.toString() ?? extractedSize,
        selectedVariants: parsedVariants,
        price: price,
        subtotal: subtotalValue,
        product: productModel,
        addedAt: json['addedAt'] != null
            ? DateTime.tryParse(json['addedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      log('❌ Error in BuyerCartItem.fromJson: $e');
      log('❌ JSON data: $json');
      // Return a default item to prevent crashes
      return BuyerCartItem(
        id: '',
        productId: '',
        serviceId: '',
        quantity: 0,
        price: 0,
        subtotal: 0,
        addedAt: DateTime.now(),
      );
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'serviceId': serviceId ?? productId,
      'quantity': quantity,
      if (selectedVariants != null && selectedVariants!.isNotEmpty)
        'selectedVariants': selectedVariants,
      if (selectedVariant != null) 'selectedVariant': selectedVariant,
      if (selectedSize != null) 'selectedSize': selectedSize,
      'price': price,
    };
  }

  BuyerCartItem copyWith({
    String? id,
    String? productId,
    String? serviceId,
    int? quantity,
    String? selectedVariant,
    String? selectedSize,
    List<Map<String, String>>? selectedVariants,
    double? price,
    double? subtotal,
    BuyerProductModel? product,
    DateTime? addedAt,
  }) {
    return BuyerCartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      serviceId: serviceId ?? this.serviceId,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      product: product ?? this.product,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Helper to check if item is in stock
  bool get isInStock {
    if (product == null) return true;
    return product!.inStock && product!.stockQuantity >= quantity;
  }
}
