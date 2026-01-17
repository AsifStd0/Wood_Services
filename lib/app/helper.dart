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

    // If user is logged in, check if data is complete
    if (isUserLoggedIn) {
      final userData = storage.getUserData();
      final userModel = storage.getUserModel();

      if (userData != null) {
        log(
          '📊 User data fields: ${userData.keys.toList()} print id  ${userData.values.toList()}',
        );
        log('📊 User model values: ${storage.getToken()}}');

        // Check for required fields based on role
        final missingFields = <String>[];

        if (userRole == 'buyer') {
          // Buyer required fields
          if (userData['address'] == null ||
              (userData['address'] as String).isEmpty) {
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
                (userData[field] as String).isEmpty) {
              missingFields.add(field);
            }
          }
        }

        // if (missingFields.isNotEmpty) {
        //   log('⚠️ Missing required fields for $userRole: $missingFields');

        //   // Try to refresh user data from API
        //   try {
        //     final authService = locator<AuthService>();
        //     final freshData = await authService.getProfile();

        //     // Save updated data
        //     await storage.saveUserModel(freshData);
        //     log('✅ Successfully refreshed user data');

        //   } catch (refreshError) {
        //     log('⚠️ Could not refresh user data: $refreshError');
        //   }
        // } else {
        //   log('✅ User data is complete');
        // }
      } else {
        log('⚠️ User data is null');
      }
    }

    log('');
    log('🔐 FINAL AUTH STATUS:');
    log('   User: ${isUserLoggedIn ? "✅ LOGGED IN" : "❌ NOT LOGGED IN"}');
    log('   Role: ${userRole ?? "Not set"}');

    // Legacy compatibility - set old variables if needed
    final isSeller = userRole == 'seller';
    final isBuyer = userRole == 'buyer';

    log('   Seller: ${isSeller ? "✅" : "❌"}');
    log('   Buyer: ${isBuyer ? "✅" : "❌"}');
    log('🔐 =========================================');

    return {
      'userLoggedIn': isUserLoggedIn,
      'userRole': userRole,
      'sellerLoggedIn': isSeller,
      'buyerLoggedIn': isBuyer,
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

// // Get user display info
// Map<String, dynamic> getUserDisplayInfo() {
//   final user = getCurrentUser();
//   return {
//     'name': user?.name ?? 'Guest',
//     'email': user?.email ?? '',
//     'role': user?.role ?? 'guest',
//     'profileImage': user?.profileImage,
//     'displayName': user?.isSeller && user.shopName != null
//         ? user.shopName
//         : user?.name ?? 'User',
//     'isProfileComplete': isProfileComplete(),
//   };
// }

void dismissKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

// Navigation helper based on auth status
void navigateBasedOnAuth(BuildContext context) {
  if (isUserLoggedIn) {
    switch (userRole) {
      case 'seller':
        // Navigator.pushReplacementNamed(context, '/seller-dashboard');
        break;
      case 'buyer':
        // Navigator.pushReplacementNamed(context, '/buyer-dashboard');
        break;
      case 'admin':
        // Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      default:
        // Navigator.pushReplacementNamed(context, '/register');
        break;
    }
  } else {
    // Navigator.pushReplacementNamed(context, '/register');
  }
}
