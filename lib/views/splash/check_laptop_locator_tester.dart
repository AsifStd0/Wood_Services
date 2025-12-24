// app/checking_locator.dart
import 'package:wood_service/views/splash/tester.dart';

void verifyRegistrations() {
  print('\n🔧 Verifying service registrations...');

  // List of URLs to try (YOUR SPECIFIC NETWORK)
  final possibleUrls = [
    'http://192.168.137.154:5000', // Your laptop, port 5000
    'http://192.168.1.8:5001', // Your laptop, port 5001
    'http://192.168.137.154:5002', // Your laptop, port 5002
    'http://192.168.137.154:5003', // Your laptop, port 5003
    // Add other common ports if needed
  ];

  // Test connection before proceeding
  testServerConnection(possibleUrls);
}

Future<void> testServerConnection(List<String> urls) async {
  print('\n📡 TESTING SERVER CONNECTION');
  print('============================\n');

  final results = await ConnectionTester.testAllUrls(urls);

  int workingCount = 0;
  for (var result in results) {
    if (result.success) {
      workingCount++;
      print('✅ ${result.baseUrl}');
      print('   Message: ${result.message}');

      // Print server info if available
      if (result.data != null && result.data!['health'] != null) {
        final health = result.data!['health'];
        print('   Server Status: ${health['status']}');
        print('   Server Message: ${health['message']}');
      }
    } else {
      print('❌ ${result.baseUrl}');
      print('   Error: ${result.message}');
    }
    print('');
  }

  if (workingCount == 0) {
    print('⚠️ WARNING: No server connection established!');
    print('\n🔧 TROUBLESHOOTING STEPS:');
    print('   1. Make sure Node.js server is running on your laptop');
    print('   2. Check the port number in Node.js console output');
    print('   3. Verify laptop IP address (should be 192.168.18.107)');
    print('   4. Ensure both devices are on same WiFi network');
    print('   5. Try different port if current one is busy');
    print('   6. Check firewall settings on your Mac');
    print('');
    print('📱 Your Network Info:');
    print('   • Laptop IP: 192.168.18.107');
    print('   • Mobile IP: 192.168.18.94');
    print('   • Both are on 192.168.18.x network ✅');
    print('');
    print('💡 Run these commands on your Mac:');
    print(
      '   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node',
    );
    print(
      '   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/node',
    );
  } else {
    print('🎉 SUCCESS: Found $workingCount working server URL(s)');
  }
}
