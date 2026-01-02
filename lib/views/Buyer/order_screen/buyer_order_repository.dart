import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_model.dart';

abstract class BuyerOrderRepository {
  Future<List<BuyerOrder>> getOrders({String? status});
  Future<BuyerOrder> getOrderDetails(String orderId);
  Future<Map<String, int>> getOrderSummary();
  Future<void> cancelOrder(String orderId, String reason);
  Future<void> markAsReceived(String orderId);
  Future<void> submitReview(
    String orderId, {
    required int rating,
    String? comment,
    List<Map<String, dynamic>>? itemReviews,
  });
}

class ApiBuyerOrderRepository implements BuyerOrderRepository {
  final BuyerLocalStorageService storageService;
  final String baseUrl;

  ApiBuyerOrderRepository({
    required this.storageService,
    required this.baseUrl,
  });

  @override
  Future<List<BuyerOrder>> getOrders({String? status}) async {
    log('message');
    log('🔄 Fetching buyer orders with status: $status');

    try {
      final token = await storageService.getBuyerToken();
      if (token == null) throw Exception('Please login again');
      final uri = Uri.parse('http://192.168.18.107:5001/api/buyer/orders')
          .replace(
            queryParameters: {
              if (status != null) 'status': status,
              'page': '1',
              'limit': '50',
            },
          );

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> orders = data['orders'] ?? [];
          log('✅ Found ${orders.length} orders');

          return orders.map((order) => BuyerOrder.fromJson(order)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load orders');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error fetching orders: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getOrderSummary() async {
    try {
      final token = await storageService.getBuyerToken();
      if (token == null) throw Exception('Please login again');

      final response = await http
          .get(
            Uri.parse(
              'http://192.168.18.107:5001/api/buyer/orders/stats/summary',
            ),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final summary = data['summary'];
          return {
            'pending': summary['pending'] ?? 0,
            'accepted': summary['accepted'] ?? 0,
            'declined': summary['declined'] ?? 0,
            'completed': summary['completed'] ?? 0,
            'total': summary['total'] ?? 0,
          };
        }
      }
      return {
        'pending': 0,
        'accepted': 0,
        'declined': 0,
        'completed': 0,
        'total': 0,
      };
    } catch (e) {
      log('❌ Error fetching order summary: $e');
      return {
        'pending': 0,
        'accepted': 0,
        'declined': 0,
        'completed': 0,
        'total': 0,
      };
    }
  }

  @override
  Future<BuyerOrder> getOrderDetails(String orderId) async {
    try {
      final token = await storageService.getBuyerToken();
      if (token == null) throw Exception('Please login again');

      final response = await http
          .get(
            Uri.parse('http://192.168.18.107:5001/api/buyer/orders/$orderId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return BuyerOrder.fromJson(data['order']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch order details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error fetching order details: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final token = await storageService.getBuyerToken();
      if (token == null) throw Exception('Please login again');

      final response = await http
          .post(
            Uri.parse(
              'http://192.168.18.107:5001/api/buyer/orders/$orderId/cancel',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'reason': reason}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Order cancelled successfully');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to cancel order');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error cancelling order: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsReceived(String orderId) async {
    try {
      final token = await storageService.getBuyerToken();
      if (token == null) throw Exception('Please login again');

      final response = await http
          .post(
            Uri.parse(
              'http://192.168.18.107:5001/api/buyer/orders/$orderId/received',
            ),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Order marked as received');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to mark as received');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error marking order as received: $e');
      rethrow;
    }
  }

  @override
  Future<void> submitReview(
    String orderId, {
    required int rating,
    String? comment,
    List<Map<String, dynamic>>? itemReviews,
  }) async {
    try {
      final token = await storageService.getBuyerToken();
      if (token == null) throw Exception('Please login again');

      final body = {
        'rating': rating,
        if (comment != null) 'comment': comment,
        if (itemReviews != null) 'itemReviews': itemReviews,
      };

      final response = await http
          .post(
            Uri.parse(
              'http://192.168.18.107:5001/api/buyer/orders/$orderId/review',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Review submitted successfully');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to submit review');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error submitting review: $e');
      rethrow;
    }
  }
}
