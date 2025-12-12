import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Core Services
import 'package:wood_service/core/services/local_storage_service.dart';

// Seller Services
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import 'package:wood_service/views/Seller/data/services/shop_service.dart';

// Repositories
import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';

// Signup Services
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  log('🚀 Setting up dependency injection...');

  // ========== STEP 1: Initialize LocalStorageService ==========
  final localStorageInstance = await LocalStorageServiceImpl.getInstance();

  // ========== STEP 2: Register Core Services ==========
  locator.registerSingleton<LocalStorageService>(localStorageInstance);
  log('✅ LocalStorageService registered');

  // ========== STEP 3: Register Dio ==========
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.18.107:5001',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ),
  );

  locator.registerSingleton<Dio>(dio);
  log('✅ Dio registered');

  // ========== STEP 4: Register Other Services ==========
  // SellerSignupViewModel
  locator.registerFactory<SellerSignupViewModel>(
    () =>
        SellerSignupViewModel(sellerAuthService: locator<SellerAuthService>()),
  );
  log('✅ SellerSignupViewModel registered');

  // ProfileViewModel - ADD THIS REGISTRATION!
  locator.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      authService: locator<SellerAuthService>(),
      localStorageService: locator<LocalStorageService>(),
    ),
  );
  // SellerAuthService
  locator.registerSingleton<SellerAuthService>(
    SellerAuthService(locator<Dio>(), locator<LocalStorageService>()),
  );
  log('✅ SellerAuthService registered');

  // ! *****
  // ShopService
  locator.registerSingleton<ShopService>(ShopService());
  log('✅ ShopService registered');

  // Repositories
  locator.registerSingleton<ProductRepository>(MockProductRepository());
  log('✅ ProductRepository registered');

  locator.registerSingleton<OrderRepository>(MockOrderRepository());
  log('✅ OrderRepository registered');

  // ========== STEP 5: Register ViewModels ==========

  log('✅ ProfileViewModel registered');

  log('🎉 All dependencies registered!');
}
