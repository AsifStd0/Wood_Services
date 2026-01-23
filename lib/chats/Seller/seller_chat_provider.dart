// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:wood_service/app/locator.dart';
// import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
// import 'package:wood_service/chats/Seller/seller_chat_model.dart';
// import 'package:wood_service/chats/Seller/seller_chat_service.dart';
// import 'package:wood_service/chats/Seller/seller_socket_service.dart';
// import 'package:wood_service/core/services/seller_local_storage_service.dart';

// class SellerChatProvider extends ChangeNotifier {
//   final SellerLocalStorageService _sellerStorage =
//       locator<SellerLocalStorageService>();
//   final SellerChatService _chatService = locator<SellerChatService>();
//   final SellerSocketService _socketService = locator<SellerSocketService>();

//   // State variables - Now using SellerChatRoom
//   List<SellerChatRoom> _chats = [];
//   List<BuyerChatModel> _currentMessages = [];
//   SellerChatRoom? _currentChat;
//   bool _isLoading = false;
//   bool _isSending = false;
//   String? _error;
//   String _searchQuery = '';
//   int _unreadCount = 0;
//   SellerDashboard? _dashboard;
//   String _filterStatus = 'all';

//   // Getters
//   List<SellerChatRoom> get chats => _chats;
//   List<BuyerChatModel> get currentMessages => _currentMessages;
//   SellerChatRoom? get currentChat => _currentChat;
//   bool get isLoading => _isLoading;
//   bool get isSending => _isSending;
//   String? get error => _error;
//   String get searchQuery => _searchQuery;
//   int get unreadCount => _unreadCount;
//   SellerDashboard? get dashboard => _dashboard;
//   String get filterStatus => _filterStatus;
//   // In initialize() method
//   Future<void> initialize() async {
//     try {
//       // Initialize socket connection (optional)
//       try {
//         await _socketService.initializeSocket();
//         _setupSocketListeners();
//         print('✅ Socket initialized successfully');
//       } catch (e) {
//         print(
//           '⚠️ Socket initialization failed (will continue without socket): $e',
//         );
//         // Don't set error - socket is optional
//       }

//       // Load initial data
//       await loadSellerChats();
//       await loadSellerDashboard();
//       await getUnreadCount();

//       print('✅ Chat system initialized successfully');
//     } catch (e) {
//       // Only set error for critical failures
//       if (e.toString().contains('Failed to load') ||
//           e.toString().contains('authentication')) {
//         _error = 'Failed to load chat data: $e';
//       }
//       print('❌ Chat initialization error: $e');
//       notifyListeners();
//     }
//   }

//   void _setupSocketListeners() {
//     _socketService.onNewMessage.listen((message) {
//       _handleNewMessage(message);
//     });

//     _socketService.onTyping.listen((data) {
//       _handleTypingIndicator(data);
//     });

//     _socketService.onRead.listen((data) {
//       _handleReadReceipts(data);
//     });
//   }

//   Future<void> _handleNewMessage(BuyerChatModel message) async {
//     // If message belongs to current chat
//     if (_currentChat?.id == message.chatId) {
//       _currentMessages.add(message);
//       notifyListeners();

//       // Mark as read if it's for seller
//       final sellerId = await _getSellerId();
//       if (message.receiverId == sellerId) {
//         await _chatService.markAsRead(message.chatId, messageIds: [message.id]);
//       }
//     }

//     // Update chat list
//     await loadSellerChats();

//     // Update dashboard
//     await loadSellerDashboard();

//     // Update unread count
//     await getUnreadCount();
//   }

//   void _handleTypingIndicator(Map<String, dynamic> data) {
//     final String chatId = data['chatId'];
//     final String buyerId = data['senderId'];
//     final bool isTyping = data['isTyping'];

//     if (_currentChat?.id == chatId) {
//       // You could add typing indicator state here
//       notifyListeners();
//     }
//   }

//   void _handleReadReceipts(Map<String, dynamic> data) {
//     final String chatId = data['chatId'];
//     final List<String> messageIds = List<String>.from(data['messageIds'] ?? []);

