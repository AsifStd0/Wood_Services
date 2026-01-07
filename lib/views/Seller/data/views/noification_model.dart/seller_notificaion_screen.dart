// views/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_notificaion_model.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/views/Seller/data/views/noification_model.dart/notification_provider.dart';

class SellerNotificaionScreen extends StatefulWidget {
  const SellerNotificaionScreen({super.key});

  @override
  State<SellerNotificaionScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<SellerNotificaionScreen> {
  final NotificationsViewModel _viewModel = NotificationsViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey[700]),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),

          // Notifications List
          Expanded(
            child: AnimatedBuilder(
              animation: _viewModel,
              builder: (context, child) {
                if (_viewModel.isLoading) {
                  return _buildLoadingState();
                }

                final notifications = _viewModel.filteredNotifications;

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildNotificationsList(notifications);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
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
          _buildFilterTab('All', NotificationType.all),
          _buildFilterTab('Unread', NotificationType.unread),
          _buildFilterTab('Visits', NotificationType.visits),
          _buildFilterTab('Contracts', NotificationType.contracts),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String text, NotificationType type) {
    final isSelected = _viewModel.selectedFilter == type;

    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: GestureDetector(
          onTap: () => _viewModel.setFilter(type),
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

  Widget _buildEmptyState() {
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
              _viewModel.selectedFilter == NotificationType.all
                  ? 'No Notifications'
                  : 'No ${_viewModel.selectedFilter.name.capitalize()} Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _viewModel.selectedFilter == NotificationType.all
                  ? 'When you receive notifications, they will appear here'
                  : 'No ${_viewModel.selectedFilter.name.toLowerCase()} notifications found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _viewModel.loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<SellerNotificaionModel> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _NotificationCard(
          notification: notifications[index],
          onTap: () {
            _viewModel.markAsRead(notifications[index].id);
            _handleNotificationTap(notifications[index]);
          },
          onDismiss: () => _handleDismissNotification(notifications[index].id),
        );
      },
    );
  }

  Widget _buildNotificationItem(SellerNotificaionModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: _buildNotificationIcon(notification),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: notification.isRead ? Colors.grey[600] : Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA),
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          _viewModel.markAsRead(notification.id);
        },
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

  void _handleDismissNotification(String notificationId) {
    _viewModel.dismissNotification(notificationId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification dismissed'),
        backgroundColor: Colors.grey[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMoreOptions() {
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
              leading: Icon(
                Icons.mark_email_read_rounded,
                color: Color(0xFF667EEA),
              ),
              title: Text('Mark all as read'),
              onTap: () {
                _viewModel.markAllAsRead();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: Text('Clear all notifications'),
              onTap: () {
                _viewModel.clearAllNotifications();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_rounded, color: Colors.grey),
              title: Text('Notification settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
                  _buildNotificationIcon(),
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

  Widget _buildNotificationIcon() {
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
