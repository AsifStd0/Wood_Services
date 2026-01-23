// lib/data/models/cart_item.dart
class CartItemModelData {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final String sellerName;
  final double price;
  int quantity;
  double subtotal;
  bool isRequested;
  String? selectedVariant;
  String? selectedSize;

  CartItemModelData({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.sellerName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.isRequested = false,
    this.selectedVariant,
    this.selectedSize,
  });

  factory CartItemModelData.fromJson(Map<String, dynamic> json) {
    return CartItemModelData(
      id: json['_id'],
      productId: json['productId'] is Map
          ? json['productId']['_id']
          : json['productId'].toString(),
      productName: json['productId'] is Map
          ? json['productId']['title']
          : 'Unknown Product',
      productImage: json['productId'] is Map
          ? json['productId']['featuredImageUrl'] ??
                (json['productId']['featuredImage'] is Map
                    ? json['productId']['featuredImage']['url']
                    : null)
          : null,
      sellerName: json['sellerId'] is Map
          ? json['sellerId']['shopName'] ?? json['sellerId']['businessName']
          : 'Unknown Seller',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
      subtotal: (json['subtotal'] as num).toDouble(),
      isRequested: json['isRequested'] ?? false,
      selectedVariant: json['selectedVariant'],
      selectedSize: json['selectedSize'],
    );
  }

  // PRICE CALCULATION METHODS
  double calculateSubtotal() => price * quantity;

  double calculateShipping() {
    final subtotal = calculateSubtotal();
    return subtotal > 500 ? 0.0 : 49.99;
  }

  double calculateTax() {
    final subtotal = calculateSubtotal();
    return subtotal * 0.08; // 8% tax
  }

  double calculateTotal() {
    final subtotal = calculateSubtotal();
    final shipping = calculateShipping();
    final tax = calculateTax();
    return subtotal + shipping + tax;
  }

  Map<String, double> getPriceBreakdown() {
    final subtotal = calculateSubtotal();
    final shipping = calculateShipping();
    final tax = calculateTax();
    final total = subtotal + shipping + tax;

    return {
      'unitPrice': price,
      'subtotal': subtotal,
      'shippingFee': shipping,
      'tax': tax,
      'total': total,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'selectedVariant': selectedVariant,
      'selectedSize': selectedSize,
    };
  }
}
// // lib/data/models/cart_item.dart
// class CartItemModelData {
//   final String id;
//   final String productId;
//   final String productName;
//   final String? productImage;
//   final String sellerName;
//   final double price;
//   int quantity;
//   double subtotal;
//   bool isRequested;
//   String? selectedVariant;
//   String? selectedSize;
//   // String? selectedCartItemIds;

//   CartItemModelData({
//     required this.id,
//     required this.productId,
//     required this.productName,
//     // required this.selectedCartItemIds,
//     this.productImage,
//     required this.sellerName,
//     required this.price,
//     required this.quantity,
//     required this.subtotal,
//     this.isRequested = false,
//     this.selectedVariant,
//     this.selectedSize,
//   });

//   factory CartItemModelData.fromJson(Map<String, dynamic> json) {
//     return CartItemModelData(
//       id: json['_id'],
//       productId: json['productId'] is Map
//           ? json['productId']['_id']
//           : json['productId'].toString(),
//       productName: json['productId'] is Map
//           ? json['productId']['title']
//           : 'Unknown Product',
//       // // selectedCartItemIds: json['selectedCartItemIds'],
//       productImage: json['productId'] is Map
//           ? json['productId']['featuredImageUrl'] ??
//                 (json['productId']['featuredImage'] is Map
//                     ? json['productId']['featuredImage']['url']
//                     : null)
//           : null,
//       sellerName: json['sellerId'] is Map
//           ? json['sellerId']['shopName'] ?? json['sellerId']['businessName']
//           : 'Unknown Seller',
//       price: (json['price'] as num).toDouble(),
//       quantity: json['quantity'] ?? 1,
//       subtotal: (json['subtotal'] as num).toDouble(),
//       isRequested: json['isRequested'] ?? false,
//       selectedVariant: json['selectedVariant'],
//       selectedSize: json['selectedSize'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'productId': productId,
//       'quantity': quantity,
//       'selectedVariant': selectedVariant,
//       'selectedSize': selectedSize,
//     };
//   }
// }
