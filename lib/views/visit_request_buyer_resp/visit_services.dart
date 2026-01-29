// services/buyer_visit_request_service.dart
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_request_model.dart';

class BuyerVisitRequestService {
  final Dio _dio;
  final UnifiedLocalStorageServiceImpl _storage;

  BuyerVisitRequestService({Dio? dio, UnifiedLocalStorageServiceImpl? storage})
    : _dio = dio ?? locator<Dio>(),
      _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>();

  String? _getToken() {
    try {
      return _storage.getToken();
    } catch (e) {
      log('❌ Error getting token: $e');
      return null;
    }
  }

  /// GET /api/visit-requests/buyer - Get buyer's visit requests
  Future<Map<String, dynamic>> getBuyerVisitRequests({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      log('📋 Fetching buyer visit requests...');
      log('   Status filter: $status');
      log('   Page: $page, Limit: $limit');

      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to view visit requests');
      }

      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/visit-requests/buyer',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final visitRequestsData = data['data']?['visitRequests'] ?? [];
          final visitRequests = (visitRequestsData as List)
              .map((json) => BuyerVisitRequest.fromJson(json))
              .toList();

          log('✅ Loaded ${visitRequests.length} visit requests');

          return {
            'success': true,
            'visitRequests': visitRequests,
            'pagination': data['data']?['pagination'] ?? {},
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load visit requests');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error fetching visit requests: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to load visit requests';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error fetching visit requests: $e');
      rethrow;
    }
  }

  /// PUT /api/visit-requests/:id/cancel - Cancel visit request
  // In your BuyerVisitRequestService.dart
  Future<bool> cancelVisitRequest(String requestId) async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Buyer not authenticated');
      }

      log('❌ Cancelling visit request: $requestId');

      // Try different endpoint variations
      final endpoints = [
        '/visit-requests/$requestId/cancel',
        '/visit-requests/$requestId/status', // Might need to update status instead
      ];

      for (final endpoint in endpoints) {
        try {
          log('🔗 Trying endpoint: $endpoint');

          final response = await _dio.put(
            endpoint,
            data: {'status': 'cancelled'},
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ),
          );

          log('✅ Cancel response: ${response.data}');

          if (response.data['success'] == true) {
            return true;
          }
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            log('❌ Endpoint not found: $endpoint');
            continue; // Try next endpoint
          }
          rethrow;
        }
      }

      return false;
    } on DioException catch (e) {
      log('❌ Dio error cancelling visit request: ${e.message}');
      if (e.response != null) {
        log('Response: ${e.response?.data}');
        throw Exception(
          e.response?.data['message'] ?? 'Failed to cancel visit request',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      log('❌ Error cancelling visit request: $e');
      rethrow;
    }
  }

  /// GET /api/visit-requests/:id - Get visit request details
  Future<BuyerVisitRequest> getVisitRequestDetails(String requestId) async {
    try {
      log('🔍 Fetching visit request details: $requestId');

      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to view visit request details');
      }

      final response = await _dio.get(
        '/visit-requests/$requestId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final visitRequestData = data['data']?['visitRequest'];
          if (visitRequestData != null) {
            log('✅ Visit request details retrieved');
            return BuyerVisitRequest.fromJson(visitRequestData);
          } else {
            throw Exception('Visit request data not found in response');
          }
        } else {
          throw Exception(
            data['message'] ?? 'Failed to get visit request details',
          );
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error getting visit request details: ${e.message}');
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to get visit request details';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error getting visit request details: $e');
      rethrow;
    }
  }
}
