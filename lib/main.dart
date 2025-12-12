import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/all_provider.dart';
import 'package:wood_service/app/helper.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Setup GetIt dependency injection
    await setupLocator();

    // Check auth status BEFORE running app
    await checkAuthStatus();

    // Test connection before proceeding
    await testInitialConnection();

    // Run app with all providers
    runApp(AppWithProviders());
  } catch (e) {
    print('❌ Failed to initialize app: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class AppWithProviders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: MyApp(
        isSellerLoggedIn: isSellerLoggedInCheck,
        workingServerUrl: workingServerUrl,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isSellerLoggedIn;
  final String? workingServerUrl;

  MyApp({required this.isSellerLoggedIn, this.workingServerUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // routerConfig: AppRouter.createRouter(isSellerLoggedIn: isSellerLoggedIn),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => dismissKeyboard(context),
          child: child,
        );
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  ErrorApp({required this.error});

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
