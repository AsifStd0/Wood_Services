// core/services/buyer_local_storage_service.dart
import 'base_local_storage_service.dart';

abstract class BuyerLocalStorageService implements BaseLocalStorageService {
  // Buyer-specific methods
  Future<void> saveBuyerToken(String token);
  Future<String?> getBuyerToken();

  // ✅ These methods are missing in your current interface:
  Future<void> saveBuyerData(
    Map<String, dynamic> buyerData,
  ); // Changed from String
  Future<Map<String, dynamic>?> getBuyerData(); // Changed from String?

  Future<void> saveBuyerLoginStatus(bool isLoggedIn);
  Future<bool?> getBuyerLoginStatus();
  Future<void> saveBuyerLastLogin();
  Future<bool> isBuyerLoggedIn(); // ✅ Add this
  Future<void> buyerLogout(); // ✅ Add this
  Future<void> deleteBuyerAuth();
}
