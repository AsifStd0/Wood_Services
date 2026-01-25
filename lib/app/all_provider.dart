// app/providers.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';
import 'package:wood_service/views/Buyer/buyer_main/buyer_main_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/views/Buyer/payment/rating/review_provider.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/views/Seller/data/services/new_service/auth_service.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_requests_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';

List<SingleChildWidget> appProviders = [
  // Services
  Provider<UnifiedLocalStorageServiceImpl>(
    create: (context) => locator<UnifiedLocalStorageServiceImpl>(),
  ),

  Provider<AuthService>(create: (context) => locator<AuthService>()),

  // ViewModels
  ChangeNotifierProvider<RegisterViewModel>(
    create: (context) => locator<RegisterViewModel>(),
  ),
  ChangeNotifierProvider<MainScreenProvider>(
    create: (context) => locator<MainScreenProvider>(),
  ),
  ChangeNotifierProvider<SellerSettingsProvider>(
    create: (context) => locator<SellerSettingsProvider>(),
  ),

  ChangeNotifierProvider<SellerProductProvider>(
    create: (context) => locator<SellerProductProvider>(),
  ),

  ChangeNotifierProvider<BuyerHomeViewProvider>(
    create: (context) => locator<BuyerHomeViewProvider>(),
  ),

  ChangeNotifierProvider<BuyerCartViewModel>(
    create: (context) => locator<BuyerCartViewModel>(),
  ),
  ChangeNotifierProvider<FavoriteProvider>(
    create: (context) => locator<FavoriteProvider>(),
  ),

  // ChangeNotifierProvider<SellerStatsProvider>(
  //   create: (context) => locator<SellerStatsProvider>(),
  // ),
  ChangeNotifierProvider<OrdersViewModel>(
    create: (context) => locator<OrdersViewModel>(),
  ),
  ChangeNotifierProvider(create: (_) => ReviewProvider()), // Add this
  // OrdersViewModel
  ChangeNotifierProvider<BuyerChatProvider>(
    create: (context) => locator<BuyerChatProvider>(),
  ),
  ChangeNotifierProvider<BuyerOrderProvider>(
    create: (context) => locator<BuyerOrderProvider>(),
  ),

  ChangeNotifierProvider(create: (_) => locator<VisitRequestsProvider>()),
];
