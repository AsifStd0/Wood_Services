// screens/connection_status_screen.dart
import 'package:flutter/material.dart';
// import 'package:wood_service/utils/connection_tester.dart';
import 'package:wood_service/views/splash/tester.dart';

class ConnectionStatusScreen extends StatefulWidget {
  final List<String> urlsToTest;

  const ConnectionStatusScreen({super.key, required this.urlsToTest});

  @override
  State<ConnectionStatusScreen> createState() => _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState extends State<ConnectionStatusScreen> {
  List<ConnectionResult> _results = [];
  bool _isTesting = false;
  String? _workingUrl;

  @override
  void initState() {
    super.initState();
    _testConnections();
  }

  Future<void> _testConnections() async {
    setState(() {
      _isTesting = true;
      _results.clear();
      _workingUrl = null;
    });

    final results = await ConnectionTester.testAllUrls(widget.urlsToTest);
    final workingResult = results.firstWhere(
      (result) => result.success,
      orElse: () => results.first,
    );

    setState(() {
      _results = results;
      _isTesting = false;
      if (workingResult.success) {
        _workingUrl = workingResult.baseUrl;
      }
    });
  }

  Future<void> _retryWithDifferentPort(String baseIp) async {
    setState(() => _isTesting = true);

    // Try ports 5000 to 5010
    final urls = List.generate(11, (index) => '$baseIp:${5000 + index}');
    final workingUrl = await ConnectionTester.findWorkingUrl(urls);

    setState(() {
      _isTesting = false;
      _workingUrl = workingUrl;
    });

    if (workingUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found working URL: $workingUrl'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Connection Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isTesting ? null : _testConnections,
            tooltip: 'Retry Test',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Network Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const ListTile(
                      leading: Icon(Icons.laptop, color: Colors.blue),
                      title: Text('Laptop IP'),
                      subtitle: Text('192.168.18.107'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.phone_android, color: Colors.green),
                      title: Text('Mobile IP'),
                      subtitle: Text('192.168.18.94'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Testing connection from mobile → laptop',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Status indicator
            if (_workingUrl != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONNECTION SUCCESSFUL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Working URL: $_workingUrl',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (_results.isNotEmpty && !_isTesting)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONNECTION FAILED',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            'No working server found',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Test button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _testConnections,
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_find),
                label: Text(_isTesting ? 'Testing...' : 'Test Connections'),
              ),
            ),

            const SizedBox(height: 20),

            // Test results
            Expanded(
              child: _isTesting
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: result.success
                              ? Colors.green[50]
                              : Colors.red[50],
                          child: ListTile(
                            leading: result.success
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(Icons.error, color: Colors.red),
                            title: Text(
                              result.baseUrl,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            subtitle: Text(result.message),
                            trailing: result.success
                                ? const Chip(
                                    label: Text('WORKING'),
                                    backgroundColor: Colors.green,
                                    labelStyle: TextStyle(color: Colors.white),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.more_horiz),
                                    onPressed: () => _retryWithDifferentPort(
                                      result.baseUrl.split(':')[0] +
                                          ':' +
                                          result.baseUrl.split(':')[1],
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
            ),

            // Troubleshooting tips
            if (!_isTesting && _workingUrl == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    'Troubleshooting:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. Make sure Node.js server is running on your laptop',
                  ),
                  const Text('2. Check the port number in Node.js console'),
                  const Text('3. Verify both devices are on same WiFi'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () =>
                        _retryWithDifferentPort('http://192.168.137.154'),
                    child: const Text('Try Different Ports (5000-5010)'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
