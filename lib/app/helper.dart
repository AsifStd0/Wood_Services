import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

// Global auth state - Now using unified system
bool isUserLoggedIn = false;
String? userRole;
String? workingServerUrl;

Future<Map<String, dynamic>> checkAuthStatus() async {
  try {
    log('🔐 ========== CHECKING AUTH STATUS (UNIFIED) ==========');

    // Get storage service
    final storage = locator<UnifiedLocalStorageServiceImpl>();

    // Check if user is logged in
    isUserLoggedIn = storage.isLoggedIn();
    userRole = storage.getUserRole();

    log('📱 User logged in: $isUserLoggedIn');
    log('👤 User role: $userRole');

    // If user is logged in, fetch fresh data from API and check if account is active
    if (isUserLoggedIn) {
      final token = storage.getToken();

      if (token != null && token.isNotEmpty) {
        try {
          log('🔄 Fetching fresh user data from API...');

          // Fetch fresh user data from API
          final dio = locator<Dio>();
          // Try '/auth/me' first (common endpoint), fallback to '/auth/profile'
          final response = await dio.get(
            '/auth/me', // Most common endpoint for getting current user
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            ),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Parse response - handle different response structures
            Map<String, dynamic> userData;

            if (response.data['data'] != null &&
                response.data['data']['user'] != null) {
              userData = response.data['data']['user'] as Map<String, dynamic>;
            } else if (response.data['user'] != null) {
              userData = response.data['user'] as Map<String, dynamic>;
            } else if (response.data['success'] == true &&
                response.data['buyer'] != null) {
              userData = response.data['buyer'] as Map<String, dynamic>;
            } else if (response.data['success'] == true &&
                response.data['seller'] != null) {
              userData = response.data['seller'] as Map<String, dynamic>;
            } else {
              userData = response.data as Map<String, dynamic>;
            }

            log('📊 Fresh API user data received:');
            log('   Fields: ${userData.keys.toList()}');
            log('   Values: ${userData.values.toList()}');

            // Check if account is active (for both buyer and seller)
            final isActiveValue = userData['isActive'];

            // Handle different types: bool, string, int
            bool isActive = true; // Default to true if not found
            if (isActiveValue != null) {
              if (isActiveValue is bool) {
                isActive = isActiveValue;
              } else if (isActiveValue is String) {
                isActive = isActiveValue.toLowerCase() == 'true';
              } else if (isActiveValue is int) {
                isActive = isActiveValue == 1;
              } else {
                // Try to parse as bool
                isActive = isActiveValue == true;
              }
            }

            log('🔍 Checking account status from API:');
            log(
              '   isActive value: $isActiveValue (Type: ${isActiveValue.runtimeType})',
            );
            log('   Parsed isActive: $isActive');
            log('   User role: $userRole');

            if (!isActive) {
              log('⚠️ Account is deactivated by admin. Logging out user...');
              log('   Role: $userRole');
              log('   isActive: $isActive');

              // Clear session and logout user
              await storage.logout();
              isUserLoggedIn = false;
              userRole = null;

              log('🔐 User logged out due to inactive account');
              log('🔐 FINAL AUTH STATUS:');
              log('   User: ❌ NOT LOGGED IN (Account Deactivated)');
              log('   Role: null');
              log('   Seller: ❌');
              log('   Buyer: ❌');
              log('🔐 =========================================');

              return {
                'userLoggedIn': false,
                'userRole': null,
                'sellerLoggedIn': false,
                'buyerLoggedIn': false,
                'isActive': false,
                'reason': 'Account deactivated by admin',
              };
            }

            log('✅ Account is active: $isActive');

            // Update local storage with fresh data
            await storage.saveUserData(userData);
            log('💾 Updated local storage with fresh user data');

            // Check for required fields based on role
            final missingFields = <String>[];

            if (userRole == 'buyer') {
              // Buyer required fields
              if (userData['address'] == null ||
                  (userData['address'] is Map &&
                      (userData['address'] as Map).isEmpty) ||
                  (userData['address'] is String &&
                      (userData['address'] as String).isEmpty)) {
                missingFields.add('address');
              }
            } else if (userRole == 'seller') {
              // Seller required fields
              final sellerRequiredFields = [
                'businessName',
                'shopName',
                'businessLicense',
              ];

              for (final field in sellerRequiredFields) {
                if (userData[field] == null ||
                    (userData[field] is String &&
                        (userData[field] as String).isEmpty)) {
                  missingFields.add(field);
                }
              }
            }
          } else if (response.statusCode == 401) {
            // Unauthorized - token expired or invalid
            log(
              '⚠️ Unauthorized (401) - Token expired or invalid. Logging out...',
            );
            await storage.logout();
            isUserLoggedIn = false;
            userRole = null;

            return {
              'userLoggedIn': false,
              'userRole': null,
              'sellerLoggedIn': false,
              'buyerLoggedIn': false,
              'isActive': false,
              'reason': 'Token expired or invalid',
            };
          } else {
            log('⚠️ Failed to fetch user data: ${response.statusCode}');
            // Fall back to cached data if API fails
            final cachedUserData = storage.getUserData();
            if (cachedUserData != null) {
              log('📊 Using cached user data as fallback');
            }
          }
        } catch (e) {
          log('❌ Error fetching fresh user data: $e');
          // Fall back to cached data if API call fails
          final cachedUserData = storage.getUserData();
          if (cachedUserData != null) {
            log('📊 Using cached user data as fallback');
            // Still check isActive from cached data
            final isActiveValue = cachedUserData['isActive'];
            bool isActive = true;
            if (isActiveValue != null) {
              if (isActiveValue is bool) {
                isActive = isActiveValue;
              } else if (isActiveValue is String) {
                isActive = isActiveValue.toLowerCase() == 'true';
              } else if (isActiveValue is int) {
                isActive = isActiveValue == 1;
              }
            }

            if (!isActive) {
              log(
                '⚠️ Account is deactivated (from cache). Logging out user...',
              );
              await storage.logout();
              isUserLoggedIn = false;
              userRole = null;

              return {
                'userLoggedIn': false,
                'userRole': null,
                'sellerLoggedIn': false,
                'buyerLoggedIn': false,
                'isActive': false,
                'reason': 'Account deactivated by admin',
              };
            }
          }
        }
      } else {
        log('⚠️ No token available');
        // No token means not logged in
        isUserLoggedIn = false;
        userRole = null;
      }
    }

    log('🔐 FINAL AUTH STATUS:');
    log('   User: ${isUserLoggedIn ? "✅ LOGGED IN" : "❌ NOT LOGGED IN"}');
    log('   Role: ${userRole ?? "Not set"}');

    // Legacy compatibility - set old variables if needed
    final isSeller = userRole == 'seller';
    final isBuyer = userRole == 'buyer';

    log('   Seller: ${isSeller ? "✅" : "❌"}');
    log('   Buyer: ${isBuyer ? "✅" : "❌"}');
    log('🔐 =========================================');

    // Get isActive status if user is logged in (for return value)
    bool? isActiveStatus;
    if (isUserLoggedIn) {
      final userData = storage.getUserData();
      if (userData != null) {
        final isActiveValue = userData['isActive'];
        // Parse isActive value (handle bool, string, int)
        if (isActiveValue is bool) {
          isActiveStatus = isActiveValue;
        } else if (isActiveValue is String) {
          isActiveStatus = isActiveValue.toLowerCase() == 'true';
        } else if (isActiveValue is int) {
          isActiveStatus = isActiveValue == 1;
        } else {
          isActiveStatus = isActiveValue == true;
        }
        log('   Account Active: ${isActiveStatus == true ? "✅" : "❌"}');
      }
    }

    return {
      'userLoggedIn': isUserLoggedIn,
      'userRole': userRole,
      'sellerLoggedIn': isSeller,
      'buyerLoggedIn': isBuyer,
      'isActive': isActiveStatus ?? true,
    };
  } catch (e) {
    log('❌ Error checking auth status: $e');
    isUserLoggedIn = false;
    userRole = null;

    return {
      'userLoggedIn': false,
      'userRole': null,
      'sellerLoggedIn': false,
      'buyerLoggedIn': false,
      'error': e.toString(),
    };
  }
}

