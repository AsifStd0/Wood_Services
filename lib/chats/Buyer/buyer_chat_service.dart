import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';

class BuyerChatService {
  final Dio _dio = locator<Dio>();
  final BuyerLocalStorageService _buyerStorage =
      locator<BuyerLocalStorageService>();
  final SellerLocalStorageService _sellerStorage =
      locator<SellerLocalStorageService>();

  static const String _baseUrl = '/api/chat';

  // ✅ FIX: Get appropriate token with proper storage service
  Future<String?> _getAuthToken() async {
    try {
      // Check buyer first since buyer is logged in
      final buyerToken = await _buyerStorage.getBuyerToken();
      if (buyerToken != null && buyerToken.isNotEmpty) {
        print('✅ Using BUYER token for chat');
        return buyerToken;
      }

      // Check seller
      final sellerToken = await _sellerStorage.getSellerToken();
      if (sellerToken != null && sellerToken.isNotEmpty) {
        print('✅ Using SELLER token for chat');
        return sellerToken;
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
      print('📤 Getting chats with auth token...');

      final options = await _getRequestOptions();

      final response = await _dio.get('$_baseUrl/list', options: options);

      print('✅ Chats response received');

      if (response.data['success'] == true) {
        final List<dynamic> chatsData = response.data['chats'] ?? [];
        print('📱 Found ${chatsData.length} chats');
        return chatsData.map((chat) => ChatRoom.fromJson(chat)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load chats');
      }
    } on DioException catch (e) {
      print('❌ DioError getting chats: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('❌ Error getting chats: $e');
      throw Exception('Failed to load chats: $e');
    }
  }

  // ✅ Update other methods to use _getRequestOptions() too:

  Future<ChatSession> startChat({
    required String sellerId,
    required String buyerId,
    String? productId,
  }) async {
    try {
      print('📤 Starting chat...');

      final options = await _getRequestOptions();

      final response = await _dio.post(
        '$_baseUrl/start',
        data: {
          'sellerId': sellerId,
          'buyerId': buyerId,
          if (productId != null) 'productId': productId,
        },
        options: options,
      );

      print('✅ Start chat response received');

      if (response.data['success'] == true) {
        final chat = ChatRoom.fromJson(response.data['chat']);
        final messages =
            (response.data['chat']['messages'] as List?)
                ?.map((msg) => BuyerChatModel.fromJson(msg))
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

      final response = await _dio.get(
        '$_baseUrl/$chatId/messages',
        queryParameters: {'limit': 50},
        options: options,
      );

      if (response.data['success'] == true) {
        final List<dynamic> messagesData = response.data['messages'] ?? [];
        return messagesData.map((msg) => BuyerChatModel.fromJson(msg)).toList();
      }

      throw Exception('Failed to load messages');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<BuyerChatModel> sendMessage({
    required String chatId,
    required String receiverId,
    required String message,
  }) async {
    try {
      final options = await _getRequestOptions();

      final response = await _dio.post(
        '$_baseUrl/send',
        data: {'chatId': chatId, 'receiverId': receiverId, 'message': message},
        options: options,
      );

      if (response.statusCode == 201 || response.data['success'] == true) {
        return BuyerChatModel.fromJson(response.data['message']);
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

      await _dio.put(
        '$_baseUrl/mark-read',
        data: {'chatId': chatId},
        options: options,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final options = await _getRequestOptions();

      final response = await _dio.get(
        '$_baseUrl/unread-count',
        options: options,
      );

      if (response.data['success'] == true) {
        return response.data['unreadCount'] ?? 0;
      }

      throw Exception('Failed to get unread count');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}

class ChatSession {
  final ChatRoom chat;
  final List<BuyerChatModel> messages;

  ChatSession({required this.chat, required this.messages});
}
