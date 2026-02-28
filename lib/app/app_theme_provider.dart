import 'package:flutter/foundation.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/core/utils/constants.dart';

/// App-level theme provider. Controls light/dark mode and persists to storage.
/// Used by [MaterialApp] in main.dart so the whole app respects the setting.
class AppThemeProvider extends ChangeNotifier {
  AppThemeProvider(this._storage) {
    _loadDarkMode();
  }

  final UnifiedLocalStorageServiceImpl _storage;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> _loadDarkMode() async {
    try {
      final saved = await _storage.getBool(AppConstants.darkModeKey);
      _isDarkMode = saved ?? false;
      if (kDebugMode) {
        // ignore: avoid_print
        print('🌙 AppThemeProvider: loaded darkMode=$_isDarkMode');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('🌙 AppThemeProvider: loadDarkMode error $e');
      }
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;
    _isDarkMode = enabled;
    await _storage.saveBool(AppConstants.darkModeKey, enabled);
    notifyListeners();
    if (kDebugMode) {
      // ignore: avoid_print
      print('🌙 AppThemeProvider: darkMode set to $enabled');
    }
  }
}
