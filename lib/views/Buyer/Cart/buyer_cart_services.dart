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

  // Add these methods to your BuyerCartService class

  // Direct order placement with endpoint parameter
  Future<Map<String, dynamic>> placeOrderDirect({
    required String endpoint,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      log('📡 Response from $endpoint: ${response.statusCode}');
      log('📡 Response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        return {
          'success': true,
          'message': responseData['message'] ?? 'Order placed successfully',
          'data': responseData['data'] ?? responseData,
          'order': responseData['data']?['order'] ?? responseData['order'],
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Endpoint not found',
          'statusCode': response.statusCode,
        };
      } else {
        final errorData = response.data;
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to place order',
          'statusCode': response.statusCode,
        };
      }
    } catch (error) {
      log('❌ Place order direct error: $error');
      return {
        'success': false,
        'message': 'Network error: $error',
        'statusCode': 0,
      };
    }
  }

  // Check if endpoint exists
  Future<Map<String, dynamic>> checkEndpoint(String endpoint) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'exists': false, 'statusCode': 401};
      }

      final response = await _dio.head(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return {
        'exists': response.statusCode != 404,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {'exists': false, 'statusCode': 0};
    }
  }

  // Get token method
  Future<String?> getToken() async {
    // Implement your token retrieval logic
    // Example:
    final storage = locator<UnifiedLocalStorageServiceImpl>();
    await storage.initialize();
    return storage.getToken();
  }

  /// GET /cart
  /// /// GET /cart - UPDATED VERSION
  /// GET /cart
  Future<BuyerCartModel?> getCart() async {
    try {
      log('🛒 Getting cart...');
      final token = storage.getToken();

      if (token == null) {
        log('❌ User not authenticated');
        throw Exception('User not authenticated');
      }

      log('📡 Making GET request to /cart');

      final response = await _dio.get(
        '/cart',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // Don't throw on 404
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map && responseData.containsKey('success')) {
          log('✅ Success field exists: ${responseData['success']}');

          if (responseData['success'] == true) {
            final cartData =
                responseData['data']?['cart'] ?? responseData['data'];

            if (cartData == null) {
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

            log('🔍 Cart data keys: ${cartData.keys.toList()}');

            // Extract summary data
            final summary = cartData['summary'] ?? {};
            final totalItems = (summary['totalItems'] ?? 0).toInt();
            final subtotalValue = (summary['subtotal'] ?? 0).toDouble();

            // Calculate totals
            const shippingFee = 0.0;
            const taxRate = 0.0;
            final tax = subtotalValue * taxRate;
            final total = subtotalValue + shippingFee + tax;

            // Create the cart model
            final cartModel = BuyerCartModel(
              id: cartData['_id']?.toString() ?? '',
              buyerId: cartData['userId']?.toString() ?? '',
              items: [],
              totalQuantity: totalItems,
              subtotal: subtotalValue,
              shippingFee: shippingFee,
              tax: tax,
              total: total,
              lastUpdated: DateTime.now(),
            );

            // Parse items
            final itemsData = cartData['items'] as List? ?? [];
            final List<BuyerCartItem> parsedItems = [];

            for (final itemData in itemsData) {
              if (itemData is Map<String, dynamic>) {
                try {
                  final Map<String, dynamic> itemMap = {
                    '_id': itemData['_id'],
                    'productId': itemData['serviceId']?['_id'],
                    'serviceId': itemData['serviceId'],
                    'quantity': itemData['quantity'],
                    'selectedVariants': itemData['selectedVariants'] ?? [],
                    'addedAt': itemData['addedAt'],
                    'price':
                        itemData['serviceId']?['price'] ??
                        itemData['serviceId']?['salePrice'] ??
                        0,
                    'subtotal':
                        ((itemData['serviceId']?['price'] ??
                                itemData['serviceId']?['salePrice'] ??
                                0)
                            .toDouble() *
                        (itemData['quantity'] ?? 1).toInt()),
                  };

                  final cartItem = BuyerCartItem.fromJson(itemMap);
                  parsedItems.add(cartItem);
                } catch (e) {
                  log('❌ Error parsing cart item: $e');
                }
              }
            }

            return cartModel.copyWith(items: parsedItems);
          } else {
            log('⚠️ API returned success: false, but HTTP 200');
            log('   Message: ${responseData['message']}');
            // Still return empty cart on false success but 200 status
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
        } else if (response.statusCode == 404) {
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
        log('❌ HTTP Error: ${response.statusCode}, returning empty cart');
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
    } on DioException catch (e) {
      log('❌ Get cart Dio error: ${e.message}');
      if (e.response?.statusCode == 404 ||
          e.type == DioExceptionType.connectionTimeout) {
        log('⚠️ Cart not found or connection issue, returning empty cart');
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
      log('❌ Get cart error: $error, returning empty cart');
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
  }

  /// POST /cart/add
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
      log('📤 Endpoint: /cart/add');

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

  /// POST /visit-requests
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
      log('📤 Endpoint: /visit-requests');

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

  /// Body: { quantity }
  /// POST /cart/update/:itemId
  /// Body: { quantity }
  /// POST /cart/update/:itemId
  /// Body: { quantity }
  /// PUT /cart/update/:itemId
  /// Body: { quantity }
  /// PUT /cart/update/:itemId
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
      log('📤 Endpoint: /cart/update/$itemId');

      // Use PUT method
      final response = await _dio.put(
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

          // Extract updated cart data from response
          final cartData = data['data']?['cart'] ?? data['cart'];

          // Parse the cart data
          BuyerCartModel? updatedCart;
          if (cartData != null) {
            try {
              // Extract summary from items
              final itemsData = cartData['items'] as List? ?? [];
              int totalQuantity = 0;
              double subtotalValue = 0.0;

              for (final itemData in itemsData) {
                if (itemData is Map<String, dynamic>) {
                  // Safely parse quantity to int
                  final dynamic quantityRaw = itemData['quantity'];
                  final int parsedQuantity = quantityRaw is int
                      ? quantityRaw
                      : (quantityRaw ?? 0).toInt();

                  // Safely parse price to double
                  final dynamic priceRaw =
                      itemData['serviceId']?['price'] ??
                      itemData['serviceId']?['salePrice'] ??
                      0;
                  final double parsedPrice = priceRaw is double
                      ? priceRaw
                      : (priceRaw ?? 0).toDouble();

                  totalQuantity += parsedQuantity;
                  subtotalValue += parsedPrice * parsedQuantity;
                }
              }

              // Parse items
              final List<BuyerCartItem> parsedItems = [];
              for (final itemData in itemsData) {
                if (itemData is Map<String, dynamic>) {
                  try {
                    final cartItem = BuyerCartItem.fromJson(itemData);
                    parsedItems.add(cartItem);
                  } catch (e) {
                    log('❌ Error parsing cart item: $e');
                  }
                }
              }

              // Create cart model
              updatedCart = BuyerCartModel(
                id: cartData['_id']?.toString() ?? '',
                buyerId: cartData['userId']?.toString() ?? '',
                items: parsedItems,
                totalQuantity: totalQuantity,
                subtotal: subtotalValue,
                shippingFee: 0,
                tax: 0,
                total: subtotalValue,
                lastUpdated: DateTime.now(),
              );
            } catch (e) {
              log('❌ Error parsing cart from update response: $e');
            }
          }

          return {
            'success': true,
            'message': data['message'] ?? 'Cart updated successfully',
            'cart': updatedCart,
          };
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
      rethrow;
    }
  }

  /// DELETE /cart/remove/:itemId
  /// DELETE /cart/remove/:itemId
  Future<Map<String, dynamic>> removeFromCart(String itemId) async {
    try {
      final token = storage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      log('🗑️ Removing cart item: $itemId');
      log('📤 Endpoint: /cart/remove/$itemId');

      final response = await _dio.delete(
        // Ensure this matches your API documentation
        '/cart/remove/$itemId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      log('📥 Remove response status: ${response.statusCode}');
      log('📥 Remove response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Item removed successfully',
          'cartSummary': response.data['cartSummary'] ?? {},
        };
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to remove from cart',
        );
      }
    } catch (error) {
      log('❌ Remove from cart error: $error');
      rethrow;
    }
  }

  /// DELETE /cart/clear
  Future<bool> clearCart() async {
    try {
      final token = storage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      log('🗑️ Clearing cart');
      log('📤 Endpoint: /cart/clear');

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

  /// GET /cart/count (if available, otherwise calculate from cart)
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

  Future<Map<String, dynamic>> placeOrder({
    required String serviceId,
    required int quantity,
    bool useSalePrice = false,
    String paymentMethod = 'card',
    List<Map<String, String>>? selectedVariants,
    Map<String, dynamic>? orderDetails,
    String? requirements,
  }) async {
    try {
      log(
        '🛒 Placing order...$serviceId $quantity $useSalePrice $paymentMethod  $selectedVariants   $orderDetails',
      );

      final token = storage.getToken();
      if (token == null) throw Exception('Please login again');

      final body = {
        'serviceId': serviceId,
        'quantity': quantity,
        'useSalePrice': useSalePrice,
        'paymentMethod': paymentMethod,
        if (selectedVariants != null && selectedVariants.isNotEmpty)
          'selectedVariants': selectedVariants,
        if (orderDetails != null && orderDetails.isNotEmpty)
          'orderDetails': orderDetails,
      };

      log('📦 Request Body: $body');

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

          // ✅ CORRECT WAY: Extract order ID from nested structure
          // Response structure: data.success, data.message, data.data.order._id
          final orderData = data['data']?['order'] ?? data['order'] ?? {};
          final orderId = orderData['_id']?.toString();

          log('📦 Extracted Order ID: $orderId');
          log('📦 Full order data structure:');
          log('   data: ${data['data']?.runtimeType}');
          log('   data["data"]: ${data['data']}');
          log('   data["data"]["order"]: ${data['data']?['order']}');
          log('   data["order"]: ${data['order']}');

          return {
            'success': true,
            'message': data['message'] ?? 'Order placed successfully',
            'order': orderData,
            'orderId': orderId,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to place order');
        }
      } else {
        log('❌ HTTP ${response.statusCode}: ${response.data}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Place order error: $e');
      rethrow;
    }
  }
}