// Helper to check specific role
bool isRoleLoggedIn(String role) {
  return isUserLoggedIn && userRole == role;
}

// Quick role check helpers
bool get isSellerLoggedIn => isRoleLoggedIn('seller');
bool get isBuyerLoggedIn => isRoleLoggedIn('buyer');
bool get isAdminLoggedIn => isRoleLoggedIn('admin');

// Get current user model
UserModel? getCurrentUser() {
  try {
    final storage = locator<UnifiedLocalStorageServiceImpl>();
    return storage.getUserModel();
  } catch (e) {
    log('Error getting current user: $e');
    return null;
  }
}

// Update user profile
Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
  try {
    final storage = locator<UnifiedLocalStorageServiceImpl>();
    final currentUser = storage.getUserModel();

    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        name: updates['name'] ?? currentUser.name,
        email: updates['email'] ?? currentUser.email,
        phone: updates['phone'] ?? currentUser.phone,
        address: updates['address'] ?? currentUser.address,
        businessName: updates['businessName'] ?? currentUser.businessName,
        shopName: updates['shopName'] ?? currentUser.shopName,
        businessDescription:
            updates['businessDescription'] ?? currentUser.businessDescription,
        businessAddress:
            updates['businessAddress'] ?? currentUser.businessAddress,
        iban: updates['iban'] ?? currentUser.iban,
        profileImage: updates['profileImage'] ?? currentUser.profileImage,
        shopLogo: updates['shopLogo'] ?? currentUser.shopLogo,
        shopBanner: updates['shopBanner'] ?? currentUser.shopBanner,
      );

      await storage.saveUserModel(updatedUser);
      log('✅ User profile updated');
      return true;
    }
    return false;
  } catch (e) {
    log('❌ Error updating user profile: $e');
    return false;
  }
}

// Logout user
Future<void> logoutUser() async {
  try {
    final storage = locator<UnifiedLocalStorageServiceImpl>();
    await storage.logout();

    // Update global state
    isUserLoggedIn = false;
    userRole = null;

    log('✅ User logged out successfully');
  } catch (e) {
    log('❌ Error during logout: $e');
  }
}

// Check if user needs to complete profile
bool isProfileComplete() {
  final user = getCurrentUser();
  if (user == null) return false;

  if (user.isBuyer) {
    return user.address != null && user.address!.isNotEmpty;
  } else if (user.isSeller) {
    return user.businessName != null &&
        user.businessName!.isNotEmpty &&
        user.shopName != null &&
        user.shopName!.isNotEmpty &&
        user.businessLicense != null &&
        user.businessLicense!.isNotEmpty;
  } else if (user.isAdmin) {
    return true; // Admins might not need extra fields
  }

  return false;
}

void dismissKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
