// features/seller_settings/data/repositories/seller_settings_repository_impl.dart
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';
import 'package:wood_service/views/Seller/data/services/seller_settings_service.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/setting_data/seller_settings_repository.dart';

class SellerSettingsRepositoryImpl implements SellerSettingsRepository {
  final SellerSettingsService _dataSource;

  SellerSettingsRepositoryImpl(this._dataSource);

  @override
  Future<UserModel?> getSellerProfile() => _dataSource.getSellerProfile();

  @override
  Future<UserModel> updateSellerProfile({
    required Map<String, dynamic> updates,
    List<Map<String, dynamic>>? files,
  }) => _dataSource.updateSellerProfile(updates: updates, files: files);

  @override
  Future<UserModel> refreshProfile() => _dataSource.refreshProfile();

  @override
  Future<bool> logout() => _dataSource.logout();
}
