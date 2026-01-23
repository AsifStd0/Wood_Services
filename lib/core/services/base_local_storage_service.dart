// core/services/base_local_storage_service.dart
abstract class BaseLocalStorageService {
  // Core methods
  Future<void> initialize();
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> delete(String key);
  Future<void> clearAll();
  Future<bool> containsKey(String key);
  Future<Set<String>> getAllKeys();
}
