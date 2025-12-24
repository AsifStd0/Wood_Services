// models/seller/seller_product_model.dart
class SellerProduct {
  final String? id;
  final String title;
  final String shortDescription;
  final String longDescription;
  final String category;
  final List<String> tags;
  final double basePrice;
  final double? salePrice;
  final double? costPrice;
  final double taxRate;
  final String currency;
  final String sku;
  final int stockQuantity;
  final int? lowStockAlert;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final String dimensionSpec;
  final List<ProductVariant> variants;
  final List<String> variantTypes;
  final List<String> images;
  final List<String> videos;
  final String status;
  final bool isActive;

  // ✅ REMOVE BUYER FIELDS from Seller model
  // These should ONLY be in BuyerProductModel
  // final double rating;
  // final int reviewCount;
  // final List<Review>? reviews;
  // final int views;
  // final int salesCount;
  // final double finalPrice;
  // final bool hasDiscount;
  // final double discountPercentage;
  // final bool inStock;
  // final bool? isFavorited;
  // final String? favoriteId;

  SellerProduct({
    this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.category,
    required this.tags,
    required this.basePrice,
    this.salePrice,
    this.costPrice,
    this.taxRate = 0.0,
    this.currency = 'USD',
    this.sku = '',
    this.stockQuantity = 0,
    this.lowStockAlert = 5,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.dimensionSpec = '',
    this.variants = const [],
    this.variantTypes = const [],
    this.images = const [],
    this.videos = const [],
    this.status = 'draft',
    this.isActive = true,
  });

  // Factory constructor for JSON from backend
  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    return SellerProduct(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      longDescription: json['longDescription'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      basePrice: (json['basePrice'] ?? 0.0).toDouble(),
      salePrice: json['salePrice']?.toDouble(),
      costPrice: json['costPrice']?.toDouble(),
      taxRate: (json['taxRate'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      sku: json['sku'] ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      lowStockAlert: json['lowStockAlert'],
      weight: json['weight']?.toDouble(),
      length: json['length']?.toDouble(),
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      dimensionSpec: json['dimensionSpec'] ?? '',
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((item) => ProductVariant.fromJson(item))
              .toList() ??
          [],
      variantTypes: List<String>.from(json['variantTypes'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      status: json['status'] ?? 'draft',
      isActive: json['isActive'] ?? true,
    );
  }

  // Copy with method
  SellerProduct copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? longDescription,
    String? category,
    List<String>? tags,
    double? basePrice,
    double? salePrice,
    double? costPrice,
    double? taxRate,
    String? currency,
    String? sku,
    int? stockQuantity,
    int? lowStockAlert,
    double? weight,
    double? length,
    double? width,
    double? height,
    String? dimensionSpec,
    List<ProductVariant>? variants,
    List<String>? variantTypes,
    List<String>? images,
    List<String>? videos,
    String? status,
    bool? isActive,
  }) {
    return SellerProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      basePrice: basePrice ?? this.basePrice,
      salePrice: salePrice ?? this.salePrice,
      costPrice: costPrice ?? this.costPrice,
      taxRate: taxRate ?? this.taxRate,
      currency: currency ?? this.currency,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      dimensionSpec: dimensionSpec ?? this.dimensionSpec,
      variants: variants ?? this.variants,
      variantTypes: variantTypes ?? this.variantTypes,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
    );
  }

  // Convert to JSON for API upload
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'category': category,
      'tags': tags,
      'basePrice': basePrice,
      if (salePrice != null) 'salePrice': salePrice,
      if (costPrice != null) 'costPrice': costPrice,
      'taxRate': taxRate,
      'currency': currency,
      'sku': sku,
      'stockQuantity': stockQuantity,
      if (lowStockAlert != null) 'lowStockAlert': lowStockAlert,
      if (weight != null) 'weight': weight,
      if (length != null) 'length': length,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'dimensionSpec': dimensionSpec,
      'variants': variants.map((v) => v.toJson()).toList(),
      'variantTypes': variantTypes,
      'images': images,
      'videos': videos,
      'status': status,
      'isActive': isActive,
    };
  }
}

