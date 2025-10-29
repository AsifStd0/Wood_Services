// lib/presentation/views/visit_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
import 'package:wood_service/views/Seller/data/repository/home_repo.dart';
import 'package:wood_service/views/Seller/data/views/seller_home_screen_widget.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/view_request_provider.dart';
import 'package:wood_service/widgets/advance_appbar.dart';

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
          backgroundColor: Colors.white,
        ),
        body: VisitRequestsContent(),
      ),
    );
  }
}

class VisitRequestsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<VisitRequestsViewModel>(
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
    );
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
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
}

class VisitRequestCard extends StatelessWidget {
  final VisitRequest visitRequest;

  const VisitRequestCard({required this.visitRequest});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(visitRequest.status),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Text(
                    _getFormattedDate(visitRequest),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Address Section
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitRequest.address,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Request #${visitRequest.id}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Status Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _getStatusColor(visitRequest.status).withOpacity(0.05),
                    _getStatusColor(visitRequest.status).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(visitRequest.status).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(visitRequest.status),
                    color: _getStatusColor(visitRequest.status),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Status: ${visitRequest.statusText}',
                      style: TextStyle(
                        color: _getStatusColor(visitRequest.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Action Buttons
            _buildActionButtons(context, visitRequest),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VisitStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(status),
            _getStatusColor(status).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(status).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            _getStatusText(status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, VisitRequest visit) {
    final buttons = _getActionButtons(context, visit);

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(
      children: buttons.length == 1
          ? [Expanded(child: buttons.first)]
          : [
              Expanded(child: buttons[0]),
              const SizedBox(width: 12),
              Expanded(child: buttons[1]),
            ],
    );
  }

  List<Widget> _getActionButtons(BuildContext context, VisitRequest visit) {
    switch (visit.status) {
      case VisitStatus.pending:
        return [
          _buildActionButton(
            'Accept Request',
            Color(0xFF6BCF7F),
            Icons.check_circle_rounded,
            () => _handleStatusUpdate(context, visit.id, VisitStatus.accepted),
          ),
        ];

      case VisitStatus.accepted:
      case VisitStatus.contractSent:
        return [
          _buildActionButton(
            'Cancel Visit',
            Color(0xFFFF6B6B),
            Icons.cancel_rounded,
            () => _handleStatusUpdate(context, visit.id, VisitStatus.cancelled),
          ),
        ];

      case VisitStatus.contractActive:
        return [
          _buildActionButton(
            'Cancel',
            Color(0xFFFF6B6B),
            Icons.cancel_rounded,
            () => _handleStatusUpdate(context, visit.id, VisitStatus.cancelled),
          ),
          _buildActionButton(
            'Confirm Visit',
            Color(0xFF4D96FF),
            Icons.verified_rounded,
            () => _handleStatusUpdate(context, visit.id, VisitStatus.completed),
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: color.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(VisitRequest visit) {
    if (visit.status == VisitStatus.pending) {
      return visit.formattedRequestedDate;
    } else {
      return visit.formattedAcceptedDate;
    }
  }

  String _getStatusText(VisitStatus status) {
    switch (status) {
      case VisitStatus.pending:
        return 'Pending Review';
      case VisitStatus.accepted:
        return 'Accepted';
      case VisitStatus.contractSent:
        return 'Contract Sent';
      case VisitStatus.contractActive:
        return 'Active Contract';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getStatusIcon(VisitStatus status) {
    switch (status) {
      case VisitStatus.pending:
        return Icons.pending_actions_rounded;
      case VisitStatus.accepted:
        return Icons.check_circle_rounded;
      case VisitStatus.contractSent:
        return Icons.send_rounded;
      case VisitStatus.contractActive:
        return Icons.play_circle_fill_rounded;
      case VisitStatus.completed:
        return Icons.verified_rounded;
      case VisitStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  void _handleStatusUpdate(
    BuildContext context,
    String visitId,
    VisitStatus newStatus,
  ) {
    final viewModel = context.read<VisitRequestsViewModel>();
    viewModel.updateVisitStatus(visitId, newStatus);
  }

  Color _getStatusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.pending:
        return Color(0xFFFFA726);
      case VisitStatus.accepted:
        return Color(0xFF4D96FF);
      case VisitStatus.contractSent:
        return Color(0xFF9C27B0);
      case VisitStatus.contractActive:
        return Color(0xFF6BCF7F);
      case VisitStatus.completed:
        return Color(0xFF4CAF50);
      case VisitStatus.cancelled:
        return Color(0xFFFF6B6B);
    }
  }
}
