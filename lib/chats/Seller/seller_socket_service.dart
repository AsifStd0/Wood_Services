// import 'dart:async';
// import 'dart:convert';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:wood_service/app/locator.dart';
// import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
// import 'package:wood_service/core/services/seller_local_storage_service.dart';

// class SellerSocketService {
//   IO.Socket? _socket;
//   final SellerLocalStorageService _sellerStorage =
//       locator<SellerLocalStorageService>();

//   // Stream controllers
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

//   // Get seller auth token
//   Future<String?> _getAuthToken() async {
//     final token = await _sellerStorage.getSellerToken();
//     if (token == null || token.isEmpty) {
//       throw Exception('Seller not authenticated');
//     }
//     return token;
//   }

//   // Get seller ID
//   // In SellerSocketService class
//   Future<String?> _getSellerId() async {
//     try {
//       final sellerData = await _sellerStorage.getSellerData();

//       // Try to find ID in any possible key
//       if (sellerData != null) {
//         // Check common ID keys
//         final possibleIdKeys = ['_id', 'id', 'sellerId', 'userId', 'user_id'];

//         for (final key in possibleIdKeys) {
//           if (sellerData.containsKey(key) && sellerData[key] != null) {
//             final id = sellerData[key].toString();
//             if (id.isNotEmpty) {
//               print('✅ Found seller ID in key "$key": $id');
//               return id;
//             }
//           }
//         }

//         // If no ID found, check if we can get it from another source
//         print('❌ No seller ID found in seller data');
//       }

//       // Try to get ID from JWT token
//       final token = await _sellerStorage.getSellerToken();
//       if (token != null) {
//         try {
//           // Your token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NTZhZGRkZmY5ZjUyNzkwY2Y2NzRmMiIsImlhdCI6MTc2NzMzOTM1NCwiZXhwIjoxNzY5OTMxMzU0fQ.mekdyeb3WSrSG6X9vZ94BgdsAvCGW_STszdtRGHb6BM
//           // The payload is: {"id":"6956adddff9f52790cf674f2","iat":1767339354,"exp":1769931354}

//           // Base64 decode the payload (middle part between dots)
//           final parts = token.split('.');
//           if (parts.length == 3) {
//             // Fix: Base64 URL decode with proper padding
//             String payload = parts[1];
//             // Add padding if needed
//             while (payload.length % 4 != 0) {
//               payload += '=';
//             }

//             // Decode
//             final decoded = utf8.decode(base64Url.decode(payload));
//             final payloadMap = jsonDecode(decoded);

//             final id = payloadMap['id']?.toString();
//             if (id != null && id.isNotEmpty) {
//               print('🔑 Extracted seller ID from token: $id');
//               return id;
//             }
//           }
//         } catch (e) {
//           print('❌ Failed to parse token: $e');
//         }
//       }

//       // As a last resort, use the hardcoded ID from your logs
//       print('⚠️ Using fallback seller ID');
//       return '6956adddff9f52790cf674f2';
//     } catch (e) {
//       print('❌ Error getting seller ID: $e');
//       return null;
//     }
//   }

//   // Get seller name
//   Future<String?> _getSellerName() async {
//     final sellerData = await _sellerStorage.getSellerData();
//     return sellerData?['shopName'] ??
//         sellerData?['businessName'] ??
//         sellerData?['fullName'] ??
//         'Seller';
//   }

//   // Initialize socket connection
//   Future<void> initializeSocket() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('No authentication token found');
//       }

//       final sellerId = await _getSellerId();
//       final sellerName = await _getSellerName();

//       if (sellerId == null) {
//         throw Exception('Seller ID not found');
//       }

//       // Get base URL from environment or config
//       final String baseUrl =
//           'http://10.0.50.105:5000'; // Replace with your server IP

//       print('🔌 Initializing socket for SELLER:');
//       print('   Seller ID: $sellerId');
//       print('   Seller Name: $sellerName');

//       _socket = IO.io(
//         baseUrl,
//         IO.OptionBuilder()
//             .setTransports(['websocket', 'polling'])
//             .enableAutoConnect()
//             .setExtraHeaders({
//               'Authorization': 'Bearer $token',
//               'User-Type': 'seller',
//               'User-Id': sellerId,
//             })
//             .build(),
//       );

//       _setupSocketListeners();
//     } catch (e) {
//       print('Seller Socket initialization error: $e');
//       throw Exception('Failed to initialize seller socket: $e');
//     }
//   }

