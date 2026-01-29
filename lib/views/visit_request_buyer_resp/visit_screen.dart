// screens/buyer_visit_request_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_provider.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_request_model.dart';

class BuyerVisitRequestScreen extends StatefulWidget {
  const BuyerVisitRequestScreen({super.key});

  @override
  State<BuyerVisitRequestScreen> createState() =>
      _BuyerVisitRequestScreenState();
}

class _BuyerVisitRequestScreenState extends State<BuyerVisitRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final provider = context.read<BuyerVisitRequestProvider>();
    provider.loadVisitRequests(refresh: true);
  }

  void _loadTabRequests(int index) {
    final provider = context.read<BuyerVisitRequestProvider>();
    BuyerVisitRequestStatus? status;

    switch (index) {
      case 0:
        status = null; // All
        break;
      case 1:
        status = BuyerVisitRequestStatus.pending;
        break;
      case 2:
        status = BuyerVisitRequestStatus.accepted;
        break;
      case 3:
        status = BuyerVisitRequestStatus.completed;
        break;
      case 4:
        status = BuyerVisitRequestStatus.rejected;
        break;
    }

    provider.loadVisitRequests(status: status, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerVisitRequestProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('My Visit Requests'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(text: 'All (${provider.totalCount})'),
                Tab(text: 'Pending (${provider.pendingCount})'),
                Tab(text: 'Accepted (${provider.acceptedCount})'),
                Tab(text: 'Completed (${provider.completedCount})'),
                Tab(text: 'Rejected (${provider.rejectedCount})'),
              ],
              onTap: _loadTabRequests,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAllRequestsTab(provider),
              _buildPendingTab(provider),
              _buildAcceptedTab(provider),
              _buildCompletedTab(provider),
              _buildRejectedTab(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllRequestsTab(BuyerVisitRequestProvider provider) {
    return _buildRequestsList(provider.visitRequests, provider);
  }

  Widget _buildPendingTab(BuyerVisitRequestProvider provider) {
    return _buildRequestsList(provider.pendingRequests, provider);
  }

  Widget _buildAcceptedTab(BuyerVisitRequestProvider provider) {
    return _buildRequestsList(provider.acceptedRequests, provider);
  }

  Widget _buildCompletedTab(BuyerVisitRequestProvider provider) {
    return _buildRequestsList(provider.completedRequests, provider);
  }

  Widget _buildRejectedTab(BuyerVisitRequestProvider provider) {
    return _buildRequestsList(provider.rejectedRequests, provider);
  }

  Widget _buildRequestsList(
    List<BuyerVisitRequest> requests,
    BuyerVisitRequestProvider provider,
  ) {
    if (provider.isLoading && requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError && requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Failed to load visit requests',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No visit requests',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Your visit requests will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return _buildVisitRequestCard(requests[index], provider);
        },
      ),
    );
  }

  Widget _buildVisitRequestCard(
    BuyerVisitRequest request,
    BuyerVisitRequestProvider provider,
  ) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: request.statusColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.serviceTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Seller: ${request.sellerName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
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
                        color: request.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request.statusText,
                        style: TextStyle(
                          color: request.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Service Image
                if (request.serviceImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      request.serviceImage!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                if (request.serviceImage != null) const SizedBox(height: 16),

                // Request Details
                _buildDetailRow(
                  Icons.description,
                  'Description',
                  request.description ?? 'No description',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.location_on,
                  'Address',
                  request.formattedAddress,
                ),
                if (request.preferredDate != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Preferred Date',
                    _formatDate(request.preferredDate!),
                  ),
                ],
                if (request.preferredTime != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.access_time,
                    'Preferred Time',
                    request.preferredTime!,
                  ),
                ],

                // Estimated Cost (if accepted)
                if (request.status == BuyerVisitRequestStatus.accepted &&
                    request.estimatedCostAmount != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated Cost: ${request.estimatedCostAmount}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Actual Cost (if completed)
                if (request.status == BuyerVisitRequestStatus.completed &&
                    request.actualCostAmount != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Final Cost: ${request.actualCostAmount}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Seller Notes
                if (request.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note,
                              color: Colors.orange[700],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Seller Notes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...request.notes.map((note) {
                          final message = note['message']?.toString() ?? '';
                          final createdAt = note['createdAt']?.toString();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                if (createdAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                // Timeline
                if (request.requestedAt != null) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    'Requested: ${_formatDateTime(request.requestedAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (request.acceptedAt != null)
                    Text(
                      'Accepted: ${_formatDateTime(request.acceptedAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (request.completedAt != null)
                    Text(
                      'Completed: ${_formatDateTime(request.completedAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],

                // Action Buttons
                const SizedBox(height: 16),
                if (request.status == BuyerVisitRequestStatus.pending ||
                    request.status == BuyerVisitRequestStatus.accepted)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelRequest(request, provider),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Request'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  Future<void> _cancelRequest(
    BuyerVisitRequest request,
    BuyerVisitRequestProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Visit Request'),
        content: const Text(
          'Are you sure you want to cancel this visit request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.cancelVisitRequest(request.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Visit request cancelled successfully'
                  : 'Failed to cancel visit request',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
