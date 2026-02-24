/// App Constants
/// NOTE: API endpoints are now in lib/app/ap_endpoint.dart
/// NOTE: App strings are now in lib/core/constants/app_strings.dart
class AppConstants {
  // ========== STORAGE KEYS ==========
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String languageKey = 'app_language';
  static const String darkModeKey = 'dark_mode';

  // ========== TIMEOUTS ==========
  // NOTE: Timeouts are now in Config class
  // Use Config.connectTimeout and Config.receiveTimeout
}

// // Or if you prefer extension methods for responsive design
// extension ResponsiveExtension on num {
//   double get w => this * 1.0; // Adjust based on your responsive logic
//   double get h => this * 1.0; // Adjust based on your responsive logic
//   double get r => this * 1.0; // Adjust based on your responsive logic
// }
