import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_widget.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class OrdersScreenSeller extends StatefulWidget {
  const OrdersScreenSeller({super.key});

  @override
  State<OrdersScreenSeller> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreenSeller> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final ordersViewModel = context.read<OrdersViewModel>();
    final statsProvider = context.read<OrdersViewModel>();
    ordersViewModel.loadOrders();
    statsProvider.loadStats();
  }

  void _onSearchChanged() {
    final viewModel = context.read<OrdersViewModel>();
    viewModel.searchOrders(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Orders Management',
        showBackButton: false,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final ordersViewModel = context.read<OrdersViewModel>();
          await Future.wait([
            ordersViewModel.loadOrders(),
            ordersViewModel.loadStats(),
          ]);
        },
        child: Column(
          children: [
            // Statistics Bar
            const _StatisticsBar(),

            // Search Bar
            SearchBar(searchController: _searchController),

            // Status Filter Bar
            const StatusFilterBar(),

            // Orders List
            const Expanded(child: OrdersList()),
          ],
        ),
      ),
    );
  }
}

class _StatisticsBar extends StatelessWidget {
  const _StatisticsBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, statsProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total',
                '${statsProvider.totalServices}',
                const Color(0xFF4F46E5), // Indigo
                Icons.inventory_2_rounded,
              ),
              _buildStatItem(
                'Active',
                '${statsProvider.activeServices}',
                const Color(0xFF10B981), // Emerald
                Icons.check_circle_outline_rounded,
              ),
              _buildStatItem(
                'Pending',
                '${statsProvider.pendingOrders}',
                const Color(0xFFF59E0B), // Amber
                Icons.schedule_rounded,
              ),
              // _buildStatItem(
              //   'In Progress',
              //   '${statsProvider.inProgressOrders}',
              //   const Color(0xFF3B82F6), // Blue
              //   Icons.autorenew_rounded,
              // ),
              _buildStatItem(
                'Completed',
                '${statsProvider.completedOrders}',
                const Color(0xFF8B5CF6), // Violet
                Icons.verified_outlined,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.grey[900],
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;

  const SearchBar({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: CustomTextFormField(
        controller: searchController,
        hintText: 'Search by name or order #',
        prefixIcon: const Icon(Icons.search_sharp, size: 24),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            searchController.clear();
            final viewModel = context.read<OrdersViewModel>();
            viewModel.searchOrders('');
          },
        ),
      ),
    );
  }
}
