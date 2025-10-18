// views/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_notificaion_model.dart';
import 'package:wood_service/widgets/advance_appbar.dart';
import 'package:wood_service/views/Seller/data/views/noification_model.dart/notification_provider.dart';

class SellerNotificaionScreen extends StatefulWidget {
  const SellerNotificaionScreen({super.key});

  @override
  State<SellerNotificaionScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<SellerNotificaionScreen> {
  final NotificationsViewModel _viewModel = NotificationsViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Notifications', showBackButton: false),
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
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = _viewModel.filteredNotifications;

                if (notifications.isEmpty) {
                  return const Center(child: Text('No notifications found'));
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(notifications[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
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
    return Expanded(
      child: InkWell(
        onTap: () => _viewModel.setFilter(type),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _viewModel.selectedFilter == type
                    ? Colors.blue
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: _viewModel.selectedFilter == type
                    ? Colors.blue
                    : Colors.grey,
                fontWeight: _viewModel.selectedFilter == type
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(SellerNotificaionModel notification) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.green, size: 20),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          notification.description,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Text(
          notification.timeAgo,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        onTap: () {
          _viewModel.markAsRead(notification.id);
          // Handle notification tap (navigate to details, etc.)
        },
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
