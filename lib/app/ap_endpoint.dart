/// Centralized API Endpoints
/// All API endpoints used across the application should be defined here
class ApiEndpoints {
  // ========== BASE URL ==========
  // Base URL is managed in Config class, endpoints here are relative paths

  // ========== AUTHENTICATION ENDPOINTS ==========
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authProfile = '/auth/profile';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';

  // ========== SELLER ENDPOINTS ==========
  static const String sellerBase = '/seller';
  
  // Seller Auth
  static const String sellerRegister = '$sellerBase/auth/register';
  static const String sellerLogin = '$sellerBase/auth/login';
  static const String sellerProfile = '$sellerBase/auth/profile';
  
  // Seller Products/Services
  static const String sellerServices = '$sellerBase/services';
  static String sellerServiceById(String id) => '$sellerServices/$id';
  static String sellerServiceStatus(String id) => '${sellerServiceById(id)}/status';
  static String sellerServiceVariants(String id) => '${sellerServiceById(id)}/variants';
  static String sellerServiceMedia(String id) => '${sellerServiceById(id)}/media';
  static String sellerServiceImages(String id) => '${sellerServiceById(id)}/images';
  
  // Seller Orders
  static const String sellerOrders = '$sellerBase/orders';
  static String sellerOrderById(String id) => '$sellerOrders/$id';
  static String sellerOrderAccept(String id) => '${sellerOrderById(id)}/accept';
  static String sellerOrderStart(String id) => '${sellerOrderById(id)}/start';
  static String sellerOrderComplete(String id) => '${sellerOrderById(id)}/complete';
  static String sellerOrderReject(String id) => '${sellerOrderById(id)}/reject';
  static String sellerOrderCancel(String id) => '${sellerOrderById(id)}/cancel';
  static String sellerOrderNotes(String id) => '${sellerOrderById(id)}/notes';
  static const String sellerOrderStatistics = '$sellerOrders/statistics';
  
  // Seller Settings
  static const String sellerSettings = '$sellerBase/settings';
  static const String sellerStats = '$sellerBase/stats';
  
  // Seller Visit Requests
  static const String sellerVisitRequests = '$sellerBase/visit-requests';
  static String sellerVisitRequestById(String id) => '$sellerVisitRequests/$id';
  static String sellerVisitRequestAccept(String id) => '${sellerVisitRequestById(id)}/accept';
  static String sellerVisitRequestReject(String id) => '${sellerVisitRequestById(id)}/reject';
  
  // Seller Ads
  static const String sellerAds = '/ads/seller';
  static const String sellerMyAds = '$sellerAds/my-ads';

  // ========== BUYER ENDPOINTS ==========
  static const String buyerBase = '/buyer';
  
  // Buyer Services/Products
  static const String buyerServices = '$buyerBase/services';
  static String buyerServiceById(String id) => '$buyerServices/$id';
  
  // Buyer Orders
  static const String buyerOrders = '$buyerBase/orders';
  static String buyerOrderById(String id) => '$buyerOrders/$id';
  static String buyerOrderCancel(String id) => '${buyerOrderById(id)}/cancel';
  static String buyerOrderReview(String id) => '${buyerOrderById(id)}/review';
  static String buyerOrderMarkReceived(String id) => '${buyerOrderById(id)}/mark-received';
  
  // Buyer Cart
  static const String buyerCart = '$buyerBase/cart';
  static const String buyerCartAdd = '$buyerCart/add';
  static const String buyerCartRemove = '$buyerCart/remove';
  static const String buyerCartUpdate = '$buyerCart/update';
  static const String buyerCartClear = '$buyerCart/clear';
  
  // Buyer Favorites
  static const String buyerFavorites = '$buyerBase/favorites';
  static String buyerFavoriteToggle(String serviceId) => '$buyerFavorites/$serviceId/toggle';
  
  // Buyer Visit Requests
  static const String buyerVisitRequests = '$buyerBase/visit-requests';
  static String buyerVisitRequestById(String id) => '$buyerVisitRequests/$id';
  static const String buyerVisitRequestCreate = buyerVisitRequests;
  
  // Buyer Profile
  static const String buyerProfile = '$buyerBase/profile';
  static const String buyerProfileUpdate = buyerProfile;

  // ========== CHAT ENDPOINTS ==========
  static const String chats = '/chats';
  static String chatById(String id) => '$chats/$id';
  static String chatMessages(String id) => '${chatById(id)}/messages';
  static String chatSendMessage(String id) => '${chatById(id)}/send';

  // ========== REVIEWS ENDPOINTS ==========
  static const String reviews = '/reviews';
  static String reviewProduct(String productId) => '$reviews/product/$productId';
  static String reviewOrder(String orderId) => '$reviews/order/$orderId';
  static const String reviewableOrders = '$reviews/orders';

  // ========== NOTIFICATIONS ENDPOINTS ==========
  static const String notifications = '/notifications';
  static String notificationById(String id) => '$notifications/$id';
  static String notificationMarkRead(String id) => '${notificationById(id)}/mark-read';
  static const String notificationsMarkAllRead = '$notifications/mark-all-read';
}
