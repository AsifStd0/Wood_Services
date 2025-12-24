// lib/app/locator.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';

// Import SEPARATE implementations
import 'package:wood_service/core/services/seller_local_storage_service_impl.dart';
import 'package:wood_service/core/services/buyer_local_storage_service_impl.dart';

// Import interfaces
import 'package:wood_service/core/services/seller_local_storage_service.dart';

// Import your services
import 'package:wood_service/views/Buyer/Buyer_home/buyer_product_service.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_services.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_auth_services.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Buyer/Service/profile_service.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import 'package:wood_service/views/Seller/data/services/shop_service.dart';
import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/seller_login.dart/login_view_model.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  log('🚀 Setting up dependency injection with SEPARATE storage...');

  // ========== STEP 1: Initialize SEPARATE Storage Services ==========
  // ✅ SELLER Storage
  final sellerStorage = SellerLocalStorageServiceImpl();
  await sellerStorage.initialize();
  locator.registerSingleton<SellerLocalStorageService>(sellerStorage);
  log('✅ Seller Storage registered');

  // ✅ BUYER Storage
  final buyerStorage = BuyerLocalStorageServiceImpl();
  await buyerStorage.initialize();
  locator.registerSingleton<BuyerLocalStorageService>(buyerStorage);
  log('✅ Buyer Storage registered');

  // ========== STEP 2: Register Dio ==========
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.8:5001',
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

  // ========== STEP 3: Register Seller Services ==========
  locator.registerSingleton<SellerAuthService>(
    SellerAuthService(locator<Dio>(), locator<SellerLocalStorageService>()),
  );

  log('✅ SellerAuthService registered');

  locator.registerFactory<SellerSignupViewModel>(
    () =>
        SellerSignupViewModel(sellerAuthService: locator<SellerAuthService>()),
  );
  log('✅ SellerSignupViewModel registered');

  locator.registerFactory<SellerLoginViewModel>(
    () => SellerLoginViewModel(sellerAuthService: locator<SellerAuthService>()),
  );
  log('✅ SellerLoginViewModel registered');

  locator.registerSingleton<ShopService>(ShopService());
  log('✅ ShopService registered');

  // ========== STEP 4: Register Seller Repositories ==========
  locator.registerSingleton<ProductRepository>(MockProductRepository());
  log('✅ ProductRepository registered');

  locator.registerSingleton<OrderRepository>(MockOrderRepository());
  log('✅ OrderRepository registered');

  // ========== STEP 5: Register Seller Providers ==========
  locator.registerFactory<SelllerSettingProvider>(
    () => SelllerSettingProvider(
      authService: locator<SellerAuthService>(),
      localStorageService: locator<SellerLocalStorageService>(),
    ),
  );
  log('✅ SelllerSettingProvider registered');

  // ========== STEP 6: Register Buyer Services ==========
  locator.registerLazySingleton(
    () => BuyerAuthService(locator<Dio>(), locator<BuyerLocalStorageService>()),
  );
  log('✅ BuyerAuthService registered');

  locator.registerSingleton<BuyerProfileService>(BuyerProfileService());
  log('✅ BuyerProfileService registered');

  locator.registerFactory(() => BuyerProfileViewProvider());
  log('✅ BuyerProfileViewProvider registered');

  locator.registerLazySingleton(() => BuyerProductService());
  log('✅ BuyerProductService registered');

  locator.registerLazySingleton(() => BuyerCartService());
  locator.registerLazySingleton(() => BuyerCartViewModel());

  // ========== STEP 7: DO NOT REGISTER ViewModels that need Provider context ==========
  // ❌ DON'T register these here - they need Provider context
  // - BuyerHomeViewModel (needs FavoriteProvider from Provider context)
  // - FavoriteProvider (no external dependencies)

  // These should be registered in providers.dart using ChangeNotifierProvider

  log('🎉 All dependencies registered!');
}
// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:get_it/get_it.dart';
// import 'package:wood_service/core/services/buyer_local_storage_service.dart';

