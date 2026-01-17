// features/seller_settings/domain/repositories/seller_settings_repository.dart
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';

abstract class SellerSettingsRepository {
  Future<UserModel?> getSellerProfile();
  Future<UserModel> updateSellerProfile({
    required Map<String, dynamic> updates,
    List<Map<String, dynamic>>? files,
  });
  Future<bool> logout();
  Future<UserModel> refreshProfile();
}