// ProductVariant model
class ProductVariant {
  final String? id;
  final String type;
  final String name;
  final String? value;
  final double priceAdjustment;
  final String? sku;
  final int stock;
  final bool isActive;

  ProductVariant({
    this.id,
    required this.type,
    required this.name,
    this.value,
    this.priceAdjustment = 0.0,
    this.sku,
    this.stock = 0,
    this.isActive = true,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'] ?? json['id'],
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      value: json['value'],
      priceAdjustment: (json['priceAdjustment'] ?? 0.0).toDouble(),
      sku: json['sku'],
      stock: json['stock'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toLowerCase(),
      'name': name,
      'value': value,
      'priceAdjustment': priceAdjustment,
      'sku': sku,
      'stock': stock,
      'isActive': isActive,
    };
  }
}

// class SellerProduct {
//   final String? id;
//   final String title;
//   final String shortDescription;
//   final String longDescription;
//   final String category;
//   final List<String> tags;
//   final double basePrice;
//   final double? salePrice;
//   final double? costPrice;
//   final double taxRate;
//   final String currency;
//   final String sku;
//   final int stockQuantity;
//   final int? lowStockAlert;
//   final double? weight;
//   final double? length;
//   final double? width;
//   final double? height;
//   final String dimensionSpec;
//   final List<ProductVariant> variants;
//   final List<String> variantTypes;
//   final List<String> images;
//   final List<String> videos;
//   final String status;
//   final bool isActive;

//   // ========== BUYER-SPECIFIC FIELDS ==========
//   // Rating & Reviews
//   final double rating;
//   final int reviewCount;
//   final List<Review>? reviews;

//   // Performance metrics
//   final int views;
//   final int salesCount;

//   // ✅ Remove these from constructor parameters - they're calculated internally
//   final double finalPrice;
//   final bool hasDiscount;
//   final double discountPercentage;

//   // Stock status
//   final bool inStock;

//   // Favorite tracking (for buyer display)
//   final bool? isFavorited;
//   final String? favoriteId;

//   SellerProduct({
//     this.id,
//     required this.title,
//     required this.shortDescription,
//     required this.longDescription,
//     required this.category,
//     required this.tags,
//     required this.basePrice,
//     this.salePrice,
//     this.costPrice,
//     this.taxRate = 0.0,
//     this.currency = 'USD',
//     this.sku = '',
//     this.stockQuantity = 0,
//     this.lowStockAlert = 5,
//     this.weight,
//     this.length,
//     this.width,
//     this.height,
//     this.dimensionSpec = '',
//     this.variants = const [],
//     this.variantTypes = const [],
//     this.images = const [],
//     this.videos = const [],
//     this.status = 'draft',
//     this.isActive = true,
//     this.rating = 0.0,
//     this.reviewCount = 0,
//     this.reviews,
//     this.views = 0,
//     this.salesCount = 0,
//     this.isFavorited,
//     this.favoriteId,
//     // ✅ REMOVE THESE - they're calculated below
//     // this.finalPrice,
//     // this.discountPercentage,
//     // this.hasDiscount,
//     // this.inStock,
//   }) : // ✅ Use initializer list (before constructor body)
//        finalPrice = salePrice ?? basePrice,
//        hasDiscount = salePrice != null && salePrice < basePrice,
//        discountPercentage = (salePrice != null && salePrice < basePrice)
//            ? ((basePrice - (salePrice ?? basePrice)) / basePrice * 100)
//            : 0.0,
//        inStock = stockQuantity > 0 {
//     // Constructor body (optional)
//   }

//   // Factory constructor for JSON
//   factory SellerProduct.fromJson(Map<String, dynamic> json) {
//     // Parse reviews if they exist
//     List<Review>? reviews;
//     if (json['reviews'] != null && json['reviews'] is List) {
//       reviews = (json['reviews'] as List)
//           .map((review) => Review.fromJson(review))
//           .toList();
//     }

//     // Calculate values
//     final basePrice = (json['basePrice'] ?? 0.0).toDouble();
//     final salePrice = json['salePrice']?.toDouble();
//     final stockQuantity = json['stockQuantity'] ?? 0;

//     // These will be calculated in initializer list
//     final finalPrice = salePrice ?? basePrice;
//     final hasDiscount = salePrice != null && salePrice < basePrice;
//     final discountPercentage = hasDiscount
//         ? ((basePrice - finalPrice) / basePrice * 100)
//         : 0.0;
//     final inStock = stockQuantity > 0;

//     return SellerProduct(
//       id: json['_id'] ?? json['id'],
//       title: json['title'] ?? '',
//       shortDescription: json['shortDescription'] ?? '',
//       longDescription: json['longDescription'] ?? '',
//       category: json['category'] ?? '',
//       tags: List<String>.from(json['tags'] ?? []),
//       basePrice: basePrice,
//       salePrice: salePrice,
//       costPrice: json['costPrice']?.toDouble(),
//       taxRate: (json['taxRate'] ?? 0.0).toDouble(),
//       currency: json['currency'] ?? 'USD',
//       sku: json['sku'] ?? '',
//       stockQuantity: stockQuantity,
//       lowStockAlert: json['lowStockAlert'],
//       weight: json['weight']?.toDouble(),
//       length: json['length']?.toDouble(),
//       width: json['width']?.toDouble(),
//       height: json['height']?.toDouble(),
//       dimensionSpec: json['dimensionSpec'] ?? '',
//       variants:
//           (json['variants'] as List<dynamic>?)
//               ?.map((item) => ProductVariant.fromJson(item))
//               .toList() ??
//           [],
//       variantTypes: List<String>.from(json['variantTypes'] ?? []),
//       images: List<String>.from(json['images'] ?? []),
//       videos: List<String>.from(json['videos'] ?? []),
//       status: json['status'] ?? 'draft',
//       isActive: json['isActive'] ?? true,
//       rating: (json['rating'] ?? 0.0).toDouble(),
//       reviewCount: json['reviewCount'] ?? 0,
//       reviews: reviews,
//       views: json['views'] ?? 0,
//       salesCount: json['salesCount'] ?? 0,
//       isFavorited: json['isFavorited'] ?? false,
//       favoriteId: json['favoriteId']?.toString(),
//       // ✅ DON'T pass calculated fields - they're calculated in initializer
//     );
//   }

//   // Copy with method
//   SellerProduct copyWith({
//     String? id,
//     String? title,
//     String? shortDescription,
//     String? longDescription,
//     String? category,
//     List<String>? tags,
//     double? basePrice,
//     double? salePrice,
//     double? costPrice,
//     double? taxRate,
//     String? currency,
//     String? sku,
//     int? stockQuantity,
//     int? lowStockAlert,
//     double? weight,
//     double? length,
//     double? width,
//     double? height,
//     String? dimensionSpec,
//     List<ProductVariant>? variants,
//     List<String>? variantTypes,
//     List<String>? images,
//     List<String>? videos,
//     String? status,
//     bool? isActive,
//     double? rating,
//     int? reviewCount,
//     List<Review>? reviews,
//     int? views,
//     int? salesCount,
//     bool? isFavorited,
//     String? favoriteId,
//   }) {
//     return SellerProduct(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       shortDescription: shortDescription ?? this.shortDescription,
//       longDescription: longDescription ?? this.longDescription,
//       category: category ?? this.category,
//       tags: tags ?? this.tags,
//       basePrice: basePrice ?? this.basePrice,
//       salePrice: salePrice ?? this.salePrice,
//       costPrice: costPrice ?? this.costPrice,
//       taxRate: taxRate ?? this.taxRate,
//       currency: currency ?? this.currency,
//       sku: sku ?? this.sku,
//       stockQuantity: stockQuantity ?? this.stockQuantity,
//       lowStockAlert: lowStockAlert ?? this.lowStockAlert,
//       weight: weight ?? this.weight,
//       length: length ?? this.length,
//       width: width ?? this.width,
//       height: height ?? this.height,
//       dimensionSpec: dimensionSpec ?? this.dimensionSpec,
//       variants: variants ?? this.variants,
//       variantTypes: variantTypes ?? this.variantTypes,
//       images: images ?? this.images,
//       videos: videos ?? this.videos,
//       status: status ?? this.status,
//       isActive: isActive ?? this.isActive,
//       rating: rating ?? this.rating,
//       reviewCount: reviewCount ?? this.reviewCount,
//       reviews: reviews ?? this.reviews,
//       views: views ?? this.views,
//       salesCount: salesCount ?? this.salesCount,
//       isFavorited: isFavorited ?? this.isFavorited,
//       favoriteId: favoriteId ?? this.favoriteId,
//     );
//   }

//   // Convert to JSON for API upload
//   Map<String, dynamic> toJson() {
//     return {
//       if (id != null) 'id': id,
//       'title': title,
//       'shortDescription': shortDescription,
//       'longDescription': longDescription,
//       'category': category,
//       'tags': tags,
//       'basePrice': basePrice,
//       if (salePrice != null) 'salePrice': salePrice,
//       if (costPrice != null) 'costPrice': costPrice,
//       'taxRate': taxRate,
//       'currency': currency,
//       'sku': sku,
//       'stockQuantity': stockQuantity,
//       if (lowStockAlert != null) 'lowStockAlert': lowStockAlert,
//       if (weight != null) 'weight': weight,
//       if (length != null) 'length': length,
//       if (width != null) 'width': width,
//       if (height != null) 'height': height,
//       'dimensionSpec': dimensionSpec,
//       'variants': variants.map((v) => v.toJson()).toList(),
//       'variantTypes': variantTypes,
//       'images': images,
//       'videos': videos,
//       'status': status,
//       'isActive': isActive,
//       // Note: The backend will calculate these, so we don't send them
//       // 'finalPrice': finalPrice,
//       // 'hasDiscount': hasDiscount,
//       // 'discountPercentage': discountPercentage,
//       // 'inStock': inStock,
//     };
//   }

//   @override
//   String toString() {
//     return '''
// SellerProduct(
//   id: $id,
//   title: $title,
//   basePrice: $basePrice,
//   salePrice: ${salePrice ?? 'none'},
//   finalPrice: $finalPrice,
//   hasDiscount: $hasDiscount (${discountPercentage}%),
//   inStock: $inStock (Qty: $stockQuantity),
//   status: $status
// )''';
//   }
// }

// // Review model
// class Review {
//   final String id;
//   final String userId;
//   final String userName;
//   final String userImage;
//   final int rating;
//   final String comment;
//   final DateTime createdAt;
//   final bool verifiedPurchase;

//   Review({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     required this.userImage,
//     required this.rating,
//     required this.comment,
//     required this.createdAt,
//     this.verifiedPurchase = false,
//   });

//   factory Review.fromJson(Map<String, dynamic> json) {
//     return Review(
//       id: json['_id'] ?? json['id'],
//       userId: json['userId'] ?? '',
//       userName: json['userName'] ?? 'Anonymous',
//       userImage: json['userImage'] ?? '',
//       rating: json['rating'] ?? 0,
//       comment: json['comment'] ?? '',
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
//       verifiedPurchase: json['verifiedPurchase'] ?? false,
//     );
//   }
// }

// // ProductVariant model
// class ProductVariant {
//   final String? id;
//   final String type;
//   final String name;
//   final String? value;
//   final double priceAdjustment;
//   final String? sku;
//   final int stock;
//   final bool isActive;

//   ProductVariant({
//     this.id,
//     required this.type,
//     required this.name,
//     this.value,
//     this.priceAdjustment = 0.0,
//     this.sku,
//     this.stock = 0,
//     this.isActive = true,
//   });

//   factory ProductVariant.fromJson(Map<String, dynamic> json) {
//     return ProductVariant(
//       id: json['_id'] ?? json['id'],
//       type: json['type'] ?? '',
//       name: json['name'] ?? '',
//       value: json['value'],
//       priceAdjustment: (json['priceAdjustment'] ?? 0.0).toDouble(),
//       sku: json['sku'],
//       stock: json['stock'] ?? 0,
//       isActive: json['isActive'] ?? true,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'type': type.toLowerCase(),
//       'name': name,
//       'value': value,
//       'priceAdjustment': priceAdjustment,
//       'sku': sku,
//       'stock': stock,
//       'isActive': isActive,
//     };
//   }
// }
