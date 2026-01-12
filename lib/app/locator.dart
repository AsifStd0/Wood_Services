import 'package:wood_service/app/index.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  //! ========== STEP 1: Initialize SEPARATE Storage Services ==========
  // ✅ SELLER Storage
  final sellerStorage = SellerLocalStorageServiceImpl();
  await sellerStorage.initialize();
  locator.registerSingleton<SellerLocalStorageService>(sellerStorage);

  // ✅ BUYER Storage
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

  // ========== STEP 4: Register Seller Repositories ==========
  locator.registerSingleton<ProductRepository>(MockProductRepository());

  // ✅ Register OrderRepository
  locator.registerSingleton<OrderRepository>(
    ApiOrderRepository(
      dio: locator<Dio>(),
      storageService: locator<SellerLocalStorageService>(),
    ),
  );

  // ========== STEP 5: Register VISIT SERVICE and VIEWMODEL ==========
  // ✅ Register VisitService
  locator.registerSingleton<VisitService>(
    VisitService(storageService: locator<SellerLocalStorageService>()),
  );

  // ✅ Register VisitRequestsViewModel
  locator.registerLazySingleton<VisitRequestsViewModel>(
    () => VisitRequestsViewModel(locator<VisitService>()),
  );

  // ========== STEP 6: Register Seller Providers ==========
  locator.registerFactory<SelllerSettingProvider>(
    () => SelllerSettingProvider(
      authService: locator<SellerAuthService>(),
      localStorageService: locator<SellerLocalStorageService>(),
    ),
  );

  locator.registerSingleton<OrdersViewModel>(
    OrdersViewModel(locator<OrderRepository>()),
  );

  // ========== STEP 7: Register Buyer Services ==========
  // ✅ Register Buyer Order Repository
  locator.registerLazySingleton<ApiBuyerOrderRepository>(
    () => ApiBuyerOrderRepository(
      storageService: locator<BuyerLocalStorageService>(),
    ),
  );

  locator.registerLazySingleton<BuyerAuthService>(
    () => BuyerAuthService(locator<Dio>(), locator<BuyerLocalStorageService>()),
  );

  locator.registerSingleton<BuyerProfileService>(BuyerProfileService());

  locator.registerFactory<BuyerProfileViewProvider>(
    () => BuyerProfileViewProvider(),
  );

  locator.registerLazySingleton<BuyerProductService>(
    () => BuyerProductService(),
  );

  locator.registerLazySingleton<BuyerCartService>(() => BuyerCartService());

  locator.registerLazySingleton<BuyerCartViewModel>(() => BuyerCartViewModel());

  // ========== STEP 8: Register CHAT & CART SERVICES ==========
  locator.registerLazySingleton<BuyerChatService>(() => BuyerChatService());

  locator.registerLazySingleton<BuyerSocketService>(() => BuyerSocketService());

  locator.registerLazySingleton<CartServices>(
    () => CartServices(locator<BuyerLocalStorageService>()),
  );

  locator.registerLazySingleton<CartProvider>(
    () => CartProvider(locator<CartServices>()),
  );

  locator.registerLazySingleton<SellerChatService>(() => SellerChatService());

  locator.registerLazySingleton<SellerSocketService>(
    () => SellerSocketService(),
  );

  locator.registerFactory<SellerChatProvider>(() => SellerChatProvider());

  // ========== STEP 9: Register Other Services ==========
  locator.registerFactory<AuthService>(() => AuthService());

  locator.registerLazySingleton<MainScreenProvider>(() => MainScreenProvider());
}
