import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';

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
  final UnifiedLocalStorageServiceImpl storageService;

  ApiBuyerOrderRepository({required this.storageService});

  String get baseUrl => Config.apiBaseUrl;

  @override
  Future<List<BuyerOrder>> getOrders({String? status}) async {
    log('message');
    log('🔄 Fetching buyer orders with status: $status');

    try {
      final token = storageService.getToken();
      if (token == null) throw Exception('Please login again');

      final uri = Uri.parse('$baseUrl/buyer/orders');

      log('📤 Fetching orders from: $uri');

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
        log('📥 Orders response: ${data['success']}');

        // 🔥 ADD THIS DEBUG
        log('📊 Full response data:');
        log('   success: ${data['success']}');
        log('   message: ${data['message']}');
        log('   data type: ${data['data'].runtimeType}');

        if (data['data'] is Map) {
          log('   data keys: ${data['data'].keys.toList()}');
          if (data['data']['orders'] is List) {
            log('   orders count: ${data['data']['orders'].length}');
            if (data['data']['orders'].isNotEmpty) {
              // Log first order structure
              log('   First order structure:');
              log('     ${data['data']['orders'][0]}');
            }
          }
        }

        if (data['success'] == true) {
          // New API structure: data.data.orders[]
          final List<dynamic> orders =
              data['data']?['orders'] ?? data['orders'] ?? [];
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
      final token = storageService.getToken();
      if (token == null) throw Exception('Please login again');

      // Calculate summary from orders list
      final orders = await getOrders();

      int pending = 0, accepted = 0, declined = 0, completed = 0;

      for (var order in orders) {
        switch (order.status) {
          case OrderStatusBuyer.pending:
            pending++;
            break;
          case OrderStatusBuyer.accepted:
            accepted++;
            break;
          case OrderStatusBuyer.declined:
            declined++;
            break;
          case OrderStatusBuyer.completed:
            completed++;
            break;
        }
      }

      return {
        'pending': pending,
        'accepted': accepted,
        'declined': declined,
        'completed': completed,
        'total': orders.length,
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
      final token = storageService.getToken();
      if (token == null) throw Exception('Please login again');

      final response = await http
          .get(
            Uri.parse('$baseUrl/buyer/orders/$orderId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // New API structure: data.data.order or data.order
          final orderData =
              data['data']?['order'] ?? data['order'] ?? data['data'];
          return BuyerOrder.fromJson(orderData);
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
      final token = storageService.getToken();
      if (token == null) throw Exception('Please login again');

      log('❌ Cancelling order: $orderId');
      log('   Reason: $reason');

      final url = '$baseUrl/buyer/orders/$orderId';
      log('📤 Sending PUT request to: $url');

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'status': 'cancelled', 'reason': reason}),
          )
          .timeout(const Duration(seconds: 30));

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          log('✅ Order cancelled successfully');
          log('   Message: ${data['message']}');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to cancel order');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Order not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      log('❌ Request timed out');
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      log('❌ Network error: $e');
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      log('❌ Error cancelling order: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsReceived(String orderId) async {
    try {
      final token = storageService.getToken();
      if (token == null) throw Exception('Please login again');

      final response = await http
          .post(
            Uri.parse('$baseUrl/buyer/orders/$orderId/received'),
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
      final token = storageService.getToken();
      if (token == null) throw Exception('Please login again');

      final body = {
        'rating': rating,
        if (comment != null) 'comment': comment,
        if (itemReviews != null) 'itemReviews': itemReviews,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/buyer/orders/$orderId/review'),
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
