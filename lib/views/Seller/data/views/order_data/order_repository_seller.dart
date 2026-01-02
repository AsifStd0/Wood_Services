import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModelSeller>> getOrders({String? status, String? type});
  Future<void> updateOrderStatus(String orderId, String status);
  Future<OrderModelSeller> getOrderDetails(String orderId);
  Future<Map<String, dynamic>> getOrderStatistics();
}

class ApiOrderRepository implements OrderRepository {
  final Dio dio;
  final SellerLocalStorageService storageService;

  ApiOrderRepository({required this.dio, required this.storageService});

  final baseUrl = 'http://192.168.18.107:5001';
  @override
  Future<List<OrderModelSeller>> getOrders({
    String? status,
    String? type,
  }) async {
    log('🔄 ========== getOrders (HTTP) START ==========');

    try {
      // 1. Get Token
      log('🔑 Step 1: Getting seller token...');
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        log('❌ ERROR: No seller token found');
        throw Exception('Please login again');
      }

      log('✅ Token exists');

      // 2. Build URL
      log('🔗 Step 2: Building URL...');
      final uri = Uri.parse('$baseUrl/api/seller/orders').replace(
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
          final data = jsonDecode(response.body);
          log('🎯 Success flag: ${data['success']}');
          log('📄 Message: ${data['message'] ?? 'No message'}');

          if (data['success'] == true) {
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
            log('❌ API Error: ${data['message']}');
            throw Exception(data['message'] ?? 'Failed to load orders');
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
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login again');
      }

      // Check if orderId is MongoDB _id or custom orderId
      final bool isMongoId = RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(orderId);

      if (isMongoId) {
        log('⚠️ Warning: Using MongoDB _id instead of orderId');
        log('💡 Suggestion: Use the custom orderId (ORD-...)');
      }

      final uri = Uri.parse('$baseUrl/api/seller/orders/$orderId/status');
      log('🌐 URL: $uri');

      final response = await http
          .put(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 30));

      log('📡 Response: ${response.statusCode}');
      log('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Status updated successfully');
          log('✅ ========== updateOrderStatus COMPLETE ==========');
          return;
        } else {
          if (isMongoId && data['message']?.contains('not found')) {
            log('❌ API Error: Order not found with MongoDB _id');
            log('💡 Try: Use orderId (ORD-...) instead of _id');
            throw Exception('Use order ID (ORD-...) instead of internal ID');
          }
          throw Exception(data['message'] ?? 'Failed to update status');
        }
      } else if (response.statusCode == 404) {
        log('❌ Order not found: $orderId');
        log('💡 The API expects orderId (ORD-...), not MongoDB _id');
        throw Exception('Order not found. Use order ID (ORD-...)');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error: $e');
      log('❌ ========== updateOrderStatus FAILED ==========');
      rethrow;
    }
  }

  @override
  Future<OrderModelSeller> getOrderDetails(String orderId) async {
    log('🔄 ========== getOrderDetails START ==========');

    try {
      final token = await storageService.getSellerToken();

      if (token == null) {
        throw Exception('Please login again');
      }

      final uri = Uri.parse('$baseUrl/api/seller/orders/$orderId');
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
      final token = await storageService.getSellerToken();

      if (token == null) {
        return _defaultStatistics();
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/seller/orders'),
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
// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:wood_service/core/services/seller_local_storage_service.dart';
// import 'package:wood_service/views/Seller/data/views/order_data/order_model.dart';

// abstract class OrderRepository {
//   Future<List<OrderModelSeller>> getOrders({String? status, String? type});
//   Future<void> updateOrderStatus(String orderId, String status);
//   Future<OrderModelSeller> getOrderDetails(String orderId);
//   Future<Map<String, dynamic>> getOrderStatistics();
// }

// class ApiOrderRepository implements OrderRepository {
//   final Dio dio;
//   final SellerLocalStorageService storageService;

//   ApiOrderRepository({required this.dio, required this.storageService});

//   @override
//   Future<List<OrderModelSeller>> getOrders({
//     String? status,
//     String? type,
//   }) async {
//     log('🔄 ========== getOrders START ==========');
//     log('📋 Parameters: status=$status, type=$type');

//     try {
//       // 1. Get Token
//       log('🔑 Step 1: Getting seller token...');
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         log('❌ ERROR: No seller token found');
//         log('💡 Suggestion: User needs to login again');
//         throw Exception('Please login again');
//       }

//       log('✅ Token exists (length: ${token.length})');

//       // 2. Build URL and Headers
//       log('🔗 Step 2: Building request...');
//       final queryParams = <String, dynamic>{};
//       if (status != null) {
//         queryParams['status'] = status;
//         log('   ↳ Added status filter: $status');
//       }
//       if (type != null) {
//         queryParams['type'] = type;
//         log('   ↳ Added type filter: $type');
//       }
//       queryParams['page'] = 1;
//       queryParams['limit'] = 50;

//       log('🌐 Final URL: /api/seller/orders');
//       log('📊 Query params: $queryParams');

//       final headers = {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       };

//       log('📨 Headers:');
//       headers.forEach((key, value) {
//         log(
//           '   $key: ${key == 'Authorization' ? 'Bearer ***${value.substring(value.length - 10)}' : value}',
//         );
//       });

//       // 3. Make API Call
//       log('🚀 Step 3: Making API call...');
//       final stopwatch = Stopwatch()..start();

//       try {
//         final response = await dio.get(
//           '/api/seller/orders',
//           queryParameters: queryParams,
//           options: Options(
//             headers: headers,
//             receiveTimeout: const Duration(seconds: 30),
//             sendTimeout: const Duration(seconds: 10),
//           ),
//         );

//         stopwatch.stop();
//         log('⏱️ Request completed in ${stopwatch.elapsedMilliseconds}ms');
//         log('📡 Step 4: Processing response...');
//         log('✅ Response Status: ${response.statusCode}');
//         log('📊 Response Headers: ${response.headers.map}');

//         // 4. Check Response
//         if (response.statusCode == 200) {
//           final data = response.data;
//           log('📦 Response data type: ${data.runtimeType}');
//           log('🎯 Success flag: ${data['success']}');
//           log('📄 Message: ${data['message'] ?? 'No message'}');

//           if (data['success'] == true) {
//             final List<dynamic> orders = data['orders'] ?? [];
//             log('📊 Orders array length: ${orders.length}');
//             log('📈 Pagination: ${data['pagination']}');
//             log('📊 Statistics: ${data['statistics']}');

//             if (orders.isEmpty) {
//               log('ℹ️ No orders found for this seller');
//               log('✅ ========== getOrders COMPLETE ==========');
//               return [];
//             }

//             // Debug first order structure
//             log('🔍 First order structure:');
//             if (orders.isNotEmpty) {
//               final firstOrder = orders.first;
//               log('   Order ID: ${firstOrder['orderId']}');
//               log('   Buyer: ${firstOrder['buyerName']}');
//               log('   Status: ${firstOrder['status']}');
//               log('   Items count: ${firstOrder['itemsCount']}');
//               log('   Total: ${firstOrder['totalAmount']}');
//             }

//             // 5. Parse Orders
//             log('🔧 Step 5: Parsing orders...');
//             List<OrderModelSeller> parsedOrders = [];
//             int successfulParses = 0;
//             int failedParses = 0;

//             for (var i = 0; i < orders.length; i++) {
//               log('   Parsing order ${i + 1}/${orders.length}...');
//               try {
//                 final orderJson = orders[i];
//                 log('     ↳ Order ID: ${orderJson['orderId']}');

//                 final parsedOrder = OrderModelSeller.fromJson(orderJson);
//                 parsedOrders.add(parsedOrder);
//                 successfulParses++;

//                 log('     ✅ Parsed successfully');
//               } catch (e, stackTrace) {
//                 failedParses++;
//                 log('     ❌ ERROR parsing order ${i + 1}:');
//                 log('        Error: $e');
//                 log('        Stack trace: $stackTrace');
//                 log('        Order data: ${orders[i]}');
//               }
//             }

//             log(
//               '📊 Parse results: $successfulParses successful, $failedParses failed',
//             );
//             log('✅ Successfully parsed ${parsedOrders.length} orders');
//             log('✅ ========== getOrders COMPLETE ==========');

//             return parsedOrders;
//           } else {
//             log('❌ API returned success: false');
//             log('❌ Error message: ${data['message']}');
//             log('❌ ========== getOrders FAILED ==========');
//             throw Exception(data['message'] ?? 'Failed to load orders');
//           }
//         } else {
//           log('❌ HTTP Error: ${response.statusCode}');
//           log('❌ Response body: ${response.data}');
//           log('❌ ========== getOrders FAILED ==========');
//           throw Exception('Server error: ${response.statusCode}');
//         }
//       } on DioException catch (e) {
//         stopwatch.stop();
//         log('⏱️ Request failed after ${stopwatch.elapsedMilliseconds}ms');
//         log('❌ DIO EXCEPTION:');
//         log('   Type: ${e.type}');
//         log('   Message: ${e.message}');
//         log('   Error: ${e.error}');
//         log('   Response: ${e.response?.statusCode} - ${e.response?.data}');
//         log('   Request: ${e.requestOptions.method} ${e.requestOptions.uri}');
//         log('   Headers: ${e.requestOptions.headers}');

//         // Detailed error handling
//         switch (e.type) {
//           case DioExceptionType.connectionTimeout:
//             log(
//               '💡 Suggestion: Check server IP/port, ensure server is running',
//             );
//             log('💡 Try: http://10.0.2.2:5001 for Android emulator');
//             throw Exception('Connection timeout. Check server connection.');
//           case DioExceptionType.receiveTimeout:
//             log('💡 Suggestion: Server is slow, increase receiveTimeout');
//             throw Exception('Server taking too long to respond.');
//           case DioExceptionType.sendTimeout:
//             log('💡 Suggestion: Network upload issue');
//             throw Exception('Network upload timeout.');
//           case DioExceptionType.badResponse:
//             log('💡 Suggestion: Check API endpoint and auth token');
//             throw Exception('Server error: ${e.response?.statusCode}');
//           case DioExceptionType.cancel:
//             log('💡 Suggestion: Request was cancelled');
//             throw Exception('Request cancelled');
//           case DioExceptionType.unknown:
//             log('💡 Suggestion: Check internet connection');
//             log('💡 Error details: ${e.toString()}');
//             throw Exception('Network error: ${e.message}');
//           default:
//             throw Exception('Network error: ${e.message}');
//         }
//       }
//     } catch (e, stackTrace) {
//       log('❌ UNEXPECTED ERROR:');
//       log('   Error: $e');
//       log('   Stack trace: $stackTrace');
//       log('❌ ========== getOrders FAILED ==========');
//       throw Exception('Failed to load orders: $e');
//     }
//   }

//   @override
//   Future<void> updateOrderStatus(String orderId, String status) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login again');
//       }

//       log('📤 Updating order $orderId status to $status');

//       // ✅ CORRECT ENDPOINT: /api/seller/orders/:orderId/status
//       final response = await dio.put(
//         '/api/seller/orders/$orderId/status',
//         data: {'status': status},
//         options: Options(
//           headers: {'Authorization': 'Bearer $token'},
//           contentType: 'application/json',
//         ),
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data['success'] == true) {
//           log('✅ Order status updated successfully');
//           return;
//         } else {
//           throw Exception(data['message'] ?? 'Failed to update status');
//         }
//       } else {
//         throw Exception('Server error: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       log('❌ Dio Error updating order status: ${e.message}');
//       throw Exception('Network error: ${e.message}');
//     } catch (e) {
//       log('❌ Error updating order status: $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<OrderModelSeller> getOrderDetails(String orderId) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login again');
//       }

//       // ✅ CORRECT ENDPOINT: /api/seller/orders/:orderId
//       final response = await dio.get(
//         '/api/seller/orders/$orderId',
//         options: Options(
//           headers: {'Authorization': 'Bearer $token'},
//           contentType: 'application/json',
//         ),
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data['success'] == true) {
//           return OrderModelSeller.fromJson(data['order']);
//         } else {
//           throw Exception(data['message'] ?? 'Failed to fetch order details');
//         }
//       } else {
//         throw Exception('Server error: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       log('❌ Dio Error fetching order details: ${e.message}');
//       throw Exception('Network error: ${e.message}');
//     } catch (e) {
//       log('❌ Error fetching order details: $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> getOrderStatistics() async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login again');
//       }

//       final response = await dio.get(
//         '/api/seller/orders',
//         options: Options(
//           headers: {'Authorization': 'Bearer $token'},
//           contentType: 'application/json',
//         ),
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data['success'] == true) {
//           return data['statistics'] ??
//               {
//                 'totalOrders': 0,
//                 'pendingOrders': 0,
//                 'acceptedOrders': 0,
//                 'completedOrders': 0,
//               };
//         } else {
//           return {
//             'totalOrders': 0,
//             'pendingOrders': 0,
//             'acceptedOrders': 0,
//             'completedOrders': 0,
//           };
//         }
//       } else {
//         return {
//           'totalOrders': 0,
//           'pendingOrders': 0,
//           'acceptedOrders': 0,
//           'completedOrders': 0,
//         };
//       }
//     } catch (e) {
//       log('❌ Error fetching statistics: $e');
//       return {
//         'totalOrders': 0,
//         'pendingOrders': 0,
//         'acceptedOrders': 0,
//         'completedOrders': 0,
//       };
//     }
//   }
// }
