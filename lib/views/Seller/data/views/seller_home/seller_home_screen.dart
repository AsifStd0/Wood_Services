import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/core/constants/app_strings.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/noification_seller/seller_notificaion_screen.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/seller_widgets.dart';
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
    _visitProvider = locator<VisitRequestsProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_visitProvider.visitRequests.isEmpty && !_visitProvider.isLoading) {
        _visitProvider.loadVisitRequests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Seller Dashboard',
        showBackButton: false,
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
            tooltip: AppStrings.notifications,
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
        value: _visitProvider,
        child: Consumer<VisitRequestsProvider>(
          builder: (context, visitProvider, child) {
            return Column(
              children: [
                // Header with Stats
                HeaderStatsWidget(visitProvider: visitProvider),

                // Filter Tabs
                FilterTabsWidget(
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (status) {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  visitProvider: visitProvider,
                ),

                // Visit Requests List
                Expanded(child: _buildVisitList(visitProvider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVisitList(VisitRequestsProvider visitProvider) {
    if (visitProvider.isLoading && visitProvider.visitRequests.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (visitProvider.hasError) {
      return ErrorStateWidget(
        message: visitProvider.errorMessage ?? 'An error occurred',
        onRetry: () => visitProvider.loadVisitRequests(
          status: _selectedStatus == 'all' ? null : _selectedStatus,
        ),
      );
    }

    final requests = _getFilteredRequests(visitProvider);

    if (requests.isEmpty) {
      return const EmptyStateWidget();
    }

    return RefreshIndicator(
      onRefresh: () => visitProvider.refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return VisitRequestCard(
            request: request,
            visitProvider: visitProvider,
            onAccept: () =>
                _acceptRequest(request['_id']?.toString() ?? '', visitProvider),
            onReject: () =>
                _rejectRequest(request['_id']?.toString() ?? '', visitProvider),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredRequests(
    VisitRequestsProvider visitProvider,
  ) {
    switch (_selectedStatus) {
      case 'pending':
        return visitProvider.pendingRequests;
      case 'accepted':
        return visitProvider.acceptedRequests;
      case 'rejected':
        return visitProvider.rejectedRequests;
      case 'completed':
        return visitProvider.completedRequests;
      default:
        return visitProvider.visitRequests;
    }
  }

  Future<void> _acceptRequest(
    String requestId,
    VisitRequestsProvider visitProvider,
  ) async {
    final estimatedCost = await _showEstimatedCostDialog(context);

    if (estimatedCost == null) {
      return;
    }

    final result = await visitProvider.acceptRequest(
      requestId: requestId,
      estimatedCost: estimatedCost,
    );

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Visit request accepted successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            visitProvider.errorMessage ?? 'Failed to accept request',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _rejectRequest(
    String requestId,
    VisitRequestsProvider visitProvider,
  ) async {
    final result = await visitProvider.rejectRequest(requestId);

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Visit request rejected'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            visitProvider.errorMessage ?? 'Failed to reject request',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<double?> _showEstimatedCostDialog(BuildContext context) async {
    final costController = TextEditingController();

    return await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.attach_money_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Enter Estimated Cost'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Estimated Cost (USD)',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estimated cost is required when accepting a visit request',
                      style: TextStyle(fontSize: 12, color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final cost = double.tryParse(costController.text);
              if (cost != null && cost > 0) {
                Navigator.pop(context, cost);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
