// services/buyer_product_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';

class BuyerProductService {
  static const String baseUrlProducts =
      'http://192.168.18.107:5001/api/buyer/products';
  static const String baseUrl = 'http://192.168.18.107:5001/api/buyer/shops';

  final BuyerLocalStorageService _storage = locator<BuyerLocalStorageService>();

  Future<List<BuyerProductModel>> getProducts() async {
    try {
      final token = await _storage.getBuyerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Buyer not authenticated');
      }

      final response = await http.get(
        Uri.parse(baseUrlProducts),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['products'] is List) {
          return _parseProducts(data['products'] as List);
        }
      }

      return [];
    } catch (error) {
      log('❌ Product Service Error: $error');
      return [];
    }
  }

  List<BuyerProductModel> _parseProducts(List<dynamic> productsJson) {
    return productsJson
        .map((json) {
          try {
            return BuyerProductModel.fromJson(json);
          } catch (e) {
            log('Failed to parse product: $e');
            return null;
          }
        })
        .where((product) => product != null)
        .cast<BuyerProductModel>()
        .toList();
  }

  // Update your requestVisit method to handle the "existing request" case
  Future<Map<String, dynamic>> requestVisit({
    required String sellerId,
    String? message,
    String? preferredDate,
    String? preferredTime,
  }) async {
    try {
      final token = await _storage.getBuyerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login to request a visit');
      }

      log('🌐 Making request to: $baseUrl/$sellerId/request-visit');

      final response = await http.post(
        Uri.parse('$baseUrl/$sellerId/request-visit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'message': message ?? '',
          'preferredDate': preferredDate,
          'preferredTime': preferredTime,
        }),
      );

      final data = json.decode(response.body);

      log('📡 Response: ${response.statusCode} - ${data['message']}');

      if (response.statusCode == 400 &&
          data['message']?.contains('already have a pending visit request')) {
        // Handle existing request case
        return {
          'success': false,
          'hasExistingRequest': true,
          'message': data['message'],
        };
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'],
            'data': data['data'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to request visit');
        }
      } else {
        throw Exception(
          data['message'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (error) {
      log('❌ Request visit error: $error');
      rethrow;
    }
  }

  // Get my visit requests
  Future<List<Map<String, dynamic>>> getMyVisitRequests() async {
    try {
      final token = await _storage.getBuyerToken();

      if (token == null || token.isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/visit-requests/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      return [];
    } catch (error) {
      print('Error getting visit requests: $error');
      return [];
    }
  }

  // Cancel visit request
  Future<Map<String, dynamic>> cancelVisitRequest({
    required String sellerId,
    required String requestId,
  }) async {
    try {
      final token = await _storage.getBuyerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login to cancel visit request');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$sellerId/cancel-visit/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'],
            'data': data['data'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to cancel visit request');
        }
      } else {
        throw Exception(
          data['message'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (error) {
      rethrow;
    }
  }
}

// ! **********
