import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_model.dart';

class BuyerCartService {
  final Dio _dio = locator<Dio>();
  final UnifiedLocalStorageServiceImpl storage =
      locator<UnifiedLocalStorageServiceImpl>();
  String? get token => storage.getToken();

  /// GET /api/cart
  Future<BuyerCartModel?> getCart() async {
    try {
      log('🛒 Cart Service - Token: ${token != null ? "Exists" : "NULL"}');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      log('📡 Making GET request to /api/cart');

      final response = await _dio.get(
        '/cart',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map && responseData.containsKey('success')) {
          log('✅ Success field exists: ${responseData['success']}');

          if (responseData['success'] == true) {
            // API might return cart directly in data.cart or just data
            final cartData =
                responseData['data']?['cart'] ??
                responseData['cart'] ??
                responseData['data'] ??
                responseData;

            if (cartData == null ||
                (cartData is Map &&
                    !cartData.containsKey('_id') &&
                    !cartData.containsKey('items'))) {
              log('🛒 Cart is null or empty in response, returning empty cart');
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

            return BuyerCartModel.fromJson(
              cartData is Map<String, dynamic>
                  ? cartData
                  : Map<String, dynamic>.from(cartData is Map ? cartData : {}),
            );
          } else {
            log('❌ API returned success: false');
            log('   Message: ${responseData['message']}');
            throw Exception(responseData['message'] ?? 'Failed to get cart');
          }
        } else if (responseData is Map &&
            (responseData.containsKey('_id') ||
                responseData.containsKey('items'))) {
          // Direct cart response
          log('✅ Direct cart data found');
          return BuyerCartModel.fromJson(
            responseData is Map<String, dynamic>
                ? responseData
                : Map<String, dynamic>.from(responseData),
          );
        } else {
          log('🛒 Empty or unexpected response, returning empty cart');
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
      } else {
        log('❌ HTTP Error: ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Get cart Dio error: ${e.message}');
      if (e.response?.statusCode == 404) {
        // Cart doesn't exist yet, return empty cart
        log('⚠️ Cart not found (404), returning empty cart');
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
      rethrow;
    } catch (error) {
      log('❌ Get cart error: $error');
      rethrow;
    }
  }

  /// POST /api/cart/add
  /// Body: { serviceId, quantity, selectedVariants: [{type, value}] }
  Future<Map<String, dynamic>> addToCartService({
    required String serviceId, // Changed from productId to serviceId
    required int quantity,
    String? selectedVariant,
    String? selectedSize,
  }) async {
    try {
      log('🔍 Calling addToCart API...');
      final token = storage.getToken();
      if (token == null) throw Exception('Please login again');

      // Build selectedVariants array from selectedVariant and selectedSize
      // API expects: [{type: "size", value: "Large"}, {type: "color", value: "Red"}, etc.]
      final List<Map<String, String>> selectedVariants = [];

      if (selectedSize != null && selectedSize.isNotEmpty) {
        selectedVariants.add({'type': 'size', 'value': selectedSize});
      }

      if (selectedVariant != null && selectedVariant.isNotEmpty) {
        // Default to 'color' type, but can be enhanced to detect actual type from product variants
        // For now, we assume variants other than size are colors
        // TODO: Enhance to detect actual variant type from product.variants list
        String variantType = 'color'; // Default

        // Check common variant type patterns
        final variantLower = selectedVariant.toLowerCase();
        if (variantLower.contains('material') ||
            ['wood', 'metal', 'plastic', 'glass'].contains(variantLower)) {
          variantType = 'material';
        } else if (variantLower.contains('color') ||
            ['red', 'blue', 'green', 'black', 'white'].contains(variantLower)) {
          variantType = 'color';
        }

        selectedVariants.add({'type': variantType, 'value': selectedVariant});
      }

      final body = {
        'serviceId': serviceId,
        'quantity': quantity,
        if (selectedVariants.isNotEmpty) 'selectedVariants': selectedVariants,
      };

      log('📦 Request Body: $body');
      log('📤 Endpoint: /api/cart/add');

      final response = await _dio.post(
        '/cart/add',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true || response.statusCode == 201) {
          log('✅ Item added to cart successfully');

          return {
            'success': true,
            'message': data['message'] ?? 'Item added to cart',
            'cartSummary': data['cartSummary'] ?? data['data'] ?? {},
          };
        } else {
          // API returned success: false with a message
          log('⚠️ API returned success: false');
          log('   Message: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to add to cart',
            'error': true,
          };
        }
      } else {
        log('❌ HTTP ${response.statusCode}: ${response.data}');
        final data = response.data;
        return {
          'success': false,
          'message': data['message'] ?? 'Server error: ${response.statusCode}',
          'error': true,
        };
      }
    } on DioException catch (e) {
      log('❌ Add to cart Dio error: ${e.message}');
      log('   Status: ${e.response?.statusCode}');
      log('   Response: ${e.response?.data}');

      // Check if response has error message
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        // Handle both Map and String responses
        if (responseData is Map) {
          final message =
              responseData['message']?.toString() ?? 'Failed to add to cart';
          log('   Extracted message: $message');
          return {'success': false, 'message': message, 'error': true};
        } else if (responseData is String) {
          // Try to parse JSON string
          try {
            final parsed = jsonDecode(responseData);
            if (parsed is Map) {
              return {
                'success': false,
                'message':
                    parsed['message']?.toString() ?? 'Failed to add to cart',
                'error': true,
              };
            }
          } catch (_) {
            // If parsing fails, use the string as message
          }
          return {'success': false, 'message': responseData, 'error': true};
        }
      }

      return {
        'success': false,
        'message': e.message ?? 'Failed to add to cart',
        'error': true,
      };
    } catch (e) {
      log('❌ Add to cart error in service: $e');
      return {'success': false, 'message': e.toString(), 'error': true};
    }
  }

  /// POST /api/visit-requests
  /// Body: { serviceId, description, address: {...}, preferredDate, preferredTime, specialRequirements }
  Future<Map<String, dynamic>> requestBuy({
    required String
    serviceId, // Changed: now requires single serviceId, not itemIds
    String? description,
    Map<String, dynamic>? address,
    String? preferredDate,
    String? preferredTime,
    String? specialRequirements,
  }) async {
    try {
      log('🔍 Calling requestBuy (visit-requests) API...');
      final token = storage.getToken();

      if (token == null) throw Exception('Please login again');

      final body = {
        'serviceId': serviceId,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (address != null) 'address': address,
        if (preferredDate != null && preferredDate.isNotEmpty)
          'preferredDate': preferredDate,
        if (preferredTime != null && preferredTime.isNotEmpty)
          'preferredTime': preferredTime,
        if (specialRequirements != null && specialRequirements.isNotEmpty)
          'specialRequirements': specialRequirements,
      };

      log('📦 Request Body: $body');
      log('📤 Endpoint: /api/visit-requests');

      final response = await _dio.post(
        '/visit-requests',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true || response.statusCode == 201) {
          log('✅ Visit request submitted successfully');
          return data; // Return full data
        } else {
          throw Exception(data['message'] ?? 'Failed to submit visit request');
        }
      } else {
        log('❌ HTTP ${response.statusCode}: ${response.data}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Request buy Dio error: ${e.message}');
      log('   Response: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ??
            e.message ??
            'Failed to submit visit request',
      );
    } catch (e) {
      log('❌ Request buy error: $e');
      rethrow;
    }
  }

  /// POST /api/cart/update/:itemId
  /// Body: { quantity }
  Future<Map<String, dynamic>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      log('🔄 Updating cart item: $itemId to quantity: $quantity');

      final token = storage.getToken();

      if (token == null) {
        log('❌ User not authenticated');
        throw Exception('User not authenticated');
      }

      log('🔍 Sending request to update cart item...');
      log('📤 Endpoint: /api/cart/update/$itemId');

      final response = await _dio.post(
        // Changed from PUT to POST
        '/cart/update/$itemId',
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

  /// DELETE /api/cart/remove/:itemId
  Future<Map<String, dynamic>> removeFromCart(String itemId) async {
    try {
      final token = storage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      log('🗑️ Removing cart item: $itemId');
      log('📤 Endpoint: /api/cart/remove/$itemId');

      final response = await _dio.delete(
        '/cart/remove/$itemId',
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

  /// DELETE /api/cart/clear
  Future<bool> clearCart() async {
    try {
      final token = storage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      log('🗑️ Clearing cart');
      log('📤 Endpoint: /api/cart/clear');

      final response = await _dio.delete(
        '/cart/clear',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (error) {
      print('Clear cart error: $error');
      rethrow;
    }
  }

  /// GET /api/cart/count (if available, otherwise calculate from cart)
  Future<int> getCartCount() async {
    try {
      final token = storage.getToken();

      if (token == null) {
        return 0;
      }

      // Try to get cart and calculate count
      final cart = await getCart();
      return cart?.totalQuantity ?? 0;
    } catch (error) {
      log('Get cart count error: $error');
      return 0;
    }
  }

  /// POST /api/buyer/orders
  /// Body: { serviceId, quantity, requirements }
  Future<Map<String, dynamic>> placeOrder({
    required String serviceId,
    required int quantity,
    String? requirements,
  }) async {
    try {
      log('🛒 Placing order...');
      log('   Service ID: $serviceId');
      log('   Quantity: $quantity');
      log('   Requirements: $requirements');

      final token = storage.getToken();
      if (token == null) throw Exception('Please login again');

      final body = {
        'serviceId': serviceId,
        'quantity': quantity,
        if (requirements != null && requirements.isNotEmpty)
          'requirements': requirements,
      };

      log('📦 Request Body: $body');
      log('📤 Endpoint: /api/buyer/orders');

      final response = await _dio.post(
        '/buyer/orders',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true || response.statusCode == 201) {
          log('✅ Order placed successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Order placed successfully',
            'order': data['order'] ?? data['data'] ?? {},
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to place order');
        }
      } else {
        log('❌ HTTP ${response.statusCode}: ${response.data}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Place order Dio error: ${e.message}');
      log('   Response: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Failed to place order',
      );
    } catch (e) {
      log('❌ Place order error: $e');
      rethrow;
    }
  }

  /// PUT /api/buyer/orders/:id
  /// Body: { status: "cancelled" }
  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      log('❌ Cancelling order: $orderId');
      if (reason != null) log('   Reason: $reason');

      final token = storage.getToken();
      if (token == null) throw Exception('Please login again');

      final body = {
        'status': 'cancelled',
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };

      log('📦 Request Body: $body');
      log('📤 Endpoint: /api/buyer/orders/$orderId');

      final response = await _dio.put(
        '/buyer/orders/$orderId',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          log('✅ Order cancelled successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Order cancelled successfully',
            'order': data['order'] ?? data['data'] ?? {},
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to cancel order');
        }
      } else {
        log('❌ HTTP ${response.statusCode}: ${response.data}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Cancel order Dio error: ${e.message}');
      log('   Response: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Failed to cancel order',
      );
    } catch (e) {
      log('❌ Cancel order error: $e');
      rethrow;
    }
  }
}
