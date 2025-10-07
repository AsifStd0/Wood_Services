import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  String? _userId;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  // Initialize socket connection
  Future<void> initializeSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      final token = prefs.getString('token');

      if (_userId == null || token == null) {
        print('❌ User not authenticated');
        return;
      }

      _socket = IO.io(
        'http://localhost:5000', // Your backend URL
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _socket!.onConnect((_) {
        print('🔌 Socket connected');

        // Notify server about user connection
        _socket!.emit('user_connected', {
          'userId': _userId,
          'timestamp': DateTime.now().toString(),
        });
      });

      _socket!.onDisconnect((_) => print('🔌 Socket disconnected'));
      _socket!.onError((error) => print('❌ Socket error: $error'));

      // Connect to server
      _socket!.connect();
    } catch (e) {
      print('❌ Socket initialization error: $e');
    }
  }

  // Send message
  void sendMessage(String receiverId, String message) {
    if (_socket == null || !_socket!.connected) {
      print('❌ Socket not connected');
      return;
    }

    _socket!.emit('send_message', {
      'senderId': _userId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now().toString(),
    });
  }

  // Listen for new messages
  void onNewMessage(Function(dynamic) callback) {
    _socket?.on('new_message', callback);
  }

  // Typing indicators
  void startTyping(String receiverId) {
    _socket?.emit('typing_start', {'receiverId': receiverId});
  }

  void stopTyping(String receiverId) {
    _socket?.emit('typing_stop', {'receiverId': receiverId});
  }

  // Order updates
  void sendOrderUpdate(Map<String, dynamic> orderData) {
    _socket?.emit('order_update', orderData);
  }

  // Listen for order updates
  void onOrderUpdate(Function(dynamic) callback) {
    _socket?.on('new_order', callback);
    _socket?.on('order_status_update', callback);
  }

  // Disconnect socket
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  bool get isConnected => _socket?.connected ?? false;
  IO.Socket? get socket => _socket;
}
