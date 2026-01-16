// // repositories/visit_repository.dart
// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:wood_service/core/services/seller_local_storage_service.dart';
// import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';

// // services/visit_service.dart
// class VisitService {
//   // final SellerLocalStorageService storageService;
//   // static const String baseUrl = 'http://192.168.18.107:5001/api/seller';

//   // VisitService({required this.storageService});

//   Future<List<VisitRequest>> getVisitRequests({
//     String? status,
//     String? requestType,
//   }) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         log('❌ No seller token found');
//         return [];
//       }

//       // Build URL with status filter if provided
//       String url = '$baseUrl/dashboard/visit-requests';
//       if (status != null) {
//         url += '?status=$status';
//       }

//       log('🌐 Fetching visit requests from: $url');

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       log('📡 Response status: ${response.statusCode}');
//       log('📡 Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['success'] == true) {
//           final List<dynamic> requests = data['data'] ?? [];

//           log('✅ Found ${requests.length} visit requests');

//           return requests.map((json) {
//             try {
//               return VisitRequest.fromJson(json);
//             } catch (e) {
//               log('❌ Error parsing visit request: $e');
//               log('❌ Problematic JSON: $json');
//               return VisitRequest.fromJson({});
//             }
//           }).toList();
//         } else {
//           throw Exception(data['message'] ?? 'Failed to fetch visit requests');
//         }
//       } else if (response.statusCode == 404) {
//         log('⚠️ Endpoint not found (404), returning empty list');
//         return [];
//       } else {
//         throw Exception(
//           'Failed to load visit requests: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       log('❌ Error in getVisitRequests: $e');
//       return [];
//     }
//   }

//   Future<void> updateVisitStatus(
//     String requestId,
//     VisitStatus newStatus,
//   ) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       // Map to backend status
//       final statusMap = {
//         VisitStatus.accepted: 'accepted',
//         VisitStatus.rejected: 'rejected',
//         VisitStatus.declined: 'declined',
//         VisitStatus.completed: 'completed',
//         VisitStatus.cancelled: 'cancelled',
//         VisitStatus.noshow: 'noshow',
//       };

//       final backendStatus = statusMap[newStatus];
//       if (backendStatus == null) {
//         throw Exception('Invalid status: $newStatus');
//       }

//       // Try multiple endpoints
//       final endpoints = [
//         '$baseUrl/visit-requests/$requestId/status',
//         '$baseUrl/visit-requests/$requestId',
//         '$baseUrl/orders/$requestId/status',
//       ];

//       Exception? lastError;

//       for (final endpoint in endpoints) {
//         try {
//           log('🌐 Updating status via: $endpoint');

//           final response = await http.put(
//             Uri.parse(endpoint),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//             body: json.encode({
//               'status': backendStatus,
//               'visitStatus': backendStatus,
//             }),
//           );

//           log(
//             '📡 Status update response: ${response.statusCode} - ${response.body}',
//           );

//           if (response.statusCode == 200) {
//             final data = json.decode(response.body);
//             if (data['success'] == true) {
//               log('✅ Status updated successfully');
//               return;
//             }
//           }
//         } catch (e) {
//           lastError = e as Exception;
//           log('❌ Failed via $endpoint: $e');
//         }
//       }

//       throw lastError ?? Exception('Failed to update status');
//     } catch (e) {
//       log('❌ Update status error: $e');
//       rethrow;
//     }
//   }

//   Future<void> acceptVisitRequest({
//     required String requestId,
//     String? message,
//     String? suggestedDate,
//     String? suggestedTime,
//     String? visitDate,
//     String? visitTime,
//     String? duration,
//     String? location,
//   }) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       final url = '$baseUrl/dashboard/visit-requests/$requestId/accept';
//       log('🌐 Accepting request: $url');

//       final response = await http.put(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({
//           'message': message ?? '',
//           'suggestedDate': suggestedDate,
//           'suggestedTime': suggestedTime,
//           'visitDate': visitDate,
//           'visitTime': visitTime,
//           'duration': duration,
//           'location': location,
//         }),
//       );

//       log('📡 Accept response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ Request accepted successfully');
//           return;
//         } else {
//           throw Exception(data['message'] ?? 'Failed to accept request');
//         }
//       } else {
//         final data = json.decode(response.body);
//         throw Exception(data['message'] ?? 'Failed to accept request');
//       }
//     } catch (e) {
//       log('❌ Accept request error: $e');
//       rethrow;
//     }
//   }

//   Future<void> declineVisitRequest({
//     required String requestId,
//     String? message,
//   }) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       final url = '$baseUrl/dashboard/visit-requests/$requestId/decline';
//       log('🌐 Declining request: $url');

//       final response = await http.put(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({'message': message ?? 'Visit request declined'}),
//       );

//       log('📡 Decline response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ Request declined successfully');
//           return;
//         } else {
//           throw Exception(data['message'] ?? 'Failed to decline request');
//         }
//       } else {
//         final data = json.decode(response.body);
//         throw Exception(data['message'] ?? 'Failed to decline request');
//       }
//     } catch (e) {
//       log('❌ Decline request error: $e');
//       rethrow;
//     }
//   }

//   Future<void> updateVisitSettings({
//     required bool acceptsVisits,
//     String? visitHours,
//     String? visitDays,
//     String? appointmentDuration,
//   }) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       final url = '$baseUrl/dashboard/visit-settings';
//       log('🌐 Updating settings: $url');

//       final response = await http.put(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({
//           'acceptsVisits': acceptsVisits,
//           'visitHours': visitHours,
//           'visitDays': visitDays,
//           'appointmentDuration': appointmentDuration,
//         }),
//       );

//       log('📡 Settings response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ Settings updated successfully');
//           return;
//         } else {
//           throw Exception(data['message'] ?? 'Failed to update settings');
//         }
//       } else {
//         final data = json.decode(response.body);
//         throw Exception(data['message'] ?? 'Failed to update settings');
//       }
//     } catch (e) {
//       log('❌ Update settings error: $e');
//       rethrow;
//     }
//   }
// }
