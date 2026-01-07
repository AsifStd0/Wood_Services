import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_service.dart';
import 'package:wood_service/chats/Buyer/buyer_socket_service.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/data/repositories/auth_service.dart';

class BuyerChatProvider extends ChangeNotifier {
  final BuyerChatService _chatService = locator<BuyerChatService>();
  final BuyerSocketService _socketService = locator<BuyerSocketService>();
  final AuthService _authService = locator<AuthService>();

  List<ChatRoom> _chats = [];
  List<BuyerChatModel> _currentMessages = [];
  ChatRoom? _currentChat;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  int _unreadCount = 0;

  // Store current user info
  Map<String, dynamic>? _currentUser;

  // Getters
  List<ChatRoom> get chats => _chats;
  List<BuyerChatModel> get currentMessages => _currentMessages;
  ChatRoom? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> initialize() async {
    try {
      // Get and store current user info
      _currentUser = await _authService.getCurrentUser();

      await _socketService.initializeSocket(
        _currentUser!['token'],
        _currentUser!['userId'],
      );

      _setupSocketListeners();
      await loadChats();
    } catch (e) {
      _error = 'Failed to initialize chat';
      notifyListeners();
    }
  }

  void _setupSocketListeners() {
    _socketService.onNewMessage.listen(_handleNewMessage);
    _socketService.onTyping.listen(_handleTyping);
  }

  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _chats = await _chatService.getChats();
      _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      _error = 'Failed to load chats';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openChat({
    required String sellerId,
    required String buyerId,
    String? productId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _chatService.startChat(
        sellerId: sellerId,
        buyerId: buyerId,
        productId: productId,
      );

      _currentChat = session.chat;
      _currentMessages = session.messages;

      if (_currentChat != null) {
        _socketService.joinChat(_currentChat!.id);
        await _chatService.markAsRead(_currentChat!.id);
      }

      await _updateUnreadCount();
    } catch (e) {
      _error = 'Failed to open chat';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Get current user info
  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    if (_currentUser != null) return _currentUser!;

    _currentUser = await _authService.getCurrentUser();
    return _currentUser!;
  }

  // ✅ Get current user ID
  Future<String?> getCurrentUserId() async {
    final user = await getCurrentUserInfo();
    return user['userId'];
  }

  // ✅ Get current user type
  Future<String> getCurrentUserType() async {
    final user = await getCurrentUserInfo();
    return user['userType'];
  }

  // ✅ Get current user name
  Future<String?> getCurrentUserName() async {
    final user = await getCurrentUserInfo();
    return user['userName'];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _currentChat == null) return;

    _isSending = true;
    notifyListeners();

    try {
      final user = await getCurrentUserInfo();
      final receiver = _getOtherParticipant();

      final message = await _chatService.sendMessage(
        chatId: _currentChat!.id,
        receiverId: receiver.userId,
        message: text.trim(),
      );

      _currentMessages.add(message);

      // Send via socket
      _socketService.sendMessage(
        chatId: _currentChat!.id,
        message: text.trim(),
        receiverId: receiver.userId,
      );

      // Update chat list
      _updateChatList(text.trim());

      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ✅ Send typing indicator
  Future<void> sendTypingIndicator(bool isTyping) async {
    if (_currentChat == null) return;

    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) return;

      final otherParticipant = _currentChat!.participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => _currentChat!.participants.first,
      );

      _socketService.sendTypingIndicator(
        chatId: _currentChat!.id,
        receiverId: otherParticipant.userId,
        isTyping: isTyping,
      );
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  // ✅ Get other participant
  ChatParticipant _getOtherParticipant() {
    if (_currentChat == null || _currentChat!.participants.isEmpty) {
      throw Exception('No chat or participants found');
    }

    final currentUserId = _currentUser?['userId'];
    if (currentUserId == null) {
      return _currentChat!.participants.first;
    }

    return _currentChat!.participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => _currentChat!.participants.first,
    );
  }

  // ✅ Handle new message
  Future<void> _handleNewMessage(BuyerChatModel message) async {
    if (_currentChat?.id == message.chatId) {
      _currentMessages.add(message);

      // Mark as read if it's for current user
      final currentUserId = await getCurrentUserId();
      if (message.receiverId == currentUserId) {
        await _chatService.markAsRead(message.chatId);
      }

      notifyListeners();
    }

    await _updateUnreadCount();
  }

  void _handleTyping(Map<String, dynamic> data) {
    // Handle typing indicator
    notifyListeners();
  }

  Future<void> _updateUnreadCount() async {
    try {
      _unreadCount = await _chatService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Failed to update unread count: $e');
    }
  }

  void _updateChatList(String lastMessage) {
    if (_currentChat == null) return;

    final index = _chats.indexWhere((c) => c.id == _currentChat!.id);

    if (index != -1) {
      _chats[index] = _chats[index].copyWith(
        lastMessageText: lastMessage,
        updatedAt: DateTime.now(),
      );
      _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }

  void clearCurrentChat() {
    if (_currentChat != null) {
      _socketService.leaveChat(_currentChat!.id);
    }
    _currentChat = null;
    _currentMessages.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}


// class BuyerChatProvider extends ChangeNotifier {
  // final SellerLocalStorageService _sellerStorage =
  //     locator<SellerLocalStorageService>();
  // final BuyerLocalStorageService _buyerStorage =
  //     locator<BuyerLocalStorageService>();
//   final BuyerChatService _chatService = locator<BuyerChatService>();
//   final BuyerSocketService _socketService = locator<BuyerSocketService>();

//   // State variables
//   List<ChatRoom> _chats = [];
//   List<BuyerChatModel> _currentMessages = [];
//   ChatRoom? _currentChat;
//   bool _isLoading = false;
//   bool _isSending = false;
//   String? _error;
//   String _searchQuery = '';
//   int _unreadCount = 0;

//   // Track typing status
//   final Map<String, bool> _typingStatus = {};

//   // Get current user type (seller or buyer)
//   Future<String> _getCurrentUserType() async {
//     final sellerLoggedIn = await _sellerStorage.isSellerLoggedIn();
//     if (sellerLoggedIn) return 'seller';

//     final buyerLoggedIn = await _buyerStorage.isBuyerLoggedIn();
//     if (buyerLoggedIn) return 'buyer';

//     return 'unknown';
//   }

//   // Get current user ID
  // Future<String?> _getCurrentUserId() async {
  //   final userType = await _getCurrentUserType();

  //   if (userType == 'seller') {
  //     final sellerData = await _sellerStorage.getSellerData();
  //     return sellerData?['_id']?.toString() ?? sellerData?['id']?.toString();
  //   } else if (userType == 'buyer') {
  //     final buyerData = await _buyerStorage.getBuyerData();
  //     return buyerData?['_id']?.toString() ?? buyerData?['id']?.toString();
  //   }

  //   return null;
  // }

//   // Get current user name
//   Future<String?> _getCurrentUserName() async {
//     final userType = await _getCurrentUserType();

//     if (userType == 'seller') {
//       final sellerData = await _sellerStorage.getSellerData();
//       return sellerData?['fullName'] ??
//           sellerData?['shopName'] ??
//           sellerData?['businessName'] ??
//           'Seller';
//     } else if (userType == 'buyer') {
//       final buyerData = await _buyerStorage.getBuyerData();
//       return buyerData?['fullName'] ??
//           buyerData?['businessName'] ??
//           buyerData?['contactName'] ??
//           'Buyer';
//     }

//     return null;
//   }

//   // Getters
//   List<ChatRoom> get chats => _chats;
//   List<BuyerChatModel> get currentMessages => _currentMessages;
//   ChatRoom? get currentChat => _currentChat;
//   bool get isLoading => _isLoading;
//   bool get isSending => _isSending;
//   String? get error => _error;
//   String get searchQuery => _searchQuery;
//   int get unreadCount => _unreadCount;

//   // Check if user is typing in a specific chat
//   bool isUserTyping(String userId) => _typingStatus[userId] ?? false;

//   // Filtered chats based on search
//   List<ChatRoom> get filteredChats {
//     if (_searchQuery.isEmpty) return _chats;
//     return _chats.where((chat) {
//       final name = chat.otherUserName.toLowerCase();
//       final lastMessage = chat.lastMessageText?.toLowerCase() ?? '';
//       final query = _searchQuery.toLowerCase();
//       return name.contains(query) || lastMessage.contains(query);
//     }).toList();
//   }

//   // Initialize chat system
//   Future<void> initialize() async {
//     try {
//       // Initialize socket connection
//       await _socketService.initializeSocket();

//       // Setup socket listeners
//       _setupSocketListeners();

//       // Load initial data
//       await loadChats();
//       await getUnreadCount();
//     } catch (e) {
//       _error = 'Failed to initialize chat: $e';
//       notifyListeners();
//     }
//   }

//   void _setupSocketListeners() {
//     // Listen for new messages
//     _socketService.onNewMessage.listen((message) {
//       _handleNewMessage(message);
//     });

//     // Listen for typing indicators
//     _socketService.onTyping.listen((data) {
//       _handleTypingIndicator(data);
//     });

//     // Listen for read receipts
//     _socketService.onRead.listen((data) {
//       _handleReadReceipts(data);
//     });
//   }

//   Future<void> _handleNewMessage(BuyerChatModel message) async {
//     // If message belongs to current chat
//     if (_currentChat?.id == message.chatId) {
//       _currentMessages.add(message);
//       notifyListeners();

//       // Mark as read if it's for current user
//       final currentUserId = await _getCurrentUserId();
//       if (message.receiverId == currentUserId) {
//         _chatService.markAsRead(message.chatId, messageIds: [message.id]);
//       }
//     }

//     // Update chat list
//     final chatIndex = _chats.indexWhere((chat) => chat.id == message.chatId);
//     if (chatIndex != -1) {
//       final chat = _chats[chatIndex];
//       _chats[chatIndex] = chat;
//       _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//     } else {
//       // If new chat, reload chats
//       loadChats();
//     }

//     // Update unread count
//     getUnreadCount();
//   }

//   void _handleTypingIndicator(Map<String, dynamic> data) {
//     final String chatId = data['chatId'];
//     final String senderId = data['senderId'];
//     final bool isTyping = data['isTyping'];

//     if (_currentChat?.id == chatId) {
//       _typingStatus[senderId] = isTyping;
//       notifyListeners();
//     }
//   }

//   void _handleReadReceipts(Map<String, dynamic> data) {
//     final String chatId = data['chatId'];
//     final List<String> messageIds = List<String>.from(data['messageIds'] ?? []);

//     // Update messages as read in current chat
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

//   // Load user's chats
//   Future<void> loadChats() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       _chats = await _chatService.getChats();
//       _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//     } catch (e) {
//       _error = 'Failed to load chats: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> openChat({
//     required String sellerId,
//     required String buyerId,
//     String? productId,
//   }) async {
//     debugPrint('🟢 openChat() called');
//     debugPrint('   SellerId: $sellerId');
//     debugPrint('   BuyerId: $buyerId');
//     debugPrint('   ProductId: $productId');

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       debugPrint('📤 Calling _chatService.startChat...');

//       final result = await _chatService.startChat(
//         ChatStartRequest(
//           sellerId: sellerId,
//           buyerId: buyerId,
//           productId: productId,
//         ),
//       );

//       debugPrint('✅ Chat service response received');

//       _currentChat = result['chat'] as ChatRoom;
//       _currentMessages = result['messages'] as List<BuyerChatModel>;

//       debugPrint('🎯 CurrentChat set: ${_currentChat?.id}');
//       debugPrint('📩 Messages loaded: ${_currentMessages.length}');

//       // Join socket room
//       if (_currentChat != null) {
//         _socketService.joinChat(_currentChat!.id);
//         debugPrint('🔌 Joined socket room: ${_currentChat!.id}');
//       }

//       // Mark all messages as read
//       if (_currentChat != null) {
//         await _chatService.markAsRead(_currentChat!.id);
//         debugPrint('👁 Marked messages as read');
//       }

//       // Update unread count
//       await getUnreadCount();
//       debugPrint('✅ Chat opened successfully');
//     } catch (e, stackTrace) {
//       _error = 'Failed to open chat: $e';
//       debugPrint('❌ openChat error: $e');
//       debugPrint('📛 StackTrace: $stackTrace');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//       debugPrint('🔵 openChat() finished');
//     }
//   }

//   // Open chat from existing chat room
//   Future<void> openExistingChat(ChatRoom chat) async {
//     _currentChat = chat;
//     _currentMessages.clear();

//     // Join socket room
//     _socketService.joinChat(chat.id);

//     // Load messages
//     await loadMessages(chat.id);

//     // Mark as read
//     await _chatService.markAsRead(chat.id);

//     notifyListeners();
//   }

//   // Load chat messages
//   Future<void> loadMessages(String chatId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       _currentMessages = await _chatService.getChatMessages(chatId);

//       // Mark as read
//       await _chatService.markAsRead(chatId);

//       // Update unread count
//       await getUnreadCount();
//     } catch (e) {
//       _error = 'Failed to load messages: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> sendMessage(String text) async {
//     debugPrint('🟢 sendMessage() called');

//     if (text.trim().isEmpty) {
//       debugPrint('⚠️ Message text is empty');
//       return;
//     }

//     if (_currentChat == null) {
//       debugPrint('❌ Current chat is NULL');
//       return;
//     }

//     _isSending = true;
//     notifyListeners();

//     try {
//       debugPrint('🔍 Fetching current user info...');

//       final currentUserId = await _getCurrentUserId();
//       final currentUserType = await _getCurrentUserType();

//       debugPrint('👤 CurrentUserId: $currentUserId');
//       debugPrint('👤 CurrentUserType: $currentUserType');

//       if (currentUserId == null) {
//         throw Exception('User ID not found');
//       }

//       debugPrint('👥 Chat Participants: ${_currentChat!.participants.length}');

//       final otherParticipant = _currentChat!.participants.firstWhere(
//         (p) => p.userId != currentUserId,
//         orElse: () {
//           throw Exception('Other participant not found');
//         },
//       );

//       debugPrint('➡️ ReceiverId: ${otherParticipant.userId}');
//       debugPrint('➡️ ReceiverType: ${otherParticipant.userType}');

//       debugPrint('📤 Sending message via API...');

//       final sentMessage = await _chatService.sendMessage(
//         chatId: _currentChat!.id,
//         receiverId: otherParticipant.userId,
//         receiverType: otherParticipant.userType,
//         message: text.trim(),
//         messageType: 'text',
//       );

//       debugPrint('✅ Message sent successfully');
//       debugPrint('🆔 MessageId: ${sentMessage.id}');

//       _currentMessages.add(sentMessage);

//       debugPrint('📡 Sending message via Socket...');

//       _socketService.sendMessage(
//         chatId: _currentChat!.id,
//         message: text.trim(),
//         receiverId: otherParticipant.userId,
//         messageType: 'text',
//       );

//       debugPrint('🗂 Updating chat list...');

//       final chatIndex = _chats.indexWhere((c) => c.id == _currentChat!.id);

//       if (chatIndex != -1) {
//         _chats[chatIndex] = _chats[chatIndex].copyWith(
//           lastMessageText: text.trim(),
//           updatedAt: DateTime.now(),
//           lastMessage: sentMessage.id,
//         );

//         _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

//         debugPrint('✅ Chat list updated');
//       } else {
//         debugPrint('⚠️ Chat not found in chat list');
//       }

//       notifyListeners();
//     } catch (e, stackTrace) {
//       _error = 'Failed to send message';
//       debugPrint('❌ Send message error: $e');
//       debugPrint('📛 StackTrace: $stackTrace');
//       notifyListeners();
//     } finally {
//       _isSending = false;
//       debugPrint('🔵 sendMessage() finished');
//     }
//   }

//   // Send typing indicator
  // Future<void> sendTypingIndicator(bool isTyping) async {
  //   if (_currentChat == null) return;

  //   try {
  //     final currentUserId = await _getCurrentUserId();
  //     final otherParticipant = _currentChat!.participants.firstWhere(
  //       (p) => p.userId != currentUserId,
  //       orElse: () => _currentChat!.participants.first,
  //     );

  //     await _socketService.sendTypingIndicator(
  //       chatId: _currentChat!.id,
  //       receiverId: otherParticipant.userId,
  //       isTyping: isTyping,
  //     );
  //   } catch (e) {
  //     print('Error sending typing indicator: $e');
  //   }
  // }

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
//       await loadChats();
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

//   // Archive/unarchive chat
//   Future<void> toggleArchiveChat(String chatId, bool archive) async {
//     try {
//       await _chatService.archiveChat(chatId, archive);
//       await loadChats(); // Reload to reflect changes
//     } catch (e) {
//       _error = 'Failed to archive chat: $e';
//       notifyListeners();
//     }
//   }

//   // Delete message
//   Future<void> deleteMessage(String messageId) async {
//     try {
//       await _chatService.deleteMessage(messageId);
//       _currentMessages.removeWhere((msg) => msg.id == messageId);
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to delete message: $e';
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
//     _typingStatus.clear();
//     notifyListeners();
//   }

//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   // Get current user info
//   Future<Map<String, dynamic>> getCurrentUserInfo() async {
//     return {
//       'userId': await _getCurrentUserId(),
//       'userName': await _getCurrentUserName(),
//       'userType': await _getCurrentUserType(),
//     };
//   }

//   // Check if current user is seller
//   Future<bool> isCurrentUserSeller() async {
//     final userType = await _getCurrentUserType();
//     return userType == 'seller';
//   }

//   // Check if current user is buyer
//   Future<bool> isCurrentUserBuyer() async {
//     final userType = await _getCurrentUserType();
//     return userType == 'buyer';
//   }

//   // Dispose
//   void disposeProvider() {
//     _socketService.dispose();
//     super.dispose();
//   }
// }
