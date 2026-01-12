import 'package:wood_service/app/index.dart';

List<SingleChildWidget> appProviders = [
  // ========== SERVICES (Synchronous) ==========
  Provider<ProductRepository>(create: (_) => locator<ProductRepository>()),

  // ========== FAVORITE PROVIDER ==========
  ChangeNotifierProvider<FavoriteProvider>(
    create: (context) => FavoriteProvider(locator<BuyerLocalStorageService>()),
  ),

  // ========== BUYER PROVIDERS ==========
  ChangeNotifierProxyProvider<FavoriteProvider, BuyerHomeViewModel>(
    create: (context) => BuyerHomeViewModel(
      Provider.of<FavoriteProvider>(context, listen: false),
    ),
    update: (context, favoriteProvider, previous) {
      if (previous == null) {
        return BuyerHomeViewModel(favoriteProvider);
      }
      return previous;
    },
  ),

  ChangeNotifierProvider<BuyerProfileViewProvider>(
    create: (_) => BuyerProfileViewProvider(),
  ),

  // ========== BUYER CART VIEWMODEL ==========
  ChangeNotifierProvider<BuyerCartViewModel>(
    create: (_) => locator<BuyerCartViewModel>(),
  ),

  // ========== BUYER AUTH PROVIDERS ==========
  ChangeNotifierProvider<BuyerSignupProvider>(
    create: (_) => BuyerSignupProvider(),
  ),

  ChangeNotifierProvider<BuyerAuthProvider>(create: (_) => BuyerAuthProvider()),

  // ========== BUYER ORDER PROVIDER ==========
  ChangeNotifierProvider<BuyerOrderProvider>(
    create: (_) => BuyerOrderProvider(
      ApiBuyerOrderRepository(
        storageService: locator<BuyerLocalStorageService>(),
      ),
    ),
  ),

  // ========== SELLER VIEWMODELS ==========
  ChangeNotifierProvider<SellerAuthProvider>(
    create: (_) => SellerAuthProvider(locator<SellerAuthService>()),
  ),

  ChangeNotifierProvider<OrdersViewModel>(
    create: (_) => OrdersViewModel(locator<OrderRepository>()),
  ),

  ChangeNotifierProvider<SellerSignupViewModel>(
    create: (_) => locator<SellerSignupViewModel>(),
  ),

  // ========== SELLER SETTINGS ==========
  ChangeNotifierProvider<SelllerSettingProvider>(
    create: (_) => locator<SelllerSettingProvider>(),
  ),

  // ========== VISIT REQUESTS VIEWMODEL ==========
  ChangeNotifierProvider<VisitRequestsViewModel>(
    create: (_) => locator<VisitRequestsViewModel>(),
  ),

  // ========== CHAT PROVIDERS ==========
  ChangeNotifierProvider<BuyerChatProvider>(create: (_) => BuyerChatProvider()),

  // ✅ ADD THIS: SELLER CHAT PROVIDER (UNCOMMENTED)
  ChangeNotifierProvider<SellerChatProvider>(
    create: (_) =>
        SellerChatProvider(), // or locator<SellerChatProvider>() if registered
  ),

  // ========== CART & REVIEW PROVIDERS ==========
  ChangeNotifierProvider<CartProvider>(create: (_) => locator<CartProvider>()),

  ChangeNotifierProvider<ReviewProvider>(create: (_) => ReviewProvider()),

  ChangeNotifierProvider<MainScreenProvider>(
    create: (_) => MainScreenProvider(),
  ),
];
