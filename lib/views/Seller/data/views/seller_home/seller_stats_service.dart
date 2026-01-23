// seller_stats_service.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

class SellerStatsService {
  final Dio _dio = locator<Dio>();
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();

  /// Get seller statistics
  Future<Map<String, dynamic>> getSellerStats() async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Seller not authenticated');
      }

      log('📊 Fetching seller stats...');
      log('🔑 Token: ${token.substring(0, 20)}...');

      final response = await _dio.get(
        '/seller/stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.data['success'] == true) {
        final stats = response.data['data']?['stats'] ?? {};
        log('✅ Stats retrieved successfully');
        return stats;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get stats');
      }
    } on DioException catch (e) {
      log('❌ Stats API Dio error: ${e.message}');
      if (e.response != null) {
        log('Response: ${e.response?.data}');
        throw Exception(
            e.response?.data['message'] ?? 'Failed to get statistics');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      log('❌ Error getting stats: $e');
      rethrow;
    }
  }
}