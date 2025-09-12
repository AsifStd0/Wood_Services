class AppConstants {
  static const String appName = 'Wood Service';
  static const String apiBaseUrl = 'https://api.woodservice.com';
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String products = '/products';
  static const String orders = '/orders';
}

class AppStrings {
  static const String welcome = 'Welcome to Wood Service';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String alreadyHaveAccount = 'Already have an account?';
}

// // Or if you prefer extension methods for responsive design
// extension ResponsiveExtension on num {
//   double get w => this * 1.0; // Adjust based on your responsive logic
//   double get h => this * 1.0; // Adjust based on your responsive logic
//   double get r => this * 1.0; // Adjust based on your responsive logic
// }