//     if (_currentChat?.id == chatId) {
//       for (var message in _currentMessages) {
//         if (messageIds.contains(message.id)) {
//           message.isRead = true;
//           message.readAt = DateTime.now();
//         }
//       }
//       notifyListeners();
//     }
//   }

//   // Get seller ID
//   Future<String?> _getSellerId() async {
//     final sellerData = await _sellerStorage.getSellerData();
//     return sellerData?['_id']?.toString() ?? sellerData?['id']?.toString();
//   }

//   // Get seller name
//   Future<String?> _getSellerName() async {
//     final sellerData = await _sellerStorage.getSellerData();
//     return sellerData?['shopName'] ??
//         sellerData?['businessName'] ??
//         sellerData?['fullName'] ??
//         'Seller';
//   }

//   // Load seller dashboard
//   Future<void> loadSellerDashboard() async {
//     try {
//       _dashboard = await _chatService.getSellerDashboard();
//       notifyListeners();
//     } catch (e) {
//       print('Failed to load seller dashboard: $e');
//     }
//   }

//   // Start new chat with buyer
//   Future<void> startChat({
//     required String buyerId,
//     required String sellerId,
//     String? productId,
//     String? orderId,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final result = await _chatService.startSellerChat(
//         sellerId: sellerId,
//         buyerId: buyerId,
//         productId: productId,
//         orderId: orderId,
//       );

//       _currentChat = SellerChatRoom.fromJson(result['chat']);
//       _currentMessages = result['messages'] as List<BuyerChatModel>;

//       // Join socket room
//       if (_currentChat != null) {
//         _socketService.joinChat(_currentChat!.id);
//       }

//       // Mark all messages as read
//       if (_currentChat != null) {
//         await _chatService.markAsRead(_currentChat!.id);
//       }

//       // Update data
//       await loadSellerChats();
//       await loadSellerDashboard();
//       await getUnreadCount();
//     } catch (e) {
//       _error = 'Failed to start chat: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Open existing chat
//   Future<void> openExistingChat(String chatId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       // Get chat details
//       final chat = await _chatService.getChatDetails(chatId);
//       _currentChat = chat;

//       // Load messages
//       await loadChatMessages(chatId);

//       // Join socket room
//       _socketService.joinChat(chatId);

//       // Mark as read
//       await _chatService.markAsRead(chatId);

//       // Update unread count
//       await getUnreadCount();
//     } catch (e) {
//       _error = 'Failed to open chat: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Load chat messages
//   Future<void> loadChatMessages(String chatId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       _currentMessages = await _chatService.getChatMessages(chatId);
//     } catch (e) {
//       _error = 'Failed to load messages: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Send message
//   Future<void> sendMessage(String text) async {
//     if (text.trim().isEmpty) return;
//     if (_currentChat == null) return;

//     _isSending = true;
//     notifyListeners();

//     try {
//       final sellerId = await _getSellerId();
//       if (sellerId == null) throw Exception('Seller ID not found');

//       // Get buyer participant
//       final buyerParticipant = _currentChat!.participants.firstWhere(
//         (p) => p.userType == 'Buyer',
//         orElse: () => _currentChat!.participants.first,
//       );

//       final sentMessage = await _chatService.sendSellerMessage(
//         chatId: _currentChat!.id,
//         receiverId: buyerParticipant.userId,
//         receiverType: 'Buyer',
//         message: text.trim(),
//       );

//       _currentMessages.add(sentMessage);

//       // Send via socket
//       await _socketService.sendMessage(
//         chatId: _currentChat!.id,
//         message: text.trim(),
//         receiverId: buyerParticipant.userId,
//         messageType: 'text',
//       );

//       // Update chat list
//       await loadSellerChats();

//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to send message';
//       notifyListeners();
//     } finally {
//       _isSending = false;
//     }
//   }

//   // Send typing indicator
//   Future<void> sendTypingIndicator(bool isTyping) async {
//     if (_currentChat == null) return;

//     try {
//       final sellerId = await _getSellerId();
//       final buyerParticipant = _currentChat!.participants.firstWhere(
//         (p) => p.userType == 'Buyer',
//         orElse: () => _currentChat!.participants.first,
//       );

