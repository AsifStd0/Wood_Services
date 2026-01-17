import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Buyer/profile/profile_widget.dart';
import 'package:wood_service/views/Buyer/profile/setting/setting_screen.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      _refreshData();
    }
  }

  void _refreshData() {
    final provider = context.read<BuyerProfileViewProvider>();
    provider.refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => locator<BuyerProfileViewProvider>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: 'Profile',
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<BuyerProfileViewProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!provider.isLoggedIn) {
              return CircularProgressIndicator();
            }

            return _buildProfileContent(context, provider);
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) {
    final user = provider.currentUser!;
    return RefreshIndicator(
      onRefresh: () async {
        await provider.refreshProfile();
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              // User Header Section with REAL DATA
              _buildUserHeader(user, provider),
              const SizedBox(height: 20),

              // Stats Section
              _buildStatsSection(provider),
              const SizedBox(height: 20),

              // Main Menu Section
              _buildMenuSection(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  // BuyerProfileViewProvider
  Widget _buildUserHeader(UserModel user, BuyerProfileViewProvider provider) {
    // Use provider's profileImagePath for consistency with settings screen
    final profileImageUrl = provider.profileImagePath ?? user.profileImage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.brown.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Avatar
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.brown.shade400, Colors.orange.shade400],
                      ),
                    ),
                    child:
                        (profileImageUrl != null && profileImageUrl.isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.brown.shade100,
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.brown.shade100,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                            ),
                          )
                        : CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.brown.shade100,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                  ),

                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      width: 20,
                      height: 20,
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
                      child: const Icon(
                        Icons.pending,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      provider.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    if (provider.businessName.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            provider.businessName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced Stats Section
  Widget _buildStatsSection(BuyerProfileViewProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
              CustomText('Activity ', type: CustomTextType.activityHeading),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatItem('12', 'Orders', Icons.shopping_bag),
              buildStatItem('8', 'Favorites', Icons.favorite),
              buildStatItem('4', 'Reviews', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced Main Menu Section
  Widget _buildMenuSection(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) {
    return Container(
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
          buildMenuHeader('Orders & Management'),
          buildMenuTile(
            context: context,
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'Track purchases and returns',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return OrdersScreen();
                  },
                ),
              );
            },

            // //  => GoRouter.of(context).push('/orders'),
            // showBadge: true,
            // badgeCount: 3,
            // // gradient: [Colors.blue.shade400, Colors.blue.shade600],
          ),

          buildMenuTile(
            context: context,
            icon: Icons.assignment_return_outlined,
            title: 'Returns & Refunds',
            subtitle: 'Manage returns and refund requests',
            onTap: () {},
            // gradient: [Colors.orange.shade400, Colors.orange.shade600],
          ),

          const Divider(height: 20),

          // Account & Preferences
          buildMenuHeader('Account & Preferences'),

          buildMenuTile(
            context: context,
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Cards, wallets, and payment options',
            onTap: () {},
            // gradient: [Colors.teal.shade400, Colors.teal.shade600],
          ),
          buildMenuTile(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            subtitle: 'Delivery and billing addresses',
            onTap: () {},
            // gradient: [Colors.red.shade400, Colors.red.shade600],
          ),

          const Divider(height: 20),

          // Support & Information
          buildMenuHeader('Support & Information'),
          buildMenuTile(
            context: context,
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'FAQs and support articles',
            onTap: () {},
            // gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
          ),
          buildMenuTile(
            context: context,
            icon: Icons.contact_support_outlined,
            title: 'Contact Support',
            subtitle: '24/7 customer service',
            onTap: () {},
            // gradient: [Colors.pink.shade400, Colors.pink.shade600],
          ),
          buildMenuTile(
            context: context,
            icon: Icons.info_outline,
            title: 'About WoodMart',
            subtitle: 'App version 1.0.0',
            onTap: () {},
            // gradient: [Colors.cyan.shade400, Colors.cyan.shade600],
          ),

          const Divider(height: 20),
          // App Preferences
          // buildSettingsSection('App Preferences', [
          //   buildSettingsTile(
          //     icon: Icons.language_outlined,
          //     title: 'Language',
          //     subtitle: _language,
          //     onTap: () => _showLanguageDialog(context),
          //     color: Colors.blue,
          //   ),
          //   _buildSwitchTile(
          //     icon: Icons.dark_mode_outlined,
          //     title: 'Dark Mode',
          //     subtitle: 'Switch to dark theme',
          //     value: _darkMode,
          //     onChanged: (value) {
          //       setState(() => _darkMode = value);
          //     },
          //     color: Colors.purple,
          //   ),
          // ]),

          // Account Actions
          buildMenuHeader('Account Actions'),
          buildMenuTile(
            context: context,
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            subtitle: 'Logout from your account',
            onTap: () => showLogoutDialog(context, provider),
            iconColor: Colors.red,
            textColor: Colors.red,
            // gradient: [Colors.red.shade400, Colors.red.shade600],
          ),
          buildMenuTile(
            context: context,
            icon: Icons.logout_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently remove account',
            onTap: () => showLogoutDialog(context, provider),
            iconColor: Colors.red,
            textColor: Colors.red,
            // gradient: [Colors.red.shade400, Colors.red.shade600],
          ),
        ],
      ),
    );
  }
}
