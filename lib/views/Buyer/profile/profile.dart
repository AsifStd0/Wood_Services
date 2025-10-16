import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/views/Buyer/setting/setting_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                  fullscreenDialog: true, // Slide up animation
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // User Header Section
            _buildUserHeader(),

            // Stats Section
            _buildStatsSection(),

            // Quick Actions
            _buildQuickActions(),

            // Main Menu Section
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  // Enhanced User Header
  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.brown.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar with Badge
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.brown.shade400, Colors.orange.shade400],
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.brown.shade100,
                  backgroundImage: const NetworkImage(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.brown,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Anderson',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'john.anderson@email.com',
                  style: TextStyle(fontSize: 14, color: Colors.brown.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Stats Section
  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                'This Month',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('12', 'Orders', Icons.shopping_bag),
              _buildStatItem('8', 'Favorites', Icons.favorite),
              _buildStatItem('4', 'Reviews', Icons.star),
              _buildStatItem('2', 'Active', Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.brown, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Quick Actions Section
  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                Icons.add_card,
                'Add Payment',
                Colors.green,
              ),
              _buildQuickActionItem(
                Icons.location_on,
                'Add Address',
                Colors.blue,
              ),

              _buildQuickActionItem(
                Icons.help_center,
                'Support',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Enhanced Main Menu Section
  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Orders & Purchases
          _buildMenuHeader('Orders & Management'),
          _buildMenuTile(
            context: context,
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'Track purchases and returns',
            onTap: () => GoRouter.of(context).push('/orders'),
            showBadge: true,
            badgeCount: 3,
            gradient: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.receipt_long_outlined,
            title: 'Order History',
            subtitle: 'Complete purchase history',
            onTap: () {},
            gradient: [Colors.green.shade400, Colors.green.shade600],
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.assignment_return_outlined,
            title: 'Returns & Refunds',
            subtitle: 'Manage returns and refund requests',
            onTap: () {},
            gradient: [Colors.orange.shade400, Colors.orange.shade600],
          ),

          const Divider(height: 20),

          // Account & Preferences
          _buildMenuHeader('Account & Preferences'),
          _buildMenuTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage alerts and preferences',
            onTap: () => GoRouter.of(context).push('/notifications'),
            gradient: [Colors.purple.shade400, Colors.purple.shade600],
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Cards, wallets, and payment options',
            onTap: () {},
            gradient: [Colors.teal.shade400, Colors.teal.shade600],
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            subtitle: 'Delivery and billing addresses',
            onTap: () {},
            gradient: [Colors.red.shade400, Colors.red.shade600],
          ),

          const Divider(height: 20),

          // Support & Information
          _buildMenuHeader('Support & Information'),
          _buildMenuTile(
            context: context,
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'FAQs and support articles',
            onTap: () {},
            gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.contact_support_outlined,
            title: 'Contact Support',
            subtitle: '24/7 customer service',
            onTap: () {},
            gradient: [Colors.pink.shade400, Colors.pink.shade600],
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.info_outline,
            title: 'About WoodMart',
            subtitle: 'App version 1.0.0',
            onTap: () {},
            gradient: [Colors.cyan.shade400, Colors.cyan.shade600],
          ),

          const Divider(height: 20),

          // Account Actions
          _buildMenuHeader('Account Actions'),
          _buildMenuTile(
            context: context,
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            subtitle: 'Logout from your account',
            onTap: () => _showLogoutDialog(context),
            iconColor: Colors.red,
            textColor: Colors.red,
            gradient: [Colors.red.shade400, Colors.red.shade600],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = false,
    int badgeCount = 0,
    Color iconColor = Colors.white,
    Color textColor = Colors.black,
    List<Color>? gradient,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient != null
            ? LinearGradient(
                colors: gradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: gradient == null ? Colors.grey[50] : null,
        boxShadow: gradient == null
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: gradient != null
                ? Colors.white.withOpacity(0.2)
                : Colors.brown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: gradient != null ? Colors.white : Colors.brown,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: gradient != null ? Colors.white : textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: gradient != null
                ? Colors.white.withOpacity(0.8)
                : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: showBadge
            ? Badge(
                label: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: gradient != null ? Colors.white : Colors.grey,
                ),
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: gradient != null ? Colors.white : Colors.grey,
              ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade400,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to sign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Add logout logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
