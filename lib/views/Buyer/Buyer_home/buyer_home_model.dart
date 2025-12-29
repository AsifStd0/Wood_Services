class BuyerProductModel {
  final String id;
  final dynamic sellerId; // Could be String or Map
  final Map<String, dynamic>? sellerInfo; // NEW: Full seller info
  final String title;
  final String shortDescription;
  final String longDescription;
  final String category;
  final List<String> tags;
  final double basePrice;
  final double? salePrice;
  final double? costPrice;
  final double? taxRate;
  final String currency;
  final bool hasDiscount;
  final String? sku;
  final int stockQuantity;
  final int? lowStockAlert;
  final double? weight;
  final ProductDimensions? dimensions;
  final String? dimensionSpec; // NEW: Additional dimension info
  final List<Variant> variants;
  final List<String> variantTypes; // NEW: Available variant types
  final String? featuredImage;
  final List<String> imageGallery;
  final Map<String, dynamic>? video; // NEW: Video info
  final String status;
  final bool isActive;
  final int views;
  final int salesCount;
  final bool inStock;
  final double finalPrice;
  final double discountPercentage;
  final double? rating;
  final int? reviewCount;
  final bool isFavorited;
  final String? favoriteId;
  final DateTime createdAt; // NEW: Timestamp
  final DateTime updatedAt; // NEW: Timestamp
  final String? createdBy; // NEW: Creator reference

  // Computed properties
  String get sellerName => sellerInfo?['name'] ?? 'Unknown Seller';
  String? get businessName => sellerInfo?['businessName'];
  String? get sellerEmail => sellerInfo?['email'];
  String? get sellerPhone => sellerInfo?['phone'];
  String? get shopName => sellerInfo?['shopName'];
  String? get shopLogo => sellerInfo?['shopLogo'];
  double? get sellerRating => (sellerInfo?['rating'] as num?)?.toDouble();
  int? get sellerTotalProducts => sellerInfo?['totalProducts'];
  String? get sellerVerificationStatus => sellerInfo?['verificationStatus'];

  BuyerProductModel({
    required this.id,
    this.sellerId,
    this.sellerInfo,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.category,
    required this.tags,
    required this.basePrice,
    this.salePrice,
    this.costPrice,
    this.taxRate,
    required this.currency,
    required this.hasDiscount,
    this.sku,
    required this.stockQuantity,
    this.lowStockAlert,
    this.weight,
    this.dimensions,
    this.dimensionSpec,
    required this.variants,
    this.variantTypes = const [],
    this.featuredImage,
    required this.imageGallery,
    this.video,
    required this.status,
    required this.isActive,
    required this.views,
    required this.salesCount,
    required this.inStock,
    required this.finalPrice,
    required this.discountPercentage,
    this.rating,
    this.reviewCount,
    this.isFavorited = false,
    this.favoriteId,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  // COPY WITH method
  BuyerProductModel copyWith({
    String? id,
    dynamic sellerId,
    Map<String, dynamic>? sellerInfo,
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
    bool? hasDiscount,
    String? sku,
    int? stockQuantity,
    int? lowStockAlert,
    double? weight,
    ProductDimensions? dimensions,
    String? dimensionSpec,
    List<Variant>? variants,
    List<String>? variantTypes,
    String? featuredImage,
    List<String>? imageGallery,
    Map<String, dynamic>? video,
    String? status,
    bool? isActive,
    int? views,
    int? salesCount,
    bool? inStock,
    double? finalPrice,
    double? discountPercentage,
    double? rating,
    int? reviewCount,
    bool? isFavorited,
    String? favoriteId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return BuyerProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerInfo: sellerInfo ?? this.sellerInfo,
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
      hasDiscount: hasDiscount ?? this.hasDiscount,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      dimensionSpec: dimensionSpec ?? this.dimensionSpec,
      variants: variants ?? this.variants,
      variantTypes: variantTypes ?? this.variantTypes,
      featuredImage: featuredImage ?? this.featuredImage,
      imageGallery: imageGallery ?? this.imageGallery,
      video: video ?? this.video,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      views: views ?? this.views,
      salesCount: salesCount ?? this.salesCount,
      inStock: inStock ?? this.inStock,
      finalPrice: finalPrice ?? this.finalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavorited: isFavorited ?? this.isFavorited,
      favoriteId: favoriteId ?? this.favoriteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory BuyerProductModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Available fields: ${json.keys.join(', ')}');

    // Debug log for important fields
    final debugFields = [
      'longDescription',
      'costPrice',
      'taxRate',
      'status',
      'sellerInfo',
      'dimensions',
      'variantTypes',
      'createdAt',
      'updatedAt',
    ];

    for (final field in debugFields) {
      if (json.containsKey(field)) {
        print('🔍 $field exists: ${json[field]}');
      } else {
        print('🔍 $field NOT in API response');
      }
    }

    // Parse timestamps
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is String) return DateTime.parse(timestamp).toLocal();
      if (timestamp is int)
        return DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      return DateTime.now();
    }

    return BuyerProductModel(
      // ID
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'unknown_id',

      // Seller info
      sellerId: json['seller'] ?? json['sellerId'],
      sellerInfo: json['sellerInfo'] is Map
          ? Map<String, dynamic>.from(json['sellerInfo'])
          : null,

      // Basic info
      title: json['title']?.toString() ?? 'Untitled Product',
      shortDescription:
          json['shortDescription']?.toString() ?? 'No description',
      longDescription: json['longDescription']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      tags: _parseStringList(json['tags']),

      // Pricing
      basePrice: _parseDouble(json['basePrice']),
      salePrice: _parseDouble(json['salePrice']),
      costPrice: json.containsKey('costPrice')
          ? _parseDouble(json['costPrice'])
          : null,
      taxRate: json.containsKey('taxRate')
          ? _parseDouble(json['taxRate'])
          : null,
      currency: json['currency']?.toString() ?? 'USD',
      hasDiscount: json['hasDiscount'] ?? false,
      sku: json['sku']?.toString(),
      stockQuantity: json['stockQuantity'] ?? 0,
      lowStockAlert: json['lowStockAlert'],

      // Physical properties
      weight: _parseDouble(json['weight']),
      dimensions: json['dimensions'] != null && json['dimensions'] is Map
          ? ProductDimensions.fromJson(json['dimensions'])
          : null,
      dimensionSpec: json['dimensionSpec']?.toString(),

      // Variants
      variants: _parseVariants(json['variants']),
      variantTypes: _parseStringList(json['variantTypes']),

      // Media
      featuredImage: _parseImageField(json['featuredImage']),
      imageGallery: _parseImageGallery(json['imageGallery']),
      video: json['video'] is Map
          ? Map<String, dynamic>.from(json['video'])
          : null,

      // Status
      status: json['status']?.toString() ?? 'draft',
      isActive: json.containsKey('isActive')
          ? (json['isActive'] ?? true)
          : true,

      // Performance metrics
      views: json['views'] ?? 0,
      salesCount: json['salesCount'] ?? 0,

      // Computed fields
      inStock: json['inStock'] ?? false,
      finalPrice: _parseDouble(
        json['finalPrice'] ?? json['salePrice'] ?? json['basePrice'],
      ),
      discountPercentage: _parseDouble(json['discountPercentage'] ?? 0),
      rating: _parseDouble(json['rating']),
      reviewCount: json['reviewCount'],

      // Favorite fields
      isFavorited: json['isFavorited'] ?? false,
      favoriteId: json['favoriteId']?.toString(),

      // Timestamps
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),

      // Creator
      createdBy: json['createdBy']?.toString(),
    );
  }

  // Convert to JSON for sending to API (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerInfo': sellerInfo,
      'title': title,
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'category': category,
      'tags': tags,
      'basePrice': basePrice,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'taxRate': taxRate,
      'currency': currency,
      'hasDiscount': hasDiscount,
      'sku': sku,
      'stockQuantity': stockQuantity,
      'lowStockAlert': lowStockAlert,
      'weight': weight,
      'dimensions': dimensions?.toJson(),
      'dimensionSpec': dimensionSpec,
      'variants': variants.map((v) => v.toJson()).toList(),
      'variantTypes': variantTypes,
      'featuredImage': featuredImage,
      'imageGallery': imageGallery,
      'video': video,
      'status': status,
      'isActive': isActive,
      'views': views,
      'salesCount': salesCount,
      'inStock': inStock,
      'finalPrice': finalPrice,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFavorited': isFavorited,
      'favoriteId': favoriteId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  // Helper methods
  static String? _parseImageField(dynamic imageData) {
    if (imageData == null) return null;

    if (imageData is String) {
      return imageData;
    } else if (imageData is Map) {
      return imageData['url']?.toString();
    }

    return imageData.toString();
  }

  static List<String> _parseImageGallery(dynamic galleryData) {
    if (galleryData == null || galleryData is! List) return <String>[];

    return galleryData
        .map((item) {
          if (item is String) return item;
          if (item is Map) return item['url']?.toString() ?? '';
          return item?.toString() ?? '';
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null || data is! List) return <String>[];

    return data
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<Variant> _parseVariants(dynamic data) {
    if (data == null || data is! List) return <Variant>[];

    return data.map((item) => Variant.fromJson(item)).toList();
  }

  // Computed properties
  bool get isInStock => inStock && stockQuantity > 0;
  bool get isPublished => status == 'published';
  bool get isOnSale => hasDiscount && (salePrice ?? 0) > 0;
  double get savingsAmount => basePrice - finalPrice;
  String get formattedPrice => '\$${finalPrice.toStringAsFixed(2)}';
  String get formattedBasePrice => '\$${basePrice.toStringAsFixed(2)}';
  String get formattedDiscount =>
      '${discountPercentage.toStringAsFixed(0)}% OFF';
  String get stockStatus {
    if (!isActive) return 'Unavailable';
    if (!inStock) return 'Out of Stock';
    if (stockQuantity <= (lowStockAlert ?? 5)) return 'Low Stock';
    return 'In Stock';
  }

  @override
  String toString() {
    return '''
BuyerProductModel(
  id: $id,
  title: $title,
  seller: $sellerName,
  price: $formattedPrice (Base: $formattedBasePrice, Discount: $discountPercentage%),
  stock: $stockQuantity ($stockStatus),
  status: $status,
  isActive: $isActive,
  variants: ${variants.length},
  images: ${imageGallery.length},
  views: $views,
  sales: $salesCount,
  isFavorited: $isFavorited,
  rating: ${rating ?? 'No ratings'},
  createdAt: ${createdAt.toString()}
)
''';
  }
}

// Enhanced Variant class
class Variant {
  final String id;
  final String type;
  final String name;
  final String value;
  final double priceAdjustment;
  final String? sku;
  final int? stock;
  final bool isActive;

  Variant({
    required this.id,
    required this.type,
    required this.name,
    required this.value,
    required this.priceAdjustment,
    this.sku,
    this.stock,
    required this.isActive,
  });

  Variant copyWith({
    String? id,
    String? type,
    String? name,
    String? value,
    double? priceAdjustment,
    String? sku,
    int? stock,
    bool? isActive,
  }) {
    return Variant(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      value: value ?? this.value,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Unknown',
      value: json['value']?.toString() ?? json['name']?.toString() ?? 'Unknown',
      priceAdjustment: _parseDouble(json['priceAdjustment']),
      sku: json['sku']?.toString(),
      stock: json['stock'] is int ? json['stock'] : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'value': value,
      'priceAdjustment': priceAdjustment,
      'sku': sku,
      'stock': stock,
      'isActive': isActive,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    final extra = priceAdjustment > 0
        ? ' (+${priceAdjustment.toStringAsFixed(2)})'
        : '';
    return '$type: $value$extra';
  }
}

// Enhanced ProductDimensions class
class ProductDimensions {
  final double? length;
  final double? width;
  final double? height;

  ProductDimensions({this.length, this.width, this.height});

  ProductDimensions copyWith({double? length, double? width, double? height}) {
    return ProductDimensions(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      length: _parseDouble(json['length']),
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'length': length, 'width': width, 'height': height};
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? get formatted {
    if (length == null && width == null && height == null) return null;
    final parts = <String>[];
    if (length != null) parts.add('${length!.toStringAsFixed(1)}L');
    if (width != null) parts.add('${width!.toStringAsFixed(1)}W');
    if (height != null) parts.add('${height!.toStringAsFixed(1)}H');
    return parts.isNotEmpty ? parts.join(' × ') : null;
  }

  @override
  String toString() => formatted ?? 'No dimensions';
}
// *********
// *********
// *********
// *********
// *********
// *********
// *********
// *********// *********
// *********
// *********
// *********// *********
// *********
// *********
// *********// *********
// *********
// *********
// *********// *********
// *********
// *********
// *********// *********
// *********
// *********
// *********

// Updated FurnitureProductDummyData class with optional properties
class FurnitureProductDummyData {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final String image;
  final String description;
  final double rating;
  final int orders;
  final bool isNew;
  final bool freeDelivery;

  FurnitureProductDummyData({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.image,
    required this.description,
    this.rating = 4.5,
    this.orders = 0,
    this.isNew = false,
    this.freeDelivery = false,
  });
}

final List<FurnitureProductDummyData> furnitureproducts = [
  FurnitureProductDummyData(
    freeDelivery: false, // Has free delivery

    id: '123',
    name: 'Modern Sofa',
    price: 499,
    category: 'Living Room',
    image: 'assets/images/sofa.jpg',
    isNew: true,
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProductDummyData(
    originalPrice: 400,
    freeDelivery: true, // Has free delivery

    id: '123',
    name: 'Dining Table',
    price: 249,
    category: 'Dining Room',
    image: 'assets/images/table.jpg',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProductDummyData(
    freeDelivery: true, // Has free delivery

    id: '123',
    name: 'Accent Chair',
    price: 149,
    category: 'Living Room',
    image: 'assets/images/chair.jpg',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProductDummyData(
    freeDelivery: false, // Has free delivery

    id: '123',
    name: 'Queen Bed',
    price: 599,
    category: 'Bedroom',
    image: 'assets/images/table2.jpg',
    isNew: true,
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProductDummyData(
    originalPrice: 400,
    freeDelivery: true, // Has free delivery

    id: '123',
    name: 'Storage Cabinet',
    price: 349,
    category: 'Bedroom',
    image: 'assets/images/sofa2.jpg',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProductDummyData(
    freeDelivery: true, // Has free delivery

    id: '123',
    name: 'Patio Set',
    price: 799,
    category: 'Outdoor',
    image: 'assets/images/sofa.jpg',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
];

final List<String> categories = [
  'All',
  'Living Room',
  'Dining Room',
  'Bedroom',
  'Entryway',
];

final List<String> productTypes = [
  'Ready Product',
  'Customize Product',
  'Indoor',
  'Outdoor',
];

enum ProductType { readyProduct, customizeProduct }

class Category {
  final String name;
  final bool isSelected;

  Category({required this.name, required this.isSelected});

  Category copyWith({String? name, bool? isSelected}) {
    return Category(
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ProductCategory {
  final String name;
  final bool isSelected;

  ProductCategory({required this.name, required this.isSelected});

  ProductCategory copyWith({String? name, bool? isSelected}) {
    return ProductCategory(
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
