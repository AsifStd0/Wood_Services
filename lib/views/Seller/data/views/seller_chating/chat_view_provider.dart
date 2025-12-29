// // view_models/chat_view_model.dart
// import 'package:flutter/foundation.dart';
// import 'package:wood_service/views/Seller/data/views/seller_chating/seller_%20chat_model.dart';

// class SellerChatViewModel with ChangeNotifier {
//   List<SellerChatModel> _chats = [];
//   List<MessageModel> _currentMessages = [];
//   SellerChatModel? _selectedChat;
//   bool _isLoading = false;
//   bool _isSending = false;
//   String? _errorMessage;
//   String _searchQuery = '';

//   List<SellerChatModel> get chats => _chats;
//   List<MessageModel> get currentMessages => _currentMessages;
//   SellerChatModel? get selectedChat => _selectedChat;
//   bool get isLoading => _isLoading;
//   bool get isSending => _isSending;
//   String? get errorMessage => _errorMessage;
//   String get searchQuery => _searchQuery;

//   // Filtered chats based on search
//   List<SellerChatModel> get filteredChats {
//     if (_searchQuery.isEmpty) return _chats;
//     return _chats.where((chat) {
//       return chat.buyerName.toLowerCase().contains(
//             _searchQuery.toLowerCase(),
//           ) ||
//           chat.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   // Get unread chats count
//   int get unreadChatsCount {
//     return _chats.where((chat) => chat.unreadCount > 0).length;
//   }

//   SellerChatViewModel() {
//     _loadChats();
//   }

//   Future<void> _loadChats() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 1));

//       // Mock data - replace with actual API call
//       _chats = [
//         SellerChatModel(
//           id: 'chat_1',
//           buyerId: 'buyer_1',
//           buyerName: 'John Smith',
//           buyerImage: null,
//           lastMessage: 'Hi, I\'m interested in the oak dining table',
//           lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
//           unreadCount: 2,
//           orderId: 'ORD-12345',
//           createdAt: DateTime.now().subtract(const Duration(days: 2)),
//           isOnline: true,
//         ),
//         SellerChatModel(
//           id: 'chat_2',
//           buyerId: 'buyer_2',
//           buyerName: 'Sarah Johnson',
//           buyerImage: null,
//           lastMessage: 'When can you deliver the custom chair?',
//           lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
//           unreadCount: 0,
//           orderId: 'ORD-12346',
//           createdAt: DateTime.now().subtract(const Duration(days: 1)),
//           isOnline: false,
//         ),
//         SellerChatModel(
//           id: 'chat_3',
//           buyerId: 'buyer_3',
//           buyerName: 'Mike Wilson',
//           buyerImage: null,
//           lastMessage: 'Thanks for the quick response!',
//           lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
//           unreadCount: 1,
//           orderId: 'ORD-12347',
//           createdAt: DateTime.now().subtract(const Duration(days: 3)),
//           isOnline: true,
//         ),
//         SellerChatModel(
//           id: 'chat_4',
//           buyerId: 'buyer_4',
//           buyerName: 'Emily Davis',
//           buyerImage: null,
//           lastMessage: 'Can you share more pictures of the product?',
//           lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
//           unreadCount: 0,
//           orderId: 'ORD-12348',
//           createdAt: DateTime.now().subtract(const Duration(days: 4)),
//           isOnline: false,
//         ),
//         SellerChatModel(
//           id: 'chat_5',
//           buyerId: 'buyer_5',
//           buyerName: 'Robert Brown',
//           buyerImage: null,
//           lastMessage: 'I received the package, thank you!',
//           lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
//           unreadCount: 0,
//           orderId: 'ORD-12349',
//           createdAt: DateTime.now().subtract(const Duration(days: 5)),
//           isOnline: false,
//         ),
//       ];
//     } catch (e) {
//       _errorMessage = 'Failed to load chats: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> selectChat(SellerChatModel chat) async {
//     _selectedChat = chat;
//     _isLoading = true;
//     notifyListeners();

