import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/buyer_favorite_product_model.dart';

class FavoriteProvider extends ChangeNotifier {
  // ========== STATE VARIABLES ==========
  final BuyerLocalStorageService _buyerLocalStorageService;
  final Map<String, bool> _favorites = {}; // productId -> isFavorited
  final Map<String, String> _favoriteIds = {}; // productId -> favoriteId
  bool _isLoading = false;
  List<FavoriteProduct> _cachedFavorites = [];
  int _totalFavorites = 0;

  // ========== BASE URL ==========
  // Use centralized config
  static String get _baseUrl => Config.baseUrl;

  // ========== CONSTRUCTOR ==========
  FavoriteProvider(this._buyerLocalStorageService);

  // ========== GETTERS ==========
  bool get isLoading => _isLoading;
  int get favoriteCount => _totalFavorites;
  List<FavoriteProduct> get cachedFavorites => _cachedFavorites;

  // Check if product is favorited
  bool isProductFavorited(String productId) {
    return _favorites[productId] ?? false;
  }

  // Get favorite ID
  String? getFavoriteId(String productId) {
    return _favoriteIds[productId];
  }

  String? _token;
  String? get token => _token;

  void setToken(String? token) {
    _token = token;
    if (token != null && token.isNotEmpty) {
      loadFavoriteCount();
    }
    notifyListeners();
  }

  // ========== CORE METHODS ==========

  // ✅ TOGGLE FAVORITE (Add/Remove)
  Future<void> toggleFavorite(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _buyerLocalStorageService.getBuyerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login to add favorites');
      }

      log('❤️ Toggling favorite for product: $productId');

      final url = Uri.parse('$_baseUrl/api/buyer/favorites/toggle/$productId');

      final client = http.Client();
      try {
        final response = await client
            .post(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Request timeout');
              },
            );

        log('📡 Response status: ${response.statusCode}');
        log('📡 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);

          if (jsonData['success'] == true) {
            final isFavorited = jsonData['data']['isFavorited'];
            final favoriteCount = jsonData['data']['favoriteCount'];

            // Update local state
            _favorites[productId] = isFavorited;
            _totalFavorites = favoriteCount;

            // Remove from cached list if unfavorited
            if (!isFavorited) {
              _cachedFavorites.removeWhere((fav) => fav.productId == productId);
            }

            log('✅ Favorite toggled: $isFavorited, Total: $_totalFavorites');
            notifyListeners();
          } else {
            throw Exception(jsonData['message'] ?? 'Failed to toggle favorite');
          }
        } else {
          throw Exception('Request failed with status: ${response.statusCode}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      log('❌ Toggle favorite error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ LOAD FAVORITE STATUS FOR MULTIPLE PRODUCTS
  Future<void> loadFavoriteStatusForProducts(List<String> productIds) async {
    try {
      final token = await _buyerLocalStorageService.getBuyerToken();

      if (token == null || token.isEmpty) {
        log('⚠️ Skipping favorite status load - no token');
        return;
      }

      log('📋 Loading favorite status for ${productIds.length} products');

      for (var productId in productIds) {
        try {
          final url = Uri.parse(
            '$_baseUrl/api/buyer/favorites/check/$productId',
          );

          final response = await http.get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);

            if (jsonData['success'] == true) {
              _favorites[productId] = jsonData['isFavorited'];

              if (jsonData['favoriteId'] != null) {
                _favoriteIds[productId] = jsonData['favoriteId'].toString();
              }

              log(
                '✅ Product $productId isFavorited: ${jsonData['isFavorited']}',
              );
            }
          }
        } catch (e) {
          log('⚠️ Error checking favorite for $productId: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error loading favorite status: $e');
    }
  }

  // ✅ GET ALL FAVORITE PRODUCTS
  Future<List<FavoriteProduct>> getFavoriteProducts({
    int page = 1,
    int limit = 20,
    bool refreshCache = false,
  }) async {
    if (refreshCache) {
      _cachedFavorites.clear();
    }

    try {
      final token = await _buyerLocalStorageService.getBuyerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login to view favorites');
      }

      final url = Uri.parse(
        '$_baseUrl/api/buyer/favorites?page=$page&limit=$limit',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final favorites = jsonData['favorites'] as List<dynamic>;
          final pagination = jsonData['pagination'] ?? {};

          _totalFavorites = pagination['total'] ?? 0;

          // Parse favorites
          final newFavorites = favorites
              .map((fav) => FavoriteProduct.fromJson(fav))
              .toList();

          if (page == 1) {
            _cachedFavorites = newFavorites;
          } else {
            _cachedFavorites.addAll(newFavorites);
          }

          // Update favorite status for these products
          for (var fav in newFavorites) {
            _favorites[fav.productId] = true;
          }

          log(
            '✅ Loaded ${newFavorites.length} favorite products (Total: $_totalFavorites)',
          );
          notifyListeners();

          return newFavorites;
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to load favorites');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Get favorite products error: $e');
      rethrow;
    }
  }

  // ✅ REMOVE FROM FAVORITES
  Future<void> removeFromFavorites(String productId) async {
    try {
      final token = await _buyerLocalStorageService.getBuyerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login to remove favorites');
      }

      final url = Uri.parse('$_baseUrl/api/buyer/favorites/$productId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          // Update local state
          _favorites.remove(productId);
          _favoriteIds.remove(productId);
          _cachedFavorites.removeWhere((fav) => fav.productId == productId);
          _totalFavorites =
              jsonData['data']['favoriteCount'] ?? _totalFavorites - 1;

          log('✅ Removed from favorites: $productId');
          notifyListeners();
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to remove favorite');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Remove from favorites error: $e');
      rethrow;
    }
  }

  // ✅ CLEAR ALL FAVORITES
  Future<void> clearAllFavorites() async {
    try {
      final token = await _buyerLocalStorageService.getBuyerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login to clear favorites');
      }

      final url = Uri.parse('$_baseUrl/api/buyer/favorites/clear');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          // Clear all local state
          _favorites.clear();
          _favoriteIds.clear();
          _cachedFavorites.clear();
          _totalFavorites = 0;

          log('✅ Cleared all favorites');
          notifyListeners();
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to clear favorites');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Clear all favorites error: $e');
      rethrow;
    }
  }

  // ✅ LOAD FAVORITE COUNT
  Future<void> loadFavoriteCount() async {
    try {
      final token = await _buyerLocalStorageService.getBuyerToken();

      if (token == null || token.isEmpty) {
        _totalFavorites = 0;
        return;
      }

      final url = Uri.parse('$_baseUrl/api/buyer/favorites/count');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          _totalFavorites = jsonData['count'] ?? 0;
          log('✅ Favorite count loaded: $_totalFavorites');
          notifyListeners();
        }
      }
    } catch (e) {
      log('⚠️ Load favorite count error: $e');
    }
  }

  // ✅ CLEAR ALL DATA (Logout)
  void clearAllData() {
    _favorites.clear();
    _favoriteIds.clear();
    _cachedFavorites.clear();
    _totalFavorites = 0;
    _isLoading = false;
    notifyListeners();
  }
}
