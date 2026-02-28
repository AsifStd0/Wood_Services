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
        status = null;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<BuyerVisitRequestProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Visit Requests',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  onTap: _loadTabRequests,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: 'All (${provider.totalCount})'),
                    Tab(text: 'Pending (${provider.pendingCount})'),
                    Tab(text: 'Accepted (${provider.acceptedCount})'),
                    Tab(text: 'Completed (${provider.completedCount})'),
                    Tab(text: 'Rejected (${provider.rejectedCount})'),
                  ],
                ),
              ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (provider.isLoading && requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Loading visit requests...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.hasError && requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                provider.errorMessage ?? 'Failed to load visit requests',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => provider.refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No visit requests',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your visit requests will appear here when you request a seller visit.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: request.statusColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.serviceTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Seller: ${request.sellerName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: request.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (request.serviceImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      request.serviceImage!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildDetailRow(
                  theme,
                  colorScheme,
                  Icons.description_outlined,
                  'Description',
                  request.description ?? 'No description',
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  theme,
                  colorScheme,
                  Icons.location_on_outlined,
                  'Address',
                  request.formattedAddress,
                ),
                if (request.preferredDate != null) ...[
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    theme,
                    colorScheme,
                    Icons.calendar_today_outlined,
                    'Preferred Date',
                    _formatDate(request.preferredDate!),
                  ),
                ],
                if (request.preferredTime != null) ...[
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    theme,
                    colorScheme,
                    Icons.access_time_rounded,
                    'Preferred Time',
                    request.preferredTime!,
                  ),
                ],

                if (request.status == BuyerVisitRequestStatus.accepted &&
                    request.estimatedCostAmount != null) ...[
                  const SizedBox(height: 14),
                  _buildCostChip(
                    theme,
                    colorScheme,
                    Icons.attach_money_rounded,
                    'Estimated Cost',
                    request.estimatedCostAmount!,
                    colorScheme.primary,
                  ),
                ],

                if (request.status == BuyerVisitRequestStatus.completed &&
                    request.actualCostAmount != null) ...[
                  const SizedBox(height: 14),
                  _buildCostChip(
                    theme,
                    colorScheme,
                    Icons.check_circle_outline_rounded,
                    'Final Cost',
                    request.actualCostAmount!,
                    colorScheme.tertiary,
                  ),
                ],

                if (request.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.6,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Seller Notes',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                if (createdAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(createdAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
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

                if (request.requestedAt != null) ...[
                  const SizedBox(height: 16),
                  Divider(color: colorScheme.outline.withOpacity(0.3)),
                  const SizedBox(height: 10),
                  Text(
                    'Requested: ${_formatDateTime(request.requestedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (request.acceptedAt != null)
                    Text(
                      'Accepted: ${_formatDateTime(request.acceptedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (request.completedAt != null)
                    Text(
                      'Completed: ${_formatDateTime(request.completedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],

                if (request.status == BuyerVisitRequestStatus.pending ||
                    request.status == BuyerVisitRequestStatus.accepted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelRequest(request, provider),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Request'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if address it will be two lines
              if (label == 'Address' && value.isNotEmpty) ...[
                Text(
                  "$label: ",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  // Add Expanded here to allow wrapping
                  child: Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    value ?? 'N/A',
                    textAlign: TextAlign.start,
                    // Remove maxLines and overflow constraints
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  "${label}: ",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value ?? 'N/A',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostChip(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String label,
    String value,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Text(
            '$label: $value',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
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
    return DateFormat('MMM dd, yyyy · hh:mm a').format(dateTime);
  }

  Future<void> _cancelRequest(
    BuyerVisitRequest request,
    BuyerVisitRequestProvider provider,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Visit Request'),
        content: const Text(
          'Are you sure you want to cancel this visit request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep', style: TextStyle(color: colorScheme.primary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
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
                  ? 'Visit request cancelled'
                  : 'Failed to cancel visit request',
            ),
            backgroundColor: success ? colorScheme.tertiary : colorScheme.error,
            behavior: SnackBarBehavior.floating,
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
