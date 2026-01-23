import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';

class BuyerSocketService {
  IO.Socket? _socket;

  final StreamController<BuyerChatModel> _messageStreamController =
      StreamController<BuyerChatModel>.broadcast();
  final StreamController<Map<String, dynamic>> _typingStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _readStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<BuyerChatModel> get onNewMessage => _messageStreamController.stream;
  Stream<Map<String, dynamic>> get onTyping => _typingStreamController.stream;
  Stream<Map<String, dynamic>> get onRead => _readStreamController.stream;

  Future<void> initializeSocket(String token, String userId) async {
    try {
      _socket = IO.io(
        "${Config.apiBaseUrl}",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
              'User-Id': userId,
            })
            .build(),
      );

      _setupSocketListeners();
    } catch (e) {
      throw Exception('Socket init failed: $e');
    }
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) => print('✅ Socket connected'));
    _socket?.onDisconnect((_) => print('❌ Socket disconnected'));

    _socket?.on('new_message', (data) {
      try {
        final message = BuyerChatModel.fromJson(data);
        _messageStreamController.add(message);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });

    _socket?.on('user_typing', (data) {
      _typingStreamController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('messages_read', (data) {
      _readStreamController.add(Map<String, dynamic>.from(data));
    });
  }

  void joinChat(String chatId) {
    _socket?.emit('join_chat', chatId);
  }

  void leaveChat(String chatId) {
    _socket?.emit('leave_chat', chatId);
  }

  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String receiverId,
  }) async {
    final messageData = {
      'chatId': chatId,
      'message': message,
      'receiverId': receiverId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socket?.emit('send_message', messageData);
  }

  void sendTypingIndicator({
    required String chatId,
    required String receiverId,
    required bool isTyping,
  }) {
    _socket?.emit('typing', {
      'chatId': chatId,
      'receiverId': receiverId,
      'isTyping': isTyping,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageStreamController.close();
    _typingStreamController.close();
    _readStreamController.close();
  }

  bool get isConnected => _socket?.connected ?? false;
}
