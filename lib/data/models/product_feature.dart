// ========== MODELS ==========
import 'package:flutter/material.dart';
import 'package:wood_service/core/constant/image_paths.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String sellerName;
  final String sellerImage;
  final double rating;
  final int totalReviews;
  final List<Color> availableColors;
  final String description;
  final List<String> keyFeatures;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.sellerName,
    required this.sellerImage,
    required this.rating,
    required this.totalReviews,
    required this.availableColors,
    required this.description,
    required this.keyFeatures,
  });
}

class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});
}

// ========== DATA SOURCE ==========
class AppData {
  static final List<Category> categories = [
    Category(name: 'Table', icon: Icons.table_bar),
    Category(name: 'Chair', icon: Icons.chair),
    Category(name: 'Sofa', icon: Icons.weekend),
    Category(name: 'Cabinet', icon: Icons.cabin),
    Category(name: 'Lamp', icon: Icons.light),
  ];

  static final List<Product> featuredProducts = [
    Product(
      id: '1',
      name: 'Modern Chair',
      price: 250,
      image: AssetImages.redChair,
      sellerName: 'ABC Enterprise',
      sellerImage: AssetImages.redSofa,
      rating: 4.5,
      totalReviews: 738,
      availableColors: [Colors.brown, Colors.black],
      description:
          'Comfortable and sturdy chair with metal frame, soft seat and nice backrest with curved shape. All in a clean, classic design with a modern touch that doesn\'t take up space – and at a surprising price!',
      keyFeatures: [
        'You can sit comfortably for long periods of time at a desk because the angle of the back provides good lumbar support.',
        'Easy to assemble as you don\'t have to think which leg is facing forward. All the same.',
        'The chair stands firmly in place thanks to the metal underframe.',
      ],
    ),
    Product(
      id: '2',
      name: 'Minimalist Table',
      price: 300,
      image: AssetImages.whiteDesk,
      sellerName: 'ABC Enterprise',
      sellerImage: AssetImages.redChair,
      rating: 4.5,
      totalReviews: 738,
      availableColors: [Colors.white, Colors.black],
      description:
          'A sleek and minimalist table perfect for modern homes and offices. Features a durable surface and stable construction.',
      keyFeatures: [
        'Scratch-resistant surface that maintains its appearance over time.',
        'Easy to clean and maintain with just a damp cloth.',
        'Sturdy construction supports up to 100kg.',
      ],
    ),
  ];
}