//       await _socketService.sendTypingIndicator(
//         chatId: _currentChat!.id,
//         receiverId: buyerParticipant.userId,
//         isTyping: isTyping,
//       );
//     } catch (e) {
//       print('Error sending typing indicator: $e');
//     }
//   }

//   // Get unread count
//   Future<void> getUnreadCount() async {
//     try {
//       _unreadCount = await _chatService.getUnreadCount();
//       notifyListeners();
//     } catch (e) {
//       print('Failed to get unread count: $e');
//     }
//   }

//   // Search chats
//   Future<void> searchChats(String query) async {
//     _searchQuery = query;

//     if (query.isEmpty) {
//       await loadSellerChats();
//     } else {
//       _isLoading = true;
//       notifyListeners();

//       try {
//         _chats = await _chatService.searchChats(query);
//       } catch (e) {
//         _error = 'Failed to search chats: $e';
//       } finally {
//         _isLoading = false;
//         notifyListeners();
//       }
//     }
//   }

//   // Filter chats
//   Future<void> filterChats(String status) async {
//     _filterStatus = status;
//     await loadSellerChats();
//   }

//   // Archive/unarchive chat
//   Future<void> toggleArchiveChat(String chatId, bool archive) async {
//     try {
//       await _chatService.archiveChat(chatId, archive);
//       await loadSellerChats();
//     } catch (e) {
//       _error = 'Failed to archive chat: $e';
//       notifyListeners();
//     }
//   }

//   // Clear current chat
//   void clearCurrentChat() {
//     if (_currentChat != null) {
//       _socketService.leaveChat(_currentChat!.id);
//     }
//     _currentChat = null;
//     _currentMessages.clear();
//     notifyListeners();
//   }

//   // Get current user info
//   Future<Map<String, dynamic>> getCurrentUserInfo() async {
//     final sellerId = await _getSellerId();
//     final sellerName = await _getSellerName();
//     final token = await _sellerStorage.getSellerToken();

//     return {
//       'userType': 'Seller',
//       'userId': sellerId ?? '',
//       'userName': sellerName ?? '',
//       'token': token,
//     };
//   }

//   // Dispose
//   void disposeProvider() {
//     _socketService.dispose();
//     super.dispose();
//   }

//   // Add this method to SellerChatProvider
//   void clearError() {
//     if (_error != null) {
//       print('🗑️ Clearing error: $_error');
//       _error = null;
//       notifyListeners();
//     }
//   }

//   // Update loadSellerChats to clear error:
//   Future<void> loadSellerChats() async {
//     clearError(); // Clear any existing errors
//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('🔄 Loading seller chats...');
//       final chats = await _chatService.getSellerChats(
//         status: _filterStatus,
//         page: 1,
//         limit: 50,
//       );

//       print('✅ Loaded ${chats.length} chats');
//       _chats = chats;
//       _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//     } catch (e, stackTrace) {
//       _error = 'Failed to load chats: $e';
//       print('❌ Error loading chats: $e');
//       print('📛 StackTrace: $stackTrace');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }

// // Seller Dashboard Model
// class SellerDashboard {
//   final int totalChats;
//   final int unreadMessages;
//   final int todaysChats;
//   final int activeBuyers;
//   final List<Map<String, dynamic>> recentChats;
//   final List<Map<String, dynamic>> topProducts;

//   SellerDashboard({
//     required this.totalChats,
//     required this.unreadMessages,
//     required this.todaysChats,
//     required this.activeBuyers,
//     required this.recentChats,
//     required this.topProducts,
//   });

//   factory SellerDashboard.fromJson(Map<String, dynamic> json) {
//     return SellerDashboard(
//       totalChats: json['totalChats'] ?? 0,
//       unreadMessages: json['unreadMessages'] ?? 0,
//       todaysChats: json['todaysChats'] ?? 0,
//       activeBuyers: json['activeBuyers'] ?? 0,
//       recentChats: List<Map<String, dynamic>>.from(json['recentChats'] ?? []),
//       topProducts: List<Map<String, dynamic>>.from(json['topProducts'] ?? []),
//     );
//   }
// }
