// lib/app/providers.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/chat_provider.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_provider.dart';
import 'package:wood_service/views/Buyer/login.dart/auth_provider.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/rating/review_provider.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Seller/data/services/shop_model.dart';
import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/services/shop_service.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_home_view_model.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_settings_view_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_chating/chat_view_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

List<SingleChildWidget> appProviders = [
  // ========== SERVICES (Synchronous) ==========
  // Provider<ShopService>(create: (_) => locator<ShopService>()),
  Provider<ProductRepository>(create: (_) => locator<ProductRepository>()),
  Provider<OrderRepository>(create: (_) => locator<OrderRepository>()),

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

  // ========== SELLER VIEWMODELS ==========
  // ChangeNotifierProvider<SellerHomeViewModel>(
  //   create: (context) => SellerHomeViewModel(context.read<ShopService>()),
  // ),

  // ChangeNotifierProvider<SellerSettingsViewModel>(
  //   create: (context) => SellerSettingsViewModel(
  //     context.read<ShopService>(),
  //     ShopSeller(
  //       name: 'Crafty Creations',
  //       description: 'Tell us about your shop...',
  //       rating: 4.8,
  //       reviewCount: 120,
  //       categories: ['Handmade Jewelry'],
  //       deliveryLeadTime: '1-3 Business Days',
  //       returnPolicy: '30-Day Returns',
  //       isVerified: true,
  //     ),
  //   ),
  // ),
  ChangeNotifierProvider<OrdersViewModel>(
    create: (context) => OrdersViewModel(context.read<OrderRepository>()),
  ),

  // // ========== SELLER CHAT ==========
  // ChangeNotifierProvider<SellerChatViewModel>(
  //   create: (_) => SellerChatViewModel(),
  // ),

  // ========== SELLER AUTH VIEWMODELS ==========
  ChangeNotifierProvider<SellerSignupViewModel>(
    create: (_) => locator<SellerSignupViewModel>(),
  ),

  // ========== SELLER SETTINGS ==========
  ChangeNotifierProvider<SelllerSettingProvider>(
    create: (_) => locator<SelllerSettingProvider>(),
  ),
  ChangeNotifierProvider(create: (_) => ChatProvider()),
  ChangeNotifierProvider(create: (_) => CartProvider()),
  ChangeNotifierProvider(create: (_) => ReviewProvider()),
];
// // lib/app/providers.dart
// import 'package:provider/provider.dart';
// import 'package:provider/single_child_widget.dart';
// import 'package:wood_service/app/locator.dart';
// import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
// import 'package:wood_service/views/Buyer/Favorite_Screen/buyer_favorite_service.dart';
// import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';
// import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_provider.dart';
// import 'package:wood_service/views/Buyer/login.dart/auth_provider.dart';
// import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
// import 'package:wood_service/views/Seller/data/models/shop_model.dart';
// import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
// import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
// import 'package:wood_service/views/Seller/data/services/shop_service.dart';
// import 'package:wood_service/views/Seller/data/view_models/seller_home_view_model.dart';
// import 'package:wood_service/views/Seller/data/view_models/seller_settings_view_model.dart';
// import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
// import 'package:wood_service/views/Seller/data/views/seller_chating/chat_view_provider.dart';
// import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
// import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

// List<SingleChildWidget> appProviders = [
//   // ========== SERVICES (Synchronous) ==========
//   Provider<ShopService>(create: (_) => locator<ShopService>()),

//   Provider<ProductRepository>(create: (_) => locator<ProductRepository>()),

//   Provider<OrderRepository>(create: (_) => locator<OrderRepository>()),

//   // ========== SELLER VIEWMODELS ==========
//   ChangeNotifierProvider<SellerHomeViewModel>(
//     create: (context) => SellerHomeViewModel(context.read<ShopService>()),
//   ),

//   ChangeNotifierProvider<SellerSettingsViewModel>(
//     create: (context) => SellerSettingsViewModel(
//       context.read<ShopService>(),
//       ShopSeller(
//         name: 'Crafty Creations',
//         description: 'Tell us about your shop...',
//         rating: 4.8,
//         reviewCount: 120,
//         categories: ['Handmade Jewelry'],
//         deliveryLeadTime: '1-3 Business Days',
//         returnPolicy: '30-Day Returns',
//         isVerified: true,
//       ),
//     ),
//   ),

//   ChangeNotifierProvider<OrdersViewModel>(
//     create: (context) => OrdersViewModel(context.read<OrderRepository>()),
//   ),

//   // // ========== SHOP SETTINGS VIEWMODEL (Lazy Load) ==========
//   ChangeNotifierProvider<BuyerProfileViewProvider>(
//     create: (_) => BuyerProfileViewProvider(),
//   ),

//   ChangeNotifierProvider<SellerChatViewModel>(
//     create: (_) => SellerChatViewModel(),
//   ),

//   // ========== AUTH VIEWMODELS ==========
//   ChangeNotifierProvider<SellerSignupViewModel>(
//     create: (_) => locator<SellerSignupViewModel>(),
//   ),

//   // ! ****** Buyer Provider
//   ChangeNotifierProvider<BuyerSignupProvider>(
//     create: (_) => BuyerSignupProvider(),
//   ),
//   ChangeNotifierProvider(create: (_) => BuyerAuthProvider()),

//   ChangeNotifierProvider<SelllerSettingProvider>(
//     create: (_) => locator<SelllerSettingProvider>(),
//   ),
//   ChangeNotifierProvider(create: (context) => FavoriteProvider()),
//   ChangeNotifierProxyProvider<FavoriteProvider, BuyerHomeViewModel>(
//     create: (context) => BuyerHomeViewModel(
//       Provider.of<FavoriteProvider>(context, listen: false),
//     ),
//     update: (context, favoriteProvider, previous) {
//       if (previous == null) {
//         return BuyerHomeViewModel(favoriteProvider);
//       }
//       return previous;
//     },
//   ),
// ];
