// // services/seller_visit_service.dart
// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:wood_service/core/services/seller_local_storage_service.dart';

// class SellerVisitService {
//   static const String baseUrl = 'http://10.0.20.221:5001/api/seller';

//   final SellerLocalStorageService _storageService;

//   SellerVisitService(this._storageService);

//   // Get pending visit requests
//   Future<List<Map<String, dynamic>>> getPendingVisitRequests() async {
//     try {
//       final token = await _storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/visit-requests/pending'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       log('📡 Pending requests response: ${response.statusCode}');
//       log('📡 Pending requests body: ${response.body}');

//       final data = json.decode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         return List<Map<String, dynamic>>.from(data['data'] ?? []);
//       }

//       return [];
//     } catch (error) {
//       log('❌ Get pending requests error: $error');
//       return [];
//     }
//   }

//   // Get all visit requests with optional status filter
//   Future<List<Map<String, dynamic>>> getAllVisitRequests({
//     String? status,
//   }) async {
//     try {
//       final token = await _storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       String url = '$baseUrl/visit-requests';
//       if (status != null) {
//         url += '?status=$status';
//       }

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       log('📡 All requests response: ${response.statusCode}');

//       final data = json.decode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         return List<Map<String, dynamic>>.from(data['data'] ?? []);
//       }

//       return [];
//     } catch (error) {
//       log('❌ Get all requests error: $error');
//       return [];
//     }
//   }

//   // Accept visit request
//   Future<Map<String, dynamic>> acceptVisitRequest({
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
//       final token = await _storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       final response = await http.put(
//         Uri.parse('$baseUrl/visit-requests/$requestId/accept'),
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

//       final data = json.decode(response.body);
//       log('📡 Accept response: ${response.statusCode} - ${data['message']}');

//       if (response.statusCode == 200) {
//         if (data['success'] == true) {
//           return {
//             'success': true,
//             'message': data['message'],
//             'data': data['data'],
//           };
//         } else {
//           throw Exception(data['message'] ?? 'Failed to accept request');
//         }
//       } else {
//         throw Exception(
//           data['message'] ?? 'Server error: ${response.statusCode}',
//         );
//       }
//     } catch (error) {
//       log('❌ Accept request error: $error');
//       rethrow;
//     }
//   }

//   // Decline visit request
//   Future<Map<String, dynamic>> declineVisitRequest({
//     required String requestId,
//     String? message,
//   }) async {
//     try {
//       final token = await _storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       final response = await http.put(
//         Uri.parse('$baseUrl/visit-requests/$requestId/decline'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({'message': message ?? 'Visit request declined'}),
//       );

//       final data = json.decode(response.body);
//       log('📡 Decline response: ${response.statusCode} - ${data['message']}');

//       if (response.statusCode == 200) {
//         if (data['success'] == true) {
//           return {
//             'success': true,
//             'message': data['message'],
//             'data': data['data'],
//           };
//         } else {
//           throw Exception(data['message'] ?? 'Failed to decline request');
//         }
//       } else {
//         throw Exception(
//           data['message'] ?? 'Server error: ${response.statusCode}',
//         );
//       }
//     } catch (error) {
//       log('❌ Decline request error: $error');
//       rethrow;
//     }
//   }

//   // Update visit settings
//   Future<Map<String, dynamic>> updateVisitSettings({
//     required bool acceptsVisits,
//     String? visitHours,
//     String? visitDays,
//     String? appointmentDuration,
//   }) async {
//     try {
//       final token = await _storageService.getSellerToken();

//       if (token == null || token.isEmpty) {
//         throw Exception('Please login as seller');
//       }

//       final response = await http.put(
//         Uri.parse('$baseUrl/visit-settings'),
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

//       final data = json.decode(response.body);

//       if (response.statusCode == 200) {
//         if (data['success'] == true) {
//           return {
//             'success': true,
//             'message': data['message'],
//             'data': data['data'],
//           };
//         } else {
//           throw Exception(data['message'] ?? 'Failed to update settings');
//         }
//       } else {
//         throw Exception(
//           data['message'] ?? 'Server error: ${response.statusCode}',
//         );
//       }
//     } catch (error) {
//       log('❌ Update settings error: $error');
//       rethrow;
//     }
//   }
// }
