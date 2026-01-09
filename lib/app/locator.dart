// lib/app/locator.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_service.dart';
import 'package:wood_service/chats/Buyer/buyer_socket_service.dart';
import 'package:wood_service/chats/Seller/new_seller_chat/seller_chat_provider.dart';
import 'package:wood_service/chats/Seller/new_seller_chat/seller_chat_service.dart';
import 'package:wood_service/chats/Seller/new_seller_chat/seller_socket_service.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';

// Import SEPARATE implementations
import 'package:wood_service/core/services/seller_local_storage_service_impl.dart';
import 'package:wood_service/core/services/buyer_local_storage_service_impl.dart';

// Import interfaces
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/data/repositories/auth_service.dart';

// Import your services
import 'package:wood_service/views/Buyer/Buyer_home/buyer_product_service.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_services.dart';
import 'package:wood_service/views/Buyer/buyer_main/buyer_main_provider.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_auth_services.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_repository.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/cart_services.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Buyer/Service/profile_service.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_repository_seller.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/visit_repository.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/seller_login.dart/seller_login_provider.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  //!  ========== STEP 1: Initialize SEPARATE Storage Services ==========
  // ! ✅ SELLER Storage
  final sellerStorage = SellerLocalStorageServiceImpl();
  await sellerStorage.initialize();
  locator.registerSingleton<SellerLocalStorageService>(sellerStorage);

  // ! ✅ BUYER Storage
  final buyerStorage = BuyerLocalStorageServiceImpl();
  await buyerStorage.initialize();
  locator.registerSingleton<BuyerLocalStorageService>(buyerStorage);

  // ========== STEP 2: Register Dio ==========
  final dio = Dio(
    BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: Config.connectTimeout,
      receiveTimeout: Config.receiveTimeout,
      headers: Config.defaultHeaders,
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

  // ! *********

  // ========== STEP 3: Register Seller Services ==========
  locator.registerSingleton<SellerAuthService>(
    SellerAuthService(locator<Dio>(), locator<SellerLocalStorageService>()),
  );

  locator.registerFactory<SellerSignupViewModel>(
    () =>
        SellerSignupViewModel(sellerAuthService: locator<SellerAuthService>()),
  );
  locator.registerFactory<SellerAuthProvider>(
    () => SellerAuthProvider(locator<SellerAuthService>()),
  );
  // ! Named Parameter
  // locator.registerFactory<SellerAuthProvider>(
  //   () => SellerAuthProvider(sellerAuthService: locator<SellerAuthService>()),
  // );

  // ========== STEP 4: Register Seller Repositories ==========
  locator.registerSingleton<ProductRepository>(MockProductRepository());

  // ✅ ADD THIS: Register OrderRepository FIRST
  locator.registerSingleton<OrderRepository>(
    ApiOrderRepository(
      dio: locator<Dio>(),
      storageService: locator<SellerLocalStorageService>(),
    ),
  );

  // ========== STEP 5: Register Seller Providers ==========
  locator.registerFactory<SelllerSettingProvider>(
    () => SelllerSettingProvider(
      authService: locator<SellerAuthService>(),
      localStorageService: locator<SellerLocalStorageService>(),
    ),
  );

  // ========== STEP 6: Register Visit Repository ==========

  // locator.registerLazySingleton<SellerVisitRepository>(
  //   () => ApiSellerVisitRepository(
  //     storageService: locator<SellerLocalStorageService>(),
  //   ),
  // );
  // ! ****
  // ! *************
  // ! *************
  // ! *************
  // ! *************
  // ! *************

  // locator.registerLazySingleton(
  //   () => SellerVisitService(locator<SellerLocalStorageService>()),
  // );

  // In setupLocator() function, add this:

  // Register VisitRepository (if not already registered)
  locator.registerLazySingleton<VisitRepository>(
    () => ApiVisitRepository(
      storageService: locator<SellerLocalStorageService>(),
    ),
  );

  // Register VisitRequestsViewModel
  locator.registerLazySingleton<VisitRequestsViewModel>(
    () => VisitRequestsViewModel(locator<VisitRepository>()),
  );
  // ! *************
  // ! *************
  // ! *************
  // ! *************
  // ! *************
  // ✅ ADD THIS: Register OrdersViewModel in locator too
  locator.registerLazySingleton<OrdersViewModel>(
    () => OrdersViewModel(locator<OrderRepository>()),
  );
  // Register Buyer Order Repository
  locator.registerLazySingleton(
    () => ApiBuyerOrderRepository(
      storageService: locator<BuyerLocalStorageService>(),
    ),
  );

  // ========== STEP 8: Register Buyer Services ==========
  locator.registerLazySingleton(
    () => BuyerAuthService(locator<Dio>(), locator<BuyerLocalStorageService>()),
  );

  locator.registerSingleton<BuyerProfileService>(BuyerProfileService());

  locator.registerFactory(() => BuyerProfileViewProvider());

  locator.registerLazySingleton(() => BuyerProductService());

  locator.registerLazySingleton(() => BuyerCartService());
  locator.registerLazySingleton(() => BuyerCartViewModel());

  // ========== CHAT & CART SERVICES ==========
  locator.registerLazySingleton(() => BuyerChatService());
  locator.registerLazySingleton(() => BuyerSocketService());

  // In setupLocator()
  locator.registerLazySingleton<CartServices>(
    () => CartServices(locator<BuyerLocalStorageService>()), // Use interface
  );

  // ✅ 5. Register CartProvider
  locator.registerLazySingleton<CartProvider>(
    () => CartProvider(locator<CartServices>()),
  );
  locator.registerLazySingleton(() => SellerChatService());
  locator.registerLazySingleton(() => SellerSocketService());
  locator.registerFactory(() => SellerChatProvider());
  locator.registerFactory(() => AuthService());
  locator.registerLazySingleton(() => MainScreenProvider());
}
// ! ********