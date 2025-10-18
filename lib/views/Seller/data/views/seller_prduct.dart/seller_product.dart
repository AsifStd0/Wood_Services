// lib/models/product_model.dart
class SellerProduct {
  String? id;
  String title;
  String shortDescription;
  String longDescription;
  String? category;
  List<String> tags;
  double? price;
  int? stock;
  List<String>? mediaUrls;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isPublished;

  SellerProduct({
    this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    this.category,
    this.tags = const [],
    this.price,
    this.stock,
    this.mediaUrls,
    this.createdAt,
    this.updatedAt,
    this.isPublished = false,
  });

  SellerProduct copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? longDescription,
    String? category,
    List<String>? tags,
    double? price,
    int? stock,
    List<String>? mediaUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
  }) {
    return SellerProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'category': category,
      'tags': tags,
      'price': price,
      'stock': stock,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPublished': isPublished,
    };
  }

  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    return SellerProduct(
      id: json['id'],
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      longDescription: json['longDescription'] ?? '',
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      price: json['price'],
      stock: json['stock'],
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isPublished: json['isPublished'] ?? false,
    );
  }
}
