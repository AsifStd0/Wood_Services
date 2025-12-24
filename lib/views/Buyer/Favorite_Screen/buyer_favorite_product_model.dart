// models/favorite_model.dart
class FavoriteProduct {
  final String id;
  final String productId;
  final String title;
  final String shortDescription;
  final String? longDescription;
  final String category;
  final double basePrice;
  final double? salePrice;
  final double finalPrice;
  final double discountPercentage;
  final String? featuredImage;
  final List<String> imageGallery;
  final bool inStock;
  final int stockQuantity;
  final int salesCount;
  final double rating;
  final int views;
  final DateTime addedDate;

  FavoriteProduct({
    required this.id,
    required this.productId,
    required this.title,
    required this.shortDescription,
    this.longDescription,
    required this.category,
    required this.basePrice,
    this.salePrice,
    required this.finalPrice,
    required this.discountPercentage,
    this.featuredImage,
    required this.imageGallery,
    required this.inStock,
    required this.stockQuantity,
    required this.salesCount,
    required this.rating,
    required this.views,
    required this.addedDate,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'No Title',
      shortDescription: json['shortDescription']?.toString() ?? '',
      longDescription: json['longDescription']?.toString(),
      category: json['category']?.toString() ?? 'Uncategorized',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      featuredImage: json['featuredImage']?.toString(),
      imageGallery:
          (json['imageGallery'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      inStock: json['inStock'] ?? false,
      stockQuantity: json['stockQuantity'] ?? 0,
      salesCount: json['salesCount'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      views: json['views'] ?? 0,
      addedDate: DateTime.parse(
        json['addedDate']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'title': title,
    'shortDescription': shortDescription,
    'longDescription': longDescription,
    'category': category,
    'basePrice': basePrice,
    'salePrice': salePrice,
    'finalPrice': finalPrice,
    'discountPercentage': discountPercentage,
    'featuredImage': featuredImage,
    'imageGallery': imageGallery,
    'inStock': inStock,
    'stockQuantity': stockQuantity,
    'salesCount': salesCount,
    'rating': rating,
    'views': views,
    'addedDate': addedDate.toIso8601String(),
  };
}

// Response models
class FavoriteResponse {
  final bool success;
  final String message;
  final bool isFavorited;
  final int favoriteCount;

  FavoriteResponse({
    required this.success,
    required this.message,
    required this.isFavorited,
    required this.favoriteCount,
  });

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      isFavorited: json['data']['isFavorited'] ?? false,
      favoriteCount: json['data']['favoriteCount'] ?? 0,
    );
  }
}

class FavoritesListResponse {
  final bool success;
  final String message;
  final List<FavoriteProduct> favorites;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  FavoritesListResponse({
    required this.success,
    required this.message,
    required this.favorites,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory FavoritesListResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesListResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      favorites:
          (json['favorites'] as List<dynamic>?)
              ?.map((item) => FavoriteProduct.fromJson(item))
              .toList() ??
          [],
      total: json['pagination']['total'] ?? 0,
      page: json['pagination']['page'] ?? 1,
      limit: json['pagination']['limit'] ?? 20,
      hasMore: json['pagination']['hasMore'] ?? false,
    );
  }
}

class FavoriteCheckResponse {
  final bool success;
  final bool isFavorited;
  final String? favoriteId;

  FavoriteCheckResponse({
    required this.success,
    required this.isFavorited,
    this.favoriteId,
  });

  factory FavoriteCheckResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteCheckResponse(
      success: json['success'] ?? false,
      isFavorited: json['isFavorited'] ?? false,
      favoriteId: json['favoriteId']?.toString(),
    );
  }
}
