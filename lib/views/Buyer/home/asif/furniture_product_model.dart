// Updated FurnitureProduct class with optional properties
class FurnitureProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final double? originalPrice; // Nullable for products without discount
  final String image;
  final String description;
  final double rating;
  final int orders;
  final bool isNew;
  final bool freeDelivery; // false for paid delivery

  FurnitureProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    this.originalPrice, // Can be null for non-discounted products
    required this.image,
    required this.description,
    this.rating = 4.5,
    this.orders = 0,
    this.isNew = false,
    this.freeDelivery = false, // Default to false
  });
}
