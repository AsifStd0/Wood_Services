// services/seller_stats_service.dart
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/models/seller_stats_model.dart';

class SellerStatsService {
  final Dio _dio = locator<Dio>();
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();

  /// GET /api/seller/stats
  Future<SellerStatsModel> getSellerStats() async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Seller not authenticated');
      }

      log('📊 Fetching seller stats...');

      final response = await _dio.get(
        '/seller/stats',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      log('📥 Stats Response Status: ${response.statusCode}');
      log('📥 Stats Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final statsData = response.data['data']?['stats'];
        if (statsData != null) {
          return SellerStatsModel.fromJson({'stats': statsData});
        }
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch stats');
    } on DioException catch (e) {
      log('❌ Stats API Dio error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to get statistics',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      log('❌ Error getting stats: $e');
      rethrow;
    }
  }
}
