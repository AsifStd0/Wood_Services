// screens/seller/seller_stats_screen.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/status/seller_stats_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerStatsScreen extends StatefulWidget {
  const SellerStatsScreen({super.key});

  @override
  State<SellerStatsScreen> createState() => _SellerStatsScreenState();
}

class _SellerStatsScreenState extends State<SellerStatsScreen> {
  late SellerStatsProvider _statsProvider;

  @override
  void initState() {
    super.initState();
    _statsProvider = locator<SellerStatsProvider>();

    // Load stats on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_statsProvider.hasStats && !_statsProvider.isLoading) {
        _statsProvider.loadSellerStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _statsProvider,
      child: Consumer<SellerStatsProvider>(
        builder: (context, statsProvider, child) {
          // Debug: Log stats data
          if (statsProvider.hasStats) {
            log(
              '📊 Stats loaded - Total Services: ${statsProvider.totalServices}, Total Orders: ${statsProvider.totalOrders}, Revenue: ${statsProvider.totalRevenue}',
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: CustomAppBar(
              title: 'Seller Dashboard',
              showBackButton: true,
            ),
            body: _buildBody(statsProvider),
          );
        },
      ),
    );
  }

  Widget _buildBody(SellerStatsProvider statsProvider) {
    // Show loading only on initial load
    if (statsProvider.isLoading && !statsProvider.hasStats) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading statistics...'),
          ],
        ),
      );
    }

    // Show error only if no stats available
    if (statsProvider.errorMessage != null && !statsProvider.hasStats) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                statsProvider.errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state if no stats
    if (!statsProvider.hasStats && !statsProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No statistics available',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Start selling to see your statistics',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      // ✅ ADD THIS
      physics: const AlwaysScrollableScrollPhysics(), // ✅ ADD THIS
      child: Padding(
        // ✅ ADD PADDING
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(statsProvider),
            const SizedBox(height: 20),

            // Orders Section
            _buildOrdersSection(statsProvider),
            const SizedBox(height: 20),

            // Revenue & Rating Section
            _buildRevenueRatingSection(statsProvider),
            const SizedBox(height: 20),

            // Stats Summary
            _buildStatsSummary(statsProvider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(SellerStatsProvider statsProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.indigo.shade600,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatTile(
                'Total Services',
                statsProvider.totalServices.toString(),
                Icons.widgets_rounded,
                Colors.white.withOpacity(0.9),
              ),
              _buildStatTile(
                'Active Orders',
                statsProvider.pendingOrders.toString(),
                Icons.shopping_cart_rounded,
                Colors.white.withOpacity(0.9),
              ),
              _buildStatTile(
                'Revenue',
                '\$${statsProvider.totalRevenue.toStringAsFixed(2)}',
                Icons.attach_money_rounded,
                Colors.white.withOpacity(0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection(SellerStatsProvider statsProvider) {
    final orderStats = [
      {
        'title': 'Total Orders',
        'value': statsProvider.totalOrders.toString(),
        'icon': Icons.shopping_bag_rounded,
        'color': Colors.purple,
      },
      {
        'title': 'Pending',
        'value': statsProvider.pendingOrders.toString(),
        'icon': Icons.pending_actions_rounded,
        'color': Colors.orange,
      },
      {
        'title': 'In Progress',
        'value': statsProvider.inProgressOrders.toString(),
        'icon': Icons.hourglass_bottom_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Completed',
        'value': statsProvider.completedOrders.toString(),
        'icon': Icons.check_circle_rounded,
        'color': Colors.green,
      },
    ];

    return _buildSection(
      title: 'Orders',
      icon: Icons.shopping_cart_rounded,
      color: Colors.purple,
      children: [
        // Order stats cards in a grid (2x2)
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildOrderStatCard(
                    orderStats[0]['title'] as String,
                    orderStats[0]['value'] as String,
                    orderStats[0]['icon']! as IconData,
                    orderStats[0]['color']! as Color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOrderStatCard(
                    orderStats[1]['title'] as String,
                    orderStats[1]['value'] as String,
                    orderStats[1]['icon']! as IconData,
                    orderStats[1]['color']! as Color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOrderStatCard(
                    orderStats[2]['title'] as String,
                    orderStats[2]['value'] as String,
                    orderStats[2]['icon']! as IconData,
                    orderStats[2]['color']! as Color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOrderStatCard(
                    orderStats[3]['title'] as String,
                    orderStats[3]['value'] as String,
                    orderStats[3]['icon']! as IconData,
                    orderStats[3]['color']! as Color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Progress bar for order completion
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Completion',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    statsProvider.totalOrders > 0
                        ? '${((statsProvider.completedOrders / statsProvider.totalOrders) * 100).toStringAsFixed(1)}%'
                        : '0%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: statsProvider.totalOrders > 0
                      ? statsProvider.completedOrders /
                            statsProvider.totalOrders
                      : 0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green.shade600,
                  ),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${statsProvider.completedOrders} completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${statsProvider.totalOrders - statsProvider.completedOrders} remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueRatingSection(SellerStatsProvider statsProvider) {
    return ConstrainedBox(
      // ✅ ADD CONSTRAINT
      constraints: const BoxConstraints(
        minHeight: 200,
        maxWidth: double.infinity,
      ),
      child: IntrinsicHeight(
        // ✅ ADD THIS for equal height children
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // ✅ ADD THIS
          children: [
            Expanded(child: _buildRevenueCard(statsProvider)),
            const SizedBox(width: 12),
            Expanded(child: _buildRatingCard(statsProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(SellerStatsProvider statsProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                color: Colors.green.shade700,
                size: 20,
              ),
              Text(
                'Total Revenue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${statsProvider.totalRevenue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All time revenue from completed orders',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(SellerStatsProvider statsProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 15),
              Text(
                'Average Rating',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            statsProvider.averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.amber,
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 8),
              Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 20),
              Icon(
                Icons.star_rounded,
                color: statsProvider.averageRating >= 2
                    ? Colors.amber.shade600
                    : Colors.grey.shade300,
                size: 20,
              ),
              Icon(
                Icons.star_rounded,
                color: statsProvider.averageRating >= 3
                    ? Colors.amber.shade600
                    : Colors.grey.shade300,
                size: 20,
              ),
              Icon(
                Icons.star_rounded,
                color: statsProvider.averageRating >= 4
                    ? Colors.amber.shade600
                    : Colors.grey.shade300,
                size: 20,
              ),
              Icon(
                Icons.star_rounded,
                color: statsProvider.averageRating >= 5
                    ? Colors.amber.shade600
                    : Colors.grey.shade300,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on customer reviews',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(SellerStatsProvider statsProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Performance Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            'Order Completion Rate',
            statsProvider.totalOrders > 0
                ? '${((statsProvider.completedOrders / statsProvider.totalOrders) * 100).toStringAsFixed(1)}%'
                : '0%',
            Colors.green,
          ),
          _buildSummaryItem(
            'Service Activation Rate',
            statsProvider.totalServices > 0
                ? '${((statsProvider.activeServices / statsProvider.totalServices) * 100).toStringAsFixed(1)}%'
                : '0%',
            Colors.blue,
          ),
          _buildSummaryItem(
            'Average Order Value',
            statsProvider.completedOrders > 0
                ? '\$${(statsProvider.totalRevenue / statsProvider.completedOrders).toStringAsFixed(2)}'
                : '\$0.00',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: children,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ],
    );
  }

  Widget _buildStatTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, backgroundColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Flexible(
      // Use Flexible instead of fixed width
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            FittedBox(
              // This ensures text scales properly
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
