// main_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Cart/cart_screen.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_screen.dart';
import 'package:wood_service/views/Buyer/Messages/message_screen.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_screen.dart';
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
