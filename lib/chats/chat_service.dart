import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/chat_messages.dart';
import 'package:wood_service/chats/model_user_type.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/chat_messages.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/chat_messages.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';

class ChatService {
  final Dio _dio = locator<Dio>();
  final SellerLocalStorageService _sellerStorage =
      locator<SellerLocalStorageService>();
  final BuyerLocalStorageService _buyerStorage =
      locator<BuyerLocalStorageService>();

  // Chat endpoints
  static const String _baseUrl = '/api/chat';

  // Helper method to get appropriate token
  Future<String?> _getAuthToken() async {
    // First check if seller is logged in
    final sellerToken = await _sellerStorage.getSellerToken();
    if (sellerToken != null && sellerToken.isNotEmpty) {
      return sellerToken;
    }

    // If not seller, check if buyer is logged in
    final buyerToken = await _buyerStorage.getBuyerToken();
    if (buyerToken != null && buyerToken.isNotEmpty) {
      return buyerToken;
    }

    // No token found
    return null;
  }

  // Get current user type
  Future<String> _getUserType() async {
    final sellerToken = await _sellerStorage.getSellerToken();
    if (sellerToken != null && sellerToken.isNotEmpty) {
      return 'seller';
    }

    return 'buyer';
  }

  // Get current user ID
  Future<String?> _getCurrentUserId() async {
    final userType = await _getUserType();

    if (userType == 'seller') {
      // Get seller ID from storage
      final sellerData = await _sellerStorage.getSellerData();
      return sellerData?['_id']?.toString() ?? sellerData?['id']?.toString();
    } else {
      // Get buyer ID from storage
      final buyerData = await _buyerStorage.getBuyerData();
      return buyerData?['_id']?.toString() ?? buyerData?['id']?.toString();
    }
  }

  // Get current user name
  Future<String?> _getCurrentUserName() async {
    final userType = await _getUserType();

    if (userType == 'seller') {
      final sellerData = await _sellerStorage.getSellerData();
      return sellerData?['fullName'] ??
          sellerData?['shopName'] ??
          sellerData?['businessName'] ??
          'Seller';
    } else {
      final buyerData = await _buyerStorage.getBuyerData();
      return buyerData?['fullName'] ??
          buyerData?['businessName'] ??
          buyerData?['contactName'] ??
          'Buyer';
    }
  }

  // Check which user is currently logged in
  Future<String?> _getLoggedInUserId() async {
    // Check seller login status
    final sellerLoggedIn = await _sellerStorage.isSellerLoggedIn();
    if (sellerLoggedIn) {
      final sellerData = await _sellerStorage.getSellerData();
      return sellerData?['_id']?.toString();
    }

    // Check buyer login status
    final buyerLoggedIn = await _buyerStorage.isBuyerLoggedIn();
    if (buyerLoggedIn) {
      final buyerData = await _buyerStorage.getBuyerData();
      return buyerData?['_id']?.toString();
    }

    return null;
  }

  Future<List<ChatRoom>> getChats() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get('$_baseUrl/list');

