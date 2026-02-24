import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:wood_service/app/ap_endpoint.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Seller_Ads_Own_Products/seller_own_ad_model.dart';

/// Seller Own Ad Service
/// Handles API calls for seller product ads
class SellerOwnAdService {
  final UnifiedLocalStorageServiceImpl _storage;

  SellerOwnAdService({required UnifiedLocalStorageServiceImpl storage})
    : _storage = storage;

  /// Create advertisement request for a product/service
  /// POST: /api/ads/seller
  /// Body: { serviceId, startDate, endDate }
  Future<Map<String, dynamic>> createAd({
    required String serviceId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Seller not authenticated');
      }

      log('📢 Creating ad for service: $serviceId');

      final url = Uri.parse('${Config.apiBaseUrl}${ApiEndpoints.sellerAds}');

      final body = jsonEncode({
        'serviceId': serviceId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });

      log('📤 Request URL: $url');
      log('📤 Request Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          // API returns ad data directly in data field
          final adData = data['data'] ?? {};
          return {
            'success': true,
            'ad': SellerOwnAdModel.fromJson(adData),
            'message': data['message'] ?? 'Ad created successfully',
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to create ad');
        }
      } else {
        throw Exception(
          data['message'] ?? 'Failed to create ad: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error creating ad: $e');
      rethrow;
    }
  }

  /// Get seller's ads
  /// GET: /api/ads/seller/my-ads?page=1&limit=10
  Future<Map<String, dynamic>> getMyAds({
    int page = 1,
    int limit = 10,
    ProductAdStatus? status,
  }) async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Seller not authenticated');
      }

      log('📢 Fetching seller ads (Page: $page, Limit: $limit)');

      var queryParams = {'page': page.toString(), 'limit': limit.toString()};

      if (status != null) {
        // Map enum to API status string (pending, approved, rejected)
        queryParams['status'] = _mapStatusToApi(status);
      }

      final uri = Uri.parse(
        '${Config.apiBaseUrl}${ApiEndpoints.sellerMyAds}',
      ).replace(queryParameters: queryParams);

      log('📤 Request URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          // API returns 'advertisements' not 'ads'
          final adsData =
              data['data']?['advertisements'] ??
              data['data']?['ads'] ??
              data['advertisements'] ??
              data['ads'] ??
              [];
          final ads = (adsData as List)
              .map((ad) => SellerOwnAdModel.fromJson(ad))
              .toList();

          final pagination =
              data['data']?['pagination'] ??
              data['pagination'] ??
              <String, dynamic>{};

          return {
            'success': true,
            'ads': ads,
            'pagination': {
              'currentPage':
                  pagination['currentPage'] ?? pagination['page'] ?? page,
              'totalPages': pagination['totalPages'] ?? 1,
              'total': pagination['total'] ?? ads.length,
              'limit': pagination['limit'] ?? limit,
            },
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch ads');
        }
      } else {
        throw Exception(
          data['message'] ?? 'Failed to fetch ads: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error fetching ads: $e');
      rethrow;
    }
  }

  /// Map ProductAdStatus enum to API status string
  /// API supports: pending, approved, rejected
  /// Note: 'completed' status is not supported by API, so we don't filter by it
  String _mapStatusToApi(ProductAdStatus status) {
    switch (status) {
      case ProductAdStatus.pending:
        return 'pending';
      case ProductAdStatus.approved:
        return 'approved';
      case ProductAdStatus.rejected:
        return 'rejected';
      case ProductAdStatus.completed:
        // API doesn't support 'completed' status filter
        // Return empty string or handle client-side filtering
        return 'approved'; // Fallback, but completed ads should be filtered client-side
    }
  }

  /// Delete an ad
  Future<bool> deleteAd(String adId) async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Seller not authenticated');
      }

      log('📢 Deleting ad: $adId');

      final url = Uri.parse(
        '${Config.apiBaseUrl}${ApiEndpoints.sellerAds}/$adId',
      );

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      log('❌ Error deleting ad: $e');
      rethrow;
    }
  }
}
