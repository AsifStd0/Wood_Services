class BuyerProductModel {
  final String id;
  final dynamic seller; // Could be String or Map
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
  final List<Variant> variants;
  final String? featuredImage;
  final List<String> imageGallery;
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

  BuyerProductModel({
    required this.id,
    this.seller,
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
    required this.variants,
    this.featuredImage,
    required this.imageGallery,
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
  });

  // Add this COPY WITH method
  BuyerProductModel copyWith({
    String? id,
    dynamic seller,
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
    List<Variant>? variants,
    String? featuredImage,
    List<String>? imageGallery,
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
  }) {
    return BuyerProductModel(
      id: id ?? this.id,
      seller: seller ?? this.seller,
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
      variants: variants ?? this.variants,
      featuredImage: featuredImage ?? this.featuredImage,
      imageGallery: imageGallery ?? this.imageGallery,
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
    );
  }

  factory BuyerProductModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Available fields: ${json.keys.join(', ')}');

    // Check for longDescription
    if (json.containsKey('longDescription')) {
      print('🔍 longDescription exists: ${json['longDescription']}');
    } else {
      print('🔍 longDescription NOT in API response');
    }

    // Check for costPrice
    if (json.containsKey('costPrice')) {
      print('🔍 costPrice exists: ${json['costPrice']}');
    } else {
      print('🔍 costPrice NOT in API response');
    }

    // Check for taxRate
    if (json.containsKey('taxRate')) {
      print('🔍 taxRate exists: ${json['taxRate']}');
    } else {
      print('🔍 taxRate NOT in API response');
    }

    // Check for status
    if (json.containsKey('status')) {
      print('🔍 status exists: ${json['status']}');
    } else {
      print('🔍 status NOT in API response');
    }

    return BuyerProductModel(
      // ID
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'unknown_id',

      // Seller
      seller: json['seller'],

      // Basic info
      title: json['title']?.toString() ?? 'Untitled Product',
      shortDescription:
          json['shortDescription']?.toString() ?? 'No description',

      // 🔥 Check if longDescription exists in API
      longDescription: json['longDescription']?.toString() ?? '',

      category: json['category']?.toString() ?? 'Uncategorized',

      tags: _parseStringList(json['tags']),

      // Pricing - use API values
      basePrice: _parseDouble(json['basePrice']),
      salePrice: _parseDouble(json['salePrice']),

      // These might not be in API response
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
      weight: _parseDouble(json['weight']),

      // Dimensions
      dimensions: json['dimensions'] != null && json['dimensions'] is Map
          ? ProductDimensions.fromJson(json['dimensions'])
          : null,

      // Variants
      variants: _parseVariants(json['variants']),

      // Images - handle both String and Map
      featuredImage: _parseImageField(json['featuredImage']),
      imageGallery: _parseImageGallery(json['imageGallery']),

      // Status - check if exists in API
      status: json['status']?.toString() ?? 'draft',

      // isActive might not be in API - check
      isActive: json.containsKey('isActive')
          ? (json['isActive'] ?? true)
          : true,

      views: json['views'] ?? 0,
      salesCount: json['salesCount'] ?? 0,

      // NEW fields from API
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
    );
  }

  // Helper method for image fields
  static String? _parseImageField(dynamic imageData) {
    if (imageData == null) return null;

    if (imageData is String) {
      return imageData;
    } else if (imageData is Map) {
      // Could be {url: "...", publicId: "..."}
      return imageData['url']?.toString();
    }

    return imageData.toString();
  }

  // Helper method for image gallery
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

  // Other helper methods stay the same...
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

  // Fix the inStock logic
  bool get isInStock => inStock && stockQuantity > 0;

  @override
  String toString() {
    return '''
BuyerProductModel(
  id: $id,
  title: $title,
  shortDescription: $shortDescription,
  longDescription: ${longDescription.isNotEmpty ? longDescription : "NULL"},
  category: $category,
  price: $finalPrice (Base: $basePrice, Sale: $salePrice),
  discount: $discountPercentage%,
  stock: $stockQuantity (API inStock: $inStock, Calculated: $isInStock),
  status: $status,
  isActive: $isActive,
  costPrice: ${costPrice ?? "NULL"},
  taxRate: ${taxRate ?? "NULL"},
  variants: ${variants.length},
  images: ${imageGallery.length},
  views: $views,
  sales: $salesCount,
  isFavorited: $isFavorited,
  favoriteId: ${favoriteId ?? "NULL"}
)
''';
  }
}

// Also add copyWith to Variant class
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

  // Add copyWith to Variant too
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
      priceAdjustment: (json['priceAdjustment'] ?? 0).toDouble(),
      sku: json['sku']?.toString(),
      stock: json['stock'] is int ? json['stock'] : null,
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  String toString() =>
      '$type: $value (+${priceAdjustment}${priceAdjustment > 0 ? ' extra' : ''})';
}

// Also add copyWith to ProductDimensions
class ProductDimensions {
  final double length;
  final double width;
  final double height;

  ProductDimensions({
    required this.length,
    required this.width,
    required this.height,
  });

  // Add copyWith to ProductDimensions
  ProductDimensions copyWith({double? length, double? width, double? height}) {
    return ProductDimensions(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      length: (json['length'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
    );
  }

  @override
  String toString() => '${length}L x ${width}W x ${height}H';
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
