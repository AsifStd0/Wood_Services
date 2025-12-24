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
  final String productId;
  final int quantity;
  final String? selectedVariant;
  final String? selectedSize;
  final double price;
  final double subtotal;
  final BuyerProductModel? product; // Populated product details
  final DateTime addedAt;

  BuyerCartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    this.selectedVariant,
    this.selectedSize,
    required this.price,
    required this.subtotal,
    this.product,
    required this.addedAt,
  });

  factory BuyerCartItem.fromJson(Map<String, dynamic> json) {
    return BuyerCartItem(
      id: json['_id']?.toString() ?? '',
      productId: json['productId'] is Map
          ? (json['productId']['_id']?.toString() ?? '')
          : json['productId']?.toString() ?? '',
      quantity: json['quantity']?.toInt() ?? 1,
      selectedVariant: json['selectedVariant']?.toString(),
      selectedSize: json['selectedSize']?.toString(),
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      product: json['productId'] is Map
          ? BuyerProductModel.fromJson(json['productId'])
          : null,
      addedAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'selectedVariant': selectedVariant,
      'selectedSize': selectedSize,
      'price': price,
    };
  }

  BuyerCartItem copyWith({
    String? id,
    String? productId,
    int? quantity,
    String? selectedVariant,
    String? selectedSize,
    double? price,
    double? subtotal,
    BuyerProductModel? product,
    DateTime? addedAt,
  }) {
    return BuyerCartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedSize: selectedSize ?? this.selectedSize,
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