//     try {
//       // Simulate loading messages
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Mock messages - replace with actual API call
//       _currentMessages = [
//         MessageModel(
//           id: 'msg_1',
//           chatId: chat.id,
//           senderId: 'buyer_${chat.buyerId}',
//           senderName: chat.buyerName,
//           message: 'Hi, I\'m interested in the oak dining table',
//           type: MessageType.text,
//           timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
//           isRead: true,
//         ),
//         MessageModel(
//           id: 'msg_2',
//           chatId: chat.id,
//           senderId: 'seller_1',
//           senderName: 'You',
//           message:
//               'Hello! Thanks for your interest. The oak dining table is available and made from solid oak wood.',
//           type: MessageType.text,
//           timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
//           isRead: true,
//         ),
//         MessageModel(
//           id: 'msg_3',
//           chatId: chat.id,
//           senderId: 'buyer_${chat.buyerId}',
//           senderName: chat.buyerName,
//           message: 'That sounds great! What are the dimensions?',
//           type: MessageType.text,
//           timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
//           isRead: true,
//         ),
//         MessageModel(
//           id: 'msg_4',
//           chatId: chat.id,
//           senderId: 'seller_1',
//           senderName: 'You',
//           message:
//               'The dimensions are 180cm x 90cm x 75cm. It can seat 6 people comfortably.',
//           type: MessageType.text,
//           timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
//           isRead: true,
//         ),
//         MessageModel(
//           id: 'msg_5',
//           chatId: chat.id,
//           senderId: 'buyer_${chat.buyerId}',
//           senderName: chat.buyerName,
//           message: 'Perfect! Can you deliver by next week?',
//           type: MessageType.text,
//           timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
//           isRead: false,
//         ),
//       ];

//       // Mark chat as read
//       _markChatAsRead(chat.id);
//     } catch (e) {
//       _errorMessage = 'Failed to load messages: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> sendMessage(String message) async {
//     if (message.trim().isEmpty || _selectedChat == null) return;

//     _isSending = true;
//     notifyListeners();

//     try {
//       // Simulate sending message
//       await Future.delayed(const Duration(milliseconds: 500));

//       final newMessage = MessageModel(
//         id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
//         chatId: _selectedChat!.id,
//         senderId: 'seller_1',
//         senderName: 'You',
//         message: message.trim(),
//         type: MessageType.text,
//         timestamp: DateTime.now(),
//         isRead: true,
//       );

//       _currentMessages.add(newMessage);

//       // Update last message in chat
//       final chatIndex = _chats.indexWhere((c) => c.id == _selectedChat!.id);
//       if (chatIndex != -1) {
//         _chats[chatIndex] = _chats[chatIndex].copyWith(
//           lastMessage: message.trim(),
//           lastMessageTime: DateTime.now(),
//         );
//       }

//       // Simulate buyer response after some time
//       _simulateBuyerResponse();
//     } catch (e) {
//       _errorMessage = 'Failed to send message: $e';
//     } finally {
//       _isSending = false;
//       notifyListeners();
//     }
//   }

//   void _simulateBuyerResponse() {
//     Future.delayed(const Duration(seconds: 3), () {
//       final responses = [
//         'Thanks for the information!',
//         'That sounds good to me.',
//         'Can you tell me more about the warranty?',
//         'Do you offer installation service?',
//         'What payment methods do you accept?',
//       ];

//       final randomResponse =
//           responses[DateTime.now().millisecond % responses.length];

//       final responseMessage = MessageModel(
//         id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
//         chatId: _selectedChat!.id,
//         senderId: _selectedChat!.buyerId,
//         senderName: _selectedChat!.buyerName,
//         message: randomResponse,
//         type: MessageType.text,
//         timestamp: DateTime.now().add(const Duration(seconds: 1)),
//         isRead: false,
//       );

//       _currentMessages.add(responseMessage);

//       // Update last message in chat
//       final chatIndex = _chats.indexWhere((c) => c.id == _selectedChat!.id);
//       if (chatIndex != -1) {
//         _chats[chatIndex] = _chats[chatIndex].copyWith(
//           lastMessage: randomResponse,
//           lastMessageTime: DateTime.now().add(const Duration(seconds: 1)),
//           unreadCount: _chats[chatIndex].unreadCount + 1,
//         );
//       }

//       notifyListeners();
//     });
//   }

//   void _markChatAsRead(String chatId) {
//     final chatIndex = _chats.indexWhere((c) => c.id == chatId);
//     if (chatIndex != -1 && _chats[chatIndex].unreadCount > 0) {
//       _chats[chatIndex] = _chats[chatIndex].copyWith(unreadCount: 0);
//       notifyListeners();
//     }
//   }

//   void setSearchQuery(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }

//   void clearSearch() {
//     _searchQuery = '';
//     notifyListeners();
//   }

//   void goBack() {
//     _selectedChat = null;
//     _currentMessages.clear();
//     notifyListeners();
//   }

//   Future<void> refreshChats() async {
//     await _loadChats();
//   }

//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }
