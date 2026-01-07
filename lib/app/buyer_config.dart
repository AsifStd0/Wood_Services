// ========== ALL API ENDPOINTS IN ONE CLASS ==========
class Endpoints {
  // ========== SELLER ROUTES ==========
  static const String sellerRegister = '/api/seller/auth/register';
  static const String sellerLogin = '/api/seller/auth/login';
  static const String sellerProfile = '/api/seller/auth/profile';

  static const String sellerProducts = '/api/seller/products';
  static String sellerProductById(String id) => '$sellerProducts/$id';
  static String sellerProductStatus(String id) => '$sellerProducts/$id/status';
  static String sellerProductVariants(String id) =>
      '$sellerProducts/$id/variants';
  static String sellerProductMedia(String id) => '$sellerProducts/$id/media';

  static const String sellerOrders = '/api/seller/orders';
  static String sellerOrderById(String id) => '$sellerOrders/$id';
  static String sellerOrderStatus(String id) => '$sellerOrders/$id/status';

  static const String sellerChat = '/api/seller/chat';
  static const String sellerChatDashboard = '$sellerChat/dashboard';
  static const String sellerChatList = '$sellerChat/list';
  static const String sellerChatStats = '$sellerChat/stats';
  static String sellerProductChats(String id) =>
      '$sellerChat/products/$id/chats';
  static String sellerOrderChats(String id) => '$sellerChat/orders/$id/chats';
  static String sellerChatById(String id) => '$sellerChat/$id';
  static const String sellerStartChat = '$sellerChat/start';
  static const String sellerSearchChats = '$sellerChat/search';
  static String sellerArchiveChat(String id) => '$sellerChat/archive/$id';
  static const String sellerUnreadCount = '$sellerChat/unread-count';
  static const String sellerSendMessage = '$sellerChat/send';
  static String sellerChatMessages(String id) => '$sellerChat/$id/messages';
  static const String sellerMarkAsRead = '$sellerChat/mark-read';
  static String sellerDeleteMessage(String id) => '$sellerChat/message/$id';

  // ========== BUYER ROUTES ==========
  static const String buyerRegister = '/api/buyer/auth/register';
  static const String buyerLogin = '/api/buyer/auth/login';
  static const String buyerProfile = '/api/buyer/auth/profile';

  static const String buyerProducts = '/api/buyer/products';
  static String buyerProductById(String id) => '$buyerProducts/$id';
  static const String buyerSearchProducts = '$buyerProducts/search';

  static const String buyerFavorites = '/api/buyer/favorites';
  static String buyerToggleFavorite(String id) => '$buyerFavorites/toggle/$id';
  static String buyerCheckFavorite(String id) => '$buyerFavorites/check/$id';
  static const String buyerFavoriteCount = '$buyerFavorites/count';
  static String buyerRemoveFavorite(String id) => '$buyerFavorites/$id';
  static const String buyerClearFavorites = '$buyerFavorites/clear';

  static const String buyerCart = '/api/buyer/cart';
  static const String buyerCartCount = '$buyerCart/count';
  static const String buyerAddToCart = '$buyerCart/add';
  static String buyerUpdateCartItem(String id) => '$buyerCart/update/$id';
  static String buyerRemoveCartItem(String id) => '$buyerCart/remove/$id';
  static const String buyerClearCart = '$buyerCart/clear';
  static const String buyerRequestBuy = '$buyerCart/request/buy';
  static const String buyerDirectBuy = '$buyerCart/direct-buy';
  static const String buyerCartRequests = '$buyerCart/requests';
  static String buyerCartRequestDetails(String id) => '$buyerCart/requests/$id';
  static String buyerCancelRequest(String id) =>
      '$buyerCart/requests/$id/cancel';

  static const String buyerOrders = '/api/buyer/orders';
  static String buyerOrderById(String id) => '$buyerOrders/$id';
  static String buyerCancelOrder(String id) => '$buyerOrders/$id/cancel';
  static String buyerMarkReceived(String id) => '$buyerOrders/$id/received';
  static const String buyerOrderSummary = '$buyerOrders/stats/summary';
  static String buyerSubmitReview(String id) => '$buyerOrders/$id/review';

  static const String buyerReviews = '/api/buyer/reviews';
  static String buyerProductReviews(String id) => '$buyerReviews/product/$id';
  static const String buyerMyReviews = '$buyerReviews/my';
  static const String buyerReviewableOrders = '$buyerReviews/orders';
  static String buyerUpdateReview(String id) => '$buyerReviews/$id';
  static String buyerDeleteReview(String id) => '$buyerReviews/$id';
  static String buyerMarkHelpful(String id) => '$buyerReviews/$id/helpful';

  // ========== GENERAL CHAT ROUTES ==========
  static const String chat = '/api/chat';
  static const String chatStart = '$chat/start';
  static const String chatList = '$chat/list';
  static const String chatSearch = '$chat/search';
  static String chatArchive(String id) => '$chat/archive/$id';
  static const String chatUnreadCount = '$chat/unread-count';
  static const String chatSendMessage = '$chat/send';
  static String chatMessages(String id) => '$chat/$id/messages';
  static const String chatMarkAsRead = '$chat/mark-read';
  static String chatDeleteMessage(String id) => '$chat/message/$id';
}
