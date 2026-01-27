// services/uploaded_product_services.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart';

class UploadedProductService {
  final Dio _dio;
  final UnifiedLocalStorageServiceImpl _storage;

  UploadedProductService({Dio? dio, UnifiedLocalStorageServiceImpl? storage})
    : _dio = dio ?? locator<Dio>(),
      _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>();

  /// GET /api/seller/services
  /// Query params: page, limit, status
  Future<Map<String, dynamic>> getUploadedProducts({
    int page = 1,
    int limit = 10,
    String? status, // 'active', 'inactive', etc.
  }) async {
    try {
      log('📦 Fetching uploaded products...');
      log('   Page: $page, Limit: $limit, Status: $status');

      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to view your products');
      }

      // Build query parameters
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/seller/services',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Parse services
          final servicesData = data['data']?['services'] ?? [];
          final services = (servicesData as List)
              .map((json) => UploadedProductModel.fromJson(json))
              .toList();

          // Parse pagination info
          final pagination = data['data']?['pagination'] ?? {};
          final total = pagination['total'] ?? services.length;
          final totalPages = pagination['totalPages'] ?? 1;
          final currentPage = pagination['currentPage'] ?? page;

          log('✅ Loaded ${services.length} products (Total: $total)');

          return {
            'success': true,
            'services': services,
            'pagination': {
              'total': total,
              'totalPages': totalPages,
              'currentPage': currentPage,
              'limit': limit,
            },
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error fetching products: ${e.message}');
      log('   Status: ${e.response?.statusCode}');
      log('   Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Products not found');
      } else {
        final errorMsg =
            e.response?.data?['message']?.toString() ??
            e.message ??
            'Failed to load products';
        throw Exception(errorMsg);
      }
    } catch (e) {
      log('❌ Error fetching products: $e');
      rethrow;
    }
  }

  /// GET /api/seller/services/:id - Get single product for editing
  Future<UploadedProductModel> getProductById(String productId) async {
    try {
      log('📦 Fetching product: $productId');

      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to view product');
      }

      final response = await _dio.get(
        '/seller/services/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final serviceData =
              data['data']?['service'] ?? data['service'] ?? data['data'];
          final product = UploadedProductModel.fromJson(serviceData);
          log('✅ Product loaded successfully');
          return product;
        } else {
          throw Exception(data['message'] ?? 'Failed to load product');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error fetching product: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to load product';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error fetching product: $e');
      rethrow;
    }
  }

  /// PUT /api/seller/services/:id - Update product
  Future<bool> updateProduct({
    required String productId,
    required Map<String, dynamic> productData,
    List<Map<String, dynamic>>? images,
  }) async {
    try {
      log('📝 Updating product: $productId');

      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to update products');
      }

      // Prepare FormData
      final formData = FormData();

      // Add all text fields
      productData.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            // Handle arrays (tags, variants)
            formData.fields.add(MapEntry(key, jsonEncode(value)));
          } else if (value is Map) {
            // Handle objects (dimensions)
            formData.fields.add(MapEntry(key, jsonEncode(value)));
          } else {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        }
      });

      // Add images if provided
      if (images != null && images.isNotEmpty) {
        for (var imageData in images) {
          if (imageData['file'] != null) {
            final file = imageData['file'] as File;
            formData.files.add(
              MapEntry(
                'images',
                await MultipartFile.fromFile(
                  file.path,
                  filename: imageData['filename'] ?? 'image.jpg',
                ),
              ),
            );
          }
        }
      }

      final response = await _dio.put(
        '/seller/services/$productId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          log('✅ Product updated successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to update product');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error updating product: ${e.message}');
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to update product';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error updating product: $e');
      rethrow;
    }
  }

  /// DELETE /api/seller/services/:id/images - Delete product image
  Future<bool> deleteProductImage(String productId, String imageUrl) async {
    try {
      log('🗑️ Deleting product image: $imageUrl');

      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to delete images');
      }

      final response = await _dio.delete(
        '/seller/services/$productId/images',
        data: {'imageUrl': imageUrl},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          log('✅ Image deleted successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to delete image');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error deleting image: ${e.message}');
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to delete image';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error deleting image: $e');
      rethrow;
    }
  }

  /// DELETE /api/seller/services/:id
  Future<bool> deleteProduct(String productId) async {
    try {
      log('🗑️ Deleting product: $productId');

      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login to delete products');
      }

      final response = await _dio.delete(
        '/seller/services/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          log('✅ Product deleted successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to delete product');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Dio error deleting product: ${e.message}');
      final errorMsg =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to delete product';
      throw Exception(errorMsg);
    } catch (e) {
      log('❌ Error deleting product: $e');
      rethrow;
    }
  }
}
