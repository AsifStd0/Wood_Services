// main_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Cart/cart_screen.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_screen.dart';
import 'package:wood_service/views/Buyer/Messages/message_screen.dart';
import 'package:wood_service/views/Buyer/home/asif/furniture_product.dart';
import 'package:wood_service/views/Buyer/home/asif/model/home_screen.dart';
import 'package:wood_service/views/Buyer/profile/profile.dart';
import 'package:wood_service/views/Buyer/home/seller_home.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    SellerHomeScreen(), // Index 0 - Home
    const FavoritesScreen(), // Index 1 - Favorites
    const CartScreen(), // Index 2 - Cart
    const MessagesScreen(), // Index 3 - Messages
    const ProfileScreen(), // Index 4 - Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Sample data - Easy to customize
final List<FurnitureProduct> products = [
  FurnitureProduct(
    id: '123',
    name: 'Modern Sofa',
    price: 499,
    category: 'Living Room',
    image: 'assets/sofa.jpg',
    isNew: true,
  ),
  FurnitureProduct(
    id: '123',
    name: 'Dining Table',
    price: 249,
    category: 'Dining Room',
    image: 'assets/dining_table.jpg',
  ),
  FurnitureProduct(
    id: '123',
    name: 'Accent Chair',
    price: 149,
    category: 'Living Room',
    image: 'assets/chair.jpg',
  ),
  FurnitureProduct(
    id: '123',
    name: 'Queen Bed',
    price: 599,
    category: 'Bedroom',
    image: 'assets/bed.jpg',
    isNew: true,
  ),
  FurnitureProduct(
    id: '123',
    name: 'Storage Cabinet',
    price: 349,
    category: 'Bedroom',
    image: 'assets/cabinet.jpg',
  ),
  FurnitureProduct(
    id: '123',
    name: 'Patio Set',
    price: 799,
    category: 'Outdoor',
    image: 'assets/patio.jpg',
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
