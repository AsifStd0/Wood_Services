// utils/connection_tester.dart
import 'package:dio/dio.dart';

class ConnectionTester {
  static Future<ConnectionResult> testConnection(String baseUrl) async {
    print('\n🔍 Testing connection to: $baseUrl');

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    try {
      // Test 1: Basic endpoint
      print('   Testing / endpoint...');
      final rootResponse = await dio.get('/');

      // Test 2: Health endpoint
      print('   Testing /api/health endpoint...');
      final healthResponse = await dio.get('/api/health');

      return ConnectionResult(
        success: true,
        baseUrl: baseUrl,
        message: 'Connection successful!',
        data: {'root': rootResponse.data, 'health': healthResponse.data},
      );
    } on DioException catch (e) {
      String errorMessage = 'Connection failed';

      if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Check if Node.js is running.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Server might be offline.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout.';
      } else if (e.response != null) {
        errorMessage = 'Server error: ${e.response!.statusCode}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }

      return ConnectionResult(
        success: false,
        baseUrl: baseUrl,
        message: errorMessage,
        error: e,
      );
    } catch (e) {
      return ConnectionResult(
        success: false,
        baseUrl: baseUrl,
        message: 'Unexpected error: $e',
        error: e,
      );
    }
  }

  static Future<List<ConnectionResult>> testAllUrls(List<String> urls) async {
    final results = <ConnectionResult>[];

    for (var url in urls) {
      final result = await testConnection(url);
      results.add(result);
    }

    return results;
  }

  static Future<String?> findWorkingUrl(List<String> urls) async {
    print('\n🔎 Searching for working server URL...');

    for (var url in urls) {
      final result = await testConnection(url);
      if (result.success) {
        print('✅ Found working URL: $url');
        return url;
      }
    }

    print('❌ No working URL found');
    return null;
  }
}

class ConnectionResult {
  final bool success;
  final String baseUrl;
  final String message;
  final Map<String, dynamic>? data;
  final dynamic error;

  ConnectionResult({
    required this.success,
    required this.baseUrl,
    required this.message,
    this.data,
    this.error,
  });

  @override
  String toString() {
    return 'ConnectionResult{success: $success, baseUrl: $baseUrl, message: $message}';
  }
}
