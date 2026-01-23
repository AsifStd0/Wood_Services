import 'dart:io';

class SellerProduct {
  final String? id;

  final String title;
  final String shortDescription;
  final String description;
  final String category;
  final String productType;

  final List<String> tags;

  final double price;
  final double? salePrice;
  final double? costPrice;
  final double taxRate;

  final String currency;
  final String priceUnit;
  final String sku;

  final int stockQuantity;
  final int? lowStockAlert;

  final double? weight;

  final ProductDimensions? dimensions;
  final List<ProductVariant> variants;

  final String location;

  /// FILES (multipart)
  final List<File> images;

  SellerProduct({
    this.id,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.category,
    required this.productType,
    required this.tags,
    required this.price,
    this.salePrice,
    this.costPrice,
    required this.taxRate,
    required this.currency,
    required this.priceUnit,
    required this.sku,
    required this.stockQuantity,
    this.lowStockAlert,
    this.weight,
    this.dimensions,
    this.variants = const [],
    required this.location,
    this.images = const [],
  });

  /// JSON fields only (no files)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'shortDescription': shortDescription,
      'description': description,
      'category': category,
      'productType': productType,
      'tags': tags,
      'price': price,
      if (salePrice != null) 'salePrice': salePrice,
      if (costPrice != null) 'costPrice': costPrice,
      'taxRate': taxRate,
      'currency': currency,
      'priceUnit': priceUnit,
      'sku': sku,
      'stockQuantity': stockQuantity,
      if (lowStockAlert != null) 'lowStockAlert': lowStockAlert,
      if (weight != null) 'weight': weight,
      if (dimensions != null) 'dimensions': dimensions!.toJson(),
      if (variants.isNotEmpty)
        'variants': variants.map((v) => v.toJson()).toList(),
      'location': location,
    };
  }
  // ! ******
  // Add this to your SellerProduct class (in the model file)

  SellerProduct copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? description,
    String? category,
    String? productType,
    List<String>? tags,
    double? price,
    double? salePrice,
    double? costPrice,
    double? taxRate,
    String? currency,
    String? priceUnit,
    String? sku,
    int? stockQuantity,
    int? lowStockAlert,
    double? weight,
    ProductDimensions? dimensions,
    List<ProductVariant>? variants,
    String? location,
    List<File>? images,
  }) {
    return SellerProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      category: category ?? this.category,
      productType: productType ?? this.productType,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      costPrice: costPrice ?? this.costPrice,
      taxRate: taxRate ?? this.taxRate,
      currency: currency ?? this.currency,
      priceUnit: priceUnit ?? this.priceUnit,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      variants: variants ?? this.variants,
      location: location ?? this.location,
      images: images ?? this.images,
    );
  }
}

class ProductDimensions {
  final double length;
  final double width;
  final double height;
  final String? specification;

  ProductDimensions({
    required this.length,
    required this.width,
    required this.height,
    this.specification,
  });

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'width': width,
      'height': height,
      if (specification != null) 'specification': specification,
    };
  }
}

class ProductVariant {
  final String type; // size, color, etc
  final String value;
  final double priceAdjustment;

  ProductVariant({
    required this.type,
    required this.value,
    required this.priceAdjustment,
  });

  Map<String, dynamic> toJson() {
    return {'type': type, 'value': value, 'priceAdjustment': priceAdjustment};
  }
}
