// services/favorite_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wood_service/views/Buyer/Favorite_Screen/buyer_favorite_product_model.dart';

class FavoriteService {
  final String baseUrl =
      'http://192.168.18.107:5001/api/buyer/favorites'; // CORRECTED
  final String? token;

  FavoriteService(this.token);

  // Check if user is authenticated
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  // Get headers with authentication
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Toggle favorite status
  Future<FavoriteResponse> toggleFavorite(String productId) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      print('🔄 Toggling favorite for product: $productId');

      final response = await http.post(
        Uri.parse('$baseUrl/toggle/$productId'),
        headers: _headers,
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FavoriteResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to toggle favorite');
      }
    } catch (error) {
      print('❌ Toggle favorite error: $error');
      rethrow;
    }
  }

  // Get all favorites
  Future<FavoritesListResponse> getFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      print('📋 Getting favorites - Page: $page, Limit: $limit');

      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&limit=$limit'), // NOW CORRECT
        headers: _headers,
      );

      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FavoritesListResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get favorites');
      }
    } catch (error) {
      print('❌ Get favorites error: $error');
      rethrow;
    }
  }

  // Check if product is favorited
  Future<FavoriteCheckResponse> checkFavoriteStatus(String productId) async {
    try {
      if (!isAuthenticated) {
        // If user not authenticated, return false
        return FavoriteCheckResponse(success: false, isFavorited: false);
      }

      print('🔍 Checking favorite status for product: $productId');

      final response = await http.get(
        Uri.parse('$baseUrl/check/$productId'), // NOW CORRECT
        headers: _headers,
      );

      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FavoriteCheckResponse.fromJson(data);
      } else {
        // If error, assume not favorited
        return FavoriteCheckResponse(success: false, isFavorited: false);
      }
    } catch (error) {
      print('❌ Check favorite status error: $error');
      return FavoriteCheckResponse(success: false, isFavorited: false);
    }
  }

  // Get favorite count
  Future<int> getFavoriteCount() async {
    try {
      if (!isAuthenticated) {
        return 0;
      }

      print('🔢 Getting favorite count');

      final response = await http.get(
        Uri.parse('$baseUrl/count'), // NOW CORRECT
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (error) {
      print('❌ Get favorite count error: $error');
      return 0;
    }
  }

  // Remove from favorites
  Future<bool> removeFromFavorites(String productId) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      print('🗑️ Removing favorite for product: $productId');

      final response = await http.delete(
        Uri.parse('$baseUrl/$productId'), // NOW CORRECT
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to remove favorite');
      }
    } catch (error) {
      print('❌ Remove from favorites error: $error');
      rethrow;
    }
  }

  // Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      print('🧹 Clearing all favorites');

      final response = await http.delete(
        Uri.parse('$baseUrl/clear'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to clear favorites');
      }
    } catch (error) {
      print('❌ Clear all favorites error: $error');
      rethrow;
    }
  }
}
