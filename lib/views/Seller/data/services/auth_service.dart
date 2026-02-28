// services/auth_service.dart
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  // services/auth_service.dart - Update register method to handle errors better
  // services/auth_service.dart - Update register method

  // services/auth_service.dart - Update register method
  Future<Map<String, dynamic>> register(
    UserModel user,
    Map<String, File?> files,
    String role,
  ) async {
    try {
      log(
        '[RegisterSeller] AuthService.register started, role=$role',
        name: 'RegisterSeller',
      );
      // Create form data WITHOUT role initially
      final formDataMap = user.toFormData();
      formDataMap.removeWhere((key, value) => value == null);

      // Seller: backend stores address in businessAddress; ensure we send it
      if (role == 'seller') {
        if (!formDataMap.containsKey('businessAddress') ||
            formDataMap['businessAddress'] == null ||
            formDataMap['businessAddress'].toString().trim().isEmpty) {
          final addressVal =
              user.address?.trim() ?? formDataMap['address']?.toString().trim();
          if (addressVal != null && addressVal.isNotEmpty) {
            formDataMap['businessAddress'] = addressVal;
            if (kDebugMode) {
              log(
                '[RegisterSeller] Added businessAddress to form: $addressVal',
                name: 'RegisterSeller',
              );
            }
          }
        }
      }
      if (role == 'buyer') {
        if (!formDataMap.containsKey('businessAddress') ||
            formDataMap['businessAddress'] == null ||
            formDataMap['businessAddress'].toString().trim().isEmpty) {
          final addressVal =
              user.address?.trim() ?? formDataMap['address']?.toString().trim();
          if (addressVal != null && addressVal.isNotEmpty) {
            formDataMap['businessAddress'] = addressVal;
          }
        }
      }

      final formData = FormData();

      // Add all fields except role
      for (final entry in formDataMap.entries) {
        if (entry.key != 'role' && entry.value != null) {
          formData.fields.add(MapEntry(entry.key, entry.value.toString()));
        }
      }
      // Add role last
      formData.fields.add(MapEntry('role', role));

      // Add files
      for (final entry in files.entries) {
        if (entry.value != null) {
          final file = entry.value!;
          final fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              entry.key,
              await MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        }
      }

      final response = await _dio.post(
        '/auth/register',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          validateStatus: (status) =>
              status! < 600, // Don't throw for 5xx errors
        ),
      );

      log(
        '[RegisterSeller] AuthService.register: API response received status=${response.statusCode}',
        name: 'RegisterSeller',
      );
      log('✅ API Response received');
      log('   Status: ${response.statusCode}');
      log('   Data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg =
            response.data?['errors'] ??
            response.data?['message'] ??
            'Registration failed with status ${response.statusCode}';
        throw errorMsg.toString();
      }

      // ✅ MUST RETURN HERE - This was missing!
      log(
        '[RegisterSeller] AuthService.register: returning success response',
        name: 'RegisterSeller',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log(
        '[RegisterSeller] AuthService.register: DioException - ${e.message}',
        name: 'RegisterSeller',
      );
      log('❌ Registration DioError:');
      log('   Type: ${e.type}');
      log('   Message: ${e.message}');
      log('   Status: ${e.response?.statusCode}');
      log('   Data: ${e.response?.data}');

      // Extract error message
      String errorMsg = 'Registration failed';

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMsg =
              data['errors']?.toString() ??
              data['message']?.toString() ??
              errorMsg;
        } else if (data is String) {
          errorMsg = data;
        }
      }

      throw errorMsg; // This is okay because it throws, doesn't return null
    } catch (e, stackTrace) {
      log(
        '[RegisterSeller] AuthService.register: catch - $e',
        name: 'RegisterSeller',
      );
      log(
        '[RegisterSeller] AuthService.register: StackTrace - $stackTrace',
        name: 'RegisterSeller',
      );
      log('❌ Registration error: $e');
      throw 'Registration error: $e'; // This throws, doesn't return null
    }
  }

  // services/auth_service.dart - Update login method

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('🔐 Login request:');
      print('   Email: $email');
      print('   Role: $role');

      final response = await _dio.post(
        '${Config.apiBaseUrl}/auth/login',
        data: {'email': email, 'password': password, 'role': role},
      );

      print('✅ Login response received:');
      print('   Status code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Data type: ${response.data.runtimeType}');

      // Log the actual response structure
      if (response.data is Map) {
        final data = response.data as Map;
        print('📊 Response structure:');
        data.forEach((key, value) {
          print('   $key: ${value.runtimeType}');
        });

        if (data['data'] != null && data['data'] is Map) {
          final responseData = data['data'] as Map;
          print('📊 Data structure:');
          responseData.forEach((key, value) {
            print('   $key: ${value.runtimeType}');

            if (key == 'user' && value is Map) {
              print('   👤 User fields:');
              value.forEach((k, v) {
                print('      $k: $v (${v.runtimeType})');
              });
            }
          });
        }
      }

      return response.data;
    } on DioException catch (e) {
      print('❌ Login DioError:');
      print('   Message: ${e.message}');
      print('   Response status: ${e.response?.statusCode}');
      print('   Response data: ${e.response?.data}');

      // Handle 302 redirects and other unexpected response types
      String errorMsg = 'Login failed';

      if (e.response?.statusCode == 302) {
        errorMsg =
            'Network redirect error. Please check your connection or contact support.';
      } else if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          errorMsg =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'Login failed';
        } else if (errorData is String) {
          // If it's HTML or plain text, extract meaningful message
          if (errorData.contains('302') || errorData.contains('redirect')) {
            errorMsg = 'Network redirect error. Please check your connection.';
          } else {
            errorMsg = errorData;
          }
        }
      } else if (e.message != null) {
        errorMsg = e.message!;
      }

      throw errorMsg;
    } catch (e) {
      print('❌ Login error: $e');
      throw 'Login error: $e';
    }
  }

  // ! Get user profile (after login)
  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('${Config.apiBaseUrl}/auth/me');
      return UserModel.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get profile';
    }
  }
}
