// models/shop_model.dart
class SellerShopModel {
  final String shopName;
  final String description;
  final double rating;
  final int reviewCount;
  final String? bannerImage;
  final List<String> categories;
  final String deliveryLeadTime;
  final String returnPolicy;
  final bool isVerified;

  SellerShopModel({
    required this.shopName,
    required this.description,
    required this.rating,
    required this.reviewCount,
    this.bannerImage,
    required this.categories,
    required this.deliveryLeadTime,
    required this.returnPolicy,
    required this.isVerified,
  });

  SellerShopModel copyWith({
    String? shopName,
    String? description,
    double? rating,
    int? reviewCount,
    String? bannerImage,
    List<String>? categories,
    String? deliveryLeadTime,
    String? returnPolicy,
    bool? isVerified,
  }) {
    return SellerShopModel(
      shopName: shopName ?? this.shopName,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      bannerImage: bannerImage ?? this.bannerImage,
      categories: categories ?? this.categories,
      deliveryLeadTime: deliveryLeadTime ?? this.deliveryLeadTime,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
