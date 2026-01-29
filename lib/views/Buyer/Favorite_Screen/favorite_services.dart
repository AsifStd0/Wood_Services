// lib/core/services/favorite_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';

class FavoriteService {
  static String get _baseUrl => Config.baseUrl;

  // FavoriteService({
  //   required UnifiedLocalStorageServiceImpl storage,
  // }); // Constructor

  // Instance getter
  // String get baseUrl => Config.apiBaseUrl;

  // Check if product is favorited
  static Future<Map<String, dynamic>> checkFavoriteStatus(
    String productId,
    String token,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/api/favorites/check/$productId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'HTTP ${response.statusCode}'};
    } catch (e) {
      log('❌ Check favorite error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Toggle favorite (Add/Remove)
  static Future<Map<String, dynamic>> toggleFavorite(
    String serviceId,
    String token,
    bool isCurrentlyFavorited,
  ) async {
    try {
      if (isCurrentlyFavorited) {
        // Remove favorite
        return await _removeFavorite(serviceId, token);
      } else {
        // Add favorite
        return await _addFavorite(serviceId, token);
      }
    } catch (e) {
      log('❌ Toggle favorite error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Add to favorites
  static Future<Map<String, dynamic>> _addFavorite(
    String serviceId,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/api/favorites/$serviceId');
    final body = json.encode({'serviceId': serviceId});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    return {'success': false, 'error': 'HTTP ${response.statusCode}'};
  }

  // Remove from favorites
  static Future<Map<String, dynamic>> _removeFavorite(
    String serviceId,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/api/favorites/$serviceId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'success': false, 'error': 'HTTP ${response.statusCode}'};
  }

  // Get all favorite products
  static Future<Map<String, dynamic>> getFavoriteProducts({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/favorites?page=$page&limit=$limit');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'HTTP ${response.statusCode}'};
    } catch (e) {
      log('❌ Get favorites error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get favorite count
  static Future<Map<String, dynamic>> getFavoriteCount(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/favorites/count');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'HTTP ${response.statusCode}'};
    } catch (e) {
      log('❌ Get favorite count error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Clear all favorites
  static Future<Map<String, dynamic>> clearAllFavorites(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/favorites/clear');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'HTTP ${response.statusCode}'};
    } catch (e) {
      log('❌ Clear favorites error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
