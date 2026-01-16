// services/buyer_product_service.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';

class BuyerProductService {
  final Dio _dio;
  final UnifiedLocalStorageServiceImpl _storage;

  BuyerProductService({Dio? dio, UnifiedLocalStorageServiceImpl? storage})
    : _dio = dio ?? locator<Dio>(),
      _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>();

  /// Fetch services/products from API
  /// GET /api/buyer/services?page=1&limit=10
  Future<List<BuyerProductModel>> getProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      log('🔄 Fetching products from API...');
      log('   Page: $page, Limit: $limit');

      final response = await _dio.get(
        '/buyer/services',
        queryParameters: {'page': page, 'limit': limit},
      );

      log('✅ API Response received');
      log('   Status: ${response.statusCode}');
      log(
        '   Data keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'N/A'}',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data;

        // API returns: { success: true, message: "...", data: { services: [...] } }
        if (data['data'] != null && data['data']['services'] != null) {
          final services = data['data']['services'];
          log('   Found ${services.length} services');

          return _parseProducts(services);
        } else {
          log('⚠️ No services found in response');
          return [];
        }
      } else {
        log('❌ API returned unsuccessful response');
        return [];
      }
    } on DioException catch (e) {
      log('❌ Dio Error fetching products:');
      log('   Type: ${e.type}');
      log('   Message: ${e.message}');
      log('   Status: ${e.response?.statusCode}');
      log('   Response: ${e.response?.data}');
      return [];
    } catch (error) {
      log('❌ Product Service Error: $error');
      return [];
    }
  }

  List<BuyerProductModel> _parseProducts(List<dynamic> productsJson) {
    return productsJson
        .map((json) {
          try {
            return BuyerProductModel.fromJson(json);
          } catch (e, stackTrace) {
            log('❌ Failed to parse product: $e');
            log('   Stack trace: $stackTrace');
            if (json is Map) {
              log('   JSON keys: ${json.keys.toList()}');
            } else {
              log('   JSON type: ${json.runtimeType}');
            }
            return null;
          }
        })
        .where((product) => product != null)
        .cast<BuyerProductModel>()
        .toList();
  }

  /// POST /api/visit-requests
  /// Body: { serviceId, description, address: {...}, preferredDate, preferredTime, specialRequirements }
  Future<Map<String, dynamic>> requestVisit({
    required String serviceId, // Changed from sellerId to serviceId
    String? description, // Changed from message to description
    Map<String, dynamic>? address, // NEW: Optional address object
    String? preferredDate,
    String? preferredTime,
    String? specialRequirements, // NEW: Optional special requirements
  }) async {
    try {
      log('🔍 Calling requestVisit (visit-requests) API...');
      log('   Service ID: $serviceId');
      log('   Description: $description');
      log('   Address: $address');
      log('   Preferred Date: $preferredDate');
      log('   Preferred Time: $preferredTime');
      log('   Special Requirements: $specialRequirements');

      final token = _storage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login to request a visit');
      }

      // Address is required by API (must have street, city, country)
      // If not provided, create default one to avoid validation errors
      final addressData =
          address ??
          {
            'street': 'To be confirmed',
            'city': 'To be specified',
            'country': 'Pakistan',
          };

      // Ensure required address fields exist
      if (!addressData.containsKey('street') || addressData['street'] == null) {
        addressData['street'] = 'To be confirmed';
      }
      if (!addressData.containsKey('city') || addressData['city'] == null) {
        addressData['city'] = 'To be specified';
      }
      if (!addressData.containsKey('country') ||
          addressData['country'] == null) {
        addressData['country'] = 'Pakistan';
      }

      final body = {
        'serviceId': serviceId,
        'address': addressData, // Always include address (required by API)
        if (description != null && description.isNotEmpty)
          'description': description,
        if (preferredDate != null && preferredDate.isNotEmpty)
          'preferredDate': preferredDate,
        if (preferredTime != null && preferredTime.isNotEmpty)
          'preferredTime': preferredTime,
        if (specialRequirements != null && specialRequirements.isNotEmpty)
          'specialRequirements': specialRequirements,
      };

      log('📦 Request Body: $body');
      log('📤 Endpoint: /api/visit-requests');

      final response = await _dio.post(
        '/visit-requests',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true || response.statusCode == 201) {
          log('✅ Visit request submitted successfully');
          return data is Map<String, dynamic>
              ? data
              : {'success': true, 'message': 'Visit request sent!'};
        } else {
          throw Exception(data['message'] ?? 'Failed to submit visit request');
        }
      } else {
        log('❌ HTTP ${response.statusCode}: ${response.data}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ Request visit Dio error: ${e.message}');
      log('   Status: ${e.response?.statusCode}');
      log('   Response: ${e.response?.data}');

      // Check for existing request error
      if (e.response?.statusCode == 400) {
        final responseData = e.response!.data;
        if (responseData is Map) {
          final message = responseData['message']?.toString() ?? '';
          if (message.toLowerCase().contains('already') ||
              message.toLowerCase().contains('existing') ||
              message.toLowerCase().contains('pending')) {
            return {
              'success': false,
              'hasExistingRequest': true,
              'message': message,
            };
          }
        }
      }

      // Extract error message
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map) {
          throw Exception(
            responseData['message']?.toString() ??
                e.message ??
                'Failed to submit visit request',
          );
        }
      }

      throw Exception(e.message ?? 'Failed to submit visit request');
    } catch (error) {
      log('❌ Request visit error: $error');
      rethrow;
    }
  }
}
