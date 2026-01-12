import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';

// Global auth state
bool isSellerLoggedInCheck = false;
bool isBuyerLoggedInCheck = false; // Add this
String? workingServerUrl;

Future<Map<String, dynamic>> checkAuthStatus() async {
  try {
    log('🔐 ========== CHECKING AUTH STATUS ==========');

    // Check seller
    isSellerLoggedInCheck = await locator<SellerAuthService>()
        .checkSellerToken();

    isBuyerLoggedInCheck = await locator<BuyerAuthService>().isBuyerLoggedIn();

    // ✅ If buyer is logged in, check if data is complete
    if (isBuyerLoggedInCheck) {
      final buyerData = await locator<BuyerLocalStorageService>()
          .getBuyerData();

      if (buyerData != null) {
        log('🔍 Fields: -------- 22222 ${buyerData.values.toList()}');

        // Check for missing fields
        final missingFields = <String>[];
        final requiredFields = ['address', 'description', 'bankDetails'];

        for (final field in requiredFields) {
          if (buyerData[field] == null) {
            missingFields.add(field);
          }
        }

        if (missingFields.isNotEmpty) {
          // Try to refresh data
          final refreshed = await locator<BuyerAuthService>()
              .refreshBuyerData();
          if (refreshed) {
            log('✅ Successfully refreshed buyer data');

            // Get the fresh data
            final freshData = await locator<BuyerLocalStorageService>()
                .getBuyerData();
            if (freshData != null) {
              log('✅ Fresh data loaded with ${freshData.length} fields');
            }
          } else {
            log('⚠️ Could not refresh buyer data');
          }
        } else {
          log('✅ Buyer data is complete');
        }
      }
    }

    log('');
    log('🔐 FINAL AUTH STATUS:');
    log(
      '   Seller: ${isSellerLoggedInCheck ? "✅ LOGGED IN" : "❌ NOT LOGGED IN"}',
    );
    log(
      '   Buyer: ${isBuyerLoggedInCheck ? "✅ LOGGED IN" : "❌ NOT LOGGED IN"}',
    );
    log('🔐 =========================================');

    return {
      'sellerLoggedIn': isSellerLoggedInCheck,
      'buyerLoggedIn': isBuyerLoggedInCheck,
    };
  } catch (e) {
    log('❌ Error checking auth status: $e');
    isSellerLoggedInCheck = false;
    isBuyerLoggedInCheck = false;

    return {
      'sellerLoggedIn': false,
      'buyerLoggedIn': false,
      'error': e.toString(),
    };
  }
}

void dismissKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
