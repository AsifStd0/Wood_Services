import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/views/Seller/data/models/order_model.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

abstract class OrderRepository {
  Future<List<OrderModelSeller>> getOrders({String? status, String? type});
  Future<void> updateOrderStatus(String orderId, String status);
  Future<OrderModelSeller> getOrderDetails(String orderId);
  Future<Map<String, dynamic>> getOrderStatistics();
  Future<void> addOrderNote(String orderId, String message);
}

class ApiOrderRepository implements OrderRepository {
  final Dio dio;
  final UnifiedLocalStorageServiceImpl storageService;

  ApiOrderRepository({required this.dio, required this.storageService});
  @override
  Future<List<OrderModelSeller>> getOrders({
    String? status,
    String? type,
  }) async {
    log('🔄 ========== getOrders (HTTP) START ==========');

    try {
      // 1. Get Token
      log('🔑 Step 1: Getting seller token...');
      final token = storageService.getToken();
      if (token == null || token.isEmpty) {
        log('❌ ERROR: No seller token found');
        throw Exception('Please login again');
      }

      log('✅ Token exists');

      // 2. Build URL
      log('🔗 Step 2: Building URL...');
      final uri = Uri.parse('${Config.apiBaseUrl}/seller/orders').replace(
        queryParameters: {
          if (status != null) 'status': status,
          if (type != null) 'type': type,
          'page': '1',
          'limit': '50',
        },
      );

      log('🌐 Final URL: $uri');

      // 3. Make HTTP Request
      log('🚀 Step 3: Making HTTP request...');
      final stopwatch = Stopwatch()..start();

      try {
        final response = await http
            .get(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 30));

        stopwatch.stop();
        log('⏱️ Request completed in ${stopwatch.elapsedMilliseconds}ms');

        // 4. Process Response
        log('📡 Step 4: Processing response...');
        log('✅ Response Status: ${response.statusCode}');
        log('📊 Response Headers: ${response.headers}');
        log('📦 Response Body Length: ${response.body.length} bytes');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          log('🎯 Success flag: ${responseData['success']}');
          log('📄 Message: ${responseData['message'] ?? 'No message'}');

          if (responseData['success'] == true) {
            // New API structure: data.orders
            final data = responseData['data'] ?? responseData;
            final List<dynamic> orders = data['orders'] ?? [];
            log('📊 Found ${orders.length} orders');

            if (orders.isEmpty) {
              log('ℹ️ No orders found');
              log('✅ ========== getOrders COMPLETE ==========');
              return [];
            }

            // 5. Parse Orders
            log('🔧 Step 5: Parsing orders...');
            List<OrderModelSeller> parsedOrders = [];

            for (var i = 0; i < orders.length; i++) {
              log('   Parsing order ${i + 1}/${orders.length}...');
              try {
                final parsedOrder = OrderModelSeller.fromJson(orders[i]);
                parsedOrders.add(parsedOrder);
                log('     ✅ Parsed: ${parsedOrder.orderId}');
              } catch (e) {
                log('     ❌ Error: $e');
                log('     ❌ Order data: ${orders[i]}');
              }
            }

            log('✅ Successfully parsed ${parsedOrders.length} orders');
            log('✅ ========== getOrders COMPLETE ==========');

            return parsedOrders;
          } else {
            log('❌ API Error: ${responseData['message']}');
            throw Exception(responseData['message'] ?? 'Failed to load orders');
          }
        } else {
          log('❌ HTTP Error: ${response.statusCode}');
          log('❌ Response: ${response.body}');
          throw Exception('Server error: ${response.statusCode}');
        }
      } on http.ClientException catch (e) {
        log('❌ HTTP Client Exception: $e');
        log('💡 Suggestion: Check network connection and URL');
        throw Exception('Network error: $e');
      } on FormatException catch (e) {
        log('❌ JSON Parse Error: $e');
        log('💡 Suggestion: Invalid JSON response from server');
        throw Exception('Invalid server response');
      } on TimeoutException catch (e) {
        log('❌ Timeout Exception: $e');
        log('💡 Suggestion: Server not responding, check if running');
        throw Exception('Request timeout. Server may be down.');
      }
    } catch (e, stackTrace) {
      log('❌ UNEXPECTED ERROR: $e');
      log('❌ Stack trace: $stackTrace');
      log('❌ ========== getOrders FAILED ==========');
      rethrow;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    log('🔄 ========== updateOrderStatus START ==========');
    log('📋 Parameters: orderId=$orderId, status=$status');

    try {
      final token = storageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login again');
      }

      // Map status to endpoint
      String endpoint;
      switch (status.toLowerCase()) {
        case 'accepted':
          endpoint = '/seller/orders/$orderId/accept';
          break;
        case 'rejected':
          endpoint = '/seller/orders/$orderId/reject';
          break;
        case 'processing':
        case 'started':
          endpoint = '/seller/orders/$orderId/start';
          break;
        case 'delivered':
        case 'completed':
          endpoint = '/seller/orders/$orderId/complete';
          break;
        default:
          // Fallback to old endpoint
          endpoint = '/seller/orders/$orderId/status';
      }

      final uri = Uri.parse('${Config.apiBaseUrl}$endpoint');
      log('🌐 URL: $uri');

      final response = await http
          .put(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: endpoint.contains('/status')
                ? jsonEncode({'status': status})
                : jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));

      log('📡 Response: ${response.statusCode}');
      log('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Status updated successfully');
          log('✅ ========== updateOrderStatus COMPLETE ==========');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to update status');
        }
      } else if (response.statusCode == 404) {
        log('❌ Order not found: $orderId');
        throw Exception('Order not found');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error: $e');
      log('❌ ========== updateOrderStatus FAILED ==========');
      rethrow;
    }
  }

  /// Add note to order
  /// PUT /api/seller/orders/:orderId/notes
  Future<void> addOrderNote(String orderId, String message) async {
    log('📝 Adding note to order: $orderId');

    try {
      final token = storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login again');
      }

      final uri = Uri.parse(
        '${Config.apiBaseUrl}/seller/orders/$orderId/notes',
      );
      log('🌐 URL: $uri');

      final response = await http
          .put(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 30));

      log('📡 Response: ${response.statusCode}');
      log('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Note added successfully');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to add note');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error adding note: $e');
      rethrow;
    }
  }

  @override
  Future<OrderModelSeller> getOrderDetails(String orderId) async {
    log('🔄 ========== getOrderDetails START ==========');

    try {
      final token = await storageService.getToken();

      if (token == null) {
        throw Exception('Please login again');
      }

      final uri = Uri.parse('${Config.apiBaseUrl}/seller/orders/$orderId');
      log('🌐 URL: $uri');

      final response = await http
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 30));

      log('📡 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Order details fetched');
          log('✅ ========== getOrderDetails COMPLETE ==========');
          return OrderModelSeller.fromJson(data['order']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch order details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error: $e');
      log('❌ ========== getOrderDetails FAILED ==========');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final token = await storageService.getToken();

      if (token == null) {
        return _defaultStatistics();
      }

      final response = await http
          .get(
            Uri.parse('${Config.apiBaseUrl}/seller/orders'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['statistics'] ?? _defaultStatistics();
        }
      }
      return _defaultStatistics();
    } catch (e) {
      log('❌ Error getting statistics: $e');
      return _defaultStatistics();
    }
  }

  Map<String, dynamic> _defaultStatistics() {
    return {
      'totalOrders': 0,
      'pendingOrders': 0,
      'acceptedOrders': 0,
      'completedOrders': 0,
    };
  }
}
