import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wood_service/core/services/local_storage_service.dart';
import 'package:wood_service/views/Seller/data/services/profile_service.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import 'package:wood_service/views/Seller/data/services/shop_service.dart';
import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/seller_login.dart/login_view_model.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

final GetIt locator = GetIt.instance;
Future<void> setupLocator() async {
  log('🚀 Setting up dependency injection...');

  // ========== STEP 1: Initialize LocalStorageService ==========
  final localStorageService = LocalStorageServiceImpl();
  await localStorageService.initialize();
  locator.registerSingleton<LocalStorageService>(localStorageService);
  log('✅ LocalStorageService registered');

  // ========== STEP 2: Register Dio ==========
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

  // ========== STEP 3: Register Auth Services ==========
  locator.registerSingleton<SellerAuthService>(
    SellerAuthService(
      // not require
      locator<Dio>(),
      locator<LocalStorageService>(),
    ),
  );
  log('✅ SellerAuthService registered');

  // ========== STEP 4: Register ProfileService ==========
  // ⚠️ You need to create/register ProfileService first!
  locator.registerSingleton<ProfileService>(
    // !  Require
    ProfileService(
      dio: locator<Dio>(),
      localStorageService: locator<LocalStorageService>(),
    ),
  );
  log('✅ ProfileService registered');

  // ========== STEP 5: Register ProfileViewModel ==========
  locator.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      authService: locator<ProfileService>(), // or SellerAuthService
      localStorageService: locator<LocalStorageService>(),
    ),
  );
  log('✅ ProfileViewModel registered');

  // ========== STEP 6: Register Other ViewModels ==========
  locator.registerFactory<SellerSignupViewModel>(
    () =>
        SellerSignupViewModel(sellerAuthService: locator<SellerAuthService>()),
  );
  log('✅ SellerSignupViewModel registered');

  locator.registerFactory<SellerLoginViewModel>(
    () => SellerLoginViewModel(sellerAuthService: locator<SellerAuthService>()),
  );
  log('✅ SellerLoginViewModel registered');

  // ========== STEP 7: Register Other Services ==========
  locator.registerSingleton<ShopService>(ShopService());
  log('✅ ShopService registered');

  // ========== STEP 8: Register Repositories ==========
  locator.registerSingleton<ProductRepository>(MockProductRepository());
  log('✅ ProductRepository registered');

  locator.registerSingleton<OrderRepository>(MockOrderRepository());
  log('✅ OrderRepository registered');

  log('🎉 All dependencies registered!');
}
