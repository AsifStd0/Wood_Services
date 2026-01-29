// screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_requests_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  String _selectedStatus = 'all';
  late VisitRequestsProvider _visitProvider;

  @override
  void initState() {
    super.initState();
    // Get provider instance from locator
    _visitProvider = locator<VisitRequestsProvider>();

    // Load data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_visitProvider.visitRequests.isEmpty && !_visitProvider.isLoading) {
        _visitProvider.loadVisitRequests();
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
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerNotificaionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableProvider.value(
        value: _visitProvider, // Use existing instance
        child: Consumer<VisitRequestsProvider>(
          builder: (context, visitProvider, child) {
            return Column(
              children: [
                // Header with Stats
                buildHeaderStats(visitProvider),
                // Filter Tabs
                _buildFilterTabs(visitProvider),

                // Visit Requests List
                Expanded(child: _buildVisitList(visitProvider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildHeaderStats(
    // SellerStatsProvider statsProvider,
    VisitRequestsProvider visitProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 15, top: 8),
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
          // Text(
          //   '${statsProvider.totalServices}',
          //   style: const TextStyle(
          //     color: Colors.white,
          //     fontSize: 35,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const Text(
          //   'Total Services',
          //   style: TextStyle(color: Colors.white, fontSize: 14),
          // ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  'Total Visit',
                  visitProvider.totalRequests,
                  Icons.event,
                  Colors.purple,
                ),
                _buildStatChip(
                  'Pending',
                  visitProvider.pendingCount,
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatChip(
                  'Accepted',
                  visitProvider.acceptedCount,
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatChip(
                  'Rejected',
                  visitProvider.rejectedCount,
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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

  Widget _buildFilterChip(
    String label,
    String status,
    VisitRequestsProvider visitProvider,
  ) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = status;
          });
          visitProvider.loadVisitRequests(
            status: status == 'all' ? null : status,
            refresh: true,
          );
        },
        selectedColor: AppColors.brightOrange,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildVisitList(VisitRequestsProvider visitProvider) {
    if (visitProvider.isLoading && visitProvider.visitRequests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (visitProvider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${visitProvider.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => visitProvider.loadVisitRequests(
                status: _selectedStatus == 'all' ? null : _selectedStatus,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final requests = _selectedStatus == 'all'
        ? visitProvider.visitRequests
        : _selectedStatus == 'pending'
        ? visitProvider.pendingRequests
        : _selectedStatus == 'accepted'
        ? visitProvider.acceptedRequests
        : _selectedStatus == 'rejected'
        ? visitProvider.rejectedRequests
        : visitProvider.completedRequests;

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No visit requests found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visit requests will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => visitProvider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildVisitRequestCard(request, visitProvider);
        },
      ),
    );
  }

  Widget _buildVisitRequestCard(
    Map<String, dynamic> request,
    VisitRequestsProvider visitProvider,
  ) {
    final requestDetails = request['requestDetails'] ?? {};
    final address = requestDetails['address'] ?? {};
    final buyerId = request['buyerId'] ?? {};
    final serviceId = request['serviceId'] ?? {};
    final status = request['status']?.toString().toLowerCase() ?? 'pending';

    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
      case 'declined':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    serviceId['title'] ?? 'Customize Product',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Buyer Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    (buyerId['name'] ?? 'B')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyerId['name'] ?? 'Unknown Buyer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (buyerId['email'] != null)
                        Text(
                          buyerId['email'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (buyerId['phone'] != null)
                        Text(
                          buyerId['phone'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            if (requestDetails['description'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  requestDetails['description'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),

            // Address
            if (address['street'] != null || address['city'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${address['street'] ?? ''}, ${address['city'] ?? ''}'
                            .replaceAll(RegExp(r'^,\s*|,\s*$'), ''),
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),

            // Preferred Date & Time
            if (requestDetails['preferredDate'] != null)
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(requestDetails['preferredDate']),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (requestDetails['preferredTime'] != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      requestDetails['preferredTime'],
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 12),

            // Action Buttons
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptRequest(
                        request['_id']?.toString() ?? '',
                        visitProvider,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRequest(
                        request['_id']?.toString() ?? '',
                        visitProvider,
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  // In seller_home_screen.dart, update the _acceptRequest method:
  Future<void> _acceptRequest(
    String requestId,
    VisitRequestsProvider visitProvider,
  ) async {
    // Show dialog to get estimated cost
    final estimatedCost = await _showEstimatedCostDialog(context);

    if (estimatedCost == null) {
      return; // User cancelled
    }

    final result = await visitProvider.acceptRequest(
      requestId: requestId,
      estimatedCost: estimatedCost,
    );

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit request accepted with estimated cost'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            visitProvider.errorMessage ?? 'Failed to accept request',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<double?> _showEstimatedCostDialog(BuildContext context) async {
    final costController = TextEditingController();

    return await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Estimated Cost'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Estimated Cost (USD)',
                prefixText: '\$ ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter estimated cost';
                }
                final cost = double.tryParse(value);
                if (cost == null || cost <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Estimated cost is required when accepting a visit request',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final cost = double.tryParse(costController.text);
              if (cost != null && cost > 0) {
                Navigator.pop(context, cost);
              }
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  // Also update the filter tabs to include all statuses:
  Widget _buildFilterTabs(VisitRequestsProvider visitProvider) {
    final statuses = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Accepted', 'value': 'accepted'},
      {'label': 'Rejected', 'value': 'rejected'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Cancelled', 'value': 'cancelled'},
      {'label': 'Visited', 'value': 'visited'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: statuses.map((status) {
          return _buildFilterChip(
            status['label']!,
            status['value']!,
            visitProvider,
          );
        }).toList(),
      ),
    );
  }

  Future<void> _rejectRequest(
    String requestId,
    VisitRequestsProvider visitProvider,
  ) async {
    final result = await visitProvider.rejectRequest(requestId);
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit request rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            visitProvider.errorMessage ?? 'Failed to reject request',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
