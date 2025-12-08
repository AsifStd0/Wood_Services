class User {
  final String id;
  final String name;
  final String email;
  final String type; // 'buyer' or 'seller'
  final String avatar;
  final bool isBlocked;
  final DateTime joinDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.avatar,
    this.isBlocked = false,
    required this.joinDate,
  });
}

class Product {
  final String id;
  final String name;
  final String sellerName;
  final double price;
  final String status;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.sellerName,
    required this.price,
    required this.status,
    required this.imageUrl,
  });
}

class Order {
  final String id;
  final String buyerName;
  final String sellerName;
  final double amount;
  final String status;
  final DateTime orderDate;

  Order({
    required this.id,
    required this.buyerName,
    required this.sellerName,
    required this.amount,
    required this.status,
    required this.orderDate,
  });
}
