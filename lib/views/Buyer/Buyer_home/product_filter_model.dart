/// Product Filter Model
/// Holds all filter parameters for product search
class ProductFilterModel {
  // Pagination
  int page;
  int limit;

  // Filters
  String? category;
  String? search;
  double? minPrice;
  double? maxPrice;
  String? location;
  List<String>? tags;
  bool? inStock;
  String? sort; // price_asc, price_desc, rating

  ProductFilterModel({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.location,
    this.tags,
    this.inStock,
    this.sort,
  });

  /// Convert to query parameters for API
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (category != null && category!.isNotEmpty) {
      params['category'] = category;
    }
    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }
    if (minPrice != null) {
      params['minPrice'] = minPrice!.toInt();
    }
    if (maxPrice != null) {
      params['maxPrice'] = maxPrice!.toInt();
    }
    if (location != null && location!.isNotEmpty) {
      params['location'] = location;
    }
    if (tags != null && tags!.isNotEmpty) {
      params['tags'] = tags!.join(',');
    }
    if (inStock != null) {
      params['inStock'] = inStock;
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort;
    }

    return params;
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return category != null ||
        (search != null && search!.isNotEmpty) ||
        minPrice != null ||
        maxPrice != null ||
        (location != null && location!.isNotEmpty) ||
        (tags != null && tags!.isNotEmpty) ||
        inStock != null ||
        (sort != null && sort!.isNotEmpty);
  }

  /// Reset all filters
  ProductFilterModel copyWith({
    int? page,
    int? limit,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? location,
    List<String>? tags,
    bool? inStock,
    String? sort,
    bool clearCategory = false,
    bool clearSearch = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearLocation = false,
    bool clearTags = false,
    bool clearInStock = false,
    bool clearSort = false,
  }) {
    return ProductFilterModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      category: clearCategory ? null : (category ?? this.category),
      search: clearSearch ? null : (search ?? this.search),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      location: clearLocation ? null : (location ?? this.location),
      tags: clearTags ? null : (tags ?? this.tags),
      inStock: clearInStock ? null : (inStock ?? this.inStock),
      sort: clearSort ? null : (sort ?? this.sort),
    );
  }

  /// Create a copy with all filters reset
  ProductFilterModel reset() {
    return ProductFilterModel(
      page: 1,
      limit: 10,
    );
  }
}

/// Sort options
enum ProductSortOption {
  priceAsc('price_asc', 'Price: Low to High'),
  priceDesc('price_desc', 'Price: High to Low'),
  rating('rating', 'Highest Rated');

  final String value;
  final String label;

  const ProductSortOption(this.value, this.label);
}
