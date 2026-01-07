// // ! services/seller_auth_service.dart
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import 'package:wood_service/app/buyer_config.dart';
// import 'package:wood_service/app/config.dart';
// import 'package:wood_service/core/error/failure.dart';
// import 'package:wood_service/core/services/seller_local_storage_service.dart';
// import 'package:wood_service/views/Seller/data/models/seller_signup_model.dart';

// class SellerAuthService {
//   final Dio _dio;
//   final SellerLocalStorageService _localStorageService;

//   SellerAuthService(this._dio, this._localStorageService);

//   // ========== CHECK LOGIN STATUS ==========
//   Future<bool> isSellerLoggedIn() async {
//     try {
//       final token = await _localStorageService.getSellerToken();
//       final sellerData = await _localStorageService.getSellerData();

//       log('🔐 Checking seller login status...');
//       log('   Token exists: ${token != null && token.isNotEmpty}');
//       log(
//         '   Seller data exists: ${sellerData != null && sellerData.isNotEmpty}',
//       );

//       // We need BOTH token AND seller data to be logged in
//       if (token == null || token.isEmpty) {
//         log('🔐 No seller token found in storage');
//         return false;
//       }

//       if (sellerData == null || sellerData.isEmpty) {
//         log('🔐 No seller data found in storage');
//         return false;
//       }

//       // BOTH exist, so user is logged in
//       log('✅ Seller is logged in (token and data both exist)');
//       return true;
//     } catch (e) {
//       log('❌ Error checking login status: $e');
//       return false;
//     }
//   }

//   // Alias for isSellerLoggedIn
//   Future<bool> isLoggedIn() async {
//     return await isSellerLoggedIn();
//   }

//   // ========== GET CURRENT SELLER ==========
//   Future<SellerModel?> getCurrentSeller() async {
//     try {
//       final sellerData = await _localStorageService.getSellerData();
//       if (sellerData == null) return null;

//       // ✅ Make sure the ID field is present
//       if (!sellerData.containsKey('_id') && !sellerData.containsKey('id')) {
//         log('⚠️ Seller data missing ID field');
//         // Try to extract from token
//         final token = await _localStorageService.getSellerToken();
//         if (token != null) {
//           try {
//             final parts = token.split('.');
//             if (parts.length == 3) {
//               String payload = parts[1];
//               while (payload.length % 4 != 0) {
//                 payload += '=';
//               }
//               final decoded = utf8.decode(base64Url.decode(payload));
//               final payloadMap = jsonDecode(decoded);
//               final id = payloadMap['id']?.toString();
//               if (id != null) {
//                 sellerData['_id'] = id;
//                 sellerData['id'] = id;
//                 // Save back to storage
//                 await _localStorageService.saveSellerData(sellerData);
//               }
//             }
//           } catch (e) {
//             log('❌ Failed to extract ID from token: $e');
//           }
//         }
//       }

//       return SellerModel.fromJson(sellerData);
//     } catch (e) {
//       log('❌ Error getting current seller: $e');
//       return null;
//     }
//   }

//   // ========== GET SELLER TOKEN ==========
//   Future<String?> getSellerToken() async {
//     try {
//       return await _localStorageService.getSellerToken();
//     } catch (e) {
//       log('❌ Error getting seller token: $e');
//       return null;
//     }
//   }

//   // ========== PRIVATE METHODS ==========
//   Future<void> _saveSellerAuthData(String token, SellerModel seller) async {
//     try {
//       log('💾 Saving auth data to storage...');

//       // Save token
//       await _localStorageService.saveSellerToken(token);
//       log('   ✅ Token saved');

//       // ✅ Convert SellerModel to Map and ENSURE ID IS INCLUDED
//       final sellerMap = seller.toJson();

//       // Check if ID is missing and add it from token if needed
//       if ((!sellerMap.containsKey('_id') || sellerMap['_id'] == null) &&
//           (!sellerMap.containsKey('id') || sellerMap['id'] == null)) {
//         // Extract ID from JWT token
//         try {
//           final parts = token.split('.');
//           if (parts.length == 3) {
//             String payload = parts[1];
//             while (payload.length % 4 != 0) {
//               payload += '=';
//             }
//             final decoded = utf8.decode(base64Url.decode(payload));
//             final payloadMap = jsonDecode(decoded);
//             final tokenId = payloadMap['id']?.toString();

//             if (tokenId != null && tokenId.isNotEmpty) {
//               sellerMap['_id'] = tokenId;
//               sellerMap['id'] = tokenId;
//               log('   🔑 Extracted and added ID from token: $tokenId');
//             }
//           }
//         } catch (e) {
//           log('   ⚠️ Failed to extract ID from token: $e');
//         }
//       }

