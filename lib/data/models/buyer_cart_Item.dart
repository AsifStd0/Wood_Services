// Cart Item Model
class BuyerCartItem {
  final String id;
  final String name;
  final String description;
  final double price;
  int quantity;
  final String imageUrl;
  final String seller;
  final bool inStock;
  final String deliveryDate;

  BuyerCartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.seller,
    required this.inStock,
    required this.deliveryDate,
  });
}

final List<BuyerCartItem> buyerCartItems = [
  BuyerCartItem(
    id: '2',
    name: 'Mahogany Dining Table',
    description: 'Solid Mahogany, 72" x 36"',
    price: 899.99,
    quantity: 1,
    imageUrl:
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=150&h=150&fit=crop',
    seller: 'Luxury Furniture',
    inStock: true,
    deliveryDate: 'Jan 25-28',
  ),
  BuyerCartItem(
    id: '3',
    name: 'Mahogany Dining Table',
    description: 'Solid Mahogany, 72" x 36"',
    price: 899.99,
    quantity: 1,
    imageUrl:
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=150&h=150&fit=crop',
    seller: 'Luxury Furniture',
    inStock: true,
    deliveryDate: 'Jan 25-28',
  ),
  BuyerCartItem(
    id: '3',
    name: 'Oak Wood Chairs (Set of 4)',
    description: 'Solid Oak, Upholstered Seats',
    price: 349.99,
    quantity: 1,
    imageUrl:
        'https://images.unsplash.com/photo-1503602642458-232111445657?w=150&h=150&fit=crop',
    seller: 'Wood Crafts',
    inStock: false,
    deliveryDate: 'Out of Stock',
  ),
];

// class BuyerCartItem {
//   final String id;
//   final String name;
//   final String description;
//   final double price;
//   final int quantity;
//   final String imageUrl;
//   final String seller;
//   final bool inStock;
//   final String category;
//   final DateTime addedDate;

//   BuyerCartItem({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.quantity,
//     required this.imageUrl,
//     required this.seller,
//     required this.inStock,
//     required this.category,
//     required this.addedDate,
//   });

//   BuyerCartItem copyWith({
//     String? id,
//     String? name,
//     String? description,
//     double? price,
//     int? quantity,
//     String? imageUrl,
//     String? seller,
//     bool? inStock,
//     String? category,
//     DateTime? addedDate,
//   }) {
//     return BuyerCartItem(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       description: description ?? this.description,
//       price: price ?? this.price,
//       quantity: quantity ?? this.quantity,
//       imageUrl: imageUrl ?? this.imageUrl,
//       seller: seller ?? this.seller,
//       inStock: inStock ?? this.inStock,
//       category: category ?? this.category,
//       addedDate: addedDate ?? this.addedDate,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'price': price,
//       'quantity': quantity,
//       'imageUrl': imageUrl,
//       'seller': seller,
//       'inStock': inStock,
//       'category': category,
//       'addedDate': addedDate.toIso8601String(),
//     };
//   }

//   factory BuyerCartItem.fromJson(Map<String, dynamic> json) {
//     return BuyerCartItem(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       price: json['price']?.toDouble(),
//       quantity: json['quantity'],
//       imageUrl: json['imageUrl'],
//       seller: json['seller'],
//       inStock: json['inStock'],
//       category: json['category'],
//       addedDate: DateTime.parse(json['addedDate']),
//     );
//   }
// }
