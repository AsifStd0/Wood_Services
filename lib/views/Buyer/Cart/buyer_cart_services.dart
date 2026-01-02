import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_model.dart';

class BuyerCartService {
  final Dio _dio = locator<Dio>();
  final BuyerLocalStorageService _storageService =
      locator<BuyerLocalStorageService>();

  Future<BuyerCartModel?> getCart() async {
    try {
      final token = await _storageService.getBuyerToken();
      log('🛒 Cart Service - Token: ${token != null ? "Exists" : "NULL"}');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      log('📡 Making GET request to /api/buyer/cart');
      final response = await _dio.get(
        '/api/buyer/cart',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // log('   Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Check if response.data is a Map
        if (response.data is! Map<String, dynamic>) {
          log(
            '❌ Response data is not a Map, it\'s: ${response.data.runtimeType}',
          );
          throw Exception('Invalid response format');
        }

        final responseData = response.data as Map<String, dynamic>;

        // Check if success field exists
        if (responseData.containsKey('success')) {
          log('✅ Success field exists: ${responseData['success']}');

          if (responseData['success'] == true) {
            if (responseData['cart'] == null) {
              log('🛒 Cart is null in response, returning empty cart');
              return BuyerCartModel(
                id: '',
                buyerId: '',
                items: [],
                totalQuantity: 0,
                subtotal: 0,
                shippingFee: 0,
                tax: 0,
                total: 0,
                lastUpdated: DateTime.now(),
              );
            }

            return BuyerCartModel.fromJson(responseData['cart']);
          } else {
            log('❌ API returned success: false');
            log('   Message: ${responseData['message']}');
            throw Exception(responseData['message'] ?? 'Failed to get cart');
          }
        } else {
          // If no success field, assume direct cart response
          log('⚠️ No success field in response, assuming direct cart data');

          if (responseData.containsKey('_id') ||
              responseData.containsKey('items')) {
            log('✅ Direct cart data found');
            return BuyerCartModel.fromJson(responseData);
          } else if (responseData.isEmpty) {
            log('🛒 Empty response, returning empty cart');
            return BuyerCartModel(
              id: '',
              buyerId: '',
              items: [],
              totalQuantity: 0,
              subtotal: 0,
              shippingFee: 0,
              tax: 0,
              total: 0,
              lastUpdated: DateTime.now(),
            );
          } else {
            log('❌ Unexpected response format');
            log('   Response keys: ${responseData.keys}');
            throw Exception('Unexpected response format');
          }
        }
      } else {
        log('❌ HTTP Error: ${response.statusCode}');
        log('   Response: ${response.data}');
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (error) {
      log('❌ Get cart error: $error');
      log('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
  // In BuyerCartService.dart

  // Add to cart - use correct endpoint
  Future<Map<String, dynamic>> addToCartService({
    required String productId,
    required int quantity,
    String? selectedVariant,
    String? selectedSize,
  }) async {
    try {
      log('🔍 Calling addToCart API...');
      final token = await _storageService.getBuyerToken();
      if (token == null) throw Exception('Please login again');

      final body = {
        'productId': productId,
        'quantity': quantity,
        if (selectedVariant != null && selectedVariant.isNotEmpty)
          'selectedVariant': selectedVariant,
        if (selectedSize != null && selectedSize.isNotEmpty)
          'selectedSize': selectedSize,
      };

      log('📦 Request Body: $body');
      log('📤 Endpoint: $baseUrl/api/buyer/cart/add'); // CORRECT ENDPOINT

      final response = await http.post(
        Uri.parse('$baseUrl/api/buyer/cart/add'), // CORRECT: /add
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Item added to cart successfully');

          return {
            'success': true,
            'message': data['message'] ?? 'Item added to cart',
            'cartSummary': data['cartSummary'] ?? {},
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to add to cart');
        }
      } else {
        log('❌ HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Add to cart error in service: $e');

      return {'success': false, 'message': e.toString(), 'error': true};
    }
  }

  final String baseUrl = "http://192.168.18.107:5001";
  // Request buy - use correct endpoint
  Future<Map<String, dynamic>> requestBuy({
    required List<String> itemIds,
    String? buyerNotes,
    Map<String, dynamic>? deliveryAddress,
    String paymentMethod = 'cod',
  }) async {
    try {
      log('🔍 Calling requestBuy API...');
      final token = await _storageService.getBuyerToken();
      if (token == null) throw Exception('Please login again');

      final body = {
        'itemIds': itemIds,
        if (buyerNotes != null && buyerNotes.isNotEmpty)
          'buyerNotes': buyerNotes,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
      };

      log('📦 Request Body: $body');
      log(
        '📤 Endpoint: $baseUrl/api/buyer/cart/request/buy',
      ); // CORRECT: /request/buy

      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/buyer/cart/request/buy',
        ), // CORRECT: /request/buy
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          log('✅ Purchase request submitted successfully');
          return data; // Return full data
        } else {
          throw Exception(
            data['message'] ?? 'Failed to submit purchase request',
          );
        }
      } else {
        log('❌ HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Request buy error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      log('🔄 Updating cart item: $itemId to quantity: $quantity');

      final token = await _storageService.getBuyerToken();

      if (token == null) {
        log('❌ User not authenticated');
        throw Exception('User not authenticated');
      }

      log('🔍 Sending request to update cart item...');

      final response = await _dio.put(
        '/api/buyer/cart/update/$itemId',
        data: {'quantity': quantity},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📥 Response status: ${response.statusCode}');
      log('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          log('✅ Cart updated successfully');

          // FIXED: Don't try to parse updatedItem if it doesn't exist
          final result = {
            'success': true,
            'message': data['message'] ?? 'Cart updated',
            'cartSummary': data['cartSummary'] ?? {},
          };

          // Only add updatedItem if it exists
          if (data.containsKey('updatedItem') && data['updatedItem'] != null) {
            result['updatedItem'] = BuyerCartItem.fromJson(data['updatedItem']);
          } else {
            log('⚠️ No updatedItem field in response');
          }

          return result;
        } else {
          log('❌ API returned success: false');
          log('❌ Error message: ${data['message']}');
          throw Exception(data['message'] ?? 'Failed to update cart');
        }
      } else {
        log('❌ HTTP Error: ${response.statusCode}');
        log('❌ Response: ${response.data}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      log('❌ Update cart error: $error');

      if (error is DioException) {
        log('❌ Dio Error Type: ${error.type}');
        log('❌ Dio Error Message: ${error.message}');
        log('❌ Dio Response: ${error.response?.data}');
        log('❌ Dio Status Code: ${error.response?.statusCode}');

        if (error.type == DioExceptionType.connectionTimeout) {
          throw Exception('Connection timeout. Please check your internet.');
        } else if (error.type == DioExceptionType.receiveTimeout) {
          throw Exception('Server is taking too long to respond.');
        } else if (error.response != null) {
          throw Exception(
            'Server error ${error.response!.statusCode}: ${error.response!.data['message'] ?? 'Unknown error'}',
          );
        }
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> removeFromCart(String itemId) async {
    try {
      final token = await _storageService.getBuyerToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.delete(
        '/api/buyer/cart/remove/$itemId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'cartSummary': response.data['cartSummary'],
        };
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to remove from cart',
        );
      }
    } catch (error) {
      print('Remove from cart error: $error');
      rethrow;
    }
  }

  Future<bool> clearCart() async {
    try {
      final token = await _storageService.getBuyerToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.delete(
        '/api/buyer/cart/clear',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (error) {
      print('Clear cart error: $error');
      rethrow;
    }
  }

  Future<int> getCartCount() async {
    try {
      final token = await _storageService.getBuyerToken();

      if (token == null) {
        return 0;
      }

      final response = await _dio.get(
        '/api/buyer/cart/count',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (error) {
      print('Get cart count error: $error');
      return 0;
    }
  }
}