//       log('   💾 Seller data keys: ${sellerMap.keys.toList()}');
//       log('   💾 Seller ID: ${sellerMap['_id'] ?? sellerMap['id']}');

//       await _localStorageService.saveSellerData(sellerMap);
//       log('   ✅ Seller data saved (${sellerMap.length} fields)');

//       // Save login status
//       await _localStorageService.saveSellerLoginStatus(true);
//       log('   ✅ Login status saved');

//       // VERIFY: Read back to confirm
//       final savedToken = await _localStorageService.getSellerToken();
//       final savedData = await _localStorageService.getSellerData();

//       log('💾 VERIFICATION:');
//       log(
//         '   Token saved correctly: ${savedToken != null && savedToken.isNotEmpty}',
//       );
//       log('   Data saved correctly: ${savedData != null}');
//       if (savedData != null) {
//         log('   Data contains: ${savedData.keys.length} keys');
//         log(
//           '   Data has ID: ${savedData.containsKey('_id') || savedData.containsKey('id')}',
//         );
//         log('   ID value: ${savedData['_id'] ?? savedData['id']}');
//       }
//     } catch (e) {
//       log('❌ CRITICAL: Error saving auth data: $e');
//       rethrow;
//     }
//   }

//   // ========== REGISTER SELLER ==========
//   Future<Either<Failure, SellerAuthResponse>> registerSeller({
//     required SellerModel seller,
//   }) async {
//     try {
//       log('📤 Preparing seller registration...');

//       // Create FormData
//       final formData = FormData.fromMap({
//         'fullName': seller.personalInfo.fullName,
//         'email': seller.personalInfo.email,
//         'password': seller.personalInfo.password,
//         'confirmPassword': seller.personalInfo.password,
//         'phone': jsonEncode({
//           'countryCode': seller.personalInfo.countryCode,
//           'number': seller.personalInfo.phone.replaceFirst(
//             seller.personalInfo.countryCode,
//             '',
//           ),
//         }),
//         'businessName': seller.businessInfo.businessName,
//         'shopName': seller.businessInfo.shopName,
//         'businessDescription': seller.businessInfo.description,
//         'businessAddress': seller.businessInfo.address,
//         'categories': jsonEncode(seller.businessInfo.categories),
//         'bankName': seller.bankDetails.bankName,
//         'accountNumber': seller.bankDetails.accountNumber,
//         'iban': seller.bankDetails.iban,
//       });

//       int fileCount = 0;

//       // Add shop logo file
//       if (seller.shopBrandingImages.shopLogo != null) {
//         formData.files.add(
//           MapEntry(
//             'shopLogo',
//             await MultipartFile.fromFile(
//               seller.shopBrandingImages.shopLogo!.path,
//               filename: seller.shopBrandingImages.shopLogo!.path
//                   .split('/')
//                   .last,
//             ),
//           ),
//         );
//         fileCount++;
//       }

//       // Add shop banner file
//       if (seller.shopBrandingImages.shopBanner != null) {
//         formData.files.add(
//           MapEntry(
//             'shopBanner',
//             await MultipartFile.fromFile(
//               seller.shopBrandingImages.shopBanner!.path,
//               filename: seller.shopBrandingImages.shopBanner!.path
//                   .split('/')
//                   .last,
//             ),
//           ),
//         );
//         fileCount++;
//       }

//       // Add documents
//       if (seller.documentsImage.businessLicense != null) {
//         formData.files.add(
//           MapEntry(
//             'businessLicense',
//             await MultipartFile.fromFile(
//               seller.documentsImage.businessLicense!.path,
//               filename: seller.documentsImage.businessLicense!.path
//                   .split('/')
//                   .last,
//             ),
//           ),
//         );
//         fileCount++;
//       }

//       if (seller.documentsImage.taxCertificate != null) {
//         formData.files.add(
//           MapEntry(
//             'taxCertificate',
//             await MultipartFile.fromFile(
//               seller.documentsImage.taxCertificate!.path,
//               filename: seller.documentsImage.taxCertificate!.path
//                   .split('/')
//                   .last,
//             ),
//           ),
//         );
//         fileCount++;
//       }

//       if (seller.documentsImage.identityProof != null) {
//         formData.files.add(
//           MapEntry(
//             'identityProof',
//             await MultipartFile.fromFile(
//               seller.documentsImage.identityProof!.path,
//               filename: seller.documentsImage.identityProof!.path
//                   .split('/')
//                   .last,
//             ),
//           ),
//         );
//         fileCount++;
//       }

//       log('🚀 Sending registration request with $fileCount files...');

