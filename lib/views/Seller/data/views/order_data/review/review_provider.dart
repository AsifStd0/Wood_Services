// // lib/providers/review_provider.dart
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:wood_service/views/Seller/data/views/order_data/review/review_model.dart';

// class ReviewProvider with ChangeNotifier {
//   final String baseUrl = 'http://192.168.18.107:5001/api'; // Your API URL
//   final AuthService authService;
  
//   List<ReviewableItem> _reviewableItems = [];
//   List<ReviewableItem> get reviewableItems => _reviewableItems;
  
//   List<Review> _myReviews = [];
//   List<Review> get myReviews => _myReviews;
  
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
  
//   String _errorMessage = '';
//   String get errorMessage => _errorMessage;
//   bool get hasError => _errorMessage.isNotEmpty;

//   ReviewProvider(this.authService);

//   Future<Map<String, dynamic>> _getHeaders() async {
//     final token = await authService.getToken();
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }

//   // ✅ 1. Get orders eligible for review (GET /api/buyer/reviews/orders)
//   Future<List<ReviewableItem>> getReviewableOrders() async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final headers = await _getHeaders();
//       final response = await http.get(
//         Uri.parse('$baseUrl/buyer/reviews/orders'),
//         headers: headers,
//       );

//       log('📡 Get Reviewable Orders Status: ${response.statusCode}');
//       log('📡 Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           final List<dynamic> items = data['items'] ?? [];
//           _reviewableItems = items.map((item) => ReviewableItem.fromJson(item)).toList();
          
//           log('✅ Found ${_reviewableItems.length} reviewable items');
//           return _reviewableItems;
//         }
//       }
      
//       _errorMessage = 'Failed to load reviewable orders';
//       return [];
//     } catch (e) {
//       _errorMessage = 'Error: $e';
//       log('❌ Error getting reviewable orders: $e');
//       return [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ✅ 2. Submit a review (POST /api/buyer/reviews)
//   Future<Map<String, dynamic>> submitReview({
//     required String orderId,
//     required String orderItemId,
//     required String productId,
//     required int rating,
//     String? title,
//     String? comment,
//     List<String> images = const [],
//   }) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final headers = await _getHeaders();
      
//       final requestBody = {
//         'orderId': orderId,
//         'orderItemId': orderItemId,
//         'productId': productId,
//         'rating': rating,
//         'title': title ?? 'Great product!',
//         'comment': comment ?? '',
//         'images': images.map((url) => {'url': url}).toList(),
//       };

//       log('📤 Submitting review: $requestBody');

//       final response = await http.post(
//         Uri.parse('$baseUrl/buyer/reviews'),
//         headers: headers,
//         body: json.encode(requestBody),
//       );

//       log('📡 Submit Review Status: ${response.statusCode}');
//       log('📡 Response: ${response.body}');

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ Review submitted successfully');
          
//           // Refresh reviewable items
//           await getReviewableOrders();
          
//           return {
//             'success': true,
//             'message': data['message'],
//             'review': data['review'],
//           };
//         }
//       }
      
//       final errorData = json.decode(response.body);
//       return {
//         'success': false,
//         'message': errorData['message'] ?? 'Failed to submit review',
//         'statusCode': response.statusCode,
//       };
//     } catch (e) {
//       log('❌ Error submitting review: $e');
//       return {
//         'success': false,
//         'message': 'Network error: $e',
//       };
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ✅ 3. Get my reviews (GET /api/buyer/reviews/my)
//   Future<List<Review>> getMyReviews({
//     int? rating,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final headers = await _getHeaders();
      
//       final queryParams = {
//         'page': page.toString(),
//         'limit': limit.toString(),
//         if (rating != null) 'rating': rating.toString(),
//       };

//       final response = await http.get(
//         Uri.parse('$baseUrl/buyer/reviews/my').replace(queryParameters: queryParams),
//         headers: headers,
//       );

//       log('📡 Get My Reviews Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           final List<dynamic> reviews = data['reviews'] ?? [];
//           _myReviews = reviews.map((review) => Review.fromJson(review)).toList();
          
//           log('✅ Found ${_myReviews.length} reviews');
//           return _myReviews;
//         }
//       }
      
//       _errorMessage = 'Failed to load reviews';
//       return [];
//     } catch (e) {
//       _errorMessage = 'Error: $e';
//       log('❌ Error getting my reviews: $e');
//       return [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ✅ 4. Update review (PUT /api/buyer/reviews/:id)
//   Future<Map<String, dynamic>> updateReview({
//     required String reviewId,
//     int? rating,
//     String? title,
//     String? comment,
//     List<String>? images,
//   }) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final headers = await _getHeaders();
      
