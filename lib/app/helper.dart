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

  // ✅ Only test IPs on the SAME network as your phone
  final testUrls = [
    // Your laptop IP on the same network as phone
    'http://192.168.18.107:5001', // ⚠️ Replace xxx with your laptop's IP
    'http://192.168.2.1:5001', // Keep this as backup
  ];

  log('📱 Phone is on network: 192.168.18.x');
  log('💻 Testing connection to laptop...');

  bool hasConnection = false;

  for (var url in testUrls) {
    final dio = locator.get<Dio>();
    dio.options.baseUrl = url;

    try {
      log('Testing: $url');
      final response = await dio.get(
        '/api/health', // ✅ Use /api/health instead of /
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );

      if (response.statusCode == 200) {
        log('✅ CONNECTED: $url');
        log('   Server says: ${response.data}');
        hasConnection = true;
        workingServerUrl = url;

        // Save working URL
        final storage = locator.get<LocalStorageService>();
        await storage.saveString('working_server_url', url);

        break;
      }
    } catch (e) {
      log('❌ FAILED: $url - ${e.toString().split('\n').first}');
    }
  }

  if (!hasConnection) {
    log('\n⚠️ No server connection');
    log('💡 Solution:');
    log('1. Check both devices are on SAME Wi-Fi');
    log('2. Use correct laptop IP from: ifconfig/ipconfig');
    log('3. Test in phone browser first');
  }
}

void dismissKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
