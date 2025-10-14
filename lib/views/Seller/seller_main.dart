// main_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/home/home_widget.dart';
import 'package:wood_service/views/home/seller_home.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FurnitureHomeScreen(),
    const FurnitureHomeScreen(),
    const FurnitureHomeScreen(),
    const FurnitureHomeScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
        ],
      ),
    );
  }
}

// Sample data - Easy to customize
final List<FurnitureProduct> products = [
  const FurnitureProduct(
    name: 'Modern Sofa',
    price: 499,
    category: 'Living Room',
    imageUrl: 'assets/sofa.jpg',
    isNew: true,
  ),
  const FurnitureProduct(
    name: 'Dining Table',
    price: 249,
    category: 'Dining Room',
    imageUrl: 'assets/dining_table.jpg',
  ),
  const FurnitureProduct(
    name: 'Accent Chair',
    price: 149,
    category: 'Living Room',
    imageUrl: 'assets/chair.jpg',
  ),
  const FurnitureProduct(
    name: 'Queen Bed',
    price: 599,
    category: 'Bedroom',
    imageUrl: 'assets/bed.jpg',
    isNew: true,
  ),
  const FurnitureProduct(
    name: 'Storage Cabinet',
    price: 349,
    category: 'Bedroom',
    imageUrl: 'assets/cabinet.jpg',
  ),
  const FurnitureProduct(
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
