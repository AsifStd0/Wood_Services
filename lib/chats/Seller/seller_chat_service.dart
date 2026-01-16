// import 'package:dio/dio.dart';
// import 'package:wood_service/app/locator.dart';
// import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
// import 'package:wood_service/chats/Seller/seller_chat_model.dart';
// import 'package:wood_service/chats/Seller/seller_chat_provider.dart';
// import 'package:wood_service/core/services/seller_local_storage_service.dart';

// class SellerChatService {
//   final Dio _dio = locator<Dio>();
//   final SellerLocalStorageService _sellerStorage =
//       locator<SellerLocalStorageService>();

//   // Seller chat endpoints
//   static const String _baseUrl = '/api/seller/chat';

//   // Helper method to get seller token
//   Future<String?> _getAuthToken() async {
//     final token = await _sellerStorage.getSellerToken();
//     if (token == null || token.isEmpty) {
//       throw Exception('Seller not authenticated');
//     }
//     return token;
//   }

//   // Get seller dashboard
//   Future<SellerDashboard> getSellerDashboard() async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get('$_baseUrl/dashboard');

//       if (response.data['success'] == true) {
//         return SellerDashboard.fromJson(response.data['dashboard']);
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to load dashboard');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Get seller chats with filters - Now returns SellerChatRoom
//   Future<List<SellerChatRoom>> getSellerChats({
//     String? status,
//     int page = 1,
//     int limit = 20,
//     String? productId,
//   }) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final Map<String, dynamic> params = {'page': page, 'limit': limit};

//       if (status != null && status != 'all') {
//         params['status'] = status;
//       }

//       if (productId != null) {
//         params['productId'] = productId;
//       }

//       final response = await _dio.get(
//         '$_baseUrl/list',
//         queryParameters: params,
//       );

//       if (response.data['success'] == true) {
//         final List<dynamic> chatsData = response.data['chats'] ?? [];
//         return chatsData.map((chat) => SellerChatRoom.fromJson(chat)).toList();
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to load chats');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Start seller chat - Now returns SellerChatRoom
//   Future<Map<String, dynamic>> startSellerChat({
//     required String sellerId,
//     required String buyerId,
//     String? productId,
//     String? orderId,
//   }) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.post(
//         '$_baseUrl/start',
//         data: {
//           'sellerId': sellerId,
//           'buyerId': buyerId,
//           if (productId != null) 'productId': productId,
//           if (orderId != null) 'orderId': orderId,
//         },
//       );

//       if (response.data['success'] == true) {
//         final chat = SellerChatRoom.fromJson(response.data['chat']);
//         final messages =
//             (response.data['chat']['messages'] as List?)
//                 ?.map((msg) => BuyerChatModel.fromJson(msg))
//                 .toList() ??
//             [];

//         return {'chat': chat, 'messages': messages};
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to start chat');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Change to use the list endpoint and filter:
//   Future<SellerChatRoom> getChatDetails(String chatId) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       // Get all chats and filter by ID
//       final response = await _dio.get(
//         '$_baseUrl/list',
//         queryParameters: {'page': 1, 'limit': 50},
//       );

//       if (response.data['success'] == true) {
//         final List<dynamic> chatsData = response.data['chats'] ?? [];

//         // Find the specific chat by ID
//         final chatData = chatsData.firstWhere(
//           (chat) => chat['_id'] == chatId,
//           orElse: () => null,
//         );

//         if (chatData == null) {
//           throw Exception('Chat not found');
//         }

//         return SellerChatRoom.fromJson(chatData);
//       } else {
//         throw Exception(
//           response.data['message'] ?? 'Failed to get chat details',
//         );
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Get chat messages
//   Future<List<BuyerChatModel>> getChatMessages(
//     String chatId, {
//     int page = 1,
//     int limit = 50,
//   }) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get(
//         '$_baseUrl/$chatId/messages',
//         queryParameters: {'page': page, 'limit': limit},
//       );

//       if (response.data['success'] == true) {
//         final List<dynamic> messagesData = response.data['messages'] ?? [];
//         return messagesData.map((msg) => BuyerChatModel.fromJson(msg)).toList();
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to load messages');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Send seller message
//   Future<BuyerChatModel> sendSellerMessage({
//     required String chatId,
//     required String receiverId,
//     required String receiverType,
//     required String message,
//     String messageType = 'text',
//   }) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.post(
//         '$_baseUrl/send',
//         data: {
//           'chatId': chatId,
//           'receiverId': receiverId,
//           'message': message,
//           'messageType': messageType,
//         },
//       );

//       if (response.data['success'] == true) {
//         return BuyerChatModel.fromJson(response.data['message']);
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to send message');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Mark messages as read
//   Future<void> markAsRead(String chatId, {List<String>? messageIds}) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final Map<String, dynamic> data = {'chatId': chatId};
//       if (messageIds != null && messageIds.isNotEmpty) {
//         data['messageIds'] = messageIds;
//       }

//       await _dio.put('$_baseUrl/mark-read', data: data);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Get unread count
//   Future<int> getUnreadCount() async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get('$_baseUrl/unread-count');

//       if (response.data['success'] == true) {
//         return response.data['unreadCount'] ?? 0;
//       } else {
//         throw Exception(
//           response.data['message'] ?? 'Failed to get unread count',
//         );
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Search chats - Now returns SellerChatRoom
//   Future<List<SellerChatRoom>> searchChats(String query) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get(
//         '$_baseUrl/search',
//         queryParameters: {'query': query},
//       );

//       if (response.data['success'] == true) {
//         final List<dynamic> chatsData = response.data['chats'] ?? [];
//         return chatsData.map((chat) => SellerChatRoom.fromJson(chat)).toList();
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to search chats');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Archive/unarchive chat
//   Future<void> archiveChat(String chatId, bool archive) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       await _dio.put('$_baseUrl/archive/$chatId', data: {'archive': archive});
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Delete message
//   Future<void> deleteMessage(String messageId) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       await _dio.delete('$_baseUrl/message/$messageId');
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Get chat statistics
//   Future<Map<String, dynamic>> getChatStats() async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get('$_baseUrl/stats');

//       if (response.data['success'] == true) {
//         return response.data['stats'] ?? {};
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to get stats');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Get product chats - Now returns SellerChatRoom
//   Future<List<SellerChatRoom>> getProductChats(String productId) async {
//     try {
//       final token = await _getAuthToken();
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get('$_baseUrl/products/$productId/chats');

//       if (response.data['success'] == true) {
//         final List<dynamic> chatsData = response.data['chats'] ?? [];
//         return chatsData.map((chat) => SellerChatRoom.fromJson(chat)).toList();
//       } else {
//         throw Exception(
//           response.data['message'] ?? 'Failed to get product chats',
//         );
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
