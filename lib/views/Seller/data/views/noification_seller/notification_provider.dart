// view_models/notifications_view_model.dart
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/models/seller_notificaion_model.dart';
import 'package:wood_service/views/Seller/data/views/noification_seller/notification_service.dart';

enum NotificationType { all, unread, visits, contracts }

class NotificationsViewModel with ChangeNotifier {
  final NotificationService _service;

  List<SellerNotificaionModel> _notifications = [];
  NotificationType _selectedFilter = NotificationType.all;
  bool _isLoading = false;
  String? _errorMessage;

  List<SellerNotificaionModel> get notifications => _notifications;
  NotificationType get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  NotificationsViewModel({NotificationService? service})
      : _service = service ?? locator<NotificationService>() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📬 Loading notifications from API...');
      _notifications = await _service.getNotifications();
      log('✅ Loaded ${_notifications.length} notifications');
    } catch (e) {
      log('❌ Error loading notifications: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(NotificationType filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      log('✅ Marking notification as read: $notificationId');
      
      // Optimistically update UI
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      // Call API
      final success = await _service.markAsRead(notificationId);
      
      if (!success && index != -1) {
        // Revert if API call failed
        _notifications[index] = _notifications[index].copyWith(isRead: false);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      log('❌ Error marking notification as read: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      log('✅ Marking all notifications as read');
      
      // Optimistically update UI
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      notifyListeners();

      // Call API
      final success = await _service.markAllAsRead();
      
      if (!success) {
        // Revert if API call failed
        await loadNotifications(); // Reload from server
      }
      
      return success;
    } catch (e) {
      log('❌ Error marking all notifications as read: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      log('🗑️ Deleting notification: $notificationId');
      
      // Store the notification in case we need to revert
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => _notifications.first,
      );
      
      // Optimistically remove from UI
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      // Call API
      final success = await _service.deleteNotification(notificationId);
      
      if (!success) {
        // Revert if API call failed
        _notifications.add(notification);
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      log('❌ Error deleting notification: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void dismissNotification(String notificationId) {
    deleteNotification(notificationId);
  }

  void clearAllNotifications() {
    // Delete all notifications one by one
    final notificationIds = List<String>.from(_notifications.map((n) => n.id));
    for (var id in notificationIds) {
      deleteNotification(id);
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
