// lib/app/providers.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';
import 'package:wood_service/chats/Seller/new_seller_chat/seller_chat_provider.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_provider.dart';
import 'package:wood_service/views/Buyer/login.dart/auth_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_repository.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/rating/review_provider.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_repository_seller.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/seller_login.dart/seller_login_provider.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

List<SingleChildWidget> appProviders = [
  // ========== SERVICES (Synchronous) ==========
  Provider<ProductRepository>(create: (_) => locator<ProductRepository>()),

  // ✅ REMOVE THIS - Already in locator:
  // Provider<OrderRepository>(create: (_) => locator<OrderRepository>()),

  // ========== FAVORITE PROVIDER (Get BuyerLocalStorageService from locator) ==========
  ChangeNotifierProvider<FavoriteProvider>(
    create: (context) => FavoriteProvider(
      locator<BuyerLocalStorageService>(), // ✅ Get from locator
    ),
  ),

  // ========== BUYER PROVIDERS ==========
  ChangeNotifierProxyProvider<FavoriteProvider, BuyerHomeViewModel>(
    create: (context) {
      // This will be created AFTER FavoriteProvider is available
      return BuyerHomeViewModel(
        Provider.of<FavoriteProvider>(context, listen: false),
      );
    },
    update: (context, favoriteProvider, previous) {
      if (previous == null) {
        return BuyerHomeViewModel(favoriteProvider);
      }
      // Update the existing ViewModel if needed
      return previous;
    },
  ),

  ChangeNotifierProvider<BuyerProfileViewProvider>(
    create: (_) => BuyerProfileViewProvider(),
  ),

  // ========== BUYER CART VIEWMODEL ==========
  ChangeNotifierProvider<BuyerCartViewModel>(
    create: (_) => locator<BuyerCartViewModel>(), // ✅ Get from locator
  ),

  // ========== BUYER AUTH PROVIDERS ==========
  ChangeNotifierProvider<BuyerSignupProvider>(
    create: (_) => BuyerSignupProvider(),
  ),

  ChangeNotifierProvider<BuyerAuthProvider>(create: (_) => BuyerAuthProvider()),

  ChangeNotifierProvider<VisitRequestsViewModel>(
    create: (context) => locator<VisitRequestsViewModel>(),
  ),
  // Add Buyer Order Provider
  ChangeNotifierProvider<BuyerOrderProvider>(
    create: (_) => BuyerOrderProvider(
      ApiBuyerOrderRepository(
        storageService: locator<BuyerLocalStorageService>(),
      ),
    ),
  ),
  //!  ========== SELLER VIEWMODELS ==========
  // ✅ FIXED: Use locator.get() or locator() instead of context.read()
  ChangeNotifierProvider(
    create: (_) => SellerAuthProvider(locator<SellerAuthService>()),
  ),

  ChangeNotifierProvider<OrdersViewModel>(
    create: (_) => OrdersViewModel(locator<OrderRepository>()),
  ),

  // ========== SELLER AUTH VIEWMODELS ==========
  ChangeNotifierProvider<SellerSignupViewModel>(
    create: (_) => locator<SellerSignupViewModel>(),
  ),

  // ========== SELLER SETTINGS ==========
  ChangeNotifierProvider<SelllerSettingProvider>(
    create: (_) => locator<SelllerSettingProvider>(),
  ),

  // ========== OTHER PROVIDERS ==========
  ChangeNotifierProvider(create: (_) => BuyerChatProvider()),
  ChangeNotifierProvider(create: (_) => locator<CartProvider>()),
  ChangeNotifierProvider(create: (_) => ReviewProvider()),

  // ! ****
  ChangeNotifierProvider(create: (_) => SellerChatProvider()),
];
