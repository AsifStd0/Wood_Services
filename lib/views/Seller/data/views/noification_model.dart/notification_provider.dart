// view_models/notifications_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_notificaion_model.dart';

class NotificationsViewModel with ChangeNotifier {
  List<SellerNotificaionModel> _notifications = [];
  NotificationType _selectedFilter = NotificationType.all;
  bool _isLoading = false;

  List<SellerNotificaionModel> get notifications => _notifications;
  NotificationType get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;

  NotificationsViewModel() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - replace with actual API call
    _notifications = [
      SellerNotificaionModel(
        id: '1',
        type: NotificationType.visits,
        title: 'Visit request accepted',
        description: 'Order #12345',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        orderId: '12345',
      ),
      SellerNotificaionModel(
        id: '2',
        type: NotificationType.contracts,
        title: 'Contract signed',
        description: 'Contract #67890',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        contractId: '67890',
      ),
      SellerNotificaionModel(
        id: '3',
        type: NotificationType.visits,
        title: 'Visit request pending',
        description: 'Order #12345',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        orderId: '12345',
      ),
      SellerNotificaionModel(
        id: '4',
        type: NotificationType.contracts,
        title: 'Contract sent for review',
        description: 'Contract #67890',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        contractId: '67890',
      ),
      SellerNotificaionModel(
        id: '5',
        type: NotificationType.visits,
        title: 'Upcoming visit reminder',
        description: 'Order #12345',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        orderId: '12345',
      ),
      SellerNotificaionModel(
        id: '6',
        type: NotificationType.contracts,
        title: 'Payment Confirmation',
        description: 'Order #54321',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        orderId: '54321',
      ),
    ];

    _isLoading = false;
    notifyListeners();
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
  }

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
}

// Extension for copyWith method
extension NotificationModelExtension on SellerNotificaionModel {
  SellerNotificaionModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    String? orderId,
    String? contractId,
  }) {
    return SellerNotificaionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      orderId: orderId ?? this.orderId,
      contractId: contractId ?? this.contractId,
    );
  }
}