// // Import SEPARATE implementations
// import 'package:wood_service/core/services/seller_local_storage_service_impl.dart';
// import 'package:wood_service/core/services/buyer_local_storage_service_impl.dart';

// // Import interfaces
// import 'package:wood_service/core/services/seller_local_storage_service.dart';

// // Import your services
// import 'package:wood_service/views/Buyer/Buyer_home/buyer_product_service.dart';
// import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_auth_services.dart';
// import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
// import 'package:wood_service/views/Buyer/Service/profile_service.dart';
// import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
// import 'package:wood_service/views/Seller/data/services/shop_service.dart';
// import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
// import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
// import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
// import 'package:wood_service/views/Seller/seller_login.dart/login_view_model.dart';
// import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

// final GetIt locator = GetIt.instance;

// Future<void> setupLocator() async {
//   log('🚀 Setting up dependency injection with SEPARATE storage...');

//   // ========== STEP 1: Initialize SEPARATE Storage Services ==========
//   // ✅ SELLER Storage
//   final sellerStorage = SellerLocalStorageServiceImpl();
//   await sellerStorage.initialize();
//   locator.registerSingleton<SellerLocalStorageService>(sellerStorage);
//   log('✅ Seller Storage registered');

//   // ✅ BUYER Storage
//   final buyerStorage = BuyerLocalStorageServiceImpl();
//   await buyerStorage.initialize();
//   locator.registerSingleton<BuyerLocalStorageService>(buyerStorage);
//   log('✅ Buyer Storage registered');

//   // ========== STEP 2: Register Dio ==========
//   final dio = Dio(
//     BaseOptions(
//       baseUrl: 'http://192.168.1.8:5001',
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     ),
//   );

//   dio.interceptors.add(
//     LogInterceptor(
//       request: true,
//       requestHeader: true,
//       requestBody: true,
//       responseHeader: true,
//       responseBody: true,
//     ),
//   );

//   locator.registerSingleton<Dio>(dio);
//   log('✅ Dio registered');

//   // ========== STEP 3: Register Seller Services ==========
//   locator.registerSingleton<SellerAuthService>(
//     SellerAuthService(locator<Dio>(), locator<SellerLocalStorageService>()),
//   );

//   log('✅ SellerAuthService registered');

//   locator.registerFactory<SellerSignupViewModel>(
//     () =>
//         SellerSignupViewModel(sellerAuthService: locator<SellerAuthService>()),
//   );
//   log('✅ SellerSignupViewModel registered');

//   locator.registerFactory<SellerLoginViewModel>(
//     () => SellerLoginViewModel(sellerAuthService: locator<SellerAuthService>()),
//   );
//   log('✅ SellerLoginViewModel registered');

//   locator.registerSingleton<ShopService>(ShopService());
//   log('✅ ShopService registered');

//   // ========== STEP 4: Register Seller Repositories ==========
//   locator.registerSingleton<ProductRepository>(MockProductRepository());
//   log('✅ ProductRepository registered');

//   locator.registerSingleton<OrderRepository>(MockOrderRepository());
//   log('✅ OrderRepository registered');

//   // ========== STEP 5: Register Seller Providers ==========
//   locator.registerFactory<SelllerSettingProvider>(
//     () => SelllerSettingProvider(
//       authService: locator<SellerAuthService>(),
//       localStorageService: locator<SellerLocalStorageService>(),
//     ),
//   );
//   log('✅ SelllerSettingProvider registered');

//   // ========== STEP 6: Register Buyer Services ==========
//   locator.registerLazySingleton(
//     () => BuyerAuthService(locator<Dio>(), locator<BuyerLocalStorageService>()),
//   );
//   log('✅ BuyerAuthService registered');

//   locator.registerSingleton<BuyerProfileService>(BuyerProfileService());
//   log('✅ BuyerProfileService registered');

//   locator.registerFactory(() => BuyerProfileViewProvider());
//   log('✅ BuyerProfileViewProvider registered');

//   locator.registerLazySingleton(() => BuyerProductService());
//   log('✅ BuyerProductService registered');

//   log('🎉 All dependencies registered with SEPARATE storage!');
// }
