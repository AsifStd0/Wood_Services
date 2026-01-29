// lib/core/providers/favorite_provider.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/buyer_favorite_product_model.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_services.dart';

class FavoriteProvider extends ChangeNotifier {
  // ========== DEPENDENCIES ==========
  // final StorageService _storage = locator<StorageService>();
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();

  // ========== STATE VARIABLES ==========
  final Map<String, bool> _favorites = {}; // productId -> isFavorited
  final Map<String, String> _favoriteIds = {}; // productId -> favoriteId
  final Map<String, bool> _loadingProducts = {}; // productId -> isLoading
  List<FavoriteProduct> _cachedFavorites = [];
  int _totalFavorites = 0;
  bool _isLoading = false;

  // ========== GETTERS ==========
  bool get isLoading => _isLoading;
  int get favoriteCount => _totalFavorites;
  List<FavoriteProduct> get cachedFavorites => _cachedFavorites;

  bool isProductLoading(String productId) =>
      _loadingProducts[productId] ?? false;
  bool isProductFavorited(String productId) => _favorites[productId] ?? false;
  String? getFavoriteId(String productId) => _favoriteIds[productId];

  // ========== PUBLIC METHODS ==========

  // Toggle favorite status
  Future<void> toggleFavorite(String serviceId) async {
    // Prevent duplicate requests
    if (_loadingProducts[serviceId] == true) {
      log('⚠️ Toggle already in progress for: $serviceId');
      return;
    }

    // Set loading state for this product
    _loadingProducts[serviceId] = true;
    notifyListeners();

    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to add favorites');
      }

      final isCurrentlyFavorited = _favorites[serviceId] ?? false;

      // Call service
      final result = await FavoriteService.toggleFavorite(
        serviceId,
        token,
        isCurrentlyFavorited,
      );

