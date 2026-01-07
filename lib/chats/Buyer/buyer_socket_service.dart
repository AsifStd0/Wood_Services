import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wood_service/app/config.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';

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
// class BuyerSocketService {
//   IO.Socket? _socket;
//   final SellerLocalStorageService _sellerStorage =
//       locator<SellerLocalStorageService>();
//   final BuyerLocalStorageService _buyerStorage =
//       locator<BuyerLocalStorageService>();

//   // Stream controllers for real-time updates
//   final StreamController<BuyerChatModel> _messageStreamController =
//       StreamController<BuyerChatModel>.broadcast();
//   final StreamController<Map<String, dynamic>> _typingStreamController =
//       StreamController<Map<String, dynamic>>.broadcast();
//   final StreamController<Map<String, dynamic>> _readStreamController =
//       StreamController<Map<String, dynamic>>.broadcast();
//   final StreamController<bool> _connectionStreamController =
//       StreamController<bool>.broadcast();

//   Stream<BuyerChatModel> get onNewMessage => _messageStreamController.stream;
//   Stream<Map<String, dynamic>> get onTyping => _typingStreamController.stream;
//   Stream<Map<String, dynamic>> get onRead => _readStreamController.stream;
//   Stream<bool> get onConnectionStatus => _connectionStreamController.stream;

//   // Get appropriate auth token
//   Future<String?> _getAuthToken() async {
//     // First check seller token
//     final sellerToken = await _sellerStorage.getSellerToken();
//     if (sellerToken != null && sellerToken.isNotEmpty) {
//       return sellerToken;
//     }

//     // Then check buyer token
//     final buyerToken = await _buyerStorage.getBuyerToken();
//     if (buyerToken != null && buyerToken.isNotEmpty) {
//       return buyerToken;
//     }

//     return null;
//   }

//   // Get current user type for socket
//   Future<String> _getUserTypeForSocket() async {
//     final sellerToken = await _sellerStorage.getSellerToken();
//     if (sellerToken != null && sellerToken.isNotEmpty) {
//       return 'seller';
//     }

//     return 'buyer';
//   }

//   // Get current user ID
//   Future<String?> _getCurrentUserId() async {
//     // Check if seller is logged in
//     final isSellerLoggedIn = await _sellerStorage.isSellerLoggedIn();
//     if (isSellerLoggedIn) {
//       final sellerData = await _sellerStorage.getSellerData();
//       return sellerData?['_id']?.toString();
//     }

//     // Check if buyer is logged in
//     final isBuyerLoggedIn = await _buyerStorage.isBuyerLoggedIn();
//     if (isBuyerLoggedIn) {
//       final buyerData = await _buyerStorage.getBuyerData();
//       return buyerData?['_id']?.toString();
//     }

//     return null;
//   }

//   // Get current user name
//   Future<String?> _getCurrentUserName() async {
//     final isSellerLoggedIn = await _sellerStorage.isSellerLoggedIn();
//     if (isSellerLoggedIn) {
//       final sellerData = await _sellerStorage.getSellerData();
//       return sellerData?['fullName'] ?? sellerData?['shopName'] ?? 'Seller';
//     }

//     final isBuyerLoggedIn = await _buyerStorage.isBuyerLoggedIn();
//     if (isBuyerLoggedIn) {
//       final buyerData = await _buyerStorage.getBuyerData();
//       return buyerData?['fullName'] ?? buyerData?['businessName'] ?? 'Buyer';
//     }

//     return null;
//   }

//   // Initialize socket connection
//   Future<void> initializeSocket() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('No authentication token found');
//       }

//       final userType = await _getUserTypeForSocket();
//       final userId = await _getCurrentUserId();
//       final userName = await _getCurrentUserName();

//       if (userId == null) {
//         throw Exception('User ID not found');
//       }

//       // Get base URL from environment or confce with your server IP

//       print('🔌 Initializing socket for:');
//       print('   User Type: $userType');
//       print('   User ID: $userId');
//       print('   User Name: $userName');

//       _socket = IO.io(
//         "${Config.apiBaseUrl}",
//         IO.OptionBuilder()
//             .setTransports(['websocket', 'polling'])
//             .enableAutoConnect()
//             .setExtraHeaders({
//               'Authorization': 'Bearer $token',
//               'User-Type': userType,
//               'User-Id': userId,
//             })
//             .build(),
//       );

//       _setupSocketListeners();
//     } catch (e) {
//       print('Socket initialization error: $e');
//       throw Exception('Failed to initialize socket: $e');
//     }
//   }

