import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/Responsive/screen_utils.dart';
import 'package:wood_service/app/all_provider.dart';
import 'package:wood_service/app/app_theme_provider.dart';
import 'package:wood_service/app/helper.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/theme/app_theme.dart';
import 'package:wood_service/views/Buyer/buyer_main/buyer_main.dart';
import 'package:wood_service/views/Seller/main_seller_screen.dart';
import 'package:wood_service/views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Setup
    await setupLocator();
    await checkAuthStatus();

    // Run app
    runApp(const AppWithProviders());
  } catch (e) {
    print('❌ App start error: $e');
  }
}

class AppWithProviders extends StatelessWidget {
  const AppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: ScreenUtils.initWidget(child: const MyApp()),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            // Initialize responsive system
            ScreenUtils.init(context);
            return child ?? const SizedBox();
          },
          home: _getInitialScreen(),
        );
      },
    );
  }

  Widget _getInitialScreen() {
    // Check auth and show correct screen
    if (isUserLoggedIn) {
      switch (userRole) {
        case 'seller':
          return const MainSellerScreen();
        case 'buyer':
          return const BuyerMainScreen();
        // case 'admin':
        //   return const AdminMainScreen();
        default:
          return const OnboardingScreen();
      }
    } else {
      return const OnboardingScreen();
    }
  }
}
