import 'package:wood_service/core/services/base_local_storage_service.dart';

abstract class SellerLocalStorageService implements BaseLocalStorageService {
  // Seller-specific methods
  Future<void> saveSellerToken(String token);
  Future<String?> getSellerToken();

  // ✅ Update these to match actual usage:
  Future<void> saveSellerData(Map<String, dynamic> sellerData); // Changed
  Future<Map<String, dynamic>?> getSellerData(); // Changed

  Future<void> saveSellerLoginStatus(bool isLoggedIn);
  Future<bool?> getSellerLoginStatus();
  Future<bool> isSellerLoggedIn(); // ✅ Add if needed
  Future<void> sellerLogout(); // ✅ Add if needed
  Future<void> deleteSellerAuth();
}
