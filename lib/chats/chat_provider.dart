import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/chat_messages.dart';
import 'package:wood_service/chats/chat_service.dart';
import 'package:wood_service/chats/socket_service.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final SellerLocalStorageService _sellerStorage =
      locator<SellerLocalStorageService>();
  final BuyerLocalStorageService _buyerStorage =
      locator<BuyerLocalStorageService>();
  final ChatService _chatService = locator<ChatService>();
  final SocketService _socketService = locator<SocketService>();

  // State variables
  List<ChatRoom> _chats = [];
  List<ChatMessage> _currentMessages = [];
  ChatRoom? _currentChat;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  String _searchQuery = '';
  int _unreadCount = 0;

  // Track typing status
  final Map<String, bool> _typingStatus = {};

  // Get current user type (seller or buyer)
  Future<String> _getCurrentUserType() async {
    final sellerLoggedIn = await _sellerStorage.isSellerLoggedIn();
    if (sellerLoggedIn) return 'seller';

    final buyerLoggedIn = await _buyerStorage.isBuyerLoggedIn();
    if (buyerLoggedIn) return 'buyer';

    return 'unknown';
  }

  // Get current user ID
  Future<String?> _getCurrentUserId() async {
    final userType = await _getCurrentUserType();

    if (userType == 'seller') {
      final sellerData = await _sellerStorage.getSellerData();
      return sellerData?['_id']?.toString() ?? sellerData?['id']?.toString();
    } else if (userType == 'buyer') {
      final buyerData = await _buyerStorage.getBuyerData();
      return buyerData?['_id']?.toString() ?? buyerData?['id']?.toString();
    }

    return null;
  }

  // Get current user name
  Future<String?> _getCurrentUserName() async {
    final userType = await _getCurrentUserType();

    if (userType == 'seller') {
      final sellerData = await _sellerStorage.getSellerData();
      return sellerData?['fullName'] ??
          sellerData?['shopName'] ??
          sellerData?['businessName'] ??
          'Seller';
    } else if (userType == 'buyer') {
      final buyerData = await _buyerStorage.getBuyerData();
      return buyerData?['fullName'] ??
          buyerData?['businessName'] ??
          buyerData?['contactName'] ??
          'Buyer';
    }

    return null;
  }

  // Getters
  List<ChatRoom> get chats => _chats;
  List<ChatMessage> get currentMessages => _currentMessages;
  ChatRoom? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get unreadCount => _unreadCount;

  // Check if user is typing in a specific chat
  bool isUserTyping(String userId) => _typingStatus[userId] ?? false;

  // Filtered chats based on search
  List<ChatRoom> get filteredChats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats.where((chat) {
      final name = chat.otherUserName.toLowerCase();
      final lastMessage = chat.lastMessageText?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || lastMessage.contains(query);
    }).toList();
  }

  // Initialize chat system
  Future<void> initialize() async {
    try {
      // Initialize socket connection
      await _socketService.initializeSocket();

      // Setup socket listeners
      _setupSocketListeners();

      // Load initial data
      await loadChats();
      await getUnreadCount();
    } catch (e) {
      _error = 'Failed to initialize chat: $e';
      notifyListeners();
    }
  }

  void _setupSocketListeners() {
    // Listen for new messages
    _socketService.onNewMessage.listen((message) {
      _handleNewMessage(message);
    });

    // Listen for typing indicators
    _socketService.onTyping.listen((data) {
      _handleTypingIndicator(data);
    });

    // Listen for read receipts
    _socketService.onRead.listen((data) {
      _handleReadReceipts(data);
    });
  }

  Future<void> _handleNewMessage(ChatMessage message) async {
    // If message belongs to current chat
    if (_currentChat?.id == message.chatId) {
      _currentMessages.add(message);
      notifyListeners();

      // Mark as read if it's for current user
      final currentUserId = await _getCurrentUserId();
      if (message.receiverId == currentUserId) {
        _chatService.markAsRead(message.chatId, messageIds: [message.id]);
      }
    }

    // Update chat list
    final chatIndex = _chats.indexWhere((chat) => chat.id == message.chatId);
    if (chatIndex != -1) {
      final chat = _chats[chatIndex];
      _chats[chatIndex] = chat;
      _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } else {
      // If new chat, reload chats
      loadChats();
    }

    // Update unread count
    getUnreadCount();
  }

  void _handleTypingIndicator(Map<String, dynamic> data) {
    final String chatId = data['chatId'];
    final String senderId = data['senderId'];
    final bool isTyping = data['isTyping'];

    if (_currentChat?.id == chatId) {
      _typingStatus[senderId] = isTyping;
      notifyListeners();
    }
  }

  void _handleReadReceipts(Map<String, dynamic> data) {
    final String chatId = data['chatId'];
    final List<String> messageIds = List<String>.from(data['messageIds'] ?? []);

    // Update messages as read in current chat
    if (_currentChat?.id == chatId) {
      for (var message in _currentMessages) {
        if (messageIds.contains(message.id)) {
          message.isRead = true;
          message.readAt = DateTime.now();
        }
      }
      notifyListeners();
    }
  }

  // Load user's chats
  Future<void> loadChats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chats = await _chatService.getChats();
      _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      _error = 'Failed to load chats: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start or open a chat
  Future<void> openChat({
    required String sellerId,
    required String buyerId,
    String? productId,
    String? orderId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _chatService.startChat(
        ChatStartRequest(
          sellerId: sellerId,
          buyerId: buyerId,
          productId: productId,
          orderId: orderId,
        ),
      );

      _currentChat = result['chat'] as ChatRoom;
      _currentMessages = result['messages'] as List<ChatMessage>;

      // Join socket room
      _socketService.joinChat(_currentChat!.id);

      // Mark all messages as read
      await _chatService.markAsRead(_currentChat!.id);

      // Update unread count
      await getUnreadCount();
    } catch (e) {
      _error = 'Failed to open chat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open chat from existing chat room
  Future<void> openExistingChat(ChatRoom chat) async {
    _currentChat = chat;
    _currentMessages.clear();

    // Join socket room
    _socketService.joinChat(chat.id);

    // Load messages
    await loadMessages(chat.id);

    // Mark as read
    await _chatService.markAsRead(chat.id);

    notifyListeners();
  }

  // Load chat messages
  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentMessages = await _chatService.getChatMessages(chatId);

      // Mark as read
      await _chatService.markAsRead(chatId);

      // Update unread count
      await getUnreadCount();
    } catch (e) {
      _error = 'Failed to load messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message - FIXED VERSION
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _currentChat == null) return;

    _isSending = true;
    notifyListeners();

    try {
      final currentUserId = await _getCurrentUserId();
      final currentUserName = await _getCurrentUserName();
      final currentUserType = await _getCurrentUserType();

      if (currentUserId == null) {
        throw Exception('User ID not found');
      }

      // Find the other participant
      final otherParticipant = _currentChat!.participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => _currentChat!.participants.first,
      );

      // Create message object
      final newMessage = ChatMessage(
        id: '', // Will be set by server
        chatId: _currentChat!.id,
        senderId: currentUserId,
        senderName: currentUserName ?? 'User',
        senderType: currentUserType == 'seller' ? 'Seller' : 'Buyer',
        receiverId: otherParticipant.userId,
        receiverName: otherParticipant.name,
        receiverType: otherParticipant.userType,
        message: text.trim(),
        messageType: 'text',
        isRead: false,
        createdAt: DateTime.now(),
        productId: _currentChat!.productId,
        orderId: _currentChat!.orderId,
      );

      // Send via socket for real-time
      _socketService.sendMessage(
        chatId: _currentChat!.id,
        message: text.trim(),
        receiverId: otherParticipant.userId,
        messageType: 'text',
      );

      // Send via API for persistence - FIXED CALL
      final sentMessage = await _chatService.sendMessage(
        chatId: _currentChat!.id,
        receiverId: otherParticipant.userId,
        receiverType: otherParticipant.userType,
        message: text.trim(),
      );

      // Add to current messages
      _currentMessages.add(sentMessage);

      // Update chat list
      final chatIndex = _chats.indexWhere((c) => c.id == _currentChat!.id);
      if (chatIndex != -1) {
        _chats[chatIndex] = ChatRoom(
          id: _currentChat!.id,
          participants: _currentChat!.participants,
          lastMessage: sentMessage.id,
          lastMessageText: text.trim(),
          unreadCount: 0,
          updatedAt: DateTime.now(),
          productId: _currentChat!.productId,
          orderId: _currentChat!.orderId,
        );
        _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } catch (e) {
      _error = 'Failed to send message: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(bool isTyping) async {
    if (_currentChat == null) return;

    try {
      final currentUserId = await _getCurrentUserId();
      final otherParticipant = _currentChat!.participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => _currentChat!.participants.first,
      );

      await _socketService.sendTypingIndicator(
        chatId: _currentChat!.id,
        receiverId: otherParticipant.userId,
        isTyping: isTyping,
      );
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  // Get unread count
  Future<void> getUnreadCount() async {
    try {
      _unreadCount = await _chatService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Failed to get unread count: $e');
    }
  }

  // Search chats
  Future<void> searchChats(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      await loadChats();
    } else {
      _isLoading = true;
      notifyListeners();

      try {
        _chats = await _chatService.searchChats(query);
      } catch (e) {
        _error = 'Failed to search chats: $e';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Archive/unarchive chat
  Future<void> toggleArchiveChat(String chatId, bool archive) async {
    try {
      await _chatService.archiveChat(chatId, archive);
      await loadChats(); // Reload to reflect changes
    } catch (e) {
      _error = 'Failed to archive chat: $e';
      notifyListeners();
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      _currentMessages.removeWhere((msg) => msg.id == messageId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete message: $e';
      notifyListeners();
    }
  }

  // Clear current chat
  void clearCurrentChat() {
    if (_currentChat != null) {
      _socketService.leaveChat(_currentChat!.id);
    }
    _currentChat = null;
    _currentMessages.clear();
    _typingStatus.clear();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get current user info
  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    return {
      'userId': await _getCurrentUserId(),
      'userName': await _getCurrentUserName(),
      'userType': await _getCurrentUserType(),
    };
  }

  // Check if current user is seller
  Future<bool> isCurrentUserSeller() async {
    final userType = await _getCurrentUserType();
    return userType == 'seller';
  }

  // Check if current user is buyer
  Future<bool> isCurrentUserBuyer() async {
    final userType = await _getCurrentUserType();
    return userType == 'buyer';
  }

  // Dispose
  void disposeProvider() {
    _socketService.dispose();
    super.dispose();
  }
}