//       final response = await _dio.post(
//           Endpoints.sellerRegister,
//         data: formData,
//         options: Options(
//           contentType: 'multipart/form-data',
//           headers: {'Accept': 'application/json'},
//         ),
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final data = response.data;
//         log('✅ Registration successful! Response: $data');

//         final token = data['token'];
//         final sellerJson = data['seller'];

//         log('📝 Seller JSON keys: ${sellerJson?.keys.toList()}');
//         log('📝 Seller JSON: $sellerJson');

//         if (sellerJson != null) {
//           // Check if ID exists
//           final id = sellerJson['_id'] ?? sellerJson['id'];
//           log('🆔 Seller ID from response: $id');

//           if (id == null) {
//             log('⚠️ WARNING: Seller ID missing from API response!');
//           }
//         }
//         // ! ********

//         if (token == null || sellerJson == null) {
//           return Left(ServerFailure('Invalid response from server'));
//         }

//         // ✅ FIX: Parse the response seller (which should have ID)
//         final registeredSeller = SellerModel.fromJson(sellerJson);
//         log('📝 Registered seller ID: ${registeredSeller.id}');

//         await _saveSellerAuthData(token, registeredSeller);

//         final authResponse = SellerAuthResponse(
//           seller: registeredSeller,
//           token: token,
//           expiresAt: DateTime.now().add(const Duration(days: 7)),
//         );

//         return Right(authResponse);
//       } else {
//         return Left(
//           ServerFailure('Registration failed: ${response.data['message']}'),
//         );
//       }
//     } on DioException catch (e) {
//       log('❌ Dio error: ${e.message}');

//       if (e.response?.statusCode == 400) {
//         return Left(
//           ValidationFailure(e.response?.data['message'] ?? 'Invalid data'),
//         );
//       }
//       if (e.response?.statusCode == 409) {
//         return Left(AuthFailure('Seller already exists with this email'));
//       }
//       return Left(ServerFailure('Network error: ${e.message}'));
//     } catch (e) {
//       log('❌ Unexpected error: $e');
//       return Left(UnknownFailure('Unexpected error: $e'));
//     }
//   }

//   // In loginSeller method
//   Future<Either<Failure, SellerAuthResponse>> loginSeller({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       log('🔐 Attempting login for: $email');

//       final response = await _dio.post(
//           Endpoints.sellerLogin,
//         // '/api/seller/auth/login',
//         data: {'email': email.trim(), 'password': password},
//         options: Options(
//           contentType: 'application/json',
//           validateStatus: (status) => status! < 500,
//         ),
//       );

//       // In loginSeller method
//       if (response.statusCode == 200) {
//         final data = response.data;
//         final token = data['token'];
//         final sellerJson = data['seller'];

//         log('📝 Login response seller data keys: ${sellerJson.keys.toList()}');
//         log('📝 Seller JSON: $sellerJson');

//         if (token == null || sellerJson == null) {
//           return Left(AuthFailure('Invalid server response'));
//         }

//         // Try to extract ID from token first
//         String? tokenId;
//         try {
//           final parts = token.split('.');
//           if (parts.length == 3) {
//             String payload = parts[1];
//             while (payload.length % 4 != 0) {
//               payload += '=';
//             }
//             final decoded = utf8.decode(base64Url.decode(payload));
//             final payloadMap = jsonDecode(decoded);
//             tokenId = payloadMap['id']?.toString();
//             log('🔑 ID from JWT token: $tokenId');
//           }
//         } catch (e) {
//           log('❌ Failed to extract ID from token: $e');
//         }

//         // ✅ Add ID to sellerJson if missing
//         if (tokenId != null && tokenId.isNotEmpty) {
//           if (!sellerJson.containsKey('_id') && !sellerJson.containsKey('id')) {
//             sellerJson['_id'] = tokenId;
//             sellerJson['id'] = tokenId;
//             log('✅ Added ID to seller JSON: $tokenId');
//           }
//         }

//         // ✅ Parse seller (now with ID field)
//         final seller = SellerModel.fromJson(sellerJson);

//         // ✅ Log the ID
//         log('✅ Seller ID: ${seller.id}');
//         log('✅ Seller personalInfo ID: ${seller.personalInfo.id}');

//         // Save to storage
//         await _saveSellerAuthData(token, seller);

//         final authResponse = SellerAuthResponse(
//           seller: seller,
//           token: token,
//           expiresAt: DateTime.now().add(const Duration(days: 7)),
//         );

//         log('✅ Login successful for: ${seller.personalInfo.fullName}');
//         log('   ID: ${seller.id}');
//         log('   Email: ${seller.personalInfo.email}');

