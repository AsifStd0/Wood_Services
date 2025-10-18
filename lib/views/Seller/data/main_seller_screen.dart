import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/views/noification_model.dart/seller_notificaion_screen.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_screen.dart';
import 'package:wood_service/views/Seller/data/views/seller_analytics_screen.dart';
import 'package:wood_service/views/Seller/data/views/seller_home_screen.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/add_product_screen.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/seller_settings_screen.dart';

class MainSellerScreen extends StatefulWidget {
  const MainSellerScreen({super.key});

  @override
  State<MainSellerScreen> createState() => _MainSellerScreenState();
}

class _MainSellerScreenState extends State<MainSellerScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SellerHomeScreen(),
    const OrdersScreenSeller(),

    const AddProductScreen(),
    const SellerNotificaionScreen(),
    const SellerSettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
