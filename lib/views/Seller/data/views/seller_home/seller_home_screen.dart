// screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/seller_home_screen_widget.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_repository.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repository.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  late VisitRequestsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Get auth token from your auth provider
    final authToken = ''; // Get from your auth system
    _viewModel = VisitRequestsViewModel(
      ApiVisitRepository(authToken: authToken),
    );
    _viewModel.loadVisitRequests();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Visit Requests',
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (_) => SellerNotificationScreen(),
                //   ),
                // );
              },
            ),
          ],
        ),
        body: Consumer<VisitRequestsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return _buildLoadingState();
            }

            if (viewModel.hasError) {
              return _buildErrorState(viewModel);
            }

            return Column(
              children: [
                // Header with Stats
                _buildHeaderStats(viewModel),

                // Filter Tabs
                _buildFilterTabs(viewModel),

                // Visit Requests List
                Expanded(child: _buildVisitList(viewModel)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(VisitRequestsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.loadVisitRequests(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(VisitRequestsViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total',
                viewModel.totalVisits.toString(),
                Icons.assignment_rounded,
                const Color(0xFFFFD93D),
              ),
              _buildStatItem(
                'Pending',
                viewModel.pendingVisits.toString(),
                Icons.pending_actions_rounded,
                const Color(0xFF6BCF7F),
              ),
              _buildStatItem(
                'Accepted',
                viewModel.acceptedVisits.toString(),
                Icons.verified_rounded,
                const Color(0xFF4D96FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(VisitRequestsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 10, 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          _buildFilterTab('Active', VisitFilter.active, viewModel),
          _buildFilterTab('Cancelled', VisitFilter.cancelled, viewModel),
          _buildFilterTab('Completed', VisitFilter.completed, viewModel),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    String label,
    VisitFilter filter,
    VisitRequestsViewModel viewModel,
  ) {
    final isActive = viewModel.currentFilter == filter;

    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setFilter(filter),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitList(VisitRequestsViewModel viewModel) {
    final visits = viewModel.filteredVisits;

    if (visits.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        return VisitRequestCard(visitRequest: visits[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No Visit Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visit requests from buyers will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
