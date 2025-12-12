// api_config.dart
class ApiConfig {
  // Base URLs
  static const String baseUrl = 'http://192.168.18.107:5000';

  // static const String apiKey = 'your_api_key_here';

  // Seller Endpoints
  static const String sellerRegister = '/api/seller/auth/register';
  static const String sellerLogin = '/api/seller/auth/login';
  static const String sellerProfile = '/api/seller/auth/profile';
  static const String sellerProducts = '/api/seller/products';
  static const String sellerSettings = '/api/seller/settings';

  // Buyer Endpoints
  static const String buyerRegister = '/api/buyer/auth/register';
  static const String buyerLogin = '/api/buyer/auth/login';
  static const String buyerProfile = '/api/buyer/auth/profile';

  // Chat Endpoints
  static const String chatConversations = '/api/chat/conversations';
  static const String chatMessages = '/api/chat/messages';
}
