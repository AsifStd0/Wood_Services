// screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/seller_stats_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final statsProvider = context.read<SellerStatsProvider>();
      if (statsProvider.stats.isEmpty && !statsProvider.isLoading) {
        statsProvider.loadStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Seller Dashboard',
        showBackButton: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => locator<SellerStatsProvider>(),
        child: Consumer<SellerStatsProvider>(
          builder: (context, statsProvider, child) {
            if (statsProvider.isLoading && statsProvider.stats.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (statsProvider.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${statsProvider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => statsProvider.loadStats(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header with Stats
                buildHeaderStats(statsProvider),

                // ! seller_home_screen_widget.dart
                // Filter Tabs
                // _buildFilterTabs(viewModel),

                // // Visit Requests List
                // Expanded(child: _buildVisitList(viewModel)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildHeaderStats(SellerStatsProvider statsProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.blue.shade600],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            '${statsProvider.totalServices}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Total Services',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  'Active',
                  statsProvider.activeServices,
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatChip(
                  'Orders',
                  statsProvider.totalOrders,
                  Icons.shopping_bag,
                  Colors.orange,
                ),
                _buildStatChip(
                  'Revenue',
                  statsProvider.totalRevenue.toInt(),
                  Icons.attach_money,
                  Colors.amber,
                ),
                _buildStatChip(
                  'Rating',
                  statsProvider.averageRating.toStringAsFixed(1),
                  Icons.star,
                  Colors.yellow,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Orders breakdown
          if (statsProvider.totalOrders > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat(
                    'Pending',
                    statsProvider.pendingOrders,
                    Colors.orange,
                  ),
                  _buildMiniStat(
                    'In Progress',
                    statsProvider.inProgressOrders,
                    Colors.blue,
                  ),
                  _buildMiniStat(
                    'Completed',
                    statsProvider.completedOrders,
                    Colors.green,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    String label,
    dynamic value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 9),
        ),
      ],
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final viewModel = context.read<VisitRequestsViewModel>();
  //     viewModel.loadVisitRequests();
  //   });
  // }
}
