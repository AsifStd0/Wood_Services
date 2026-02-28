// views/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/models/seller_notificaion_model.dart';
import 'package:wood_service/views/Seller/data/services/notification_service.dart';
import 'package:wood_service/views/Seller/data/views/noification_seller/notification_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerNotificaionScreen extends StatefulWidget {
  const SellerNotificaionScreen({super.key});

  @override
  State<SellerNotificaionScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<SellerNotificaionScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) =>
          NotificationsViewModel(service: locator<NotificationService>()),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Notifications',
          showBackButton: true,
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () {
                    final viewModel = context.read<NotificationsViewModel>();
                    _showMoreOptions(context, viewModel);
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<NotificationsViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Filter Tabs
                _buildFilterTabs(viewModel),

                // Notifications List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => viewModel.loadNotifications(),
                    child: _buildContent(viewModel),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(NotificationsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return _buildLoadingState();
    }

    if (viewModel.errorMessage != null && viewModel.notifications.isEmpty) {
      return _buildErrorState(viewModel);
    }

    final notifications = viewModel.filteredNotifications;

    if (notifications.isEmpty) {
      return _buildEmptyState(viewModel);
    }

    return _buildNotificationsList(notifications, viewModel);
  }

  Widget _buildErrorState(NotificationsViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'Failed to load notifications',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => viewModel.loadNotifications(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(NotificationsViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildFilterTab('All', NotificationType.all, viewModel),
          _buildFilterTab('Unread', NotificationType.unread, viewModel),
          _buildFilterTab('Visits', NotificationType.visits, viewModel),
          _buildFilterTab('Orders', NotificationType.contracts, viewModel),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    String text,
    NotificationType type,
    NotificationsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = viewModel.selectedFilter == type;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: GestureDetector(
          onTap: () => viewModel.setFilter(type),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your notifications',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(NotificationsViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 56,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              viewModel.selectedFilter == NotificationType.all
                  ? 'No Notifications'
                  : 'No ${_getFilterName(viewModel.selectedFilter)} Notifications',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              viewModel.selectedFilter == NotificationType.all
                  ? 'When you receive notifications, they will appear here'
                  : 'No ${_getFilterName(viewModel.selectedFilter).toLowerCase()} notifications found',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => viewModel.loadNotifications(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Refresh'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterName(NotificationType type) {
    switch (type) {
      case NotificationType.all:
        return 'All';
      case NotificationType.unread:
        return 'Unread';
      case NotificationType.visits:
        return 'Visits';
      case NotificationType.contracts:
        return 'Orders';
    }
  }

  Widget _buildNotificationsList(
    List<SellerNotificaionModel> notifications,
    NotificationsViewModel viewModel,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _NotificationCard(
          notification: notifications[index],
          onTap: () {
            viewModel.markAsRead(notifications[index].id);
            _handleNotificationTap(notifications[index]);
          },
          onDismiss: () =>
              _handleDismissNotification(notifications[index].id, viewModel),
        );
      },
    );
  }

  Widget _buildNotificationIcon(SellerNotificaionModel notification) {
    final colorScheme = Theme.of(context).colorScheme;
    Color iconColor;
    Color backgroundColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.visits:
        iconColor = colorScheme.primary;
        backgroundColor = colorScheme.primaryContainer.withOpacity(0.6);
        icon = Icons.assignment_turned_in_rounded;
        break;
      case NotificationType.contracts:
        iconColor = colorScheme.tertiary;
        backgroundColor = colorScheme.tertiaryContainer.withOpacity(0.6);
        icon = Icons.control_camera_outlined;
        break;
      case NotificationType.unread:
        iconColor = colorScheme.error;
        backgroundColor = colorScheme.errorContainer.withOpacity(0.6);
        icon = Icons.mark_email_unread_rounded;
        break;
      default:
        iconColor = colorScheme.primary;
        backgroundColor = colorScheme.primaryContainer.withOpacity(0.6);
        icon = Icons.notifications_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  void _handleNotificationTap(SellerNotificaionModel notification) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.visits:
        // Navigate to visit requests screen
        break;
      case NotificationType.contracts:
        // Navigate to contracts screen
        break;
      default:
        // Show notification details
        _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(SellerNotificaionModel notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colorScheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildNotificationIcon(notification),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notification.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              notification.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Received ${notification.timeAgo}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDismissNotification(
    String notificationId,
    NotificationsViewModel viewModel,
  ) async {
    final success = await viewModel.deleteNotification(notificationId);
    if (context.mounted) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Notification deleted' : 'Failed to delete notification',
          ),
          backgroundColor: success ? colorScheme.tertiary : colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showMoreOptions(
    BuildContext context,
    NotificationsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.mark_email_read_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'Mark all as read',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final success = await viewModel.markAllAsRead();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'All notifications marked as read'
                              : 'Failed to mark as read',
                        ),
                        backgroundColor: success
                            ? colorScheme.tertiary
                            : colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                ),
                title: Text(
                  'Clear all notifications',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  viewModel.clearAllNotifications();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.refresh_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  'Refresh',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  viewModel.loadNotifications();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final SellerNotificaionModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_rounded, color: colorScheme.error),
      ),
      onDismissed: (direction) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildNotificationIcon(context, notification),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: notification.isRead
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification.timeAgo,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
    BuildContext context,
    SellerNotificaionModel notification,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    Color iconColor;
    Color backgroundColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.visits:
        iconColor = colorScheme.primary;
        backgroundColor = colorScheme.primaryContainer.withOpacity(0.6);
        icon = Icons.assignment_turned_in_rounded;
        break;
      case NotificationType.contracts:
        iconColor = colorScheme.tertiary;
        backgroundColor = colorScheme.tertiaryContainer.withOpacity(0.6);
        icon = Icons.control_camera_outlined;
        break;
      case NotificationType.unread:
        iconColor = colorScheme.error;
        backgroundColor = colorScheme.errorContainer.withOpacity(0.6);
        icon = Icons.mark_email_unread_rounded;
        break;
      default:
        iconColor = colorScheme.primary;
        backgroundColor = colorScheme.primaryContainer.withOpacity(0.6);
        icon = Icons.notifications_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
