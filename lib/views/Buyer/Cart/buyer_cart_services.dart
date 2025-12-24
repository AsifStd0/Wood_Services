import 'dart:developer';
import 'package:dio/dio.dart';
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

      log('   Response Data: ${response.data}');

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

            log('✅ Parsing cart data');
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

  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
    String? selectedVariant,
    String? selectedSize,
  }) async {
    try {
      final token = await _storageService.getBuyerToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.post(
        '/api/buyer/cart/add',
        data: {
          'productId': productId,
          'quantity': quantity,
          'selectedVariant': selectedVariant,
          'selectedSize': selectedSize,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'cartItem': BuyerCartItem.fromJson(response.data['cartItem']),
          'cartSummary': response.data['cartSummary'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add to cart');
      }
    } catch (error) {
      print('Add to cart error: $error');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final token = await _storageService.getBuyerToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

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

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'updatedItem': BuyerCartItem.fromJson(response.data['updatedItem']),
          'cartSummary': response.data['cartSummary'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update cart');
      }
    } catch (error) {
      print('Update cart error: $error');
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
