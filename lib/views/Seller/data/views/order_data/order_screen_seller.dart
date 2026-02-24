import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
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
    ordersViewModel.loadOrders();
    ordersViewModel.loadStats();
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
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Orders Management',
        showBackButton: false,
        backgroundColor: AppColors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final ordersViewModel = context.read<OrdersViewModel>();
          await Future.wait([
            ordersViewModel.loadOrders(),
            ordersViewModel.loadStats(),
          ]);
        },
        color: AppColors.primary,
        child: Column(
          children: [
            // Statistics Bar
            const _StatisticsBar(),

            // Search Bar
            _SearchBar(searchController: _searchController),

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

/// Statistics Bar Widget
class _StatisticsBar extends StatelessWidget {
  const _StatisticsBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(0.05),
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
              _StatItem(
                label: 'Total',
                value: '${viewModel.totalServices}',
                color: AppColors.primary,
                icon: Icons.inventory_2_rounded,
              ),
              _StatItem(
                label: 'Active',
                value: '${viewModel.activeServices}',
                color: AppColors.success,
                icon: Icons.check_circle_outline_rounded,
              ),
              _StatItem(
                label: 'Pending',
                value: '${viewModel.pendingOrders}',
                color: AppColors.warning,
                icon: Icons.schedule_rounded,
              ),
              _StatItem(
                label: 'Completed',
                value: '${viewModel.completedOrders}',
                color: AppColors.info,
                icon: Icons.verified_outlined,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final TextEditingController searchController;

  const _SearchBar({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: CustomTextFormField(
        controller: searchController,
        hintText: 'Search by name or order #',
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                onPressed: () {
                  searchController.clear();
                  final viewModel = context.read<OrdersViewModel>();
                  viewModel.searchOrders('');
                },
              )
            : null,
      ),
    );
  }
}
