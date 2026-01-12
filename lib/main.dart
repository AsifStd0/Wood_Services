import 'package:flutter/material.dart';
import 'package:wood_service/app/all_provider.dart';
import 'package:wood_service/app/helper.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await setupLocator();
    await checkAuthStatus();

    // Run app with all providers
    runApp(AppWithProviders());
  } catch (e) {
    print('❌ Failed to initialize app: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class AppWithProviders extends StatelessWidget {
  const AppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: MyApp(
        isSellerLoggedIn: isSellerLoggedInCheck,
        isBuyerLoggedIn: isBuyerLoggedInCheck, // Add this
        workingServerUrl: workingServerUrl,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isSellerLoggedIn;
  final bool isBuyerLoggedIn; // Add this
  final String? workingServerUrl;

  const MyApp({
    super.key,
    required this.isSellerLoggedIn,
    required this.isBuyerLoggedIn, // Add this
    this.workingServerUrl,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: _getInitialScreen(),

      builder: (context, child) {
        return GestureDetector(
          onTap: () => dismissKeyboard(context),
          child: child,
        );
      },
    );
  }

  Widget _getInitialScreen() {
    // Check if seller is logged in
    if (isSellerLoggedIn) {
      return MainSellerScreen();
    }

    // Check if buyer is logged in
    if (isBuyerLoggedIn) {
      return BuyerMainScreen();
    }

    // If neither is logged in, show onboarding
    return OnboardingScreen();
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  'App Initialization Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
