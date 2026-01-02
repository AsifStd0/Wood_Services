// lib/services/buyer_auth_service.dart
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_model.dart';
import 'package:wood_service/views/Buyer/Service/buyer_local_storage_service.dart';

class BuyerAuthService {
  final Dio _dio;
  final BuyerLocalStorageService _buyerLocalStorageService; // Changed this

  BuyerAuthService(this._dio, this._buyerLocalStorageService);

  // Register Buyer - Updated for your Node.js API
  Future<Map<String, dynamic>> registerBuyerServices({
    required BuyerModel buyer,
    File? profileImage,
  }) async {
    try {
      log('📤 Preparing buyer registration for Node.js API...');

      // Create FormData matching your Node.js API structure
      final formData = FormData.fromMap({
        'fullName': buyer.fullName,
        'email': buyer.email,
        'password': buyer.password,
        'confirmPassword': buyer.password, // API expects confirmPassword
        'businessName': buyer.businessName ?? '',
        'contactName': buyer.contactName ?? '',
        'address': buyer.address ?? '',
        'description': buyer.description ?? '',
        'bankName': buyer.bankName ?? '',
        'iban': buyer.iban ?? '',
      });

      // Add profile image if exists - field name must match your API
      if (profileImage != null && profileImage.path.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'profileImage', // This must match your multer field name
            await MultipartFile.fromFile(
              profileImage.path,
              filename:
                  'profileImage-${DateTime.now().millisecondsSinceEpoch}${_getFileExtension(profileImage.path)}',
            ),
          ),
        );
        log('📸 Added profile image: ${profileImage.path}');
      }

      // Log the data being sent
      log('🚀 Sending to /api/buyer/auth/register');
      log('Form fields:');
      formData.fields.forEach((field) {
        log('  ${field.key}: ${field.value}');
      });
      log('Files: ${formData.files.length}');

      final response = await _dio.post(
        '/api/buyer/auth/register',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );

      log('📥 Response status: ${response.statusCode}');
      log('📥 Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        log('✅ Registration successful!');

        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Registration failed');
        }

        final token = data['token'];
        final buyerJson = data['buyer'];

        if (token == null || buyerJson == null) {
          throw Exception('Invalid response from server');
        }

        // Map the response to your BuyerModel
        final registeredBuyer = BuyerModel(
          id: buyerJson['id'] ?? buyerJson['_id'],
          fullName: buyerJson['fullName'] ?? '',
          email: buyerJson['email'] ?? '',
          // password: '', // Don't store password
          businessName: buyerJson['businessName'],
          contactName: buyerJson['contactName'],
          address: buyerJson['address'],
          description: buyerJson['description'],
          bankName: buyerJson['bankName'],
          iban: buyerJson['iban'],
          profileImagePath: buyerJson['profileImage']?['url'],
          profileCompleted: true,
          isActive: true,
        );

