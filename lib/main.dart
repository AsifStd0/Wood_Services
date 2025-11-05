import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/models/shop_model.dart';
import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/services/shop_service.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_home_view_model.dart';
import 'package:wood_service/views/Seller/data/view_models/seller_settings_view_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_chating/chat_view_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';
import 'app/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(
    MultiProvider(
      providers: [
        Provider<ShopService>(create: (_) => ShopService()),
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
        Provider<ProductRepository>(
          create: (context) => MockProductRepository(),
        ),
        // FIX: Provide the concrete implementation, not the abstract class
        Provider<OrderRepository>(
          create: (context) => MockOrderRepository(),
          // Use Impl class
        ),
        // FIX: Create OrdersViewModel with the repository
        ChangeNotifierProvider<OrdersViewModel>(
          create: (context) => OrdersViewModel(
            context.read<OrderRepository>(), // Get the repository from provider
          ),
        ),
        ChangeNotifierProvider<ShopSettingsViewModel>(
          create: (context) => ShopSettingsViewModel(),
        ),

        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(),
        ),

        ChangeNotifierProvider<SellerChatViewModel>(
          create: (context) => SellerChatViewModel(),
        ),

        ChangeNotifierProvider(create: (_) => SellerSignupViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
