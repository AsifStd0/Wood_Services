// Favorite Product Model
class FavoriteProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final String seller;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final bool isOnSale;
  final int discountPercent;
  final bool isSustainable;
  final DateTime addedDate;
  final bool freeDelivery;

  FavoriteProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.seller,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.isOnSale,
    required this.discountPercent,
    required this.isSustainable,
    required this.addedDate,
    required this.freeDelivery, // Default to false
  });
}

final List<FavoriteProduct> favoriteItems = [
  FavoriteProduct(
    id: '2',
    name: 'Solid Mahogany Dining Table',
    description: 'Handcrafted Mahogany, 72" x 36" x 30"',
    price: 1299.99,
    originalPrice: 1499.99,
    imageUrl:
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&h=200&fit=crop',
    seller: 'Luxury Furniture',
    rating: 4.9,
    reviewCount: 89,
    inStock: true,
    isOnSale: true,
    discountPercent: 13,
    isSustainable: false,
    addedDate: DateTime.now().subtract(const Duration(days: 5)),
    freeDelivery: true,
  ),
  FavoriteProduct(
    id: '3',
    name: 'Oak Wood Bookshelf',
    description: 'Solid Oak, 5 Shelves, 60" Height',
    price: 459.99,
    originalPrice: 459.99,
    imageUrl:
        'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=200&h=200&fit=crop',
    seller: 'Wood Crafts',
    rating: 4.6,
    reviewCount: 67,
    inStock: false,
    isOnSale: false,
    discountPercent: 0,
    isSustainable: true,
    addedDate: DateTime.now().subtract(const Duration(days: 7)),
    freeDelivery: false,
  ),
  FavoriteProduct(
    id: '4',
    name: 'Walnut Coffee Table',
    description: 'Modern Design, 48" Round, Glass Top',
    price: 599.99,
    originalPrice: 699.99,
    imageUrl:
        'https://images.unsplash.com/photo-1533090368676-1fd25485db88?w=200&h=200&fit=crop',
    seller: 'Modern Furniture',
    rating: 4.7,
    reviewCount: 203,
    inStock: true,
    isOnSale: true,
    discountPercent: 14,
    isSustainable: true,
    addedDate: DateTime.now().subtract(const Duration(days: 1)),
    freeDelivery: true,
  ),
  FavoriteProduct(
    id: '5',
    name: 'Maple Wood Chairs (Set of 4)',
    description: 'Solid Maple, Upholstered Seats, Modern Design',
    price: 399.99,
    originalPrice: 499.99,
    imageUrl:
        'https://images.unsplash.com/photo-1503602642458-232111445657?w=200&h=200&fit=crop',
    seller: 'Home Comfort',
    rating: 4.5,
    reviewCount: 156,
    inStock: true,
    isOnSale: true,
    discountPercent: 20,
    isSustainable: true,
    addedDate: DateTime.now().subtract(const Duration(days: 3)),
    freeDelivery: false,
  ),
];
