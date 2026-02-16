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
}
