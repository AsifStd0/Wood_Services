import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/main_seller_screen.dart';
import 'package:wood_service/views/Seller/seller_login.dart/seller_login_provider.dart';
import 'package:wood_service/views/splash/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SellerAuthProvider>(context);

    if (authProvider.isLoading) {
      return _buildLoadingScreen();
    }

    return authProvider.checkSellerToken
        ? MainSellerScreen()
        : OnboardingScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.store_rounded, size: 40, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Wood Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Checking authentication...',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
// class AuthCheckWidget extends StatefulWidget {
//   const AuthCheckWidget({super.key});

//   @override
//   _AuthCheckWidgetState createState() => _AuthCheckWidgetState();
// }

// class _AuthCheckWidgetState extends State<AuthCheckWidget> {
//   final SellerAuthService _authService = locator<SellerAuthService>();
//   bool _isChecking = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkAuthStatus();
//   }

//   Future<void> _checkAuthStatus() async {
//     try {
//       // Check if seller is logged in
//       final isSellerLoggedIn = await _authService.isSellerLoggedIn();

//       if (isSellerLoggedIn) {
//         print('✅ Seller is logged in, going to MainSellerScreen');
//         // Seller is logged in - go to seller dashboard
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => MainSellerScreen()),
//           );
//         });
//       } else {
//         print('⚠️ No user logged in, showing onboarding');
//         // No one logged in - show onboarding
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => OnboardingScreen()),
//           );
//         });
//       }
//     } catch (e) {
//       print('❌ Error checking auth: $e');
//       // On error, show onboarding
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => OnboardingScreen()),
//         );
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isChecking = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Icon(Icons.store_rounded, size: 40, color: Colors.white),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Wood Service',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               _isChecking ? 'Checking authentication...' : 'Redirecting...',
//               style: TextStyle(color: Colors.grey),
//             ),
//             SizedBox(height: 20),
//             if (_isChecking) CircularProgressIndicator(color: Colors.blue),
//           ],
//         ),
//       ),
//     );
//   }
// }
