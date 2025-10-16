// main_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Cart/cart_screen.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_screen.dart';
import 'package:wood_service/views/Buyer/Messages/message_screen.dart';
import 'package:wood_service/views/Buyer/profile/profile.dart';
import 'package:wood_service/views/Buyer/home/home_widget.dart';
import 'package:wood_service/views/Buyer/home/seller_home.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FurnitureHomeScreen(), // Index 0 - Home
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
  const FurnitureProduct(
    id: '123',
    name: 'Modern Sofa',
    price: 499,
    category: 'Living Room',
    imageUrl: 'assets/sofa.jpg',
    isNew: true,
  ),
  const FurnitureProduct(
    id: '123',
    name: 'Dining Table',
    price: 249,
    category: 'Dining Room',
    imageUrl: 'assets/dining_table.jpg',
  ),
  const FurnitureProduct(
    id: '123',
    name: 'Accent Chair',
    price: 149,
    category: 'Living Room',
    imageUrl: 'assets/chair.jpg',
  ),
  const FurnitureProduct(
    id: '123',
    name: 'Queen Bed',
    price: 599,
    category: 'Bedroom',
    imageUrl: 'assets/bed.jpg',
    isNew: true,
  ),
  const FurnitureProduct(
    id: '123',
    name: 'Storage Cabinet',
    price: 349,
    category: 'Bedroom',
    imageUrl: 'assets/cabinet.jpg',
  ),
  const FurnitureProduct(
    id: '123',
    name: 'Patio Set',
    price: 799,
    category: 'Outdoor',
    imageUrl: 'assets/patio.jpg',
    isOutdoor: true,
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
