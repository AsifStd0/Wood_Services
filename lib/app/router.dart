import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/forgot_password/forgot_password.dart';
import 'package:wood_service/views/Seller/phone_verification/phone_verification.dart';
import 'package:wood_service/views/Seller/seller_main.dart';
import 'package:wood_service/views/Seller/seller_signup.dart/seller_signup.dart';
import 'package:wood_service/views/Seller/set_password/set_new_assword.dart';
import 'package:wood_service/views/auth/login.dart/login_screen.dart';
import 'package:wood_service/views/auth/register.dart/register_screen.dart';
import 'package:wood_service/views/auth/splash/splash_screen.dart';
import 'package:wood_service/views/home/seller_home.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      // GoRoute(path: '/', redirect: (context, state) => '/splash'),

      // GoRoute(
      //   path: '/splash',
      //   pageBuilder: (context, state) =>
      //       const MaterialPage(child: SplashScreen()),
      // ),
      GoRoute(path: '/', redirect: (context, state) => '/selection'),

      GoRoute(
        path: '/selection',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SelectionScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => MaterialPage(child: LoginScreen()),
      ),

      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => MaterialPage(child: SignUpScreen()),
      ),

      GoRoute(
        path: '/seller_signup',
        pageBuilder: (context, state) => MaterialPage(child: SellerSignup()),
      ),

      GoRoute(
        path: '/forgot',
        pageBuilder: (context, state) => MaterialPage(child: ForgotPassword()),
      ),

      GoRoute(
        path: '/new_password',
        pageBuilder: (context, state) =>
            MaterialPage(child: SetNewPasswordScreen()),
      ),
      GoRoute(
        path: '/phone_verificaion',
        pageBuilder: (context, state) =>
            MaterialPage(child: PhoneVerificationScreen()),
      ),

      GoRoute(
        path: '/seller',
        pageBuilder: (context, state) =>
            MaterialPage(child: FurnitureHomeScreen()),
      ),

      // ! *****
      GoRoute(
        path: '/main_seller',
        pageBuilder: (context, state) => MaterialPage(child: MainScreen()),
      ),
      // ! ********. Seller Signup

      // GoRoute(
      //   path: '/home',
      //   pageBuilder: (context, state) =>
      //       const MaterialPage(child: FurniHomeScreen()),
      // ),

      // // Updated route with parameter
      // GoRoute(
      //   path: '/productDetail/:productId',
      //   pageBuilder: (context, state) {
      //     final productId = state.pathParameters['productId']!;
      //     return MaterialPage(child: ProductDetailScreen(productId: productId));
      //   },
      // ),
    ],
  );
}
