// repositories/visit_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';

abstract class VisitRepository {
  Future<List<VisitRequest>> getVisitRequests();
  Future<void> updateVisitStatus(String orderId, VisitStatus newStatus);
}

class ApiVisitRepository implements VisitRepository {
  final String baseUrl = 'http://192.168.18.107:5001/api';
  final String? authToken;

  ApiVisitRepository({this.authToken});

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  @override
  Future<List<VisitRequest>> getVisitRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/seller/orders?type=visit'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> orders = data['orders'] ?? [];
          return orders.map((order) => VisitRequest.fromJson(order)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching visit requests: $e');
      return [];
    }
  }

  @override
  Future<void> updateVisitStatus(String orderId, VisitStatus newStatus) async {
    try {
      final statusMap = {
        VisitStatus.accepted: 'accepted',
        VisitStatus.rejected: 'rejected',
        VisitStatus.completed: 'completed',
        VisitStatus.cancelled: 'cancelled',
      };

      final response = await http.put(
        Uri.parse('$baseUrl/seller/orders/$orderId/visit-status'),
        headers: _getHeaders(),
        body: json.encode({'status': statusMap[newStatus]}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update visit status');
      }
    } catch (e) {
      print('Error updating visit status: $e');
      throw e;
    }
  }
}
