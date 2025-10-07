import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/views/auth/login.dart/login_screen.dart';
import 'package:wood_service/views/auth/register.dart/otp_screen.dart';
import 'package:wood_service/views/auth/register.dart/register_screen.dart';
import 'package:wood_service/views/auth/splash/sllides.dart';
import 'package:wood_service/views/auth/splash/splash_screen.dart';
import 'package:wood_service/views/home/home_screen.dart';
import 'package:wood_service/views/home/product_detail.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),

      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SplashScreen()),
      ),

      GoRoute(
        path: '/slides',
        pageBuilder: (context, state) => const MaterialPage(child: Slides()),
      ),

      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const MaterialPage(child: LoginScreen()),
      ),

      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SignupScreen()),
      ),

      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) => const MaterialPage(child: OtpScreen()),
      ),

      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            const MaterialPage(child: FurniHomeScreen()),
      ),

      // Updated route with parameter
      GoRoute(
        path: '/productDetail/:productId',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return MaterialPage(child: ProductDetailScreen(productId: productId));
        },
      ),
    ],
  );
}

// import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';
// import 'package:wood_service/views/auth/login.dart/login_screen.dart';
// import 'package:wood_service/views/auth/register.dart/otp_screen.dart';
// import 'package:wood_service/views/auth/register.dart/register_screen.dart';
// import 'package:wood_service/views/auth/splash/sllides.dart';
// import 'package:wood_service/views/auth/splash/splash_screen.dart';
// import 'package:wood_service/views/home/home_screen.dart';
// import 'package:wood_service/views/home/product_detail.dart';

// class AppRouter {
//   static final router = GoRouter(
//     routes: [
//       // GoRoute(path: '/', redirect: (context, state) => '/splash'),

//       // GoRoute(
//       //   path: '/splash',
//       //   pageBuilder: (context, state) =>
//       //       const MaterialPage(child: SplashScreen()),
//       // ),
//       GoRoute(path: '/', redirect: (context, state) => '/selection'),

//       GoRoute(
//         path: '/selection',
//         pageBuilder: (context, state) =>
//             const MaterialPage(child: SelectionScreen()),
//       ),

//       GoRoute(
//         path: '/slides',
//         pageBuilder: (context, state) => const MaterialPage(child: Slides()),
//       ),

//       GoRoute(
//         path: '/login',
//         pageBuilder: (context, state) =>
//             const MaterialPage(child: LoginScreen()),
//       ),

//       GoRoute(
//         path: '/signup',
//         pageBuilder: (context, state) =>
//             const MaterialPage(child: SignupScreen()),
//       ),

//       GoRoute(
//         path: '/otp',
//         pageBuilder: (context, state) => const MaterialPage(child: OtpScreen()),
//       ),

//       GoRoute(
//         path: '/home',
//         pageBuilder: (context, state) =>
//             const MaterialPage(child: FurniHomeScreen()),
//       ),

//       // Updated route with parameter
//       GoRoute(
//         path: '/productDetail/:productId',
//         pageBuilder: (context, state) {
//           final productId = state.pathParameters['productId']!;
//           return MaterialPage(child: ProductDetailScreen(productId: productId));
//         },
//       ),
//     ],
//   );
// }