      if (response.data['success'] == true) {
        final List<dynamic> chatsData = response.data['chats'] ?? [];
        return chatsData.map((chat) => ChatRoom.fromJson(chat)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load chats');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to load chats: $e');
    }
  }

  Future<Map<String, dynamic>> startChat(ChatStartRequest request) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post(
        '$_baseUrl/start',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'chat': ChatRoom.fromJson(response.data['chat']),
          'messages':
              (response.data['chat']['messages'] as List?)
                  ?.map((msg) => ChatMessage.fromJson(msg))
                  .toList() ??
              [],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to start chat');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to start chat: $e');
    }
  }

  Future<List<ChatMessage>> getChatMessages(
    String chatId, {
    int page = 1,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '$_baseUrl/$chatId/messages',
        queryParameters: {'page': page, 'limit': 50},
      );

      if (response.data['success'] == true) {
        final List<dynamic> messagesData = response.data['messages'] ?? [];
        return messagesData.map((msg) => ChatMessage.fromJson(msg)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load messages');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<ChatMessage> sendMessage({
    required String chatId,
    required String receiverId,
    required String receiverType,
    required String message,
    String messageType = 'text',
    List<ChatAttachment> attachments = const [],
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final currentUserType = await _getUserType();
      final currentUserId = await _getCurrentUserId();
      final currentUserName = await _getCurrentUserName();

      if (currentUserId == null) {
        throw Exception('User ID not found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final data = {
        'chatId': chatId,
        'receiverId': receiverId,
        'receiverType': receiverType,
        'message': message,
        'messageType': messageType,
        'senderId': currentUserId,
        'senderType': currentUserType == 'seller' ? 'Seller' : 'Buyer',
        'senderName': currentUserName ?? 'User',
        if (attachments.isNotEmpty)
          'attachments': attachments.map((a) => a.toJson()).toList(),
      };

      final response = await _dio.post('$_baseUrl/send', data: data);

      if (response.data['success'] == true) {
        return ChatMessage.fromJson(response.data['message']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send message');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> markAsRead(String chatId, {List<String>? messageIds}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final Map<String, dynamic> data = {'chatId': chatId};

      if (messageIds != null && messageIds.isNotEmpty) {
        data['messageIds'] = messageIds;
      }

      await _dio.put('$_baseUrl/mark-read', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get('$_baseUrl/unread-count');

      if (response.data['success'] == true) {
        return response.data['unreadCount'] ?? 0;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to get unread count',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      await _dio.delete('$_baseUrl/message/$messageId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Future<List<ChatRoom>> searchChats(String query) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {'query': query},
      );

      if (response.data['success'] == true) {
        final List<dynamic> chatsData = response.data['chats'] ?? [];
        return chatsData.map((chat) => ChatRoom.fromJson(chat)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search chats');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to search chats: $e');
    }
  }

  Future<void> archiveChat(String chatId, bool archive) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      await _dio.put('$_baseUrl/archive/$chatId', data: {'archive': archive});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Failed to archive chat: $e');
    }
  }

  // Get current user info for chat
  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    final userType = await _getUserType();
    final userId = await _getCurrentUserId();
    final userName = await _getCurrentUserName();
    final token = await _getAuthToken();

    return {
      'userType': userType == 'seller' ? 'Seller' : 'Buyer',
      'userId': userId ?? '',
      'userName': userName ?? '',
      'token': token,
      'isSeller': userType == 'seller',
    };
  }

  // Helper method to send messages with easier parameters
  Future<ChatMessage> sendSimpleMessage({
    required String chatId,
    required String receiverId,
    required String message,
    bool isReceiverSeller = false,
  }) async {
    return await sendMessage(
      chatId: chatId,
      receiverId: receiverId,
      receiverType: isReceiverSeller ? 'Seller' : 'Buyer',
      message: message,
      messageType: 'text',
    );
  }

  // Check if current user is logged in as seller
  Future<bool> isCurrentUserSeller() async {
    final userType = await _getUserType();
    return userType == 'seller';
  }

  // Check if current user is logged in as buyer
  Future<bool> isCurrentUserBuyer() async {
    final userType = await _getUserType();
    return userType == 'buyer';
  }

  // Get the logged in user's ID
  Future<String?> getLoggedInUserId() async {
    return await _getLoggedInUserId();
  }
}

// class ChatService {
//   final Dio _dio = locator<Dio>();
//   // final StorageService _sellerLocalStorageService = locator<StorageService>();
  // final SellerLocalStorageService _sellerLocalStorageService =
  //     locator<SellerLocalStorageService>();
  // final BuyerLocalStorageService _buyerLocalStorageService =
  //     locator<BuyerLocalStorageService>();

//   // Chat endpoints
//   static const String _baseUrl = '/api/chat';

//   // Helper method to get appropriate token
//   Future<String?> _getAuthToken() async {
//     // First check if seller is logged in
//     final sellerToken = await _sellerLocalStorageService.getSellerToken();
//     if (sellerToken != null && sellerToken.isNotEmpty) {
//       return sellerToken;
//     }

//     // If not seller, check if buyer is logged in
//     final buyerToken = await _buyerLocalStorageService.getBuyerToken();
//     if (buyerToken != null && buyerToken.isNotEmpty) {
//       return buyerToken;
//     }

//     // No token found
//     return null;
//   }


//   // Get current user type
//   Future<UserType> _getUserType() async {
//     final sellerToken = await _sellerLocalStorageService.getSellerToken();
//     if (sellerToken != null && sellerToken.isNotEmpty) {
//       return UserType.seller;
//     }

//     return UserType.buyer;
//   }

//   // Get current user ID
//   Future<String?> _getCurrentUserId() async {
//     final userType = await _getUserType();

//     if (userType == UserType.seller) {
//       // Get seller ID from storage
//       final sellerData = await _sellerLocalStorageService.getSellerData();
//       return sellerData?['_id'] ?? sellerData?['id'];
//     } else {
//       // Get buyer ID from storage
//       final buyerData = await _buyerLocalStorageService.getBuyerData();
//       return buyerData?['_id'] ?? buyerData?['id'];
//     }
//   }

//   // Get current user name
//   Future<String?> _getCurrentUserName() async {
//     final userType = await _getUserType();

//     if (userType == UserType.seller) {
//       final sellerData = await _sellerLocalStorageService.getSellerData();
//       return sellerData?['fullName'] ?? sellerData?['shopName'];
//     } else {
//       final buyerData = await _buyerLocalStorageService.getBuyerData();
//       return buyerData?['fullName'] ?? buyerData?['businessName'];
//     }
//   }

//   Future<List<ChatRoom>> getChats() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get('$_baseUrl/list');

//       if (response.data['success'] == true) {
//         final List<dynamic> chatsData = response.data['chats'] ?? [];
//         return chatsData.map((chat) => ChatRoom.fromJson(chat)).toList();
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to load chats');
//       }
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to load chats: $e');
//     }
//   }

//   Future<Map<String, dynamic>> startChat(ChatStartRequest request) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.post(
//         '$_baseUrl/start',
//         data: request.toJson(),
//       );

//       if (response.data['success'] == true) {
//         return {
//           'success': true,
//           'chat': ChatRoom.fromJson(response.data['chat']),
//           'messages':
//               (response.data['chat']['messages'] as List?)
//                   ?.map((msg) => ChatMessage.fromJson(msg))
//                   .toList() ??
//               [],
//         };
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to start chat');
//       }
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to start chat: $e');
//     }
//   }

//   Future<List<ChatMessage>> getChatMessages(
//     String chatId, {
//     int page = 1,
//   }) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get(
//         '$_baseUrl/$chatId/messages',
//         queryParameters: {'page': page, 'limit': 50},
//       );

//       if (response.data['success'] == true) {
//         final List<dynamic> messagesData = response.data['messages'] ?? [];
//         return messagesData.map((msg) => ChatMessage.fromJson(msg)).toList();
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to load messages');
//       }
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to load messages: $e');
//     }
//   }

//   Future<ChatMessage> sendMessage({
//     required String chatId,
//     required String receiverId,
//     required String receiverType,
//     required String message,
//     String messageType = 'text',
//     List<ChatAttachment> attachments = const [],
//   }) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       final currentUserType = await _getUserType();
//       final currentUserId = await _getCurrentUserId();
//       final currentUserName = await _getCurrentUserName();

//       if (currentUserId == null) {
//         throw Exception('User ID not found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final data = {
//         'chatId': chatId,
//         'receiverId': receiverId,
//         'receiverType': receiverType,
//         'message': message,
//         'messageType': messageType,
//         'senderId': currentUserId,
//         'senderType': currentUserType == UserType.seller ? 'Seller' : 'Buyer',
//         'senderName': currentUserName ?? 'User',
//         if (attachments.isNotEmpty)
//           'attachments': attachments.map((a) => a.toJson()).toList(),
//       };

//       final response = await _dio.post('$_baseUrl/send', data: data);

//       if (response.data['success'] == true) {
//         return ChatMessage.fromJson(response.data['message']);
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to send message');
//       }
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to send message: $e');
//     }
//   }

//   Future<void> markAsRead(String chatId, {List<String>? messageIds}) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final data = {'chatId': chatId};
//       if (messageIds != null && messageIds.isNotEmpty) {
//         data['messageIds'] = messageIds;
//       }

//       await _dio.put('$_baseUrl/mark-read', data: data);
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to mark as read: $e');
//     }
//   }

//   Future<int> getUnreadCount() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get('$_baseUrl/unread-count');

//       if (response.data['success'] == true) {
//         return response.data['unreadCount'] ?? 0;
//       } else {
//         throw Exception(
//           response.data['message'] ?? 'Failed to get unread count',
//         );
//       }
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to get unread count: $e');
//     }
//   }

//   Future<void> deleteMessage(String messageId) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       await _dio.delete('$_baseUrl/message/$messageId');
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to delete message: $e');
//     }
//   }

//   Future<List<ChatRoom>> searchChats(String query) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get(
//         '$_baseUrl/search',
//         queryParameters: {'query': query},
//       );

//       if (response.data['success'] == true) {
//         final List<dynamic> chatsData = response.data['chats'] ?? [];
//         return chatsData.map((chat) => ChatRoom.fromJson(chat)).toList();
//       } else {
//         throw Exception(response.data['message'] ?? 'Failed to search chats');
//       }
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to search chats: $e');
//     }
//   }

//   Future<void> archiveChat(String chatId, bool archive) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       await _dio.put('$_baseUrl/archive/$chatId', data: {'archive': archive});
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Network error');
//     } catch (e) {
//       throw Exception('Failed to archive chat: $e');
//     }
//   }

//   // Get current user info for chat
//   Future<Map<String, dynamic>> getCurrentUserInfo() async {
//     final userType = await _getUserType();
//     final userId = await _getCurrentUserId();
//     final userName = await _getCurrentUserName();

//     return {
//       'userType': userType == UserType.seller ? 'Seller' : 'Buyer',
//       'userId': userId ?? '',
//       'userName': userName ?? '',
//       'token': await _getAuthToken(),
//     };
//   }
// }
