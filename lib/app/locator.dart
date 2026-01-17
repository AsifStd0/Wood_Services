// app/locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/core/services/buyer_local_storage_service_impl.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';
import 'package:wood_service/views/Buyer/buyer_main/buyer_main_provider.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_product_service.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/views/Seller/data/services/new_service/auth_service.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_services.dart';

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

    // Add interceptors for logging (optional)
    if (Config.isDevelopment) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

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

  // ========== STEP 5: Register Provider Factories ==========
  // Register RegisterViewModel
  locator.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(locator<AuthService>()),
  );

  // Register SellerSettingProvider
  locator.registerFactory<SelllerSettingProvider>(
    () => SelllerSettingProvider(
      storage: locator<UnifiedLocalStorageServiceImpl>(),
      dio: locator<Dio>(),
    ),
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

  print('✅ Locator setup completed successfully!');
}
