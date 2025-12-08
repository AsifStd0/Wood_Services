import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Admin/admin_setting.dart';
import 'package:wood_service/views/Admin/order_management.dart';
import 'package:wood_service/views/Admin/payment_management.dart';
import 'package:wood_service/views/Admin/product_manager.dart';
import 'package:wood_service/views/Admin/report_analystics.dart';
import 'package:wood_service/views/Admin/home_user_management/user_management.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<NavItem> navItems = [
    NavItem('Users', Icons.people, Colors.blue, UserManagementScreen()),
    NavItem(
      'Products',
      Icons.inventory_2,
      AppColors.brightOrange,
      ProductManagementScreen(),
    ),
    NavItem(
      'Orders',
      Icons.shopping_cart,
      AppColors.brightOrange,
      OrderManagementScreen(),
    ),
    NavItem(
      'Payments',
      Icons.payment,
      AppColors.brightOrange,
      PaymentManagementScreen(),
    ),
    NavItem(
      'Reports',
      Icons.analytics,
      AppColors.brightOrange,
      ReportsScreen(),
    ),
    NavItem(
      'Settings',
      Icons.settings,
      AppColors.brightOrange,
      AdminSettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: navItems[_currentIndex].screen,
      bottomNavigationBar: _buildBeautifulCurvedNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            navItems[_currentIndex].title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            _getSubtitle(_currentIndex),
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      // backgroundColor: navItems[_currentIndex].color,
      elevation: 2,
      actions: [
        _currentIndex == 5
            ? Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(),
        _currentIndex == 5
            ? IconButton(icon: const Icon(Icons.logout), onPressed: () {})
            : SizedBox(),
      ],
    );
  }

  String _getSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Manage all users';
      case 1:
        return 'Product catalog';
      case 2:
        return 'Order tracking';
      case 3:
        return 'Payment history';
      case 4:
        return 'Analytics & reports';
      case 5:
        return 'Admin settings';
      default:
        return 'Admin Panel';
    }
  }

  Widget _buildBeautifulCurvedNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            navItems.length,
            (index) => _buildNavItem(navItems[index], index),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, int index) {
    bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? item.color.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 20,
                color: isSelected ? item.color : Colors.grey[600],
              ),
              if (isSelected) ...[
                const SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;

  NavItem(this.title, this.icon, this.color, this.screen);
}
