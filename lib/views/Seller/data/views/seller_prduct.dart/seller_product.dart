// models/seller_product.dart
class SellerProduct {
  final String id;
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
  final bool trackStock;
  final bool allowBackorders;
  final bool soldIndividually;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final List<String> images;
  final List<String> videos;
  final List<ProductDocument> documents;
  final List<ProductVariant> variants;
  final bool isPublished;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SellerProduct({
    this.id = '',
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    this.category = '',
    required this.tags,
    required this.basePrice,
    this.salePrice,
    this.costPrice,
    this.taxRate = 0.0,
    this.currency = 'USD',
    this.sku = '',
    this.stockQuantity = 0,
    this.lowStockAlert,
    this.trackStock = true,
    this.allowBackorders = false,
    this.soldIndividually = false,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.images = const [],
    this.videos = const [],
    this.documents = const [],
    this.variants = const [],
    this.isPublished = false,
    this.status = ProductStatus.draft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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
    bool? trackStock,
    bool? allowBackorders,
    bool? soldIndividually,
    double? weight,
    double? length,
    double? width,
    double? height,
    List<String>? images,
    List<String>? videos,
    List<ProductDocument>? documents,
    List<ProductVariant>? variants,
    bool? isPublished,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      trackStock: trackStock ?? this.trackStock,
      allowBackorders: allowBackorders ?? this.allowBackorders,
      soldIndividually: soldIndividually ?? this.soldIndividually,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      documents: documents ?? this.documents,
      variants: variants ?? this.variants,
      isPublished: isPublished ?? this.isPublished,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProductDocument {
  final String url;
  final String name;
  final DateTime uploadDate;
  final String? fileSize;

  ProductDocument({
    required this.url,
    required this.name,
    required this.uploadDate,
    this.fileSize,
  });
}

class ProductVariant {
  final String id;
  final String type; // 'size', 'color', 'material', etc.
  final List<VariantOption> options;

  ProductVariant({required this.id, required this.type, required this.options});

  ProductVariant copyWith({
    String? id,
    String? type,
    List<VariantOption>? options,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      type: type ?? this.type,
      options: options ?? this.options,
    );
  }
}

class VariantOption {
  final String name;
  final double priceAdjustment;
  final String? colorCode; // For color variants
  final String? imageUrl; // For variant-specific images

  VariantOption({
    required this.name,
    this.priceAdjustment = 0.0,
    this.colorCode,
    this.imageUrl,
  });
}

enum ProductStatus { draft, published, archived, outOfStock }

// // lib/models/product_model.dart
// class SellerProduct {
//   String? id;
//   String title;
//   String shortDescription;
//   String longDescription;
//   String? category;
//   List<String> tags;
//   double? price;
//   int? stock;
//   List<String>? mediaUrls;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   bool isPublished;

//   SellerProduct({
//     this.id,
//     required this.title,
//     required this.shortDescription,
//     required this.longDescription,
//     this.category,
//     this.tags = const [],
//     this.price,
//     this.stock,
//     this.mediaUrls,
//     this.createdAt,
//     this.updatedAt,
//     this.isPublished = false,
//   });

//   SellerProduct copyWith({
//     String? id,
//     String? title,
//     String? shortDescription,
//     String? longDescription,
//     String? category,
//     List<String>? tags,
//     double? price,
//     int? stock,
//     List<String>? mediaUrls,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     bool? isPublished,
//   }) {
//     return SellerProduct(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       shortDescription: shortDescription ?? this.shortDescription,
//       longDescription: longDescription ?? this.longDescription,
//       category: category ?? this.category,
//       tags: tags ?? this.tags,
//       price: price ?? this.price,
//       stock: stock ?? this.stock,
//       mediaUrls: mediaUrls ?? this.mediaUrls,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       isPublished: isPublished ?? this.isPublished,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'shortDescription': shortDescription,
//       'longDescription': longDescription,
//       'category': category,
//       'tags': tags,
//       'price': price,
//       'stock': stock,
//       'mediaUrls': mediaUrls,
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//       'isPublished': isPublished,
//     };
//   }

//   factory SellerProduct.fromJson(Map<String, dynamic> json) {
//     return SellerProduct(
//       id: json['id'],
//       title: json['title'] ?? '',
//       shortDescription: json['shortDescription'] ?? '',
//       longDescription: json['longDescription'] ?? '',
//       category: json['category'],
//       tags: List<String>.from(json['tags'] ?? []),
//       price: json['price'],
//       stock: json['stock'],
//       mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : null,
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.parse(json['updatedAt'])
//           : null,
//       isPublished: json['isPublished'] ?? false,
//     );
//   }
// }
