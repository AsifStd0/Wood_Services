// // repositories/seller_visit_repository.dart (NEW FILE)
// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:wood_service/core/services/seller_local_storage_service.dart';
// import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/seller_visit_request_model.dart';

// abstract class SellerVisitRepository {
//   Future<List<SellerVisitRequest>> getVisitRequests({String? status});
//   Future<void> acceptVisitRequest({
//     required String requestId,
//     String? message,
//     String? suggestedDate,
//     String? suggestedTime,
//     String? visitDate,
//     String? visitTime,
//     String? duration,
//     String? location,
//   });
//   Future<void> declineVisitRequest({
//     required String requestId,
//     String? message,
//   });
//   Future<void> updateVisitSettings({
//     required bool acceptsVisits,
//     String? visitHours,
//     String? visitDays,
//     String? appointmentDuration,
//   });
// }

// class ApiSellerVisitRepository implements SellerVisitRepository {
//   final SellerLocalStorageService storageService;
//   static const String baseUrl = 'http://10.0.20.221:5001/api/seller';

//   ApiSellerVisitRepository({required this.storageService});

//   @override
//   Future<List<SellerVisitRequest>> getVisitRequests({String? status}) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         log('❌ No seller token found');
//         return [];
//       }

//       String url = '$baseUrl/visit-requests';
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

//       log('📡 Visit requests response: ${response.statusCode}');
//       log('📡 Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['success'] == true) {
//           final List<dynamic> requests = data['data'] ?? [];
//           log('✅ Found ${requests.length} visit requests');

//           return requests
//               .map((json) => SellerVisitRequest.fromJson(json))
//               .toList();
//         } else {
//           log('❌ API error: ${data['message']}');
//         }
//       } else {
//         log('❌ HTTP error: ${response.statusCode}');
//       }

//       return [];
//     } catch (e) {
//       log('❌ Error fetching visit requests: $e');
//       return [];
//     }
//   }

//   @override
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

//       final url = '$baseUrl/visit-requests/$requestId/accept';
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

//       if (response.statusCode != 200) {
//         final data = json.decode(response.body);
//         throw Exception(data['message'] ?? 'Failed to accept request');
//       }
//     } catch (e) {
//       log('❌ Accept request error: $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<void> declineVisitRequest({
//     required String requestId,
//     String? message,
//   }) async {
//     try {
//       final token = await storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       final url = '$baseUrl/visit-requests/$requestId/decline';
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

//       if (response.statusCode != 200) {
//         final data = json.decode(response.body);
//         throw Exception(data['message'] ?? 'Failed to decline request');
//       }
//     } catch (e) {
//       log('❌ Decline request error: $e');
//       rethrow;
//     }
//   }

//   @override
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

//       final url = '$baseUrl/visit-settings';
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

//       if (response.statusCode != 200) {
//         final data = json.decode(response.body);
//         throw Exception(data['message'] ?? 'Failed to update settings');
//       }
//     } catch (e) {
//       log('❌ Update settings error: $e');
//       rethrow;
//     }
//   }
// }