//         return Right(authResponse);
//       } else if (response.statusCode == 401) {
//         final message = response.data['message'] ?? 'Invalid email or password';
//         return Left(AuthFailure(message));
//       } else if (response.statusCode == 404) {
//         return Left(AuthFailure('Seller not found'));
//       } else {
//         return Left(ServerFailure('Login failed: ${response.data['message']}'));
//       }
//     } on DioException catch (e) {
//       log('❌ Dio error during login: ${e.message}');

//       if (e.response?.statusCode == 401) {
//         return Left(AuthFailure('Invalid email or password'));
//       }
//       return Left(NetworkFailure('Network error: ${e.message}'));
//     } catch (e) {
//       log('❌ Unexpected login error: $e');
//       return Left(UnknownFailure('Unexpected error: $e'));
//     }
//   }

//   // ========== LOGOUT ==========
//   Future<void> logout() async {
//     try {
//       log('🚪 Logging out seller...');
//       await _localStorageService.sellerLogout();
//       log('✅ Seller logged out successfully');
//     } catch (e) {
//       log('❌ Error logging out: $e');
//       rethrow;
//     }
//   }


//   // ========== GET SELLER PROFILE ==========
//   Future<Either<Failure, SellerModel>> getSellerProfile() async {
//     try {
//       log('👤 Fetching seller profile...');

//       final token = await _localStorageService.getSellerToken();
//       if (token == null) {
//         return Left(AuthFailure('Not authenticated'));
//       }

//       final response = await _dio.get(
//         // '/api/seller/auth/profile',
//           Endpoints.sellerProfile,
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );

//       if (response.statusCode == 200) {
//         final sellerJson = response.data['seller'];
//         if (sellerJson == null) {
//           return Left(ServerFailure('Invalid response from server'));
//         }

//         final seller = SellerModel.fromJson(sellerJson);

//         // Update local storage with fresh data
//         await _localStorageService.saveSellerData(seller.toJson());

//         log('✅ Profile fetched successfully: ${seller.personalInfo.fullName}');
//         return Right(seller);
//       } else {
//         return Left(ServerFailure('Failed to fetch profile'));
//       }
//     } on DioException catch (e) {
//       log('❌ Dio error fetching profile: ${e.message}');
//       return Left(NetworkFailure('Network error: ${e.message}'));
//     } catch (e) {
//       log('❌ Unexpected error: $e');
//       return Left(UnknownFailure('Unexpected error: $e'));
//     }
//   }

//   // ! ========== UPDATE SELLER PROFILE ==========
//   Future<Map<String, dynamic>> updateProfile({
//     required Map<String, dynamic> updates,
//     File? shopLogo,
//     File? shopBanner,
//     File? businessLicense,
//     File? taxCertificate,
//     File? identityProof,
//   }) async {
//     try {
//       final token = await getSellerToken();
//       if (token == null) {
//         return {'success': false, 'message': 'Not authenticated'};
//       }

//       log('111');
//       // ! Create FormData for multipart request
//       final formData = FormData.fromMap(updates);
//       log('2222');

//       // ! Add files if provided
//       if (shopLogo != null) {
//         formData.files.add(
//           MapEntry(
//             'shopLogo',
//             await MultipartFile.fromFile(
//               shopLogo.path,
//               filename: shopLogo.path.split('/').last,
//             ),
//           ),
//         );
//       }

//       if (shopBanner != null) {
//         formData.files.add(
//           MapEntry(
//             'shopBanner',
//             await MultipartFile.fromFile(
//               shopBanner.path,
//               filename: shopBanner.path.split('/').last,
//             ),
//           ),
//         );
//       }

//       if (businessLicense != null) {
//         formData.files.add(
//           MapEntry(
//             'businessLicense',
//             await MultipartFile.fromFile(
//               businessLicense.path,
//               filename: businessLicense.path.split('/').last,
//             ),
//           ),
//         );
//       }

//       if (taxCertificate != null) {
//         formData.files.add(
//           MapEntry(
//             'taxCertificate',
//             await MultipartFile.fromFile(
//               taxCertificate.path,
//               filename: taxCertificate.path.split('/').last,
//             ),
//           ),
//         );
//       }

//       if (identityProof != null) {
//         formData.files.add(
//           MapEntry(
//             'identityProof',
//             await MultipartFile.fromFile(
//               identityProof.path,
//               filename: identityProof.path.split('/').last,
//             ),
//           ),
//         );
//       }

//       log('🔄 Updating seller profile...');

//       final response = await _dio.put(
//         '${Config.apiBaseUrl}/api/seller/auth/profileUpdate',

