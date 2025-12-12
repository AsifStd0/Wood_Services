// lib/presentation/views/visit_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
import 'package:wood_service/views/Seller/data/repository/home_repo.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/seller_home_screen_widget.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/view_request_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _VisitRequestsScreenState();
}

class _VisitRequestsScreenState extends State<SellerHomeScreen> {
  final _viewModel = VisitRequestsViewModel(MockVisitRepository());

  @override
  void initState() {
    super.initState();
    _viewModel.loadVisitRequests();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Visit Requests',
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // context.push('/seller_notificaion');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return SellerNotificaionScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<VisitRequestsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return buildLoadingState();
            }

            if (viewModel.hasError) {
              return buildErrorState(viewModel);
            }

            return Column(
              children: [
                // Header with Stats
                _buildHeaderStats(viewModel),

                // Filter Tabs
                buildFilterTabs(viewModel),

                // Visit Requests List
                Expanded(child: _buildVisitList(viewModel)),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildHeaderStats(VisitRequestsViewModel viewModel) {
  final totalVisits = viewModel.visitRequests.length;
  final pendingVisits = viewModel.visitRequests
      .where((visit) => visit.status == VisitStatus.pending)
      .length;
  final acceptedVisits = viewModel.visitRequests
      .where((visit) => visit.status == VisitStatus.accepted)
      .length;

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
              totalVisits.toString(),
              Icons.assignment_rounded,
              Color(0xFFFFD93D),
            ),
            _buildStatItem(
              'Pending',
              pendingVisits.toString(),
              Icons.pending_actions_rounded,
              Color(0xFF6BCF7F),
            ),
            _buildStatItem(
              'Accepted',
              acceptedVisits.toString(),
              Icons.verified_rounded,
              Color(0xFF4D96FF),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildStatItem(String title, String value, IconData icon, Color color) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
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

Widget _buildVisitList(VisitRequestsViewModel viewModel) {
  final visits = viewModel.filteredVisits;

  if (visits.isEmpty) {
    return buildEmptyState();
  }

  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    itemCount: visits.length,
    itemBuilder: (context, index) {
      return VisitRequestCard(visitRequest: visits[index]);
    },
  );
}
