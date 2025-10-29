// main_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Cart/cart_screen.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_screen.dart';
import 'package:wood_service/views/Buyer/Messages/message_screen.dart';
import 'package:wood_service/views/Buyer/home/asif/furniture_product_model.dart';
import 'package:wood_service/views/Buyer/home/asif/model/home_screen.dart';
import 'package:wood_service/views/Buyer/profile/profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    BuyerHomeScreen(), // Index 0 - Home
    const FavoritesScreen(), // Index 1 - Favorites
    const BuyerCartScreen(), // Index 2 - Cart
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
