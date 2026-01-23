// models/uploaded_product_model.dart
import 'dart:developer';

class UploadedProductModel {
  final String id;
  final String sellerId;
  final String title;
  final String shortDescription;
  final String description;
  final String productType;
  final String category;
  final List<String> tags;
  final double price;
  final double taxRate;
  final String currency;
  final String priceUnit;
  final int stockQuantity;
  final int lowStockAlert;
  final List<ProductVariant> variants;
  final String featuredImage;
  final List<String> images;
  final String availability;
  final String location;
  final int completedProjects;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductRatings ratings;

  UploadedProductModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.productType,
    required this.category,
    required this.tags,
    required this.price,
    required this.taxRate,
    required this.currency,
    required this.priceUnit,
    required this.stockQuantity,
    required this.lowStockAlert,
    required this.variants,
    required this.featuredImage,
    required this.images,
    required this.availability,
    required this.location,
    required this.completedProjects,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.ratings,
  });

  factory UploadedProductModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse ID (can be _id or id)
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

      // Parse sellerId
      final sellerId = json['sellerId']?.toString() ?? '';

      // Parse dates
      DateTime? createdAt;
      DateTime? updatedAt;
      try {
        if (json['createdAt'] != null) {
          createdAt = DateTime.parse(json['createdAt'].toString());
        }
        if (json['updatedAt'] != null) {
          updatedAt = DateTime.parse(json['updatedAt'].toString());
        }
      } catch (e) {
        log('⚠️ Error parsing dates: $e');
        createdAt = DateTime.now();
        updatedAt = DateTime.now();
      }

      // Parse variants
      final variants = <ProductVariant>[];
      if (json['variants'] != null && json['variants'] is List) {
        for (var variant in json['variants']) {
          try {
            variants.add(ProductVariant.fromJson(variant));
          } catch (e) {
            log('⚠️ Error parsing variant: $e');
          }
        }
      }

      // Parse images
      final images = <String>[];
      if (json['images'] != null && json['images'] is List) {
        for (var img in json['images']) {
          if (img != null && img.toString().isNotEmpty) {
            images.add(img.toString());
          }
        }
      }

      // Parse tags
      final tags = <String>[];
      if (json['tags'] != null && json['tags'] is List) {
        for (var tag in json['tags']) {
          if (tag != null && tag.toString().isNotEmpty) {
            tags.add(tag.toString());
          }
        }
      }

      // Parse ratings
      final ratings = ProductRatings.fromJson(
        json['ratings'] ?? {'average': 0, 'count': 0},
      );

      return UploadedProductModel(
        id: id,
        sellerId: sellerId,
        title: json['title']?.toString() ?? 'Untitled',
        shortDescription: json['shortDescription']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        productType: json['productType']?.toString() ?? 'Ready Product',
        category: json['category']?.toString() ?? 'Uncategorized',
        tags: tags,
        price: _parseDouble(json['price']),
        taxRate: _parseDouble(json['taxRate']),
        currency: json['currency']?.toString() ?? 'USD',
        priceUnit: json['priceUnit']?.toString() ?? 'per item',
        stockQuantity: json['stockQuantity'] ?? 0,
        lowStockAlert: json['lowStockAlert'] ?? 2,
        variants: variants,
        featuredImage: json['featuredImage']?.toString() ?? '',
        images: images,
        availability: json['availability']?.toString() ?? 'available',
        location: json['location']?.toString() ?? '',
        completedProjects: json['completedProjects'] ?? 0,
        isActive: json['isActive'] ?? true,
        createdAt: createdAt ?? DateTime.now(),
        updatedAt: updatedAt ?? DateTime.now(),
        ratings: ratings,
      );
    } catch (e) {
      log('❌ Error parsing UploadedProductModel: $e');
      log('   JSON: $json');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper getters
  bool get hasImages => images.isNotEmpty || featuredImage.isNotEmpty;
  String get displayImage => featuredImage.isNotEmpty
      ? featuredImage
      : (images.isNotEmpty ? images.first : '');
  bool get isAvailable => availability == 'available' && isActive;
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get statusText => isActive ? 'Active' : 'Inactive';
}

class ProductVariant {
  final String type;
  final String value;
  final double priceAdjustment;
  final String? id;

  ProductVariant({
    required this.type,
    required this.value,
    required this.priceAdjustment,
    this.id,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      priceAdjustment: _parseDouble(json['priceAdjustment']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ProductRatings {
  final double average;
  final int count;

  ProductRatings({required this.average, required this.count});

  factory ProductRatings.fromJson(Map<String, dynamic> json) {
    return ProductRatings(
      average: _parseDouble(json['average']),
      count: json['count'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
