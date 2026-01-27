import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

class BuyerChatService {
  final Dio _dio = locator<Dio>();
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();

  // Base URL
  static const String _baseUrl = 'http://3.27.171.3/api';

  Future<String?> _getAuthToken() async {
    try {
      return _storage.getToken();
    } catch (e) {
      log('Error getting auth token: $e');
      return null;
    }
  }

  Future<Options> _getRequestOptions() async {
    final token = await _getAuthToken();

    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  // Get chat by order ID
  Future<ChatSession> getChatByOrder(String orderId) async {
    try {
      log('📤 Getting chat by order: $orderId');

      final options = await _getRequestOptions();
      final response = await _dio.get(
        '$_baseUrl/chats/order/$orderId',
        options: options,
      );

      if (response.data['success'] == true) {
        final chatData = response.data['data']?['chat'] ?? response.data;

        // Get current user info
        final currentUserInfo = await _getCurrentUserInfo();
        final currentUserId = currentUserInfo['userId']?.toString();

        // Parse chat room
        final chat = ChatRoom.fromJson(chatData, currentUserId: currentUserId);

        // Parse messages
        final List<BuyerChatModel> messages = [];
        final messagesData = chatData['messages'] as List? ?? [];

        for (var msg in messagesData) {
          final message = BuyerChatModel.fromJson(
            msg,
            currentUserId: currentUserId!,
            chatId: chat.id,
            chatData: chatData,
          );
          messages.add(message);
        }

        log('✅ Successfully loaded chat with ${messages.length} messages');
        return ChatSession(chat: chat, messages: messages);
      }

      throw Exception('Failed to get chat: ${response.data['message']}');
    } on DioException catch (e) {
      log('❌ DioError getting chat by order: ${e.response?.statusCode}');
      if (e.response?.statusCode == 404) {
        throw Exception('Chat not found for order: $orderId');
      }
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      log('❌ Error getting chat by order: $e');
      rethrow;
    }
  }

  // Create a new chat for an order - FIXED VERSION
  Future<ChatSession> createChatForOrder({
    required String orderId,
    required String sellerId,
  }) async {
    try {
      log('📤 Creating new chat for order: $orderId');

      final options = await _getRequestOptions();

      // Get current user info
      final userInfo = await _getCurrentUserInfo();
      final buyerId = userInfo['userId']?.toString();

      if (buyerId == null) throw Exception('Buyer ID not found');

      // IMPORTANT: Based on your API documentation, try different endpoints

      // Try Option 1: POST to /api/chats (if endpoint exists)
      try {
        final response = await _dio.post(
          '$_baseUrl/chats',
          data: {'orderId': orderId, 'sellerId': sellerId, 'buyerId': buyerId},
          options: options,
        );

        if (response.data['success'] == true) {
          log('✅ Chat created successfully using POST /api/chats');
          return _parseChatResponse(response.data);
        }
      } on DioException catch (e) {
        log('⚠️ POST /api/chats failed: ${e.response?.statusCode}');
        // Continue to try other methods
      }

      // Try Option 2: Maybe chat is automatically created when first message is sent?
      // In this case, we'll just return an empty chat session
      log('⚠️ Chat creation endpoint not found, returning empty chat');

      return ChatSession(
        chat: ChatRoom(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          participants: [
            ChatParticipant(
              userId: sellerId,
              userType: 'Seller',
              name: 'Seller',
              lastSeen: DateTime.now(),
            ),
            ChatParticipant(
              userId: buyerId,
              userType: 'Buyer',
              name: userInfo['userName'] ?? 'Buyer',
              lastSeen: DateTime.now(),
            ),
          ],
          updatedAt: DateTime.now(),
          orderId: orderId,
        ),
        messages: [],
      );
    } catch (e) {
      log('❌ Error creating chat: $e');
      rethrow;
    }
  }

  // Try to send message directly - maybe chat is auto-created on first message
  Future<BuyerChatModel> sendMessageDirect({
    required String orderId,
    required String message,
    required String sellerId,
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      log('📤 Sending message directly to order: $orderId');

      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      // ✅ FIX: Always send a message, even if it's empty
      String finalMessage = message;

      // If message is empty but we have attachments, use a default message
      if (message.isEmpty && attachments != null && attachments.isNotEmpty) {
        finalMessage = '📷 Image'; // or '📎 Attachment'
      }

      // Create FormData
      FormData formData = FormData.fromMap({'message': finalMessage});

      // Add attachments if any
      if (attachments != null && attachments.isNotEmpty) {
        for (var attachment in attachments) {
          final file = attachment['file'] as File;
          final name = attachment['name'] as String? ?? 'file';

          formData.files.add(
            MapEntry(
              'attachments',
              await MultipartFile.fromFile(file.path, filename: name),
            ),
          );
        }
      }

      final response = await _dio.post(
        '$_baseUrl/chats/order/$orderId/message',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.data['success'] == true) {
        final chatData = response.data['data']?['chat'] ?? response.data;

        // Get current user info
        final currentUserInfo = await _getCurrentUserInfo();
        final currentUserId = currentUserInfo['userId']?.toString();

        // Extract the last message (newly sent)
        final messagesData = chatData['messages'] as List? ?? [];
        if (messagesData.isNotEmpty) {
          final lastMessage = messagesData.last;

          return BuyerChatModel.fromJson(
            lastMessage,
            currentUserId: currentUserId!,
            chatId: chatData['_id']?.toString() ?? '',
            chatData: chatData,
          );
        }

        throw Exception('No message in response');
      }

      throw Exception('Failed to send message: ${response.data['message']}');
    } on DioException catch (e) {
      log('❌ DioError sending message: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Chat not found. Please try sending a message first.');
      }
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      log('❌ Error sending message: $e');
      rethrow;
    }
  }