//         data: formData,
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Accept': 'application/json',
//           },
//           contentType: 'multipart/form-data',
//         ),
//       );
//       log('333');

//       log('📥 Update response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = response.data;

//         // ! Update local storage with new seller data
//         if (data['seller'] != null) {
//           final updatedSeller = SellerModel.fromJson(data['seller']);
//           await _saveSellerAuthData(token, updatedSeller);
//         }

//         log('✅ Profile updated successfully');
//         return {
//           'success': true,
//           'message': 'Profile updated successfully',
//           'data': data,
//         };
//       } else {
//         log('❌ Update failed: ${response.data}');
//         return {
//           'success': false,
//           'message': response.data['message'] ?? 'Update failed',
//         };
//       }
//     } on DioException catch (e) {
//       log('❌ Dio error updating profile: ${e.message}');
//       log('❌ Response: ${e.response?.data}');

//       return {
//         'success': false,
//         'message':
//             e.response?.data?['message'] ?? 'Network error: ${e.message}',
//       };
//     } catch (e) {
//       log('❌ Unexpected error updating profile: $e');
//       return {'success': false, 'message': 'Update failed: $e'};
//     }
//   }

//   // ! ! ********* Update ???
// }

// class SellerAuthResponse {
//   final SellerModel seller;
//   final String token;
//   final DateTime? expiresAt;

//   SellerAuthResponse({
//     required this.seller,
//     required this.token,
//     this.expiresAt,
//   });
// }




//   // // ========== FORGOT PASSWORD ==========
//   // Future<Either<Failure, void>> forgotPassword(String email) async {
//   //   try {
//   //     log('🔐 Sending password reset request for: $email');

//   //     final response = await _dio.post(
//   //       '/api/seller/auth/forgot-password',
//   //       data: {'email': email.trim()},
//   //     );

//   //     if (response.statusCode == 200) {
//   //       log('✅ Password reset email sent to: $email');
//   //       return const Right(null);
//   //     } else {
//   //       return Left(ServerFailure('Failed to send reset email'));
//   //     }
//   //   } on DioException catch (e) {
//   //     log('❌ Dio error during password reset: ${e.message}');
//   //     return Left(NetworkFailure('Network error: ${e.message}'));
//   //   } catch (e) {
//   //     log('❌ Unexpected error: $e');
//   //     return Left(UnknownFailure('Unexpected error: $e'));
//   //   }
//   // }

//   // // ========== RESET PASSWORD ==========
//   // Future<Either<Failure, void>> resetPassword({
//   //   required String token,
//   //   required String newPassword,
//   // }) async {
//   //   try {
//   //     log('🔐 Resetting password...');

//   //     final response = await _dio.post(
//   //       '/api/seller/auth/reset-password',
//   //       data: {'token': token, 'newPassword': newPassword},
//   //     );

//   //     if (response.statusCode == 200) {
//   //       log('✅ Password reset successfully');
//   //       return const Right(null);
//   //     } else {
//   //       return Left(ServerFailure('Failed to reset password'));
//   //     }
//   //   } on DioException catch (e) {
//   //     log('❌ Dio error during password reset: ${e.message}');
//   //     return Left(NetworkFailure('Network error: ${e.message}'));
//   //   } catch (e) {
//   //     log('❌ Unexpected error: $e');
//   //     return Left(UnknownFailure('Unexpected error: $e'));
//   //   }
//   // }

//   // // ========== REFRESH TOKEN ==========
//   // Future<Either<Failure, String>> refreshToken() async {
//   //   try {
//   //     log('🔄 Refreshing token...');

//   //     final currentToken = await _localStorageService.getSellerToken();
//   //     if (currentToken == null) {
//   //       return Left(AuthFailure('No token found'));
//   //     }

//   //     final response = await _dio.post(
//   //       '/api/seller/auth/refresh-token',
//   //       data: {'token': currentToken},
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final newToken = response.data['token'];
//   //       if (newToken == null) {
//   //         return Left(AuthFailure('Invalid response from server'));
//   //       }

//   //       // Save new token
//   //       await _localStorageService.saveSellerToken(newToken);
//   //       log('✅ Token refreshed successfully');

//   //       return Right(newToken);
//   //     } else {
//   //       return Left(AuthFailure('Failed to refresh token'));
//   //     }
//   //   } on DioException catch (e) {
//   //     log('❌ Dio error during token refresh: ${e.message}');
//   //     return Left(NetworkFailure('Network error: ${e.message}'));
//   //   } catch (e) {
//   //     log('❌ Unexpected error: $e');
//   //     return Left(UnknownFailure('Unexpected error: $e'));
//   //   }
//   // }

