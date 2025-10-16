import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Cart/cart_screen.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_screen.dart';
import 'package:wood_service/views/Buyer/Messages/message_screen.dart';
import 'package:wood_service/views/Buyer/Notificaion/notificaion_screen.dart';
import 'package:wood_service/views/Buyer/forgot_password/forgot_password.dart';
import 'package:wood_service/views/Buyer/order_screen/order_screen.dart';
import 'package:wood_service/views/Buyer/payment/checkout.dart';
import 'package:wood_service/views/Buyer/payment/order_confirmation.dart';
import 'package:wood_service/views/Buyer/phone_verification/phone_verification.dart';
import 'package:wood_service/views/Buyer/product_detail/product_detail.dart';
import 'package:wood_service/views/Buyer/buyer_main.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup.dart';
import 'package:wood_service/views/Buyer/profile/profile.dart';
import 'package:wood_service/views/Buyer/set_password/set_new_assword.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup.dart';
import 'package:wood_service/views/auth/login.dart/login_screen.dart';
import 'package:wood_service/views/splash_screen.dart';
import 'package:wood_service/views/Buyer/home/seller_home.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash & Auth Routes
      // GoRoute(
      //   path: '/',
      //   pageBuilder: (context, state) =>
      //       const MaterialPage(child: SplashScreen()),
      // ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SelectionScreen()),
      ),
      GoRoute(
        path: '/buyer_login',
        pageBuilder: (context, state) => MaterialPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/buyer_signup',
        pageBuilder: (context, state) => MaterialPage(child: BuyerSignup()),
      ),

      GoRoute(
        path: '/forgot',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ForgotPassword()),
      ),
      GoRoute(
        path: '/new_password',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SetNewPasswordScreen()),
      ),
      GoRoute(
        path: '/phone_verificaion',
        pageBuilder: (context, state) =>
            const MaterialPage(child: PhoneVerificationScreen()),
      ),

      // Main Buyer App (Bottom Navigation)
      GoRoute(
        path: '/main_buyer',
        pageBuilder: (context, state) =>
            const MaterialPage(child: MainScreen()),
      ),

      // Individual Screens (Can be accessed directly)
      // GoRoute(
      //   path: '/seller_signup',
      //   pageBuilder: (context, state) =>
      //       const MaterialPage(child: SellerSignup()),
      // ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            const MaterialPage(child: FurnitureHomeScreen()),
      ),
      GoRoute(
        path: '/favorites',
        pageBuilder: (context, state) =>
            const MaterialPage(child: FavoritesScreen()),
      ),
      GoRoute(
        path: '/cart',
        pageBuilder: (context, state) =>
            const MaterialPage(child: CartScreen()),
      ),
      GoRoute(
        path: '/messages',
        pageBuilder: (context, state) =>
            const MaterialPage(child: MessagesScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ProfileScreen()),
      ),

      // Product Routes
      GoRoute(
        path: '/productDetail/:productId',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return MaterialPage(child: ProductDetailScreen(productId: productId));
        },
      ),

      // Order Management Routes
      GoRoute(
        path: '/orders',
        pageBuilder: (context, state) =>
            const MaterialPage(child: OrdersScreen()),
      ),
      GoRoute(
        path: '/orders/:tabIndex',
        pageBuilder: (context, state) {
          final tabIndex =
              int.tryParse(state.pathParameters['tabIndex'] ?? '0') ?? 0;
          return MaterialPage(child: OrdersScreen(initialTab: tabIndex));
        },
      ),

      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) =>
            const MaterialPage(child: NotificationsScreen()),
      ),
      // Checkout & Payment Routes
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) =>
            const MaterialPage(child: CheckoutScreen()),
      ),
      GoRoute(
        path: '/order_confirmation',
        pageBuilder: (context, state) =>
            MaterialPage(child: OrderConfirmationScreen()),
      ),

      // ! ********
      GoRoute(
        path: '/seller_signup',
        pageBuilder: (context, state) => MaterialPage(child: SellerSignup()),
      ),
    ],
  );
}
