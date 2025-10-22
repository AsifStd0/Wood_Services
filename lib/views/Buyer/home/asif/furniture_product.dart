class FurnitureProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final bool isNew;

  FurnitureProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    this.isNew = false,
  });
}
