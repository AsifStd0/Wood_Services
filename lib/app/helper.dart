import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/local_storage_service.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';

// Global auth state
bool isSellerLoggedInCheck = false;
String? workingServerUrl;

Future<void> checkAuthStatus() async {
  try {
    final authService = locator<SellerAuthService>();
    isSellerLoggedInCheck = await authService.isSellerLoggedIn();

    log(
      '🔐 Auth Status: ${isSellerLoggedInCheck ? "SELLER LOGGED IN" : "NOT LOGGED IN"}',
    );

    if (isSellerLoggedInCheck) {
      log('✅ Seller will be redirected to main seller screen');
    } else {
      log('⚠️ No seller logged in, showing onboarding');
    }
  } catch (e) {
    log('❌ Error checking auth status: $e');
    isSellerLoggedInCheck = false;
  }
}

Future<void> testInitialConnection() async {
  log('\n🔍 Initial Connection Test');
  log('=========================\n');

  // Your possible server URLs
  final testUrls = [
    'http://192.168.18.107:5001',
    'http://192.168.18.107:5002',
    'http://192.168.18.107:5003',
  ];

  bool hasConnection = false;

  for (var url in testUrls) {
    final dio = locator.get<Dio>();
    dio.options.baseUrl = url;

    try {
      log('Testing: $url');
      final response = await dio.get(
        '/',
        options: Options(receiveTimeout: const Duration(seconds: 3)),
      );

      if (response.statusCode == 200) {
        log('✅ CONNECTED: $url');
        log('   Server says: ${response.data['message']}');
        hasConnection = true;
        workingServerUrl = url;

        // Save working URL for future use
        final storage = locator.get<LocalStorageService>();
        await storage.saveString('working_server_url', url);

        break;
      }
    } catch (e) {
      log('❌ FAILED: $url - ${e.toString().split('\n').first}');
    }
  }

  if (!hasConnection) {
    log('\n⚠️ WARNING: No server connection established');
    log('   The app will run in offline mode');
    log('   You can test connection from the debug screen');
  }
}

void dismissKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
