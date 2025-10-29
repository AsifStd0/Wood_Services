// views/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Admin/admin_dashboard_view_model.dart';
import 'package:wood_service/views/Admin/admin_repository.dart';
import 'package:wood_service/widgets/advance_appbar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdminDashboardViewModel(MockAdminRepository()),
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Admin Dashboard',
          showBackButton: false,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: Colors.grey[700]),
              onPressed: () {
                context.read<AdminDashboardViewModel>().loadDashboardData();
              },
            ),
          ],
        ),
        body: Consumer<AdminDashboardViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.stats == null) {
              return _buildLoadingState();
            }

            return Column(
              children: [
                // Stats Overview
                _buildStatsOverview(viewModel),

                // Navigation Tabs
                _buildNavigationTabs(viewModel),

                // Tab Content
                Expanded(child: _buildCurrentTab(viewModel)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Admin Dashboard',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(AdminDashboardViewModel viewModel) {
    // Check if stats is null before building
    if (viewModel.stats == null) {
      return _buildLoadingStats();
    }

    final stats = viewModel.stats!; // Now it's safe to use !

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Real-time platform statistics',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildStatCard(
                'Sellers',
                stats.totalSellers.toString(),
                Icons.store_rounded,
                Color(0xFF4D96FF),
              ),
              _buildStatCard(
                'Buyers',
                stats.totalBuyers.toString(),
                Icons.people_rounded,
                Color(0xFF6BCF7F),
              ),
              _buildStatCard(
                'Products',
                stats.totalProducts.toString(),
                Icons.inventory_2_rounded,
                Color(0xFFFFD93D),
              ),
              _buildStatCard(
                'Orders',
                stats.totalOrders.toString(),
                Icons.shopping_bag_rounded,
                Color(0xFF9C27B0),
              ),
              _buildStatCard(
                'Revenue',
                '\$${stats.totalRevenue.toStringAsFixed(0)}',
                Icons.attach_money_rounded,
                Color(0xFF4CAF50),
              ),
              _buildStatCard(
                'Pending',
                stats.pendingVerifications.toString(),
                Icons.assignment_turned_in_rounded,
                Color(0xFFFF6B6B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Loading state for stats
  Widget _buildLoadingStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Show loading indicators instead of actual stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildLoadingStatCard(
                'Sellers',
                Icons.store_rounded,
                Color(0xFF4D96FF),
              ),
              _buildLoadingStatCard(
                'Buyers',
                Icons.people_rounded,
                Color(0xFF6BCF7F),
              ),
              _buildLoadingStatCard(
                'Products',
                Icons.inventory_2_rounded,
                Color(0xFFFFD93D),
              ),
              _buildLoadingStatCard(
                'Orders',
                Icons.shopping_bag_rounded,
                Color(0xFF9C27B0),
              ),
              _buildLoadingStatCard(
                'Revenue',
                Icons.attach_money_rounded,
                Color(0xFF4CAF50),
              ),
              _buildLoadingStatCard(
                'Pending',
                Icons.assignment_turned_in_rounded,
                Color(0xFFFF6B6B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 30,
            height: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs(AdminDashboardViewModel viewModel) {
    const tabs = [
      'Overview',
      'Sellers',
      'Buyers',
      'Orders',
      'Products',
      'Verifications',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            return _buildNavigationTab(tabs[index], index, viewModel);
          }),
        ),
      ),
    );
  }

  Widget _buildNavigationTab(
    String title,
    int index,
    AdminDashboardViewModel viewModel,
  ) {
    final isSelected = viewModel.currentTab == index;

    return GestureDetector(
      onTap: () => viewModel.setCurrentTab(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(AdminDashboardViewModel viewModel) {
    switch (viewModel.currentTab) {
      case 0: // Overview
        return _buildOverviewTab(viewModel);
      case 1: // Sellers
        return _buildSellersTab();
      case 2: // Buyers
        return _buildBuyersTab();
      case 3: // Orders
        return _buildOrdersTab();
      case 4: // Products
        return _buildProductsTab();
      case 5: // Verifications
        return _buildVerificationsTab();
      default:
        return _buildOverviewTab(viewModel);
    }
  }

  Widget _buildOverviewTab(AdminDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 20),

          // Recent Activity
          _buildRecentActivity(),
          const SizedBox(height: 20),

          // Platform Analytics
          _buildAnalyticsSection(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.assignment_turned_in_rounded,
        'label': 'Verify Sellers',
        'color': Color(0xFF4D96FF),
      },
      {
        'icon': Icons.shopping_bag_rounded,
        'label': 'View Orders',
        'color': Color(0xFF6BCF7F),
      },
      {
        'icon': Icons.people_rounded,
        'label': 'Manage Users',
        'color': Color(0xFF9C27B0),
      },
      {
        'icon': Icons.analytics_rounded,
        'label': 'Analytics',
        'color': Color(0xFFFF6B6B),
      },
      {
        'icon': Icons.settings_rounded,
        'label': 'Settings',
        'color': Color(0xFFFFD93D),
      },
      {
        'icon': Icons.support_rounded,
        'label': 'Support',
        'color': Color(0xFF4CAF50),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildQuickActionItem(
                action['icon'] as IconData,
                action['label'] as String,
                action['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Handle action
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'New seller registration - John Woodcraft',
            '2 min ago',
            Icons.person_add_rounded,
            Colors.green,
          ),
          _buildDivider(),
          _buildActivityItem(
            'Order #ORD-12345 completed',
            '15 min ago',
            Icons.shopping_bag_rounded,
            Colors.blue,
          ),
          _buildDivider(),
          _buildActivityItem(
            'Product "Oak Dining Table" reported',
            '1 hour ago',
            Icons.flag_rounded,
            Colors.orange,
          ),
          _buildDivider(),
          _buildActivityItem(
            'New verification request submitted',
            '2 hours ago',
            Icons.assignment_rounded,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Text(
        time,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 24, color: Colors.grey.withOpacity(0.1));
  }

  Widget _buildAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder for charts - you can integrate charts_flutter here
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analytics Charts',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Integrate charts_flutter for visualization',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder methods for other tabs
  Widget _buildSellersTab() {
    return Center(child: Text('Sellers Management - Under Development'));
  }

  Widget _buildBuyersTab() {
    return Center(child: Text('Buyers Management - Under Development'));
  }

  Widget _buildOrdersTab() {
    return Center(child: Text('Orders Management - Under Development'));
  }

  Widget _buildProductsTab() {
    return Center(child: Text('Products Management - Under Development'));
  }

  Widget _buildVerificationsTab() {
    return Center(child: Text('Verifications Management - Under Development'));
  }
}
