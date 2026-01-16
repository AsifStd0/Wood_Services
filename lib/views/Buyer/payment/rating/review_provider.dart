// lib/providers/review_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

class ReviewProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _reviewableOrders = [];
  List<dynamic> _myReviews = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get reviewableOrders => _reviewableOrders;
  List<dynamic> get myReviews => _myReviews;

  String? _cachedToken;
  // final BuyerLocalStorageServiceImpl _storage = BuyerLocalStorageServiceImpl();
  final UnifiedLocalStorageServiceImpl _storage =
      UnifiedLocalStorageServiceImpl();

  Future<void> initialize() async {
    await _storage.initialize();
    _cachedToken = await _storage.getToken();
  }

  Future<String?> _getToken() async {
    _cachedToken ??= await _storage.getToken();
    return _cachedToken;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ========== GET REVIEWABLE ORDERS ==========
  Future<void> fetchReviewableOrders() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/buyer/reviews/orders'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _reviewableOrders = data['items'] ?? [];
          print('✅ Found ${_reviewableOrders.length} reviewable orders');
        } else {
          _errorMessage = data['message'] ?? 'Failed to fetch orders';
        }
      } else {
        _errorMessage = 'Failed to fetch orders: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      print('❌ Error fetching reviewable orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== SUBMIT REVIEW ==========
  /// POST /api/buyer/reviews
  /// Body: { serviceId, sellerId, rating, comment }
  Future<Map<String, dynamic>> submitReview({
    required String serviceId, // Changed from productId to serviceId
    required String sellerId, // NEW: Required field
    required int rating,
    String? comment,
    String? orderId, // Optional: for backward compatibility
    String? orderItemId, // Optional: for backward compatibility
    String? productId, // Optional: for backward compatibility (legacy)
    String? title, // Optional: not in new API
    List<Map<String, String>> images = const [], // Optional: not in new API
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📝 Submitting review...');
      print('• Service ID: $serviceId');
      print('• Seller ID: $sellerId');
      print('• Rating: $rating');
      print('• Comment: $comment');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/buyer/reviews'),
        headers: headers,
        body: json.encode({
          'serviceId': serviceId,
          'sellerId': sellerId,
          'rating': rating,
          'comment': comment ?? '',
        }),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          // Refresh reviewable orders after submission
          await fetchReviewableOrders();
          return {
            'success': true,
            'message': data['message'] ?? 'Review submitted successfully!',
            'review': data['review'],
          };
        }
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to submit review',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('❌ Error submitting review: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== GET MY REVIEWS ==========
  Future<void> fetchMyReviews({
    int page = 1,
    int limit = 10,
    int? rating,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String url =
          '${Config.apiBaseUrl}/buyer/reviews/my?page=$page&limit=$limit';
      if (rating != null) url += '&rating=$rating';

      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _myReviews = data['reviews'] ?? [];
          print('✅ Found ${_myReviews.length} reviews');
        }
      }
    } catch (e) {
      _errorMessage = 'Error fetching reviews: ${e.toString()}';
      print('❌ Error fetching reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== HELPER METHODS ==========
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Check if an order can be reviewed
  bool canReviewOrder(String orderId) {
    return _reviewableOrders.any((order) => order['orderId'] == orderId);
  }

  // Get order details for review
  Map<String, dynamic>? getOrderForReview(String orderId) {
    return _reviewableOrders.firstWhere(
      (order) => order['orderId'] == orderId,
      orElse: () => null,
    );
  }

  //!  ******
  // In ReviewProvider class
  // ========== GET REVIEWS FOR PRODUCT ==========
  // In ReviewProvider class, replace the old getProductReviews method with:

  // ! ========== GET PRODUCT REVIEWS WITH STATS ==========
  Future<Map<String, dynamic>> getProductReviewsWithStats({
    required String productId,
    int limit = 2,
  }) async {
    try {
      print('📝 Fetching reviews for product: $productId');

      final headers = await _getHeaders();

      // Call your existing API endpoint
      final response = await http.get(
        Uri.parse(
          '${Config.apiBaseUrl}/buyer/reviews/product/$productId?limit=$limit',
        ),
        headers: headers,
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'reviews': data['reviews'] ?? [],
            'stats':
                data['stats'] ??
                {
                  'average': 0.0,
                  'total': 0,
                  'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
                },
          };
        }
      }

      return {
        'success': false,
        'reviews': [],
        'stats': {
          'average': 0.0,
          'total': 0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        },
      };
    } catch (e) {
      print('❌ Error fetching product reviews: $e');
      return {
        'success': false,
        'reviews': [],
        'stats': {
          'average': 0.0,
          'total': 0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        },
      };
    }
  }
  // ! *******

  // ========== GET REVIEW STATS ==========
  Future<Map<String, dynamic>> getReviewStats(String productId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '${Config.apiBaseUrl}/buyer/products/$productId/reviews/stats',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'averageRating': data['averageRating'] ?? 0.0,
            'totalReviews': data['totalReviews'] ?? 0,
            'ratingDistribution': data['ratingDistribution'] ?? {},
          };
        }
      }

      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {},
      };
    } catch (e) {
      print('❌ Error fetching review stats: $e');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {},
      };
    }
  }
}
