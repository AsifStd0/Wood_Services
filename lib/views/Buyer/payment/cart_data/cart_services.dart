// lib/services/cart_services.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/core/services/buyer_local_storage_service_impl.dart';

class CartServices {
  // Instance members
  final BuyerLocalStorageServiceImpl _storage;
  String? _cachedToken;

  CartServices(this._storage); // Constructor

  // Instance getter
  String get baseUrl => Config.apiBaseUrl;

  Future<void> initialize() async {
    await _storage.initialize();
    _cachedToken = await _storage.getBuyerToken();
    print('🛒 CartServices initialized');
  }

  Future<String?> _getToken() async {
    _cachedToken ??= await _storage.getBuyerToken();
    return _cachedToken;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Clear token cache
  Future<void> _clearTokenCache() async {
    _cachedToken = null;
    await _storage.buyerLogout();
  }

  // ========== API METHODS ==========

  // Fetch cart items
  Future<Map<String, dynamic>> fetchCart() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/buyer/cart'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch cart: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('❌ Error fetching cart: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
    String? selectedVariant,
    String? selectedSize,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/buyer/cart/add'),
        headers: headers,
        body: json.encode({
          'productId': productId,
          'quantity': quantity,
          'selectedVariant': selectedVariant,
          'selectedSize': selectedSize,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'], 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add to cart',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('❌ Error adding to cart: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateQuantity(
    String itemId,
    int newQuantity,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/buyer/cart/update/$itemId'),
        headers: headers,
        body: json.encode({'quantity': newQuantity}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update quantity',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('❌ Error updating quantity: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> removeItem(String itemId) async {
    try {
      final headers = await _getHeaders(); // Now works - instance method
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/buyer/cart/remove/$itemId',
        ), // baseUrl is instance getter
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to remove item',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('❌ Error removing item: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Clear entire cart
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/buyer/cart/clear'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to clear cart',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('❌ Error clearing cart: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Direct buy
  Future<Map<String, dynamic>> directBuy({
    required String productId,
    required int quantity,
    String? buyerNotes,
    Map<String, dynamic>? deliveryAddress,
    String paymentMethod = 'cod',
  }) async {
    try {
      final headers = await _getHeaders();

      final Map<String, dynamic> body = {
        'productId': productId,
        'quantity': quantity,
        'paymentMethod': paymentMethod,
      };

      if (buyerNotes != null && buyerNotes.isNotEmpty) {
        body['buyerNotes'] = buyerNotes;
      }

      if (deliveryAddress != null && deliveryAddress.isNotEmpty) {
        body['deliveryAddress'] = deliveryAddress;
      }

      log('📦 Direct Buy Request: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/buyer/cart/direct-buy'),
        headers: headers,
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'order': data['order'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to process purchase',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('❌ Error in direct buy: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Request buy (multiple items)
  Future<Map<String, dynamic>> requestBuy({
    required List<String> itemIds,
    String? buyerNotes,
    String? deliveryAddress,
    String paymentMethod = 'cod',
  }) async {
    try {
      final headers = await _getHeaders();

      final Map<String, dynamic> body = {
        'itemIds': itemIds,
        'paymentMethod': paymentMethod,
        if (buyerNotes != null && buyerNotes.isNotEmpty)
          'buyerNotes': buyerNotes,
        if (deliveryAddress != null)
          'deliveryAddress': {'address': deliveryAddress},
      };

      log('📦 Request Buy Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/api/buyer/cart/requests/buy'),
        headers: headers,
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'orders': data['orders'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to process request',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('❌ Error in request buy: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Get request/order details
  Future<Map<String, dynamic>> getRequestDetails(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/buyer/cart/requests/$orderId'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'request': data['request'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch order details',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('❌ Error fetching order details: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // Refresh token
  Future<void> refreshToken(String newToken) async {
    _cachedToken = newToken;
    await _storage.saveBuyerToken(newToken);
  }

  Future<void> logout() async {
    _cachedToken = null;
    await _storage.buyerLogout();
    print('✅ CartServices: User logged out');
  }
}
