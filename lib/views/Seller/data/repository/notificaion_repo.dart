// repositories/notification_repository.dart

import 'package:wood_service/views/Seller/data/models/seller_notificaion_model.dart';

abstract class NotificationRepository {
  Future<List<SellerNotificaionModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class MockNotificationRepository implements NotificationRepository {
  @override
  Future<List<SellerNotificaionModel>> getNotifications() async {
    // Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    return [
      // ... same mock data as in ViewModel
    ];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Implement API call to mark as read
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> markAllAsRead() async {
    // Implement API call to mark all as read
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
