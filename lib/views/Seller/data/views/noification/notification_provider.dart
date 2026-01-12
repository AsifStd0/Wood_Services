// view_models/notifications_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/views/Seller/data/models/seller_notificaion_model.dart';

enum NotificationType { all, unread, visits, contracts }

class NotificationsViewModel with ChangeNotifier {
  List<SellerNotificaionModel> _notifications = [];
  NotificationType _selectedFilter = NotificationType.all;
  bool _isLoading = false;

  List<SellerNotificaionModel> get notifications => _notifications;
  NotificationType get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;

  // Get unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Get filtered notifications
  List<SellerNotificaionModel> get filteredNotifications {
    switch (_selectedFilter) {
      case NotificationType.all:
        return _notifications;
      case NotificationType.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationType.visits:
        return _notifications
            .where((n) => n.type == NotificationType.visits)
            .toList();
      case NotificationType.contracts:
        return _notifications
            .where((n) => n.type == NotificationType.contracts)
            .toList();
    }
  }

  NotificationsViewModel() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      // Mock data - replace with actual API call
      _notifications = [
        SellerNotificaionModel(
          id: '1',
          type: NotificationType.visits,
          title: 'New Visit Request',
          description:
              'John Smith has requested a site visit for your property listing',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: false,
          orderId: 'ORD-12345',
        ),
        SellerNotificaionModel(
          id: '2',
          type: NotificationType.contracts,
          title: 'Contract Signed',
          description:
              'Your contract for Oak Wood Supply has been signed by the buyer',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
          contractId: 'CONT-67890',
        ),
        SellerNotificaionModel(
          id: '3',
          type: NotificationType.visits,
          title: 'Visit Completed',
          description:
              'Site visit for Pine Furniture order has been completed successfully',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: false,
          orderId: 'ORD-54321',
        ),
        SellerNotificaionModel(
          id: '4',
          type: NotificationType.contracts,
          title: 'Contract Expiring Soon',
          description:
              'Your contract with WoodCraft Inc. will expire in 3 days',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: false,
          contractId: 'CONT-11223',
        ),
        SellerNotificaionModel(
          id: '5',
          type: NotificationType.visits,
          title: 'Visit Rescheduled',
          description:
              'The site visit for Teak Wood order has been rescheduled to tomorrow',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          orderId: 'ORD-99887',
        ),
        SellerNotificaionModel(
          id: '6',
          type: NotificationType.contracts,
          title: 'Payment Received',
          description:
              'Payment of \$2,500 has been received for Maple Wood delivery',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
          contractId: 'CONT-44556',
        ),
        SellerNotificaionModel(
          id: '7',
          type: NotificationType.visits,
          title: 'New Visit Scheduled',
          description:
              'A new site visit has been scheduled for your Mahogany collection',
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          isRead: false,
          orderId: 'ORD-77665',
        ),
        SellerNotificaionModel(
          id: '8',
          type: NotificationType.contracts,
          title: 'Contract Updated',
          description:
              'Terms and conditions have been updated in your active contract',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          isRead: true,
          contractId: 'CONT-33445',
        ),
      ];
    } catch (e) {
      // Handle error
      print('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(NotificationType filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();

    // Show success feedback (you can remove this if not needed)
    if (kDebugMode) {
      print('All notifications marked as read');
    }
  }

  void dismissNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();

    // Show success feedback (you can remove this if not needed)
    if (kDebugMode) {
      print('All notifications cleared');
    }
  }

  void refreshNotifications() {
    loadNotifications();
  }

  // Get notification by ID
  SellerNotificaionModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get notifications by type
  List<SellerNotificaionModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get recent notifications (last 7 days)
  List<SellerNotificaionModel> get recentNotifications {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) => n.timestamp.isAfter(weekAgo)).toList();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
