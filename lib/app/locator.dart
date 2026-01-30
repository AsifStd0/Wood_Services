// app/locator.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_service.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_product_service.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';
import 'package:wood_service/views/Buyer/buyer_main/buyer_main_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_repository.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/views/Seller/data/services/auth_service.dart';
import 'package:wood_service/views/Seller/data/services/notification_service.dart';
import 'package:wood_service/views/Seller/data/services/seller_settings_service.dart';
import 'package:wood_service/views/Seller/data/services/seller_stats_service.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_repository_seller.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_requests_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_requests_service.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/setting_data/seller_settings_repository.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/setting_data/seller_settings_repository_impl.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/status/seller_stats_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_services.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_provider.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_services.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Check if already initialized
  if (locator.isRegistered<Dio>()) {
    print('✅ Locator already initialized, skipping...');
    return;
  }

  // ========== STEP 1: Initialize SharedPreferences ==========
  final prefs = await SharedPreferences.getInstance();

  if (!locator.isRegistered<SharedPreferences>()) {
    locator.registerSingleton<SharedPreferences>(prefs);
  }

  // ========== STEP 2: Register & Initialize Storage FIRST ==========
  if (!locator.isRegistered<UnifiedLocalStorageServiceImpl>()) {
    // Create instance
    final storageService = UnifiedLocalStorageServiceImpl();

    // Initialize it (sets up SharedPreferences internally)
    await storageService.initialize();

    // Register the initialized instance
    locator.registerSingleton<UnifiedLocalStorageServiceImpl>(storageService);
  }

  // ========== STEP 3: Register Dio (with initialized storage) ==========
  if (!locator.isRegistered<Dio>()) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Config.apiBaseUrl,
        connectTimeout: Config.connectTimeout,
        receiveTimeout: Config.receiveTimeout,
        headers: Config.defaultHeaders,
      ),
    );

    // // Add interceptors for logging (optional)
    // if (Config.isDevelopment) {
    //   dio.interceptors.add(
    //     LogInterceptor(
    //       request: true,
    //       requestHeader: true,
    //       requestBody: true,
    //       responseHeader: true,
    //       responseBody: true,
    //       error: true,
    //     ),
    //   );
    // }

    // Add auth interceptor - NOW storage is ready!
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Get storage from locator
            final storage = locator<UnifiedLocalStorageServiceImpl>();
            final token = storage.getToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              // when dio call it auto get this id
              print('🔑 Token added to request');
            }
          } catch (e) {
            print('❌ Error getting token in interceptor: $e');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized errors
          if (error.response?.statusCode == 401) {
            print('🔐 Token expired, logging out...');
            final storage = locator<UnifiedLocalStorageServiceImpl>();
            await storage.logout();
            // Navigation logic here
          }
          return handler.next(error);
        },
      ),
    );

    locator.registerSingleton<Dio>(dio);
  }

  // ========== STEP 4: Register Other Services ==========
  if (!locator.isRegistered<AuthService>()) {
    locator.registerSingleton<AuthService>(AuthService(locator<Dio>()));
  }

  // Register BuyerProductService
  if (!locator.isRegistered<BuyerProductService>()) {
    locator.registerSingleton<BuyerProductService>(
      BuyerProductService(
        dio: locator<Dio>(),
        storage: locator<UnifiedLocalStorageServiceImpl>(),
      ),
    );
  }

  // Register UploadedProductService
  if (!locator.isRegistered<UploadedProductService>()) {
    locator.registerSingleton<UploadedProductService>(
      UploadedProductService(
        dio: locator<Dio>(),
        storage: locator<UnifiedLocalStorageServiceImpl>(),
      ),
    );
  }

  // Register SellerStatsService
  if (!locator.isRegistered<SellerStatsService>()) {
    locator.registerSingleton<SellerStatsService>(SellerStatsService());
  }

  // Register NotificationService
  if (!locator.isRegistered<NotificationService>()) {
    locator.registerSingleton<NotificationService>(
      NotificationService(
        dio: locator<Dio>(),
        storage: locator<UnifiedLocalStorageServiceImpl>(),
      ),
    );
  }

  // // Register BuyerVisitRequestService
  // if (!locator.isRegistered<BuyerVisitRequestService>()) {
  //   locator.registerSingleton<BuyerVisitRequestService>(
  //     BuyerVisitRequestService(
  //       dio: locator<Dio>(),
  //       storage: locator<UnifiedLocalStorageServiceImpl>(),
  //     ),
  //   );
  // }
  // Register services first
  if (!locator.isRegistered<BuyerVisitRequestService>()) {
    locator.registerSingleton<BuyerVisitRequestService>(
      BuyerVisitRequestService(
        dio: locator<Dio>(),
        storage: locator<UnifiedLocalStorageServiceImpl>(),
      ),
    );
  }

  // Then register the provider
  if (!locator.isRegistered<BuyerVisitRequestProvider>()) {
    locator.registerSingleton<BuyerVisitRequestProvider>(
      BuyerVisitRequestProvider(service: locator<BuyerVisitRequestService>()),
    );
  }

  // Register SellerSettingsDataSource
  if (!locator.isRegistered<SellerSettingsService>()) {
    locator.registerSingleton<SellerSettingsService>(SellerSettingsService());
  }

  // Register SellerSettingsRepository
  if (!locator.isRegistered<SellerSettingsRepository>()) {
    locator.registerSingleton<SellerSettingsRepository>(
      SellerSettingsRepositoryImpl(locator<SellerSettingsService>()),
    );
  }

  // Register OrderRepository
  if (!locator.isRegistered<SellerOrderRepository>()) {
    locator.registerSingleton<SellerOrderRepository>(
      ApiOrderRepositorySeller(
        dio: locator<Dio>(),
        storageService: locator<UnifiedLocalStorageServiceImpl>(),
      ),
    );
  }

  // ========== STEP 5: Register Provider Factories ==========
  // Register RegisterViewModel
  locator.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(locator<AuthService>()),
  );

  // Register SellerSettingProvider
  locator.registerFactory<SellerSettingsProvider>(
    () => SellerSettingsProvider(locator<SellerSettingsRepository>()),
  );

  // Register SellerProductProvider ✅ CORRECT - using factory
  locator.registerFactory<SellerProductProvider>(
    () => SellerProductProvider(
      storage: locator<UnifiedLocalStorageServiceImpl>(),
      dio: locator<Dio>(),
    ),
  );

  // Register UploadedProductProvider
  locator.registerFactory<UploadedProductProvider>(
    () => UploadedProductProvider(service: locator<UploadedProductService>()),
  );

  // // Register SellerStatsProvider
  // locator.registerFactory<SellerStatsProvider>(() => SellerStatsProvider());

  // Register OrdersViewModel
  locator.registerFactory<OrdersViewModel>(
    () => OrdersViewModel(locator<SellerOrderRepository>()),
  );

  // Register BuyerProfileViewProvider
  locator.registerFactory<BuyerProfileViewProvider>(
    () => BuyerProfileViewProvider(
      storage: locator<UnifiedLocalStorageServiceImpl>(),
      dio: locator<Dio>(),
    ),
  );

  // Register MainScreenProvider
  if (!locator.isRegistered<MainScreenProvider>()) {
    locator.registerSingleton<MainScreenProvider>(MainScreenProvider());
  }
  locator.registerSingleton<FavoriteProvider>(FavoriteProvider());

  // BuyerHomeViewProvider
  if (!locator.isRegistered<BuyerHomeViewProvider>()) {
    locator.registerSingleton<BuyerHomeViewProvider>(
      BuyerHomeViewProvider(
        favoriteProvider: locator<FavoriteProvider>(),
        // storage: locator<UnifiedLocalStorageServiceImpl>(),
        // dio: locator<Dio>(),
      ),
    );
  }

  // BuyerCartViewModel
  if (!locator.isRegistered<BuyerCartViewModel>()) {
    locator.registerSingleton<BuyerCartViewModel>(BuyerCartViewModel());
  }

  // Register BuyerChatService
  if (!locator.isRegistered<BuyerChatService>()) {
    locator.registerSingleton<BuyerChatService>(BuyerChatService());
  }

  // Then register BuyerChatProvider
  locator.registerFactory<BuyerChatProvider>(
    () => BuyerChatProvider(chatService: locator<BuyerChatService>()),
  );
  // BuyerOrderProviderx
  // ✅ FIRST: Register the repository interface with its implementation
  locator.registerLazySingleton<BuyerOrderRepository>(
    () => ApiBuyerOrderRepository(
      storageService: locator<UnifiedLocalStorageServiceImpl>(),
      // Add other dependencies if needed, e.g., Dio
      // locator<Dio>(),
    ),
  );
  // Register VisitRequestsService
  if (!locator.isRegistered<VisitRequestsService>()) {
    locator.registerLazySingleton<VisitRequestsService>(
      () => VisitRequestsService(),
    );
  }
  // Register VisitRequestsProvider
  locator.registerFactory<VisitRequestsProvider>(() => VisitRequestsProvider());

  // ✅ THEN: Register the provider that depends on the repository
  locator.registerFactory<BuyerOrderProvider>(
    () => BuyerOrderProvider(locator<BuyerOrderRepository>()),
  );
  // ! ******

  // Register Seller Stats Provider
  if (!locator.isRegistered<SellerStatsProvider>()) {
    locator.registerSingleton<SellerStatsProvider>(SellerStatsProvider());
  }

  print('✅ Locator setup completed successfully!');
}