//   void _setupSocketListeners() {
//     _socket?.onConnect((_) async {
//       print('✅ Socket connected');
//       _connectionStreamController.add(true);

//       // Join user's room with user ID
//       final userId = await _getCurrentUserId();
//       if (userId != null) {
//         _socket?.emit('join', userId);
//         print('👤 User $userId joined socket room');
//       }
//     });

//     _socket?.onDisconnect((_) {
//       print('❌ Socket disconnected');
//       _connectionStreamController.add(false);
//     });

//     _socket?.onError((data) {
//       print('⚠️ Socket error: $data');
//     });

//     _socket?.on('new_message', (data) {
//       print('📨 New message received: $data');
//       try {
//         final message = BuyerChatModel.fromJson(data);
//         _messageStreamController.add(message);
//       } catch (e) {
//         print('❌ Error parsing message: $e');
//       }
//     });

//     _socket?.on('user_typing', (data) {
//       print('⌨️ Typing indicator: $data');
//       _typingStreamController.add(Map<String, dynamic>.from(data));
//     });

//     _socket?.on('messages_read', (data) {
//       print('👁️ Messages read: $data');
//       _readStreamController.add(Map<String, dynamic>.from(data));
//     });

//     // Handle custom events
//     _socket?.on('message_sent', (data) {
//       print('✅ Message sent confirmation: $data');
//     });

//     _socket?.on('connection_error', (data) {
//       print('❌ Connection error: $data');
//       _connectionStreamController.add(false);
//     });
//   }

//   // Join a specific chat room
//   void joinChat(String chatId) {
//     _socket?.emit('join_chat', chatId);
//     print('🔗 Joined chat room: $chatId');
//   }

//   // Leave a chat room
//   void leaveChat(String chatId) {
//     _socket?.emit('leave_chat', chatId);
//     print('🔗 Left chat room: $chatId');
//   }

//   // Send message via socket
//   Future<void> sendMessage({
//     required String chatId,
//     required String message,
//     required String receiverId,
//     String messageType = 'text',
//     List<Map<String, dynamic>>? attachments,
//   }) async {
//     try {
//       final userId = await _getCurrentUserId();
//       final userType = await _getUserTypeForSocket();
//       final userName = await _getCurrentUserName();

//       if (userId == null) {
//         throw Exception('User ID not found');
//       }

//       final messageData = {
//         'chatId': chatId,
//         'message': message,
//         'senderId': userId,
//         'senderType': userType,
//         'senderName': userName,
//         'receiverId': receiverId,
//         'messageType': messageType,
//         'timestamp': DateTime.now().toIso8601String(),
//         if (attachments != null) 'attachments': attachments,
//       };

//       _socket?.emit('send_message', messageData);
//       print('📤 Message sent via socket to $receiverId');
//     } catch (e) {
//       print('❌ Error sending socket message: $e');
//       rethrow;
//     }
//   }

//   // Send typing indicator
//   Future<void> sendTypingIndicator({
//     required String chatId,
//     required String receiverId,
//     required bool isTyping,
//   }) async {
//     try {
//       final userId = await _getCurrentUserId();

//       if (userId == null) {
//         throw Exception('User ID not found');
//       }

//       _socket?.emit('typing', {
//         'chatId': chatId,
//         'receiverId': receiverId,
//         'senderId': userId,
//         'isTyping': isTyping,
//       });
//     } catch (e) {
//       print('❌ Error sending typing indicator: $e');
//     }
//   }

//   // Mark messages as read
//   Future<void> markAsReadViaSocket({
//     required String chatId,
//     required List<String> messageIds,
//   }) async {
//     try {
//       final userId = await _getCurrentUserId();

//       if (userId == null) {
//         throw Exception('User ID not found');
//       }

//       _socket?.emit('mark_as_read', {
//         'chatId': chatId,
//         'messageIds': messageIds,
//         'readerId': userId,
//       });
//     } catch (e) {
//       print('❌ Error marking as read via socket: $e');
//     }
//   }

//   // Disconnect socket
//   void disconnect() {
//     _socket?.disconnect();
//     _socket?.dispose();
//     _socket = null;
//     print('🔌 Socket disconnected');
//   }

//   bool get isConnected => _socket?.connected ?? false;

//   // Get socket connection status
//   String get connectionStatus {
//     if (_socket == null) return 'Not Initialized';
//     if (_socket!.connected) return 'Connected';
//     return 'Disconnected';
//   }

//   // Clean up resources
//   void dispose() {
//     disconnect();
//     _messageStreamController.close();
//     _typingStreamController.close();
//     _readStreamController.close();
//     _connectionStreamController.close();
//   }
// }
