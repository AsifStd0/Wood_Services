// lib/presentation/views/visit_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
import 'package:wood_service/views/Seller/data/repository/home_repo.dart';
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
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(title: 'Visit Requests', showBackButton: false),
        body: const _VisitRequestsContent(),
      ),
    );
  }
}

class _VisitRequestsContent extends StatelessWidget {
  const _VisitRequestsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<VisitRequestsViewModel>(
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
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading Visit Requests...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VisitRequestsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: viewModel.loadVisitRequests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade700, Colors.blue.shade500],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visit Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', totalVisits.toString(), Icons.list_alt),
              _buildStatItem(
                'Pending',
                pendingVisits.toString(),
                Icons.pending,
              ),
              _buildStatItem(
                'Accepted',
                acceptedVisits.toString(),
                Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(VisitRequestsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
    String title,
    VisitFilter filter,
    VisitRequestsViewModel viewModel,
  ) {
    final isSelected = viewModel.currentFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.setFilter(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 14,
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        return _VisitRequestCard(visitRequest: visits[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                size: 50,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Visit Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When you receive visit requests, they will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitRequestCard extends StatelessWidget {
  final VisitRequest visitRequest;

  const _VisitRequestCard({required this.visitRequest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(visitRequest.status),
                Text(
                  _getFormattedDate(visitRequest),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Address
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitRequest.address,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visit Request #${visitRequest.id}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      // Text(
                      //   'Visit Request #${visitRequest.id.length >= 8 ? visitRequest.id.substring(0, 8) : visitRequest.id}',
                      //   style: const TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 12,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status and Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(visitRequest.status),
                    color: _getStatusColor(visitRequest.status),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status: ${visitRequest.statusText}',
                      style: TextStyle(
                        color: _getStatusColor(visitRequest.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(context, visitRequest),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VisitStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 12,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
            'Accept',
            Colors.blue,
            Icons.check_circle,
            () => _handleStatusUpdate(context, visit.id, VisitStatus.accepted),
          ),
        ];

      case VisitStatus.accepted:
      case VisitStatus.contractSent:
        return [
          _buildActionButton(
            'Cancel',
            Colors.red,
            Icons.cancel,
            () => _handleStatusUpdate(context, visit.id, VisitStatus.cancelled),
          ),
        ];

      case VisitStatus.contractActive:
        return [
          _buildActionButton(
            'Cancel',
            Colors.red,
            Icons.cancel,
            () => _handleStatusUpdate(context, visit.id, VisitStatus.cancelled),
          ),
          _buildActionButton(
            'Confirm Visit',
            Colors.green,
            Icons.verified,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
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
        return 'Pending';
      case VisitStatus.accepted:
        return 'Accepted';
      case VisitStatus.contractSent:
        return 'Contract Sent';
      case VisitStatus.contractActive:
        return 'Active';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getStatusIcon(VisitStatus status) {
    switch (status) {
      case VisitStatus.pending:
        return Icons.pending;
      case VisitStatus.accepted:
        return Icons.check_circle;
      case VisitStatus.contractSent:
        return Icons.send;
      case VisitStatus.contractActive:
        return Icons.play_circle;
      case VisitStatus.completed:
        return Icons.verified;
      case VisitStatus.cancelled:
        return Icons.cancel;
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
        return Colors.orange;
      case VisitStatus.accepted:
        return Colors.blue;
      case VisitStatus.contractSent:
        return Colors.purple;
      case VisitStatus.contractActive:
        return Colors.green;
      case VisitStatus.completed:
        return Colors.green;
      case VisitStatus.cancelled:
        return Colors.red;
    }
  }
}
