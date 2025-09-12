import 'package:flutter/material.dart';
import 'package:wood_service/app/config.dart';
import 'package:wood_service/app/router.dart';
import 'package:wood_service/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
