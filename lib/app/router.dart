import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/payment/order_rating_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash & Auth Routes
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            MaterialPage(child: OnboardingScreen()),
      ),
      GoRoute(
        path: '/selction_screen',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SelectionScreen()),
      ),
      GoRoute(
        path: '/buyer_login',
        pageBuilder: (context, state) =>
            MaterialPage(child: BuyerLoginScreen()),
      ),
      GoRoute(
        path: '/buyer_signup',
        pageBuilder: (context, state) => MaterialPage(child: BuyerSignup()),
      ),

      GoRoute(
        path: '/buyer_forgot',
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
            const MaterialPage(child: SellerHomeScreen()),
      ),
      GoRoute(
        path: '/favorites',
        pageBuilder: (context, state) =>
            const MaterialPage(child: FavoritesScreen()),
      ),
      GoRoute(
        path: '/cart',
        pageBuilder: (context, state) =>
            const MaterialPage(child: BuyerCartScreen()),
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

      GoRoute(
        path: '/order_rating',
        pageBuilder: (context, state) => MaterialPage(
          child: OrderRatingScreen(
            orderNumber: '12345678',
            items: ['Modern Sofa', 'Coffee Table', 'Accent Chair'],
          ),
        ),
      ),

      // ! ******** Seller
      GoRoute(
        path: '/seller_signup',
        pageBuilder: (context, state) => MaterialPage(child: SellerSignup()),
      ),
      GoRoute(
        path: '/seller_login',
        pageBuilder: (context, state) => MaterialPage(child: SellerLogin()),
      ),

      GoRoute(
        path: '/main_seller_screen',
        pageBuilder: (context, state) =>
            MaterialPage(child: MainSellerScreen()),
      ),
      GoRoute(
        path: '/seller_home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SellerHomeScreen()),
      ),

      GoRoute(
        path: '/seller_notificaion',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SellerNotificaionScreen()),
      ),
      GoRoute(
        path: '/seller_setting',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SellerSettingsScreen()),
      ),

      GoRoute(
        path: '/seller_order',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OrdersScreenSeller()),
      ),

      GoRoute(
        path: '/seller_add_product',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AddProductScreen()),
      ),

      // VisitRequestsScreen
    ],
  );
}
