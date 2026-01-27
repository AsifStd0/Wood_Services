// views/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/models/seller_notificaion_model.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/views/Seller/data/views/noification_seller/notification_provider.dart';
import 'package:wood_service/views/Seller/data/views/noification_seller/notification_service.dart';

class SellerNotificaionScreen extends StatefulWidget {
  const SellerNotificaionScreen({super.key});

  @override
  State<SellerNotificaionScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<SellerNotificaionScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          NotificationsViewModel(service: locator<NotificationService>()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Notifications',
          showBackButton: true,
          backgroundColor: Colors.white,
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.more_vert_rounded, color: Colors.grey[700]),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? 'Failed to load notifications',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.loadNotifications(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(NotificationsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
    final isSelected = viewModel.selectedFilter == type;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: GestureDetector(
          onTap: () => viewModel.setFilter(type),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your notifications',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(NotificationsViewModel viewModel) {
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
                Icons.notifications_off_rounded,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              viewModel.selectedFilter == NotificationType.all
                  ? 'No Notifications'
                  : 'No ${_getFilterName(viewModel.selectedFilter)} Notifications',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              viewModel.selectedFilter == NotificationType.all
                  ? 'When you receive notifications, they will appear here'
                  : 'No ${_getFilterName(viewModel.selectedFilter).toLowerCase()} notifications found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Refresh'),
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
    Color iconColor;
    Color backgroundColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.visits:
        iconColor = Color(0xFF4D96FF);
        backgroundColor = Color(0xFF4D96FF).withOpacity(0.1);
        icon = Icons.assignment_turned_in_rounded;
        break;
      case NotificationType.contracts:
        iconColor = Color(0xFF9C27B0);
        backgroundColor = Color(0xFF9C27B0).withOpacity(0.1);
        icon = Icons.control_camera_outlined;
        break;
      case NotificationType.unread:
        iconColor = Color(0xFFFF6B6B);
        backgroundColor = Color(0xFFFF6B6B).withOpacity(0.1);
        icon = Icons.mark_email_unread_rounded;
        break;
      default:
        iconColor = Color(0xFF6BCF7F);
        backgroundColor = Color(0xFF6BCF7F).withOpacity(0.1);
        icon = Icons.notifications_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                notification.description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Received ${notification.timeAgo}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Notification deleted' : 'Failed to delete notification',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.mark_email_read_rounded,
                color: Color(0xFF667EEA),
              ),
              title: const Text('Mark all as read'),
              onTap: () async {
                Navigator.pop(context);
                final success = await viewModel.markAllAsRead();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'All notifications marked as read'
                            : 'Failed to mark as read',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text('Clear all notifications'),
              onTap: () {
                Navigator.pop(context);
                viewModel.clearAllNotifications();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: Colors.grey),
              title: const Text('Refresh'),
              onTap: () {
                Navigator.pop(context);
                viewModel.loadNotifications();
              },
            ),
          ],
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
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_rounded, color: Colors.red),
      ),
      onDismissed: (direction) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
                  _buildNotificationIcon(notification),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: notification.isRead
                                      ? Colors.grey[600]
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Color(0xFF667EEA),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
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

  Widget _buildNotificationIcon(SellerNotificaionModel notification) {
    Color iconColor;
    Color backgroundColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.visits:
        iconColor = Color(0xFF4D96FF);
        backgroundColor = Color(0xFF4D96FF).withOpacity(0.1);
        icon = Icons.assignment_turned_in_rounded;
        break;
      case NotificationType.contracts:
        iconColor = Color(0xFF9C27B0);
        backgroundColor = Color(0xFF9C27B0).withOpacity(0.1);
        icon = Icons.control_camera_outlined;
        break;
      case NotificationType.unread:
        iconColor = Color(0xFFFF6B6B);
        backgroundColor = Color(0xFFFF6B6B).withOpacity(0.1);
        icon = Icons.mark_email_unread_rounded;
        break;
      default:
        iconColor = Color(0xFF6BCF7F);
        backgroundColor = Color(0xFF6BCF7F).withOpacity(0.1);
        icon = Icons.notifications_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
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
