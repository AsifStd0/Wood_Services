import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

class BuyerChatService {
  final Dio _dio = locator<Dio>();
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();

  // static const String _baseUrl = '${Config.apiBaseUrl}/chats';
  static const String _baseUrl = 'http://3.27.171.3/api/chats';

  // Get auth token from unified storage
  Future<String?> _getAuthToken() async {
    try {
      final token = _storage.getToken();
      if (token != null && token.isNotEmpty) {
        print('✅ Using token for chat');
        return token;
      }

      print('❌ No auth token found');
      return null;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // ✅ FIX: Add this method to set headers for all requests
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

  Future<List<ChatRoom>> getChats() async {
    try {
      print('📤 Getting chats from $_baseUrl...');

      final options = await _getRequestOptions();

      final response = await _dio.get(_baseUrl, options: options);

      print('✅ Chats response received');
      print('Response status: ${response.statusCode}');
      print('Response data keys: ${response.data.keys}');

      if (response.data['success'] == true) {
        // Log the full structure for debugging
        print('Full response structure:');
        print(response.data.toString());

        // Extract chats array - check different possible structures
        List<dynamic> chatsData;

        if (response.data['data'] != null &&
            response.data['data']['chats'] != null) {
          print('✅ Found chats in data.chats');
          chatsData = response.data['data']['chats'];
        } else if (response.data['chats'] != null) {
          print('✅ Found chats in chats');
          chatsData = response.data['chats'];
        } else {
          print('❌ No chats found in response');
          throw Exception('No chats data found in response');
        }

        print('📱 Found ${chatsData.length} chats');

        // Log first chat for debugging
        if (chatsData.isNotEmpty) {
          print('First chat structure:');
          print(chatsData[0].toString());
        }

        // Get current user info to pass to ChatRoom
        final userInfo = await _getCurrentUserInfo();
        final currentUserId = userInfo['userId']?.toString();

        // Parse each chat
        List<ChatRoom> chatRooms = [];
        for (var chatData in chatsData) {
          try {
            final chatRoom = ChatRoom.fromJson(
              chatData,
              currentUserId: currentUserId,
            );
            chatRooms.add(chatRoom);
          } catch (e) {
            print('❌ Error parsing chat: $e');
            print('Problematic chat data: $chatData');
          }
        }

        print('✅ Successfully parsed ${chatRooms.length} chat rooms');
        return chatRooms;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to load chats';
        print('❌ API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ DioError getting chats: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('❌ Error getting chats: $e');
      throw Exception('Failed to load chats: $e');
    }
  }

  // ✅ Update other methods to use _getRequestOptions() too:

  Future<ChatSession> getChatByOrder(String orderId) async {
    try {
      print('📤 Getting chat by order: $orderId');

      final options = await _getRequestOptions();

      final response = await _dio.get(
        '$_baseUrl/order/$orderId',
        options: options,
      );

      print('✅ Get chat by order response received');

      if (response.data['success'] == true) {
        final chatData = response.data['data']?['chat'] ?? response.data;

        // Get current user info
        final userInfo = await _getCurrentUserInfo();
        final currentUserId = userInfo['userId']?.toString();

        // Parse chat room
        final chat = ChatRoom.fromJson(chatData, currentUserId: currentUserId);

        // Parse messages
        final List<BuyerChatModel> messages = [];
        final messagesData = chatData['messages'] as List? ?? [];

        for (var msg in messagesData) {
          final message = BuyerChatModel.fromJson(
            msg,
            currentUserId: currentUserId,
          );
          // Set chatId if not present
          if (message.chatId.isEmpty) {
            message.chatId = chat.id;
          }
          messages.add(message);
        }

        return ChatSession(chat: chat, messages: messages);
      }

      throw Exception('Failed to get chat: ${response.data['message']}');
    } on DioException catch (e) {
      print('❌ DioError getting chat by order: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('❌ Error getting chat by order: $e');
      throw Exception('Failed to get chat: $e');
    }
  }

  // Helper to get current user info
  Future<Map<String, dynamic>> _getCurrentUserInfo() async {
    try {
      final userData = _storage.getUserData();
      return {
        'userId': userData?['_id']?.toString() ?? userData?['id']?.toString(),
        'userType': userData?['userType'] ?? 'Buyer',
      };
    } catch (e) {
      return {'userId': '', 'userType': 'Buyer'};
    }
  }
  // // Get chat by order ID
  // Future<ChatSession> getChatByOrder(String orderId) async {
  //   try {
  //     print('📤 Getting chat by order: $orderId');

  //     final options = await _getRequestOptions();

  //     final response = await _dio.get(
  //       '$_baseUrl/order/$orderId',
  //       options: options,
  //     );

  //     print('✅ Get chat by order response received');
  //     log('----------🔍 Debug: Chat data: ${response.data['data']}');

  //     if (response.data['success'] == true) {
  //       final chatData =
  //           response.data['data']?['chat'] ?? response.data['chat'];
  //       final chat = ChatRoom.fromJson(chatData);
  //       log('🔍 Debug: Chat data: ${response.data['data']}');
  //       final messages =
  //           (chatData['messages'] as List?)
  //               ?.map((msg) => BuyerChatModel.fromJson(msg))
  //               .toList() ??
  //           [];

  //       return ChatSession(chat: chat, messages: messages);
  //     }

  //     throw Exception('Failed to get chat: ${response.data['message']}');
  //   } on DioException catch (e) {
  //     print('❌ DioError getting chat by order: ${e.response?.data}');
  //     throw Exception(e.response?.data['message'] ?? 'Network error');
  //   } catch (e) {
  //     print('❌ Error getting chat by order: $e');
  //     throw Exception('Failed to get chat: $e');
  //   }
  // }

  // Start chat (for product-based chats, or create new order chat)
  Future<ChatSession> startChat({
    required String sellerId,
    required String buyerId,
    String? productId,
    String? orderId,
  }) async {
    try {
      print('📤 Starting chat... $_baseUrl');

      final options = await _getRequestOptions();

      // If orderId exists, get chat by order
      if (orderId != null) {
        return await getChatByOrder(orderId);
      }

      // Otherwise, create new chat (API might need POST to /api/chats)
      final response = await _dio.post(
        _baseUrl,
        data: {
          'sellerId': sellerId,
          'buyerId': buyerId,
          if (productId != null) 'productId': productId,
        },
        options: options,
      );

      print('✅ Start chat response received');

      if (response.data['success'] == true) {
        final chatData =
            response.data['data']?['chat'] ?? response.data['chat'];

        // Get current user info
        final userInfo = await _getCurrentUserInfo();
        final currentUserId = userInfo['userId']?.toString();

        final chat = ChatRoom.fromJson(chatData, currentUserId: currentUserId);
        final messages =
            (chatData['messages'] as List?)
                ?.map(
                  (msg) => BuyerChatModel.fromJson(
                    msg,
                    currentUserId: currentUserId,
                  ),
                )
                .toList() ??
            [];

        return ChatSession(chat: chat, messages: messages);
      }

      throw Exception('Failed to start chat: ${response.data['message']}');
    } on DioException catch (e) {
      print('❌ DioError starting chat: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('❌ Error starting chat: $e');
      throw Exception('Failed to start chat: $e');
    }
  }

  Future<List<BuyerChatModel>> getChatMessages(String chatId) async {
    try {
      final options = await _getRequestOptions();

      // Try to get chat by ID (might need to use orderId if chat is order-based)
      final response = await _dio.get('$_baseUrl/$chatId', options: options);

      if (response.data['success'] == true) {
        final chatData =
            response.data['data']?['chat'] ?? response.data['chat'];
        final List<dynamic> messagesData = chatData['messages'] ?? [];

        // Get current user info
        final userInfo = await _getCurrentUserInfo();
        final currentUserId = userInfo['userId']?.toString();

        return messagesData
            .map(
              (msg) =>
                  BuyerChatModel.fromJson(msg, currentUserId: currentUserId),
            )
            .toList();
      }

      throw Exception('Failed to load messages');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<BuyerChatModel> sendMessage({
    required String orderId,
    required String message,
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      // Prepare form data for file uploads
      FormData formData;
      if (attachments != null && attachments.isNotEmpty) {
        formData = FormData.fromMap({
          'message': message,
          // Add file attachments here if needed
          // 'attachments': attachments,
        });
      } else {
        formData = FormData.fromMap({'message': message});
      }

      final response = await _dio.post(
        '$_baseUrl/order/$orderId/message',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201 || response.data['success'] == true) {
        // New API returns chat with updated messages
        final chatData =
            response.data['data']?['chat'] ?? response.data['chat'];
        final messages = chatData['messages'] as List?;
        if (messages != null && messages.isNotEmpty) {
          // Get current user info
          final userInfo = await _getCurrentUserInfo();
          final currentUserId = userInfo['userId']?.toString();

          // Return the last message (newly sent)
          return BuyerChatModel.fromJson(
            messages.last,
            currentUserId: currentUserId,
          );
        }
        throw Exception('No message in response');
      }

      throw Exception('Failed to send message: ${response.data['message']}');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> markAsRead(String chatId) async {
    try {
      final options = await _getRequestOptions();

      // New API might use PUT /api/chats/:chatId/read
      await _dio.put('$_baseUrl/$chatId/read', options: options);
    } on DioException catch (e) {
      // If endpoint doesn't exist, try old endpoint
      if (e.response?.statusCode == 404) {
        try {
          await _dio.put(
            '$_baseUrl/mark-read',
            data: {'chatId': chatId},
            options: await _getRequestOptions(),
          );
        } catch (e2) {
          print('⚠️ Mark as read failed: $e2');
          // Don't throw - marking as read is not critical
        }
      } else {
        throw Exception(e.response?.data['message'] ?? 'Network error');
      }
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      // Calculate unread from chats list
      final chats = await getChats();
      int totalUnread = 0;
      for (var chat in chats) {
        totalUnread += chat.unreadCount;
      }
      return totalUnread;
    } catch (e) {
      print('Failed to get unread count: $e');
      return 0;
    }
  }
}

class ChatSession {
  final ChatRoom chat;
  final List<BuyerChatModel> messages;

  ChatSession({required this.chat, required this.messages});
}