//       final requestBody = {
//         if (rating != null) 'rating': rating,
//         if (title != null) 'title': title,
//         if (comment != null) 'comment': comment,
//         if (images != null) 'images': images.map((url) => {'url': url}).toList(),
//       };

//       final response = await http.put(
//         Uri.parse('$baseUrl/buyer/reviews/$reviewId'),
//         headers: headers,
//         body: json.encode(requestBody),
//       );

//       log('📡 Update Review Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ Review updated successfully');
          
//           // Refresh my reviews
//           await getMyReviews();
          
//           return {
//             'success': true,
//             'message': data['message'],
//             'review': data['review'],
//           };
//         }
//       }
      
//       final errorData = json.decode(response.body);
//       return {
//         'success': false,
//         'message': errorData['message'] ?? 'Failed to update review',
//         'statusCode': response.statusCode,
//       };
//     } catch (e) {
//       log('❌ Error updating review: $e');
//       return {
//         'success': false,
//         'message': 'Network error: $e',
//       };
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ✅ 5. Delete review (DELETE /api/buyer/reviews/:id)
//   Future<Map<String, dynamic>> deleteReview(String reviewId) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final headers = await _getHeaders();

//       final response = await http.delete(
//         Uri.parse('$baseUrl/buyer/reviews/$reviewId'),
//         headers: headers,
//       );

//       log('📡 Delete Review Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ Review deleted successfully');
          
//           // Refresh my reviews
//           await getMyReviews();
          
//           return {
//             'success': true,
//             'message': data['message'],
//           };
//         }
//       }
      
//       final errorData = json.decode(response.body);
//       return {
//         'success': false,
//         'message': errorData['message'] ?? 'Failed to delete review',
//         'statusCode': response.statusCode,
//       };
//     } catch (e) {
//       log('❌ Error deleting review: $e');
//       return {
//         'success': false,
//         'message': 'Network error: $e',
//       };
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ✅ 6. Mark as helpful (POST /api/buyer/reviews/:id/helpful)
//   Future<Map<String, dynamic>> markHelpful(String reviewId) async {
//     try {
//       final headers = await _getHeaders();

//       final response = await http.post(
//         Uri.parse('$baseUrl/buyer/reviews/$reviewId/helpful'),
//         headers: headers,
//       );

//       log('📡 Mark Helpful Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ Marked as helpful');
//           return {
//             'success': true,
//             'message': data['message'],
//             'helpfulCount': data['helpfulCount'],
//           };
//         }
//       }
      
//       final errorData = json.decode(response.body);
//       return {
//         'success': false,
//         'message': errorData['message'] ?? 'Failed to mark as helpful',
//         'statusCode': response.statusCode,
//       };
//     } catch (e) {
//       log('❌ Error marking as helpful: $e');
//       return {
//         'success': false,
//         'message': 'Network error: $e',
//       };
//     }
//   }

//   // ✅ 7. Get product reviews (Public - GET /api/buyer/reviews/product/:productId)
//   Future<Map<String, dynamic>> getProductReviews({
//     required String productId,
//     int? rating,
//     String sort = 'newest',
//     int page = 1,
//     int limit = 10,
//   }) async {
//     try {
//       final queryParams = {
//         'page': page.toString(),
//         'limit': limit.toString(),
//         'sort': sort,
//         if (rating != null) 'rating': rating.toString(),
//       };

//       final response = await http.get(
//         Uri.parse('$baseUrl/buyer/reviews/product/$productId')
//             .replace(queryParameters: queryParams),
//       );

//       log('📡 Get Product Reviews Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           final List<dynamic> reviews = data['reviews'] ?? [];
//           final productReviews = reviews.map((review) => Review.fromJson(review)).toList();
          
//           final stats = ProductReviewStats.fromJson(data['stats']);
          
//           log('✅ Found ${productReviews.length} reviews for product $productId');
          
//           return {
//             'success': true,
//             'reviews': productReviews,
//             'stats': stats,
//             'pagination': data['pagination'],
//           };
//         }
//       }
      
//       final errorData = json.decode(response.body);
//       return {
//         'success': false,
//         'message': errorData['message'] ?? 'Failed to load product reviews',
//         'statusCode': response.statusCode,
//       };
//     } catch (e) {
//       log('❌ Error getting product reviews: $e');
//       return {
//         'success': false,
//         'message': 'Network error: $e',
//       };
//     }
//   }
// }