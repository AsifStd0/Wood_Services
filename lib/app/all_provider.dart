// lib/app/providers.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/local_storage_service.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_view_model.dart';
import 'package:wood_service/views/Seller/data/models/shop_model.dart';
import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/services/profile_service.dart';
import 'package:wood_service/views/Seller/data/services/shop_service.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_home_view_model.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_settings_view_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_chating/chat_view_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';

List<SingleChildWidget> appProviders = [
  // ========== SERVICES (Synchronous) ==========
  Provider<ShopService>(create: (_) => locator<ShopService>()),

  Provider<ProductRepository>(create: (_) => locator<ProductRepository>()),

  Provider<OrderRepository>(create: (_) => locator<OrderRepository>()),

  // ========== SELLER VIEWMODELS ==========
  ChangeNotifierProvider<SellerHomeViewModel>(
    create: (context) => SellerHomeViewModel(context.read<ShopService>()),
  ),

  ChangeNotifierProvider<SellerSettingsViewModel>(
    create: (context) => SellerSettingsViewModel(
      context.read<ShopService>(),
      ShopSeller(
        name: 'Crafty Creations',
        description: 'Tell us about your shop...',
        rating: 4.8,
        reviewCount: 120,
        categories: ['Handmade Jewelry'],
        deliveryLeadTime: '1-3 Business Days',
        returnPolicy: '30-Day Returns',
        isVerified: true,
      ),
    ),
  ),

  ChangeNotifierProvider<OrdersViewModel>(
    create: (context) => OrdersViewModel(context.read<OrderRepository>()),
  ),

  // // ========== SHOP SETTINGS VIEWMODEL (Lazy Load) ==========
  ChangeNotifierProvider<ProfileViewModel>(
    create: (_) => ProfileViewModel(
      authService: locator<ProfileService>(),
      localStorageService: locator<LocalStorageService>(),
    ),
  ),

  ChangeNotifierProvider<SellerChatViewModel>(
    create: (_) => SellerChatViewModel(),
  ),

  // ========== AUTH VIEWMODELS ==========
  ChangeNotifierProvider<SellerSignupViewModel>(
    create: (_) => locator<SellerSignupViewModel>(),
  ),

  // ========== SHARED VIEWMODELS ==========
  ChangeNotifierProvider<BuyerHomeViewModel>(
    create: (_) => BuyerHomeViewModel(),
  ),
];
