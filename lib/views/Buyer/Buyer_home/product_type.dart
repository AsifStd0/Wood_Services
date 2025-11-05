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
