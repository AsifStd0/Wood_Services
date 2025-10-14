// Model for furniture products
class FurnitureProduct {
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final bool isNew;
  final bool isReadyProduct;
  final bool isCustomizable;
  final bool isIndoor;
  final bool isOutdoor;

  const FurnitureProduct({
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isNew = false,
    this.isReadyProduct = true,
    this.isCustomizable = false,
    this.isIndoor = true,
    this.isOutdoor = false,
  });
}
