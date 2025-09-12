import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/views/auth/login.dart/login_screen.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const MaterialPage(child: LoginScreen()),
      ),
      // GoRoute(
      //   path: '/home',
      //   pageBuilder: (context, state) => const MaterialPage(child: HomeScreen()),
      // ),
      // GoRoute(
      //   path: '/orders',
      //   pageBuilder: (context, state) => const MaterialPage(child: OrderListScreen()),
      // ),
      // GoRoute(
      //   path: '/settings',
      //   pageBuilder: (context, state) => const MaterialPage(child: SettingsScreen()),
      // ),
    ],
  );
}
