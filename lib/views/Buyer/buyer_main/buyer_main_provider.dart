import 'package:flutter/material.dart';
import 'package:wood_service/chats/Buyer/buyer_outer_messages_screen.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_screen.dart';
import 'package:wood_service/views/Buyer/Cart/cart_screen.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_screen.dart';
import 'package:wood_service/views/Buyer/profile/profile.dart';

class MainScreenProvider extends ChangeNotifier {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    BuyerHomeScreen(),
    const FavoritesScreen(),
    const BuyerCartScreen(),
    const BuyerOuterMessagesScreen(),
    const ProfileScreen(),
  ];

  // Getters
  int get currentIndex => _currentIndex;
  Widget get currentScreen => _screens[_currentIndex];
  List<Widget> get screens => _screens;

  // Methods
  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToHome() {
    _currentIndex = 0;
    notifyListeners();
  }

  void goToChat() {
    _currentIndex = 3;
    notifyListeners();
  }

  void goToProfile() {
    _currentIndex = 4;
    notifyListeners();
  }

  bool get isHomeScreen => _currentIndex == 0;
  bool get isChatScreen => _currentIndex == 3;
}
