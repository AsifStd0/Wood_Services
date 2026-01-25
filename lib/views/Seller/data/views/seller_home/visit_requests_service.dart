// visit_requests_service.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

class VisitRequestsService {
  final Dio _dio = locator<Dio>();
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();

  /// GET /api/visit-requests/seller
  /// Query params: status (optional), page (optional), limit (optional)
  Future<Map<String, dynamic>> getVisitRequests({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Seller not authenticated');
      }

      log('📋 Fetching visit requests...');
      log('   Status filter: ${status ?? "all"}');
      log('   Page: $page, Limit: $limit');

      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/visit-requests/seller',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        final visitRequests = data['visitRequests'] ?? [];
        final pagination = data['pagination'] ?? {};

        log('✅ Found ${visitRequests.length} visit requests');
        return {
          'success': true,
          'visitRequests': visitRequests,
          'pagination': pagination,
        };
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to get visit requests',
        );
      }
    } on DioException catch (e) {
      log('❌ Visit requests API Dio error: ${e.message}');
      if (e.response != null) {
        log('Response: ${e.response?.data}');
        throw Exception(
          e.response?.data['message'] ?? 'Failed to get visit requests',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      log('❌ Error getting visit requests: $e');
      rethrow;
    }
  }

  /// Update visit request status
  /// PUT /api/visit-requests/:requestId/status
  Future<Map<String, dynamic>> updateVisitRequestStatus({
    required String requestId,
    required String status, // 'accepted', 'rejected', 'completed', etc.
    String? message,
  }) async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Seller not authenticated');
      }

      log('🔄 Updating visit request status...');
      log('   Request ID: $requestId');
      log('   New Status: $status');

      final body = <String, dynamic>{'status': status};
      if (message != null && message.isNotEmpty) {
        body['message'] = message;
      }

      final response = await _dio.put(
        '/visit-requests/$requestId/status',
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

      if (response.data['success'] == true) {
        log('✅ Visit request status updated successfully');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Status updated successfully',
          'visitRequest': response.data['data']?['visitRequest'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } on DioException catch (e) {
      log('❌ Update status Dio error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update status',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      log('❌ Error updating visit request status: $e');
      rethrow;
    }
  }
}