        // Save auth data
        await _saveBuyerAuthData(token, buyerJson);

        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'buyer': registeredBuyer,
          'token': token,
        };
      } else {
        throw Exception(
          response.data['message'] ??
              'Registration failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('❌ Dio error: ${e.message}');
      log('❌ Response status: ${e.response?.statusCode}');
      log('❌ Response data: ${e.response?.data}');

      String errorMessage = 'Network error occurred';

      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data['message'] ?? 'Invalid data provided';
      } else if (e.response?.statusCode == 401) {
        errorMessage = e.response?.data['message'] ?? 'Unauthorized';
      } else if (e.response?.statusCode == 409) {
        errorMessage = 'Buyer already exists with this email';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout.';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error': e.response?.data,
      };
    } catch (e) {
      log('❌ Unexpected error: $e');
      return {'success': false, 'message': 'Unexpected error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> loginBuyer({
    required String email,
    required String password,
  }) async {
    try {
      log('🔐 Attempting login for: $email');

      final response = await _dio.post(
        '/api/buyer/auth/login',
        data: {'email': email.trim(), 'password': password},
        options: Options(
          contentType: 'application/json',
          validateStatus: (status) => status! < 500,
        ),
      );

      log('📥 Login response: ${response.statusCode}');
      log('📥 Login data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == false) {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }

        final token = data['token'];
        final buyerJson = data['buyer'];

        // ✅ ADDED: Log what fields we're getting from login
        log('🔍 Login API returns these buyer fields:');
        if (buyerJson != null && buyerJson is Map) {
          buyerJson.forEach((key, value) {
            log('   $key: $value');
          });
          log('🔍 Total fields from login: ${buyerJson.length}');
        }

        if (token == null || buyerJson == null) {
          throw Exception('Invalid server response');
        }

        // ✅ Save initial auth data (partial)
        await _saveBuyerAuthData(token, buyerJson as Map<String, dynamic>);

        // ✅ CRITICAL: Fetch COMPLETE profile data after login
        log('🔄 Fetching complete buyer profile after login...');
        final completeProfileResult = await getBuyerProfile();

        if (completeProfileResult['success'] == true) {
          // ✅ Check the type of buyer in the result
          final buyer = completeProfileResult['buyer'];

          if (buyer is BuyerModel) {
            // ✅ Already a BuyerModel object
            log('✅ Got complete profile as BuyerModel');

            // Convert BuyerModel back to JSON for storage
            final buyerJsonForStorage = buyer.toJson();

            // ✅ Update local storage with COMPLETE data
            await _buyerLocalStorageService.saveBuyerData(buyerJsonForStorage);

            log('✅ Login successful for: ${buyer.fullName}');
            log('🔍 Complete buyer data after fetch:');
            log('   Address: ${buyer.address}');
            log('   Description: ${buyer.description}');
            log('   Bank: ${buyer.bankName}');
            log('   IBAN: ${buyer.iban}');

            return {
              'success': true,
              'message': data['message'] ?? 'Login successful',
              'buyer': buyer,
              'token': token,
            };
          } else {
            // Fallback - use login data
            log('⚠️ Complete profile is not BuyerModel, using login data');
            final buyer = BuyerModel.fromJson(
              buyerJson as Map<String, dynamic>,
            );

            return {
              'success': true,
              'message': data['message'] ?? 'Login successful',
              'buyer': buyer,
              'token': token,
            };
          }
        } else {
          // Fallback to partial data if complete fetch fails
          log('⚠️ Could not fetch complete profile, using login data');
          final buyer = BuyerModel.fromJson(buyerJson as Map<String, dynamic>);

          return {
            'success': true,
            'message': data['message'] ?? 'Login successful',
            'buyer': buyer,
            'token': token,
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Invalid email or password',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Invalid request',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      log('❌ Dio error during login: ${e.message}');
      log('❌ Response: ${e.response?.data}');

      String errorMessage = 'Network error occurred';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout.';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      log('❌ Unexpected login error: $e');
      return {'success': false, 'message': 'Unexpected error occurred'};
    }
  }

  // Add this method to BuyerAuthService
  Future<bool> refreshBuyerData() async {
    try {
      final token = await getBuyerToken();
      if (token == null) {
        log('❌ No token found for refresh');
        return false;
      }

      log('🔄 Refreshing buyer data from server...');

      final response = await _dio.get(
        '/api/buyer/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['buyer'] != null) {
          final buyerJson = data['buyer'] as Map<String, dynamic>;

          log('✅ Got fresh buyer data with ${buyerJson.length} fields');
          log('🔍 Fields: ${buyerJson.keys.toList()}');

          // Save to local storage
          await _buyerLocalStorageService.saveBuyerData(buyerJson);

          return true;
        }
      }

      return false;
    } catch (e) {
      log('❌ Error refreshing buyer data: $e');
      return false;
    }
  } // Get Buyer Profile - UPDATED to save data

  // In your BuyerAuthService class
  Future<Map<String, dynamic>> getBuyerProfile() async {
    try {
      final token = await _buyerLocalStorageService.getBuyerToken();

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await _dio.get(
        '/api/buyer/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      log('🔍 GET /api/buyer/auth/profile response:');
      log('🔍 Success: ${response.data['success']}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data;
        final buyerJson = data['buyer'];

        if (buyerJson != null && buyerJson is Map) {
          log('🔍 Buyer fields count: ${buyerJson.length}');
          log('🔍 All fields: ${buyerJson.keys.toList()}');

          // ✅ Parse to BuyerModel FIRST
          final buyer = BuyerModel.fromJson(buyerJson as Map<String, dynamic>);

          return {
            'success': true,
            'message': data['message'] ?? 'Profile fetched',
            'buyer': buyer, // ✅ Return BuyerModel object, not raw JSON
          };
        }
      }

      return {'success': false, 'message': 'Failed to fetch profile'};
    } catch (e) {
      log('❌ Error fetching buyer profile: $e');
      return {'success': false, 'message': 'Error fetching profile: $e'};
    }
  }

  // Update Buyer Profile
  Future<Map<String, dynamic>> updateBuyerProfile({
    required Map<String, dynamic> updates,
    File? profileImage,
  }) async {
    try {
      final token = await getBuyerToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final formData = FormData.fromMap(updates);

      if (profileImage != null && profileImage.path.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'profileImage',
            await MultipartFile.fromFile(
              profileImage.path,
              filename:
                  'profileImage-${DateTime.now().millisecondsSinceEpoch}${_getFileExtension(profileImage.path)}',
            ),
          ),
        );
      }

      final response = await _dio.put(
        '/api/buyer/auth/profile',
        data: formData,
        options: Options(
          contentType: profileImage != null
              ? 'multipart/form-data'
              : 'application/json',
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Profile updated successfully',
            'buyer': BuyerModel.fromJson(data['buyer']),
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to update profile',
          };
        }
      } else {
        return {'success': false, 'message': 'Failed to update profile'};
      }
    } on DioException catch (e) {
      log('❌ Error updating profile: ${e.message}');
      return {'success': false, 'message': 'Network error updating profile'};
    } catch (e) {
      log('❌ Unexpected error updating profile: $e');
      return {'success': false, 'message': 'Unexpected error'};
    }
  }

  // Update getBuyerToken method:
  Future<String?> getBuyerToken() async {
    try {
      final token = await _buyerLocalStorageService.getBuyerToken();
      return token;
    } catch (e) {
      log('❌ Error getting buyer token: $e');
      return null;
    }
  }

  // Update logout method:
  Future<void> logout() async {
    try {
      log('🚪 Logging out buyer...');

      // Use buyerLocalStorageService methods
      await _buyerLocalStorageService.buyerLogout();

      // Clear token from Dio headers
      _dio.options.headers.remove('Authorization');

      log('✅ Buyer logged out successfully');
    } catch (e) {
      log('❌ Error during logout: $e');
      throw Exception('Logout failed: $e');
    }
  }

  // Update isBuyerLoggedIn method:
  Future<bool> isBuyerLoggedIn() async {
    try {
      return await _buyerLocalStorageService.isBuyerLoggedIn();
    } catch (e) {
      log('❌ Error checking login status: $e');
      return false;
    }
  }

  // // Update getCurrentBuyer method:
  // Future<BuyerModel?> getCurrentBuyerData() async {
  //   try {
  //     final buyerData = await _buyerLocalStorageService.getBuyerData();
  //     if (buyerData == null) return null;

  //     return BuyerModel.fromJson(buyerData);
  //   } catch (e) {
  //     log('❌ Error getting current buyer: $e');
  //     return null;
  //   }
  // }

  // Make sure this method accepts Map<String, dynamic>
  Future<void> _saveBuyerAuthData(
    String token,
    Map<String, dynamic> buyerJson,
  ) async {
    try {
      log('💾 Saving buyer auth data...');
      log('🔍 Raw API response buyerJson:');
      buyerJson.forEach((key, value) {
        log('   $key: $value');
      });

      // ✅ Save token
      await _buyerLocalStorageService.saveBuyerToken(token);
      log('💾 Buyer: Saving token');

      // ✅ Save buyer data
      await _buyerLocalStorageService.saveBuyerData(buyerJson);
      log('💾 Buyer: Saving data');

      // ✅ Save login status
      await _buyerLocalStorageService.saveBuyerLoginStatus(true);
      log('💾 Buyer: Login status: true');

      // ✅ Save last login timestamp
      await _buyerLocalStorageService.saveBuyerLastLogin();
      log('💾 Buyer: Last login saved');

      log('✅ Buyer auth data saved');
    } catch (e) {
      log('❌ Error saving buyer auth data: $e');
      rethrow;
    }
  }

  // Helper method to get file extension
  String _getFileExtension(String path) {
    final ext = path.split('.').last;
    return '.$ext';
  }
}