  // Main send message method
  Future<BuyerChatModel> sendMessage({
    required String orderId,
    required String message,
    required String sellerId,
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      // Try to get existing chat first
      try {
        final chat = await getChatByOrder(orderId);
        log('✅ Chat exists, sending message...');

        return await sendMessageDirect(
          orderId: orderId,
          message: message,
          sellerId: sellerId,
          attachments: attachments,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          log(
            '⚠️ Chat not found, trying to send message directly (might auto-create chat)',
          );

          // Try to send message directly - chat might be auto-created
          return await sendMessageDirect(
            orderId: orderId,
            message: message,
            sellerId: sellerId,
            attachments: attachments,
          );
        }
        rethrow;
      } catch (e) {
        if (e.toString().contains('Chat not found')) {
          log('⚠️ Chat not found, trying to send message directly');

          return await sendMessageDirect(
            orderId: orderId,
            message: message,
            sellerId: sellerId,
            attachments: attachments,
          );
        }
        rethrow;
      }
    } catch (e) {
      log('❌ Error in sendMessage: $e');
      rethrow;
    }
  }

  // Open chat - simplified version
  Future<ChatSession> openChat({
    required String sellerId,
    required String orderId,
  }) async {
    try {
      log('🚀 Opening chat for order: $orderId');

      // Try to get existing chat
      try {
        return await getChatByOrder(orderId);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          log('⚠️ Chat not found, returning empty chat session');

          // Get current user info
          final userInfo = await _getCurrentUserInfo();
          final buyerId = userInfo['userId']?.toString() ?? '';

          return ChatSession(
            chat: ChatRoom(
              id: 'temp_$orderId',
              participants: [
                ChatParticipant(
                  userId: sellerId,
                  userType: 'Seller',
                  name: 'Seller',
                  lastSeen: DateTime.now(),
                ),
                ChatParticipant(
                  userId: buyerId,
                  userType: 'Buyer',
                  name: userInfo['userName'] ?? 'Buyer',
                  lastSeen: DateTime.now(),
                ),
              ],
              updatedAt: DateTime.now(),
              orderId: orderId,
            ),
            messages: [],
          );
        }
        rethrow;
      }
    } catch (e) {
      log('❌ Error opening chat: $e');
      rethrow;
    }
  }

  Future<List<ChatRoom>> getChats() async {
    try {
      log('📤 Getting all chats...');

      final options = await _getRequestOptions();
      final response = await _dio.get('$_baseUrl/chats', options: options);

      if (response.data['success'] == true) {
        // Get current user info
        final currentUserInfo = await _getCurrentUserInfo();
        final currentUserId = currentUserInfo['userId']?.toString();

        // Extract chats array
        List<dynamic> chatsData;

        if (response.data['data'] != null &&
            response.data['data']['chats'] != null) {
          chatsData = response.data['data']['chats'];
        } else if (response.data['chats'] != null) {
          chatsData = response.data['chats'];
        } else {
          throw Exception('No chats data found');
        }

        // Parse chats
        List<ChatRoom> chatRooms = [];
        for (var chatData in chatsData) {
          try {
            final chatRoom = ChatRoom.fromJson(
              chatData,
              currentUserId: currentUserId,
            );
            chatRooms.add(chatRoom);
          } catch (e) {
            log('Error parsing chat: $e');
          }
        }

        log('✅ Successfully loaded ${chatRooms.length} chats');
        return chatRooms;
      }

      throw Exception('Failed to load chats: ${response.data['message']}');
    } on DioException catch (e) {
      log('❌ DioError getting chats: ${e.message}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      log('❌ Error getting chats: $e');
      rethrow;
    }
  }

  ChatSession _parseChatResponse(Map<String, dynamic> responseData) {
    final chatData = responseData['data']?['chat'] ?? responseData;

    // Get current user info
    // final currentUserInfo = _getCurrentUserInfo();
    final currentUserId = _storage.getUserData()?['_id']?.toString() ?? '';

    final chat = ChatRoom.fromJson(chatData, currentUserId: currentUserId);

    // Parse messages
    final List<BuyerChatModel> messages = [];
    final messagesData = chatData['messages'] as List? ?? [];

    for (var msg in messagesData) {
      final message = BuyerChatModel.fromJson(
        msg,
        currentUserId: currentUserId,
        chatId: chat.id,
        chatData: chatData,
      );
      messages.add(message);
    }

    return ChatSession(chat: chat, messages: messages);
  }

  Future<Map<String, dynamic>> _getCurrentUserInfo() async {
    try {
      final userData = _storage.getUserData();
      return {
        'userId':
            userData?['_id']?.toString() ?? userData?['id']?.toString() ?? '',
        'userType': userData?['userType']?.toString() ?? 'Buyer',
        'userName':
            userData?['fullName']?.toString() ??
            userData?['businessName']?.toString() ??
            userData?['name']?.toString() ??
            'User',
      };
    } catch (e) {
      log('Error getting current user info: $e');
      return {'userId': '', 'userType': 'Buyer', 'userName': 'User'};
    }
  }
}

class ChatSession {
  final ChatRoom chat;
  final List<BuyerChatModel> messages;

  ChatSession({required this.chat, required this.messages});
}
