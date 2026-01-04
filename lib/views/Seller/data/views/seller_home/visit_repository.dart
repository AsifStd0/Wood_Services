// repositories/visit_repository.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';

abstract class VisitRepository {
  Future<List<VisitRequest>> getVisitRequests();
  Future<void> updateVisitStatus(String orderId, VisitStatus newStatus);
}

class ApiVisitRepository implements VisitRepository {
  final Dio dio;
  final SellerLocalStorageService storageService;

  ApiVisitRepository({required this.dio, required this.storageService});

  // REMOVE THESE - They're redundant with Dio
  // final String baseUrl = 'http://192.168.10.20:5001/api';
  // final String? authToken;
  // Map<String, String> _getHeaders() { ... }

  @override
  Future<List<VisitRequest>> getVisitRequests() async {
    try {
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        print('❌ No seller token found');
        return [];
      }

      final response = await dio.get(
        '/api/seller/orders', // Dio already has baseUrl
        queryParameters: {
          'requestType': 'visit_request',
        }, // ✅ Correct parameter
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('📡 Visit Requests Response Status: ${response.statusCode}');
      print('📡 Visit Requests Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> orders = data['orders'] ?? data['requests'] ?? [];

          // ✅ Filter only visit requests
          final visitOrders = orders.where((order) {
            final isVisit =
                order['requestType'] == 'visit_request' ||
                order['isVisitRequest'] == true;
            print('📋 Order ${order['orderId']}: isVisit = $isVisit');
            return isVisit;
          }).toList();

          print('✅ Found ${visitOrders.length} visit requests');

          return visitOrders
              .map((order) => VisitRequest.fromJson(order))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ Error fetching visit requests: $e');
      return [];
    }
  }

  @override
  Future<void> updateVisitStatus(String orderId, VisitStatus newStatus) async {
    try {
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        throw Exception('No seller token found');
      }

      // Map Flutter enum to backend status
      final statusMap = {
        VisitStatus.accepted: 'accepted',
        VisitStatus.rejected: 'rejected',
        VisitStatus.completed: 'completed',
        VisitStatus.cancelled: 'cancelled',
        VisitStatus.noshow: 'noshow',
      };

      final backendStatus = statusMap[newStatus];
      if (backendStatus == null) {
        throw Exception('Invalid status: $newStatus');
      }

      print('📤 Updating visit status for order: $orderId to $backendStatus');

      // Try different endpoints based on your API
      final response = await dio.put(
        '/api/seller/orders/$orderId/status', // Try this first
        data: {
          'status': backendStatus,
          'visitStatus': backendStatus, // Also try with visitStatus
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Visit status updated: ${response.data}');
    } catch (e) {
      print('❌ Error updating visit status: $e');
      rethrow;
    }
  }
}
