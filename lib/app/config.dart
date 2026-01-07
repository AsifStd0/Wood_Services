enum Environment { development, production }

class Config {
  // ========== ENVIRONMENT CONFIGURATION ==========
  static const Environment currentEnvironment = Environment.development;

  // Environment-based URLs
  static const String _devBaseUrl = "http://192.168.18.107:5001";

  static const String _prodBaseUrl = "https://api.woodservice.com";

  // Get current base URL based on environment
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return _devBaseUrl;
      case Environment.production:
        return _prodBaseUrl;
    }
  }

  // API endpoints
  static const String apiPath = "/api";

  // Full API base URL
  static String get apiBaseUrl => baseUrl + apiPath;

  // ========== TIMEOUTS ==========
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========== HEADERS ==========
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ========== ENVIRONMENT HELPERS ==========
  static bool get isDevelopment =>
      currentEnvironment == Environment.development;
  static bool get isProduction => currentEnvironment == Environment.production;

  static String get environmentName {
    switch (currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.production:
        return 'Production';
    }
  }
}
