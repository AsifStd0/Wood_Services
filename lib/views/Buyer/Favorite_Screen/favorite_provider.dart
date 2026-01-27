import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/buyer_favorite_product_model.dart';

class FavoriteProvider extends ChangeNotifier {
  // ========== STATE VARIABLES ==========
  // Use locator to get the initialized instance
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();
  final Map<String, bool> _favorites = {}; // productId -> isFavorited
  final Map<String, String> _favoriteIds = {}; // productId -> favoriteId
  bool _isLoading = false;
  final Map<String, bool> _loadingProducts = {}; // productId -> isLoading
  List<FavoriteProduct> _cachedFavorites = [];
  int _totalFavorites = 0;

  // ========== BASE URL ==========
  // Use centralized config
  static String get _baseUrl => Config.baseUrl;

  // ========== CONSTRUCTOR ==========
  FavoriteProvider();

  // ========== GETTERS ==========
  bool get isLoading => _isLoading;
  int get favoriteCount => _totalFavorites;
  List<FavoriteProduct> get cachedFavorites => _cachedFavorites;

  // Check if a specific product is loading
  bool isProductLoading(String productId) {
    return _loadingProducts[productId] ?? false;
  }

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
  /// POST /api/favorites (add)
  /// DELETE /api/favorites/:id (remove)
  /// Body: { serviceId } for POST
  Future<void> toggleFavorite(String serviceId) async {
    // Check if this specific product is already loading
    if (_loadingProducts[serviceId] == true) {
      log('⚠️ Toggle already in progress for: $serviceId');
      return;
    }

    // Set loading state for this specific product only
    _loadingProducts[serviceId] = true;
    notifyListeners();

    try {
      final token = _storage
          .getToken(); // getToken() is synchronous, no await needed

      if (token == null || token.isEmpty) {
        throw Exception('Please login to add favorites');
      }

      final isCurrentlyFavorited = _favorites[serviceId] ?? false;
      final favoriteId = _favoriteIds[serviceId];

      // If already favorited, remove it (DELETE)
      // API uses serviceId for both POST and DELETE, so we only need to check isCurrentlyFavorited
      if (isCurrentlyFavorited) {
        log(
          '🗑️ Removing favorite for service: $serviceId (favoriteId: $favoriteId)',
        );

        final url = Uri.parse('$_baseUrl/api/favorites/$serviceId');
        final client = http.Client();
        try {
          final response = await client
              .delete(
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

          log('📡 DELETE Response status: ${response.statusCode}');
          log('📡 DELETE Response body: ${response.body}');

          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);

            if (jsonData['success'] == true) {
              // Update local state - remove favorite
              _favorites.remove(serviceId);
              _favoriteIds.remove(serviceId);
              _cachedFavorites.removeWhere((fav) => fav.productId == serviceId);
              _totalFavorites =
                  jsonData['data']?['favoriteCount']?.toInt() ??
                  jsonData['data']?['total']?.toInt() ??
                  (_totalFavorites > 0 ? _totalFavorites - 1 : 0);

              log('✅ Favorite removed. Total: $_totalFavorites');
              log(
                '📋 Cached favorites after remove: ${_cachedFavorites.length}',
              );
              notifyListeners();
            } else {
              throw Exception(
                jsonData['message'] ?? 'Failed to remove favorite',
              );
            }
          } else {
            throw Exception(
              'Request failed with status: ${response.statusCode}',
            );
          }
        } finally {
          client.close();
        }
      } else {
        // Add favorite (POST)
        log('❤️ Adding favorite for service: $serviceId');

        final url = Uri.parse('$_baseUrl/api/favorites/$serviceId');
        final body = json.encode({'serviceId': serviceId});

        final client = http.Client();
        try {
          final response = await client
              .post(
                url,
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: body,
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception('Request timeout');
                },
              );

          log('📡 POST Response status: ${response.statusCode}');
          log('📡 POST Response body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            final jsonData = json.decode(response.body);

            if (jsonData['success'] == true || response.statusCode == 201) {
              final isFavorited = jsonData['data']?['isFavorited'] ?? true;
              final favoriteCount =
                  jsonData['data']?['favoriteCount'] ?? _totalFavorites + 1;
              final newFavoriteId =
                  jsonData['data']?['favoriteId']?.toString() ??
                  jsonData['data']?['_id']?.toString();

              // Update local state - add favorite
              _favorites[serviceId] = isFavorited;
              _totalFavorites = favoriteCount;

              if (newFavoriteId != null) {
                _favoriteIds[serviceId] = newFavoriteId;
              }

              log('✅ Favorite added. Total: $_totalFavorites');
              notifyListeners();
            } else {
              throw Exception(jsonData['message'] ?? 'Failed to add favorite');
            }
          } else {
            throw Exception(
              'Request failed with status: ${response.statusCode}',
            );
          }
        } finally {
          client.close();
        }
      }
    } catch (e) {
      log('❌ Toggle favorite error: $e');
      rethrow;
    } finally {
      // Clear loading state for this product
      _loadingProducts.remove(serviceId);
      notifyListeners();
    }
  }

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
              // ✅ Get data safely
              final data = jsonData['data'];

              if (data is Map<String, dynamic>) {
                // ✅ Get isFavorited from data object
                final isFavorited = data['isFavorited'];

                // Set favorite status (handle null as false)
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

  // // ✅ LOAD FAVORITE STATUS FOR MULTIPLE PRODUCTS
  // Future<void> loadFavoriteStatusForProducts(List<String> productIds) async {
  //   try {
  //     final token = _storage.getToken(); // getToken() is synchronous

  //     if (token == null || token.isEmpty) {
  //       log('⚠️ Skipping favorite status load - no token');
  //       return;
  //     }

  //     log('📋 Loading favorite status for ${productIds.length} products');

  //     for (var productId in productIds) {
  //       try {
  //         final url = Uri.parse('$_baseUrl/api/favorites/check/$productId');

  //         final response = await http.get(
  //           url,
  //           headers: {
  //             'Authorization': 'Bearer $token',
  //             'Content-Type': 'application/json',
  //           },
  //         );

  //         if (response.statusCode == 200) {
  //           final jsonData = json.decode(response.body);

  //           if (jsonData['success'] == true) {
  //             _favorites[productId] = jsonData['isFavorited'];

  //             if (jsonData['favoriteId'] != null) {
  //               _favoriteIds[productId] = jsonData['favoriteId'].toString();
  //             }

  //             log(
  //               '✅ Product $productId isFavorited: ${jsonData['isFavorited']}',
  //             );
  //           }
  //         }
  //       } catch (e) {
  //         log('⚠️ Error checking favorite for $productId: $e');
  //       }
  //     }

  //     notifyListeners();
  //   } catch (e) {
  //     log('❌ Error loading favorite status: $e');
  //   }
  // }

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
      final token = _storage.getToken(); // getToken() is synchronous

      if (token == null || token.isEmpty) {
        throw Exception('Please login to view favorites');
      }

      final url = Uri.parse('$_baseUrl/api/favorites?page=$page&limit=$limit');

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
          // API response structure: data.favorites
          final data = jsonData['data'] ?? {};
          final favorites = data['favorites'] as List<dynamic>? ?? [];
          final pagination = data['pagination'] ?? jsonData['pagination'] ?? {};

          _totalFavorites = pagination['total']?.toInt() ?? favorites.length;

          log('📊 Parsing ${favorites.length} favorites from API response');

          // Parse favorites - each favorite has serviceId object containing product data
          final newFavorites = favorites
              .map((fav) {
                try {
                  // Handle nested structure: fav has _id, userId, serviceId (object), createdAt
                  // The serviceId contains the actual product data
                  if (fav is Map<String, dynamic>) {
                    final serviceIdData = fav['serviceId'];
                    if (serviceIdData is Map<String, dynamic>) {
                      // Merge favorite metadata with product data
                      final favoriteData = {
                        ...serviceIdData,
                        '_favoriteId': fav['_id']?.toString() ?? '',
                        '_userId': fav['userId']?.toString() ?? '',
                        '_createdAt': fav['createdAt']?.toString() ?? '',
                      };
                      return FavoriteProduct.fromJson(favoriteData);
                    }
                  }
                  // Fallback to direct parsing
                  return FavoriteProduct.fromJson(fav);
                } catch (e) {
                  log('❌ Error parsing favorite: $e');
                  return null;
                }
              })
              .whereType<FavoriteProduct>()
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
  /// DELETE /api/favorites/:id
  /// Where :id is the favoriteId (not serviceId)
  Future<void> removeFromFavorites(String favoriteId) async {
    log('removeFromFavorites: -------- $favoriteId');
    try {
      final token = _storage.getToken(); // getToken() is synchronous

      if (token == null || token.isEmpty) {
        throw Exception('Please login to remove favorites');
      }

      log('🗑️ Removing favorite with ID: $favoriteId');

      final url = Uri.parse('$_baseUrl/api/favorites/$favoriteId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log('📡 Response status: ${response.statusCode}');
      log('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          // Find and remove by favoriteId
          final removedFavorite = _cachedFavorites.firstWhere(
            (fav) => fav.id == favoriteId,
            orElse: () => _cachedFavorites.first,
          );

          final serviceId = removedFavorite.productId;

          // Update local state
          _favorites.remove(serviceId);
          _favoriteIds.remove(serviceId);
          _cachedFavorites.removeWhere((fav) => fav.id == favoriteId);
          _totalFavorites =
              jsonData['data']?['favoriteCount'] ?? _totalFavorites - 1;

          log('✅ Removed from favorites: $favoriteId (serviceId: $serviceId)');
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

  // ✅ REMOVE FROM FAVORITES BY SERVICE ID (Helper method)
  /// Helper method to remove favorite using serviceId
  Future<void> removeFavoriteByServiceId(String serviceId) async {
    try {
      final favoriteId = _favoriteIds[serviceId];
      if (favoriteId != null) {
        await removeFromFavorites(favoriteId);
      } else {
        // Try to find in cached favorites
        final favorite = _cachedFavorites.firstWhere(
          (fav) => fav.productId == serviceId,
          orElse: () =>
              throw Exception('Favorite not found for service: $serviceId'),
        );
        await removeFromFavorites(favorite.id);
      }
    } catch (e) {
      log('❌ Remove favorite by serviceId error: $e');
      rethrow;
    }
  }

  // ✅ CLEAR ALL FAVORITES
  Future<void> clearAllFavorites() async {
    try {
      final token = _storage.getToken(); // getToken() is synchronous

      if (token == null || token.isEmpty) {
        throw Exception('Please login to clear favorites');
      }

      final url = Uri.parse('$_baseUrl/api/favorites/clear');

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
      final token = _storage.getToken(); // getToken() is synchronous

      if (token == null || token.isEmpty) {
        _totalFavorites = 0;
        return;
      }

      final url = Uri.parse('$_baseUrl/api/favorites/count');

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

  // ✅ SYNC INITIAL FAVORITE STATUS (from product model)
  /// Initialize favorite status from product data
  void syncInitialFavoriteStatus(
    String productId,
    bool isFavorited, {
    String? favoriteId,
  }) {
    // Only set if not already in map (to avoid overwriting server data)
    if (!_favorites.containsKey(productId)) {
      _favorites[productId] = isFavorited;
      if (favoriteId != null) {
        _favoriteIds[productId] = favoriteId;
      }
    }
  }

  // ✅ CLEAR ALL DATA (Logout)
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
