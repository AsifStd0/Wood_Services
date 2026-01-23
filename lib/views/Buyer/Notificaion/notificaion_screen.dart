import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications data
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'New Message',
      message: 'John Wood Crafts sent you a message about your teak wood order',
      type: NotificationType.message,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      sender: 'John Wood Crafts',
    ),
    NotificationItem(
      id: '2',
      title: 'Order Confirmed',
      message: 'Your order #WOOD123 for Mahogany Table has been confirmed',
      type: NotificationType.order,
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      orderId: 'WOOD123',
    ),
    NotificationItem(
      id: '3',
      title: 'Price Drop Alert',
      message: 'Oak Wood price dropped by 15%. Check it out now!',
      type: NotificationType.promotion,
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'New Arrival',
      message: 'New Teak Wood collection is now available in our store',
      type: NotificationType.newArrival,
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Delivery Update',
      message: 'Your order #WOOD122 is out for delivery today',
      type: NotificationType.delivery,
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      orderId: 'WOOD122',
    ),
    NotificationItem(
      id: '6',
      title: 'Payment Successful',
      message: 'Your payment of \$299.99 for order #WOOD121 was successful',
      type: NotificationType.payment,
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationItem(
      id: '7',
      title: 'Order Declined',
      message: 'Your order #WOOD120 was declined due to out of stock',
      type: NotificationType.order,
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      orderId: 'WOOD120',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Text('Mark all as read'),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Text('Clear all notifications'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Notification settings'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Quick Actions
                _buildQuickActions(),

                // Notifications List
                Expanded(
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.mark_email_read, size: 18),
              label: const Text('Mark all as read'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _clearAllNotifications,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear all'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue[50],
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: ListTile(
          leading: _buildNotificationIcon(notification.type),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(notification.time),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  if (notification.orderId != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.brown[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        notification.orderId!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.brown[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () {
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    final iconData = switch (type) {
      NotificationType.message => Icons.chat,
      NotificationType.order => Icons.shopping_bag,
      NotificationType.promotion => Icons.local_offer,
      NotificationType.newArrival => Icons.new_releases,
      NotificationType.delivery => Icons.local_shipping,
      NotificationType.payment => Icons.payment,
      NotificationType.system => Icons.info,
    };

    final color = switch (type) {
      NotificationType.message => Colors.blue,
      NotificationType.order => Colors.green,
      NotificationType.promotion => Colors.orange,
      NotificationType.newArrival => Colors.purple,
      NotificationType.delivery => Colors.teal,
      NotificationType.payment => Colors.green,
      NotificationType.system => Colors.grey,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read when tapped
    setState(() {
      notification.isRead = true;
    });

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.message:
        // Navigate to messages screen
        // context.push('/messages');
        break;
      case NotificationType.order:
        // Navigate to order details
        if (notification.orderId != null) {
          // context.push('/orders');
        }
        break;
      case NotificationType.promotion:
        // Navigate to promotions
        break;
      case NotificationType.newArrival:
        // Navigate to new arrivals
        // context.push('/home');
        break;
      case NotificationType.delivery:
        // Navigate to tracking
        break;
      case NotificationType.payment:
        // Navigate to payment history
        break;
      case NotificationType.system:
        // Show system message
        break;
    }

    // Show snackbar for demo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${notification.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text(
            'Are you sure you want to clear all notifications? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _notifications.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cleared')),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((notification) => notification.id == id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notification deleted')));
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'clear_all':
        _clearAllNotifications();
        break;
      case 'settings':
        // Navigate to notification settings
        // context.push('/notification_settings');
        break;
    }
  }
}

// Notification Types
enum NotificationType {
  message,
  order,
  promotion,
  newArrival,
  delivery,
  payment,
  system,
}

// Notification Model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime time;
  bool isRead;
  final String? sender;
  final String? orderId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.isRead = false,
    this.sender,
    this.orderId,
  });
}
