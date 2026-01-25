// lib/providers/review_provider.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
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
  final UnifiedLocalStorageServiceImpl _storage =
      UnifiedLocalStorageServiceImpl();
  ReviewProvider() {
    _initStorage();
  }
  void _initStorage() {
    _storage.initialize();
  }

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
        Uri.parse('${Config.apiBaseUrl}/reviews/orders'),
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

  //! ========== SUBMIT REVIEW BY ORDER ID ==========
  Future<Map<String, dynamic>> submitOrderReview({
    required String orderId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    log('📝 Starting review submission...');
    log('   Order ID: $orderId');
    log('   Rating: $rating');
    log('   Comment: $comment');
    log('   Images count: ${images?.length ?? 0}');

    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      if (token == null) {
        log('❌ No token found');
        return {'success': false, 'message': 'Please login to submit review'};
      }

      log('✅ Token obtained');

      // Check Config.baseUrl
      log('🔧 Config.baseUrl: ${Config.baseUrl}');

      // Build URL correctly
      String url;
      if (Config.baseUrl.endsWith('/api')) {
        url = '${Config.baseUrl}/buyer/orders/$orderId/review';
      } else {
        url = '${Config.baseUrl}/api/buyer/orders/$orderId/review';
      }

      log('🌐 Final URL: $url');
      final uri = Uri.parse(url);

      // Decide: Use multipart (with images) or JSON (without images)
      final hasImages = images != null && images.isNotEmpty;

      if (hasImages) {
        log('📤 Using multipart/form-data (has images)');
        return await _submitMultipartReview(
          uri,
          token,
          rating,
          comment,
          images!,
        );
      } else {
        log('📤 Using application/json (no images)');
        return await _submitJsonReview(uri, token, rating, comment);
      }
    } catch (e, stackTrace) {
      log('❌ Error in submitOrderReview: $e');
      log('Stack trace: $stackTrace');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _submitJsonReview(
    Uri uri,
    String token,
    int rating,
    String comment,
  ) async {
    try {
      log('📤 Sending JSON review request');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'rating': rating, 'comment': comment}),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          log('✅ Review submitted successfully (JSON)');
          await fetchReviewableOrders();
          return {
            'success': true,
            'message': data['message'] ?? 'Review submitted successfully!',
            'review': data['review'] ?? data['data'],
          };
        }
      }

      log('❌ Review submission failed (JSON)');
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to submit review',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      log('❌ Error in _submitJsonReview: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _submitMultipartReview(
    Uri uri,
    String token,
    int rating,
    String comment,
    List<String> images,
  ) async {
    try {
      log('📤 Sending multipart review request');

      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add fields
      request.fields['rating'] = rating.toString();
      request.fields['comment'] = comment;

      // Add images
      for (int i = 0; i < images.length && i < 5; i++) {
        try {
          final imageFile = io.File(images[i]);
          if (await imageFile.exists()) {
            final fileBytes = await imageFile.readAsBytes();
            final fileName = imageFile.path.split('/').last;

            request.files.add(
              http.MultipartFile.fromBytes(
                'images',
                fileBytes,
                filename: fileName,
              ),
            );
            log('✅ Added image $i: $fileName');
          }
        } catch (e) {
          log('⚠️ Error loading image ${images[i]}: $e');
        }
      }

      log('📤 Files count: ${request.files.length}');
      log('📤 Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          log('✅ Review submitted successfully (Multipart)');
          await fetchReviewableOrders();
          return {
            'success': true,
            'message': data['message'] ?? 'Review submitted successfully!',
            'review': data['review'] ?? data['data'],
          };
        }
      }

      log('❌ Review submission failed (Multipart)');
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to submit review',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      log('❌ Error in _submitMultipartReview: $e');
      rethrow;
    }
  }

  // ========== SUBMIT REVIEW ==========
  /// POST /reviews
  /// Body: { serviceId, sellerId, rating, comment }

  // ========== GET MY REVIEWS ==========
  Future<void> fetchMyReviews({
    int page = 1,
    int limit = 10,
    int? rating,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String url = '${Config.apiBaseUrl}/reviews/my?page=$page&limit=$limit';
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
          '${Config.apiBaseUrl}/reviews/product/$productId?limit=$limit',
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
        Uri.parse('${Config.apiBaseUrl}/products/$productId/reviews/stats'),
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
