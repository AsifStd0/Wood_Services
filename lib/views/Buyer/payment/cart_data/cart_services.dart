// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wood_service/core/services/buyer_local_storage_service_impl.dart';

class CartServices {
  static const String baseUrl = 'http://localhost:5001/api';
  static String? _token;
  static BuyerLocalStorageServiceImpl _storage = BuyerLocalStorageServiceImpl();

  static Future<void> initialize() async {
    await _storage.initialize();
    _token = await _storage.getBuyerToken();
    print(
      '🛒 CartServices initialized with token: ${_token != null ? "EXISTS" : "NULL"}',
    );
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    await _storage.saveBuyerToken(token);
  }

  static Future<void> clearToken() async {
    _token = null;
    await _storage.buyerLogout();
  }

  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    };
  }

  // ========== HELPER METHOD ==========
  static Map<String, dynamic> _handleResponse(http.Response response) {
    print('📡 Response Status: ${response.statusCode}');
    print('📡 Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'API Error ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  // ========== CART APIS ==========

  // GET Cart
  static Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buyer/cart'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error getting cart: $e');
      rethrow;
    }
  }

  // // ADD to Cart
  // static Future<Map<String, dynamic>> addToCart(
  //   String productId,
  //   int quantity,
  // ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/buyer/cart/add'),
  //       headers: _headers,
  //       body: json.encode({'productId': productId, 'quantity': quantity}),
  //     );
  //     return _handleResponse(response);
  //   } catch (e) {
  //     print('❌ Error adding to cart: $e');
  //     rethrow;
  //   }
  // }

  // UPDATE Cart Item
  static Future<Map<String, dynamic>> updateCartItem(
    String itemId,
    int quantity,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/buyer/cart/update/$itemId'),
        headers: _headers,
        body: json.encode({'quantity': quantity}),
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error updating cart item: $e');
      rethrow;
    }
  }

  // REMOVE Cart Item
  static Future<Map<String, dynamic>> removeCartItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/buyer/cart/remove/$itemId'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error removing cart item: $e');
      rethrow;
    }
  }

  // CLEAR Cart
  static Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/buyer/cart/clear'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error clearing cart: $e');
      rethrow;
    }
  }

  // // REQUEST to Buy
  // static Future<Map<String, dynamic>> requestBuy({
  //   required List<String> itemIds,
  //   String? buyerNotes,
  //   String? deliveryAddress,
  //   String paymentMethod = 'cod',
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/buyer/cart/request/buy'),
  //       headers: _headers,
  //       body: json.encode({
  //         'itemIds': itemIds,
  //         'buyerNotes': buyerNotes,
  //         'deliveryAddress': deliveryAddress,
  //         'paymentMethod': paymentMethod,
  //       }),
  //     );
  //     return _handleResponse(response);
  //   } catch (e) {
  //     print('❌ Error requesting buy: $e');
  //     rethrow;
  //   }
  // }

  // ========== REVIEW APIS ==========

  // Get orders eligible for review
  static Future<Map<String, dynamic>> getReviewableOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buyer/reviews/orders'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error getting reviewable orders: $e');
      rethrow;
    }
  }

  // // Submit review
  // static Future<Map<String, dynamic>> submitReview({
  //   required String orderId,
  //   required String orderItemId,
  //   required String productId,
  //   required int rating,
  //   String? title,
  //   String? comment,
  //   List<Map<String, String>> images = const [],
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/buyer/reviews'),
  //       headers: _headers,
  //       body: json.encode({
  //         'orderId': orderId,
  //         'orderItemId': orderItemId,
  //         'productId': productId,
  //         'rating': rating,
  //         'title': title,
  //         'comment': comment,
  //         'images': images,
  //       }),
  //     );
  //     return _handleResponse(response);
  //   } catch (e) {
  //     print('❌ Error submitting review: $e');
  //     rethrow;
  //   }
  // }

  // // Get my reviews
  static Future<Map<String, dynamic>> getMyReviews({
    int page = 1,
    int limit = 10,
    int? rating,
  }) async {
    try {
      String url = '$baseUrl/buyer/reviews/my?page=$page&limit=$limit';
      if (rating != null) url += '&rating=$rating';

      final response = await http.get(Uri.parse(url), headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error getting my reviews: $e');
      rethrow;
    }
  }

  // Update review
  static Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    int? rating,
    String? title,
    String? comment,
    List<Map<String, String>>? images,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/buyer/reviews/$reviewId'),
        headers: _headers,
        body: json.encode({
          'rating': rating,
          'title': title,
          'comment': comment,
          'images': images,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error updating review: $e');
      rethrow;
    }
  }

  // Delete review
  static Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/buyer/reviews/$reviewId'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error deleting review: $e');
      rethrow;
    }
  }

  // Mark review as helpful
  static Future<Map<String, dynamic>> markHelpful(String reviewId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/buyer/reviews/$reviewId/helpful'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error marking helpful: $e');
      rethrow;
    }
  }

  // Get product reviews (public)
  static Future<Map<String, dynamic>> getProductReviews({
    required String productId,
    int page = 1,
    int limit = 10,
    int? rating,
    String sort = 'newest',
  }) async {
    try {
      String url =
          '$baseUrl/buyer/reviews/product/$productId?'
          'page=$page&limit=$limit&sort=$sort';
      if (rating != null) url += '&rating=$rating';

      final response = await http.get(Uri.parse(url));
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error getting product reviews: $e');
      rethrow;
    }
  }
}
