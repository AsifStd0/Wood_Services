// services/notification_service.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/models/seller_notificaion_model.dart';

class NotificationService {
  final Dio _dio;
  final UnifiedLocalStorageServiceImpl _storage;

  NotificationService({Dio? dio, UnifiedLocalStorageServiceImpl? storage})
    : _dio = dio ?? locator<Dio>(),
      _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>();

  String? _getToken() {
    try {
      return _storage.getToken();
    } catch (e) {
      log('❌ Error getting token: $e');
      return null;
    }
  }

  /// GET /api/notifications - Get all notifications
  Future<List<SellerNotificaionModel>> getNotifications() async {
    try {
      log('📬 Fetching notifications...');

      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to view notifications');
      }

      final response = await _dio.get(
        '/notifications',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final notificationsData = data['data']?['notifications'] ?? [];
          final notifications = (notificationsData as List)
              .map((json) => SellerNotificaionModel.fromJson(json))
              .toList();

          log('✅ Loaded ${notifications.length} notifications');
          return notifications;
        } else {
          throw Exception(data['message'] ?? 'Failed to load notifications');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error fetching notifications: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to load notifications';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error fetching notifications: $e');
      rethrow;
    }
  }

  /// PUT /api/notifications/:id/read - Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      log('✅ Marking notification as read: $notificationId');

      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to mark notifications as read');
      }

      final response = await _dio.put(
        '/notifications/$notificationId/read',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          log('✅ Notification marked as read');
          return true;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to mark notification as read',
          );
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error marking notification as read: ${e.message}');
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to mark notification as read';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  /// PUT /api/notifications/read-all - Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      log('✅ Marking all notifications as read');

      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to mark notifications as read');
      }

      final response = await _dio.put(
        '/notifications/read-all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          log('✅ All notifications marked as read');
          return true;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to mark all notifications as read',
          );
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error marking all notifications as read: ${e.message}');
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to mark all notifications as read';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// DELETE /api/notifications/:id - Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      log('🗑️ Deleting notification: $notificationId');

      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to delete notifications');
      }

      final response = await _dio.delete(
        '/notifications/$notificationId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          log('✅ Notification deleted successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to delete notification');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error deleting notification: ${e.message}');
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to delete notification';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error deleting notification: $e');
      rethrow;
    }
  }
}