//   void _setupSocketListeners() {
//     _socket?.onConnect((_) async {
//       print('✅ Seller Socket connected');
//       _connectionStreamController.add(true);

//       // Join seller's room
//       final sellerId = await _getSellerId();
//       if (sellerId != null) {
//         _socket?.emit('join', sellerId);
//         print('👨‍💼 Seller $sellerId joined socket room');
//       }
//     });

//     _socket?.onDisconnect((_) {
//       print('❌ Seller Socket disconnected');
//       _connectionStreamController.add(false);
//     });

//     _socket?.onError((data) {
//       print('⚠️ Seller Socket error: $data');
//     });

//     _socket?.on('new_message', (data) {
//       print('📨 Seller received new message: $data');
//       try {
//         final message = BuyerChatModel.fromJson(data);
//         _messageStreamController.add(message);
//       } catch (e) {
//         print('❌ Error parsing seller message: $e');
//       }
//     });

//     _socket?.on('user_typing', (data) {
//       print('⌨️ Seller typing indicator: $data');
//       _typingStreamController.add(Map<String, dynamic>.from(data));
//     });

//     _socket?.on('messages_read', (data) {
//       print('👁️ Seller messages read: $data');
//       _readStreamController.add(Map<String, dynamic>.from(data));
//     });

//     _socket?.on('message_sent', (data) {
//       print('✅ Seller message sent confirmation: $data');
//     });

//     _socket?.on('connection_error', (data) {
//       print('❌ Seller connection error: $data');
//       _connectionStreamController.add(false);
//     });
//   }

//   // Join chat room
//   void joinChat(String chatId) {
//     _socket?.emit('join_chat', chatId);
//     print('🔗 Seller joined chat room: $chatId');
//   }

//   // Leave chat room
//   void leaveChat(String chatId) {
//     _socket?.emit('leave_chat', chatId);
//     print('🔗 Seller left chat room: $chatId');
//   }

//   // Send message
//   Future<void> sendMessage({
//     required String chatId,
//     required String message,
//     required String receiverId,
//     String messageType = 'text',
//     List<Map<String, dynamic>>? attachments,
//   }) async {
//     try {
//       final sellerId = await _getSellerId();
//       final sellerName = await _getSellerName();

//       if (sellerId == null) {
//         throw Exception('Seller ID not found');
//       }

//       final messageData = {
//         'chatId': chatId,
//         'message': message,
//         'senderId': sellerId,
//         'senderType': 'seller',
//         'senderName': sellerName,
//         'receiverId': receiverId,
//         'messageType': messageType,
//         'timestamp': DateTime.now().toIso8601String(),
//         if (attachments != null) 'attachments': attachments,
//       };

//       _socket?.emit('send_message', messageData);
//       print('📤 Seller message sent via socket to $receiverId');
//     } catch (e) {
//       print('❌ Error sending seller socket message: $e');
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
//       final sellerId = await _getSellerId();

//       if (sellerId == null) {
//         throw Exception('Seller ID not found');
//       }

//       _socket?.emit('typing', {
//         'chatId': chatId,
//         'receiverId': receiverId,
//         'senderId': sellerId,
//         'isTyping': isTyping,
//       });
//     } catch (e) {
//       print('❌ Error sending seller typing indicator: $e');
//     }
//   }

//   // Mark messages as read
//   Future<void> markAsReadViaSocket({
//     required String chatId,
//     required List<String> messageIds,
//   }) async {
//     try {
//       final sellerId = await _getSellerId();

//       if (sellerId == null) {
//         throw Exception('Seller ID not found');
//       }

//       _socket?.emit('mark_as_read', {
//         'chatId': chatId,
//         'messageIds': messageIds,
//         'readerId': sellerId,
//       });
//     } catch (e) {
//       print('❌ Error marking as read via seller socket: $e');
//     }
//   }

//   // Disconnect socket
//   void disconnect() {
//     _socket?.disconnect();
//     _socket?.dispose();
//     _socket = null;
//     print('🔌 Seller socket disconnected');
//   }

//   bool get isConnected => _socket?.connected ?? false;

//   String get connectionStatus {
//     if (_socket == null) return 'Not Initialized';
//     if (_socket!.connected) return 'Connected';
//     return 'Disconnected';
//   }

//   // Clean up
//   void dispose() {
//     disconnect();
//     _messageStreamController.close();
//     _typingStreamController.close();
//     _readStreamController.close();
//     _connectionStreamController.close();
//   }
// }
