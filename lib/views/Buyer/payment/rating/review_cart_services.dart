// lib/views/Buyer/data/services/review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

class ReviewService {
  // final BuyerLocalStorageService _storage = locator<BuyerLocalStorageService>();
  final UnifiedLocalStorageServiceImpl _storage =
      UnifiedLocalStorageServiceImpl();
  Future<String?> _getToken() async {
    return await _storage.getToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Get product/service reviews
  /// GET /api/reviews/product/:serviceId or /api/reviews/service/:serviceId
  Future<Map<String, dynamic>> getProductReviews({
    required String productId, // Can be serviceId or productId
    int page = 1,
    int limit = 10,
    String? sort = 'newest',
  }) async {
    try {
      // API might accept both /product/:id or /service/:id
      String url =
          '${Config.apiBaseUrl}/api/reviews/product/$productId?page=$page&limit=$limit';
      if (sort != null) url += '&sort=$sort';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch reviews',
          'reviews': [],
          'stats': {
            'average': 0.0,
            'total': 0,
            'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
          },
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'reviews': [],
        'stats': {
          'average': 0.0,
          'total': 0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        },
      };
    }
  }

  // Get review statistics for a product/service
  /// GET /api/reviews/product/:serviceId or /api/reviews/service/:serviceId
  Future<Map<String, dynamic>> getReviewStats(String productId) async {
    try {
      // API might accept both /product/:id or /service/:id
      final response = await http.get(
        Uri.parse(
          '${Config.apiBaseUrl}/api/reviews/product/$productId?limit=1',
        ),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'averageRating': data['stats']['average'] ?? 0.0,
          'totalReviews': data['stats']['total'] ?? 0,
          'ratingDistribution': data['stats'] ?? {},
        };
      } else {
        return {
          'success': false,
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }
  }
}
