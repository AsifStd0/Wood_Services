//

import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/view_request_provider.dart';

Widget buildFilterTabs(VisitRequestsViewModel viewModel) {
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
        buildFilterTab('Active', VisitFilter.active, viewModel),
        buildFilterTab('Cancelled', VisitFilter.cancelled, viewModel),
        buildFilterTab('Completed', VisitFilter.completed, viewModel),
      ],
    ),
  );
}

Widget buildFilterTab(
  String title,
  VisitFilter filter,
  VisitRequestsViewModel viewModel,
) {
  final isSelected = viewModel.currentFilter == filter;

  return Expanded(
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.primaryGradient : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: () => viewModel.setFilter(filter),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}

Widget buildErrorState(VisitRequestsViewModel viewModel) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Something Went Wrong',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: viewModel.loadVisitRequests,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: Color(0xFF667EEA).withOpacity(0.3),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 22),
            label: const Text(
              'Try Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading Visit Requests',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while we fetch your requests',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    ),
  );
}

Widget buildEmptyState() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Visit Requests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'When you receive visit requests, they will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
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
                Text(
                  _getFormattedDate(visitRequest),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Address Section
            Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitRequest.address,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
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

            const SizedBox(height: 5),

            // Status Info Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.getStatusColor(
                      visitRequest.status,
                    ).withOpacity(0.05),
                    AppColors.getStatusColor(
                      visitRequest.status,
                    ).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.getStatusColor(
                    visitRequest.status,
                  ).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(visitRequest.status),
                    color: AppColors.getStatusColor(visitRequest.status),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Status: ${visitRequest.statusText}',
                      style: TextStyle(
                        color: AppColors.getStatusColor(visitRequest.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
            AppColors.getStatusColor(status),
            AppColors.getStatusColor(status).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getStatusColor(status).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
    return CustomButton(
      onPressed: () {},
      backgroundColor: color,
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
}
