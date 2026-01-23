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
    // Parse selectedVariants array if present
    List<Map<String, String>>? parsedVariants;
    if (json['selectedVariants'] != null && json['selectedVariants'] is List) {
      parsedVariants = (json['selectedVariants'] as List).map((v) {
        if (v is Map) {
          return {
            'type': v['type']?.toString() ?? '',
            'value': v['value']?.toString() ?? '',
          };
        }
        return {'type': '', 'value': ''};
      }).toList();

      // Also extract selectedVariant and selectedSize from selectedVariants for backward compatibility
      String? extractedVariant;
      String? extractedSize;
      for (var variant in parsedVariants) {
        if (variant['type']?.toLowerCase() == 'size') {
          extractedSize = variant['value'];
        } else {
          extractedVariant = variant['value'];
        }
      }

      // Use extracted values if individual fields not present
      final selectedVariant =
          json['selectedVariant']?.toString() ?? extractedVariant;
      final selectedSize = json['selectedSize']?.toString() ?? extractedSize;

      // Extract serviceId or productId
      final serviceId = json['serviceId']?.toString();
      final productIdValue = json['productId'] is Map
          ? (json['productId']['_id']?.toString() ??
                json['productId']['id']?.toString() ??
                '')
          : json['productId']?.toString() ??
                json['serviceId']?.toString() ??
                '';

      return BuyerCartItem(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        productId: productIdValue,
        serviceId: serviceId ?? productIdValue,
        quantity: json['quantity']?.toInt() ?? 1,
        selectedVariant: selectedVariant,
        selectedSize: selectedSize,
        selectedVariants: parsedVariants,
        price: (json['price'] ?? 0).toDouble(),
        subtotal: (json['subtotal'] ?? 0).toDouble(),
        product: json['serviceId'] is Map
            ? BuyerProductModel.fromJson(json['serviceId'])
            : json['productId'] is Map
            ? BuyerProductModel.fromJson(json['productId'])
            : null,
        addedAt: DateTime.parse(
          json['createdAt'] ??
              json['addedAt'] ??
              DateTime.now().toIso8601String(),
        ),
      );
    }

    // Fallback for old format (no selectedVariants)
    final serviceIdFallback = json['serviceId']?.toString();
    final productIdValue = json['productId'] is Map
        ? (json['productId']['_id']?.toString() ??
              json['productId']['id']?.toString() ??
              '')
        : json['productId']?.toString() ?? json['serviceId']?.toString() ?? '';

    return BuyerCartItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productId: productIdValue,
      serviceId: serviceIdFallback ?? productIdValue,
      quantity: json['quantity']?.toInt() ?? 1,
      selectedVariant: json['selectedVariant']?.toString(),
      selectedSize: json['selectedSize']?.toString(),
      selectedVariants: parsedVariants,
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      product: json['productId'] is Map
          ? BuyerProductModel.fromJson(json['productId'])
          : json['serviceId'] is Map
          ? BuyerProductModel.fromJson(json['serviceId'])
          : null,
      addedAt: DateTime.parse(
        json['createdAt'] ??
            json['addedAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
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
