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

final List<FurnitureProduct> furnitureproducts = [
  FurnitureProduct(
    freeDelivery: false, // Has free delivery

    id: '123',
    name: 'Modern Sofa',
    price: 499,
    category: 'Living Room',
    image: 'assets/images/sofa.jpg',
    isNew: true,
    brand: 'Sofa Set',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProduct(
    originalPrice: 400,
    freeDelivery: true, // Has free delivery

    id: '123',
    name: 'Dining Table',
    price: 249,
    category: 'Dining Room',
    image: 'assets/images/table.jpg',
    brand: 'Sofa Set',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProduct(
    freeDelivery: true, // Has free delivery

    id: '123',
    name: 'Accent Chair',
    price: 149,
    category: 'Living Room',
    image: 'assets/images/chair.jpg',
    brand: 'Sofa Set',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProduct(
    freeDelivery: false, // Has free delivery

    id: '123',
    name: 'Queen Bed',
    price: 599,
    category: 'Bedroom',
    image: 'assets/images/table2.jpg',
    isNew: true,
    brand: 'Sofa Set',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProduct(
    originalPrice: 400,
    freeDelivery: true, // Has free delivery

    id: '123',
    name: 'Storage Cabinet',
    price: 349,
    category: 'Bedroom',
    image: 'assets/images/sofa2.jpg',
    brand: 'Sofa Set',
    description:
        'Comfortable 3-seater sofa with premium fabric and wooden legs',
  ),
  FurnitureProduct(
    freeDelivery: true, // Has free delivery

    id: '123',
    name: 'Patio Set',
    price: 799,
    category: 'Outdoor',
    image: 'assets/images/sofa.jpg',
    brand: 'Sofa Set',
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
