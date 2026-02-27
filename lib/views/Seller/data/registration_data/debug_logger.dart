// logger.dart
import 'package:flutter/foundation.dart';

class DebugLogger {
  static bool get isDebugMode {
    bool inDebug = false;
    assert(inDebug = true); // This only runs in debug mode
    return inDebug;
  }

  static void log(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      // Always log in debug mode
      if (tag != null) {
        debugPrint('[$tag] $message');
      } else {
        debugPrint(message);
      }
    } else {
      // In release mode, only log errors
      if (error != null || stackTrace != null) {
        // You could send these to a crash reporting service
        debugPrint('[ERROR] $message');
        if (error != null) debugPrint('Error: $error');
        if (stackTrace != null) debugPrint('Stack: $stackTrace');
      }
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    // Always log errors
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('   Error: $error');
    if (stackTrace != null) debugPrint('   Stack: $stackTrace');
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ SUCCESS: $message');
    }
  }
}