      if (result['success'] == true) {
        if (isCurrentlyFavorited) {
          // Remove from favorites
          _favorites.remove(serviceId);
          _favoriteIds.remove(serviceId);
          _cachedFavorites.removeWhere((fav) => fav.productId == serviceId);
          _totalFavorites =
              result['data']?['favoriteCount']?.toInt() ??
              (_totalFavorites > 0 ? _totalFavorites - 1 : 0);
        } else {
          // Add to favorites
          _favorites[serviceId] = true;
          _totalFavorites =
              result['data']?['favoriteCount'] ?? _totalFavorites + 1;

          final favoriteId = result['data']?['favoriteId']?.toString();
          if (favoriteId != null) {
            _favoriteIds[serviceId] = favoriteId;
          }
        }

        log('✅ Favorite toggled. Total: $_totalFavorites');
        notifyListeners();
      } else {
        throw Exception(result['message'] ?? 'Failed to toggle favorite');
      }
    } catch (e) {
      log('❌ Toggle favorite error: $e');
      rethrow;
    } finally {
      _loadingProducts.remove(serviceId);
      notifyListeners();
    }
  }

  // Load favorite products
  Future<List<FavoriteProduct>> getFavoriteProducts({
    int page = 1,
    int limit = 20,
    bool refreshCache = false,
  }) async {
    if (refreshCache) {
      _cachedFavorites.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to view favorites');
      }

      final result = await FavoriteService.getFavoriteProducts(
        token: token,
        page: page,
        limit: limit,
      );

      if (result['success'] == true) {
        final data = result['data'] ?? {};
        final favorites = data['favorites'] as List<dynamic>? ?? [];
        final pagination = data['pagination'] ?? {};

        _totalFavorites = pagination['total']?.toInt() ?? favorites.length;

        // Parse favorites
        final newFavorites = favorites
            .map((fav) {
              try {
                if (fav is Map<String, dynamic>) {
                  final serviceIdData = fav['serviceId'];
                  if (serviceIdData is Map<String, dynamic>) {
                    final favoriteData = {
                      ...serviceIdData,
                      '_favoriteId': fav['_id']?.toString() ?? '',
                      '_userId': fav['userId']?.toString() ?? '',
                      '_createdAt': fav['createdAt']?.toString() ?? '',
                    };
                    return FavoriteProduct.fromJson(favoriteData);
                  }
                }
                return FavoriteProduct.fromJson(fav);
              } catch (e) {
                log('❌ Error parsing favorite: $e');
                return null;
              }
            })
            .whereType<FavoriteProduct>()
            .toList();

        // Update cache
        if (page == 1) {
          _cachedFavorites = newFavorites;
        } else {
          _cachedFavorites.addAll(newFavorites);
        }

        // Update favorite status
        for (var fav in newFavorites) {
          _favorites[fav.productId] = true;
        }

        log('✅ Loaded ${newFavorites.length} favorite products');
        return newFavorites;
      } else {
        throw Exception(result['message'] ?? 'Failed to load favorites');
      }
    } catch (e) {
      log('❌ Get favorite products error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load favorite count
  Future<void> loadFavoriteCount() async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        _totalFavorites = 0;
        return;
      }

      final result = await FavoriteService.getFavoriteCount(token);
      if (result['success'] == true) {
        _totalFavorites = result['count'] ?? 0;
        log('✅ Favorite count loaded: $_totalFavorites');
        notifyListeners();
      }
    } catch (e) {
      log('⚠️ Load favorite count error: $e');
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to clear favorites');
      }

      final result = await FavoriteService.clearAllFavorites(token);
      if (result['success'] == true) {
        _favorites.clear();
        _favoriteIds.clear();
        _cachedFavorites.clear();
        _totalFavorites = 0;
        log('✅ Cleared all favorites');
        notifyListeners();
      } else {
        throw Exception(result['message'] ?? 'Failed to clear favorites');
      }
    } catch (e) {
      log('❌ Clear all favorites error: $e');
      rethrow;
    }
  }

  // Sync initial favorite status
  void syncInitialFavoriteStatus(
    String productId,
    bool isFavorited, {
    String? favoriteId,
  }) {
    if (!_favorites.containsKey(productId)) {
      _favorites[productId] = isFavorited;
      if (favoriteId != null) {
        _favoriteIds[productId] = favoriteId;
      }
    }
  }

  // ! ******
  static String get _baseUrl => Config.baseUrl;
  // Add this method to your FavoriteProvider class
  Future<void> loadFavoriteStatusForProducts(List<String> productIds) async {
    try {
      final token = _storage.getToken();

      if (token == null || token.isEmpty) {
        log('⚠️ Skipping favorite status load - no token');
        return;
      }

      log('📋 Loading favorite status for ${productIds.length} products');

      for (var productId in productIds) {
        try {
          final url = Uri.parse('$_baseUrl/api/favorites/check/$productId');
          log('🌐 Checking favorite for: $productId');

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
              final data = jsonData['data'];

              if (data is Map<String, dynamic>) {
                final isFavorited = data['isFavorited'];

                // Set favorite status
                _favorites[productId] = isFavorited is bool
                    ? isFavorited
                    : false;

                // Set favorite ID if available
                if (data['favoriteId'] != null) {
                  _favoriteIds[productId] = data['favoriteId'].toString();
                }

                log(
                  '✅ Product $productId: ${_favorites[productId] ?? false ? '❤️ Favorited' : '🤍 Not favorited'}',
                );
              } else {
                _favorites[productId] = false;
                log('⚠️ Product $productId: Invalid data format');
              }
            } else {
              _favorites[productId] = false;
              log('⚠️ Product $productId: API returned success=false');
            }
          } else {
            _favorites[productId] = false;
            log('⚠️ Product $productId: HTTP ${response.statusCode}');
          }
        } catch (e) {
          _favorites[productId] = false;
          log('⚠️ Error for $productId: $e');
        }
      }

      log('✅ Completed loading favorite status');
      notifyListeners();
    } catch (e) {
      log('❌ Error loading favorite status: $e');
    }
  }

  // Clear all data (for logout)
  void clearAllData() {
    _favorites.clear();
    _favoriteIds.clear();
    _cachedFavorites.clear();
    _totalFavorites = 0;
    _isLoading = false;
    _loadingProducts.clear();
    notifyListeners();
  }
}
