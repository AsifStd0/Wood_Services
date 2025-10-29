// models/shop_model.dart
class ShopModel {
  final String id;
  final String sellerId;
  final String shopName;
  final String ownerName;
  final String description;
  final String? bannerImage;
  final String? logoImage;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final int deliveryLeadTime;
  final String returnPolicy;
  final bool isVerified;
  final String phoneNumber;
  final String email;
  final String address;
  final List<ShopDocument> documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopModel({
    this.id = '',
    required this.sellerId,
    required this.shopName,
    required this.ownerName,
    required this.description,
    this.bannerImage,
    this.logoImage,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.categories = const [],
    this.deliveryLeadTime = 7,
    this.returnPolicy = '30 days',
    this.isVerified = false,
    required this.phoneNumber,
    required this.email,
    required this.address,
    this.documents = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  ShopModel copyWith({
    String? id,
    String? sellerId,
    String? shopName,
    String? ownerName,
    String? description,
    String? bannerImage,
    String? logoImage,
    double? rating,
    int? reviewCount,
    List<String>? categories,
    int? deliveryLeadTime,
    String? returnPolicy,
    bool? isVerified,
    String? phoneNumber,
    String? email,
    String? address,
    List<ShopDocument>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      description: description ?? this.description,
      bannerImage: bannerImage ?? this.bannerImage,
      logoImage: logoImage ?? this.logoImage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      categories: categories ?? this.categories,
      deliveryLeadTime: deliveryLeadTime ?? this.deliveryLeadTime,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      isVerified: isVerified ?? this.isVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ShopDocument {
  final String id;
  final String name;
  final String url;
  final String type; // 'license', 'tax_certificate', 'identity', etc.
  final DateTime uploadDate;
  final bool isVerified;

  ShopDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadDate,
    this.isVerified = false,
  });
}
