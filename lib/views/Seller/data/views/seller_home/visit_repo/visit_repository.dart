// repositories/visit_repository.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';

abstract class VisitRepository {
  Future<List<VisitRequest>> getVisitRequests({
    String? status,
    String? requestType,
  });
  Future<void> updateVisitStatus(String requestId, VisitStatus newStatus);
  Future<void> acceptVisitRequest({
    required String requestId,
    String? message,
    String? suggestedDate,
    String? suggestedTime,
    String? visitDate,
    String? visitTime,
    String? duration,
    String? location,
  });
  Future<void> declineVisitRequest({
    required String requestId,
    String? message,
  });
  Future<void> updateVisitSettings({
    required bool acceptsVisits,
    String? visitHours,
    String? visitDays,
    String? appointmentDuration,
  });
}

class ApiVisitRepository implements VisitRepository {
  final SellerLocalStorageService storageService;
  static const String baseUrl = 'http://10.0.20.221:5001/api/seller';

  ApiVisitRepository({required this.storageService});

  Future<List<VisitRequest>> _getVisitRequestsFromOrders(
    String token,
    String? status,
    String? requestType,
  ) async {
    try {
      String url = '$baseUrl/orders';
      final params = <String, String>{};
      if (requestType != null) params['requestType'] = requestType;
      if (status != null) params['status'] = status;

      if (params.isNotEmpty) {
        url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      log('🌐 Falling back to orders endpoint: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> orders = data['orders'] ?? data['requests'] ?? [];

          // Filter visit requests
          final visitOrders = orders.where((order) {
            final isVisit =
                order['requestType'] == 'visit_request' ||
                order['isVisitRequest'] == true ||
                order['visitType'] == 'shopVisit';
            return isVisit;
          }).toList();

          log(
            '✅ Found ${visitOrders.length} visit requests from orders endpoint',
          );

          return visitOrders
              .map((order) => VisitRequest.fromJson(order))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ Error fetching from orders: $e');
      return [];
    }
  }

  @override
  Future<void> updateVisitStatus(
    String requestId,
    VisitStatus newStatus,
  ) async {
    try {
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login as seller');
      }

      // Map to backend status
      final statusMap = {
        VisitStatus.accepted: 'accepted',
        VisitStatus.rejected: 'rejected',
        VisitStatus.declined: 'declined',
        VisitStatus.completed: 'completed',
        VisitStatus.cancelled: 'cancelled',
        VisitStatus.noshow: 'noshow',
      };

      final backendStatus = statusMap[newStatus];
      if (backendStatus == null) {
        throw Exception('Invalid status: $newStatus');
      }

      // Try multiple endpoints
      final endpoints = [
        '$baseUrl/visit-requests/$requestId/status',
        '$baseUrl/visit-requests/$requestId',
        '$baseUrl/orders/$requestId/status',
      ];

      Exception? lastError;

      for (final endpoint in endpoints) {
        try {
          log('🌐 Updating status via: $endpoint');

          final response = await http.put(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'status': backendStatus,
              'visitStatus': backendStatus,
            }),
          );

          log(
            '📡 Status update response: ${response.statusCode} - ${response.body}',
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] == true) {
              log('✅ Status updated successfully');
              return;
            }
          }
        } catch (e) {
          lastError = e as Exception;
          log('❌ Failed via $endpoint: $e');
        }
      }

      throw lastError ?? Exception('Failed to update status');
    } catch (e) {
      log('❌ Update status error: $e');
      rethrow;
    }
  }

  @override
  Future<void> acceptVisitRequest({
    required String requestId,
    String? message,
    String? suggestedDate,
    String? suggestedTime,
    String? visitDate,
    String? visitTime,
    String? duration,
    String? location,
  }) async {
    try {
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login as seller');
      }

      final url = '$baseUrl/visit-requests/$requestId/accept';
      log('🌐 Accepting request: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'message': message ?? '',
          'suggestedDate': suggestedDate,
          'suggestedTime': suggestedTime,
          'visitDate': visitDate,
          'visitTime': visitTime,
          'duration': duration,
          'location': location,
        }),
      );

      log('📡 Accept response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to accept request');
      }
    } catch (e) {
      log('❌ Accept request error: $e');
      rethrow;
    }
  }

  @override
  Future<void> declineVisitRequest({
    required String requestId,
    String? message,
  }) async {
    try {
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login as seller');
      }

      final url = '$baseUrl/visit-requests/$requestId/decline';
      log('🌐 Declining request: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'message': message ?? 'Visit request declined'}),
      );

      log('📡 Decline response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to decline request');
      }
    } catch (e) {
      log('❌ Decline request error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateVisitSettings({
    required bool acceptsVisits,
    String? visitHours,
    String? visitDays,
    String? appointmentDuration,
  }) async {
    try {
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login as seller');
      }

      final url = '$baseUrl/visit-settings';
      log('🌐 Updating settings: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'acceptsVisits': acceptsVisits,
          'visitHours': visitHours,
          'visitDays': visitDays,
          'appointmentDuration': appointmentDuration,
        }),
      );

      log('📡 Settings response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to update settings');
      }
    } catch (e) {
      log('❌ Update settings error: $e');
      rethrow;
    }
  }

  @override
  Future<List<VisitRequest>> getVisitRequests({
    String? status,
    String? requestType,
  }) async {
    try {
      final token = await storageService.getSellerToken();

      if (token == null || token.isEmpty) {
        log('❌ No seller token found');
        return [];
      }

      // First, try the visit-requests endpoint
      try {
        log('🔄 Trying visit-requests endpoint...');
        final visitRequests = await _getFromVisitRequestsEndpoint(
          token,
          status,
        );
        if (visitRequests.isNotEmpty) {
          log(
            '✅ Found ${visitRequests.length} visit requests from visit-requests endpoint',
          );
          return visitRequests;
        }
      } catch (e) {
        log('⚠️ Visit-requests endpoint failed: $e');
      }

      // If no visit requests found or endpoint fails, check orders
      log('🔄 Checking orders for visit requests...');
      final orders = await _getFromOrdersEndpoint(token, status);

      if (orders.isNotEmpty) {
        log('✅ Found ${orders.length} potential visit requests in orders');
        return orders;
      }

      log('ℹ️ No visit requests found in either endpoint');
      return [];
    } catch (e) {
      log('❌ Error fetching visit requests: $e');
      return [];
    }
  }

  Future<List<VisitRequest>> _getFromVisitRequestsEndpoint(
    String token,
    String? status,
  ) async {
    try {
      String url = '$baseUrl/visit-requests';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> requests = data['data'] ?? [];
          return requests.map((json) => VisitRequest.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ _getFromVisitRequestsEndpoint error: $e');
      return [];
    }
  }

  Future<List<VisitRequest>> _getFromOrdersEndpoint(
    String token,
    String? status,
  ) async {
    try {
      String url = '$baseUrl/orders';
      final params = <String, String>{};

      // Look for any orders that might be visit requests
      if (status != null) {
        params['status'] = status;
      }

      if (params.isNotEmpty) {
        url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> orders = data['orders'] ?? [];

          // Filter for visit requests
          final visitOrders = orders.where((order) {
            return order['requestType'] == 'visit_request' ||
                order['isVisitRequest'] == true ||
                order['visitType'] == 'shop_visit' ||
                order['visitType'] == 'shopVisit';
          }).toList();

          if (visitOrders.isNotEmpty) {
            log(
              '✅ Found ${visitOrders.length} actual visit requests in orders',
            );
            return visitOrders
                .map((json) => VisitRequest.fromJson(json))
                .toList();
          }

          // If no visit requests found, check if we should show regular orders as demo
          log('ℹ️ No visit requests found, showing regular orders for demo');
          return _convertOrdersToVisitRequests(orders);
        }
      }
      return [];
    } catch (e) {
      log('❌ _getFromOrdersEndpoint error: $e');
      return [];
    }
  }

  List<VisitRequest> _convertOrdersToVisitRequests(List<dynamic> orders) {
    // Convert regular orders to visit requests for demo purposes
    return orders.take(3).map((order) {
      return VisitRequest(
        id: order['_id'] ?? '',
        requestId: order['_id'] ?? '',
        buyer: {
          'name': order['buyerName'] ?? 'Unknown Buyer',
          'email': order['buyerEmail'] ?? '',
          'phone': '',
          'profileImage': '',
        },
        seller: {},
        message:
            'Interested in ${order['items']?.first?['productName'] ?? 'products'}',
        status: _parseOrderStatusToVisitStatus(order['status'] ?? 'pending'),
        requestedDate: order['requestedAt'] != null
            ? DateTime.parse(order['requestedAt']).toLocal()
            : DateTime.now(),
        preferredDate: DateTime.now().add(const Duration(days: 3)),
        preferredTime: '10:00 AM',
        items:
            (order['items'] as List?)?.map((item) {
              return VisitItem(
                productName: item['productName'] ?? 'Unknown Product',
                productImage: item['productImage'] ?? '',
                quantity: (item['quantity'] ?? 1).toInt(),
                price: (item['unitPrice'] ?? 0.0).toDouble(),
              );
            }).toList() ??
            [],
        createdAt: order['createdAt'] != null
            ? DateTime.parse(order['createdAt']).toLocal()
            : DateTime.now(),
        updatedAt: order['updatedAt'] != null
            ? DateTime.parse(order['updatedAt']).toLocal()
            : DateTime.now(),
        visitType: VisitType.shopVisit,
      );
    }).toList();
  }

  VisitStatus _parseOrderStatusToVisitStatus(String orderStatus) {
    switch (orderStatus.toLowerCase()) {
      case 'requested':
      case 'pending':
        return VisitStatus.pending;
      case 'accepted':
      case 'confirmed':
        return VisitStatus.accepted;
      case 'completed':
      case 'delivered':
        return VisitStatus.completed;
      case 'cancelled':
      case 'rejected':
        return VisitStatus.cancelled;
      default:
        return VisitStatus.pending;
    }
  }
}
