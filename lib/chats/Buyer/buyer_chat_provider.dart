import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_service.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

class BuyerChatProvider extends ChangeNotifier {
  final BuyerChatService _chatService;

  BuyerChatProvider({required BuyerChatService chatService})
    : _chatService = chatService;

  // final BuyerChatService _chatService = locator<BuyerChatService>();
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();

  // Socket service is optional - comment out if not available
  // final BuyerSocketService? _socketService;

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
      // Get and store current user info from storage
      await _loadCurrentUser();

      await loadChats();
    } catch (e) {
      _error = 'Failed to initialize chat: $e';
      notifyListeners();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final token = _storage.getToken();
      final userData = _storage.getUserData();

      _currentUser = {
        'userId': userData?['_id']?.toString() ?? userData?['id']?.toString(),
        'userType': userData?['userType'] ?? 'Buyer',
        'token': token ?? '',
        'userName':
            userData?['fullName'] ??
            userData?['businessName'] ??
            userData?['name'] ??
            'User',
      };
    } catch (e) {
      log('Error loading current user: $e');
    }
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
    String? orderId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _chatService.startChat(
        sellerId: sellerId,
        buyerId: buyerId,
        productId: productId,
        orderId: orderId,
      );

      _currentChat = session.chat;
      _currentMessages = session.messages;

      if (_currentChat != null) {
        // Socket join is optional
        // _socketService?.joinChat(_currentChat!.id);
        await _chatService.markAsRead(_currentChat!.id);
      }

      await _updateUnreadCount();
    } catch (e) {
      _error = 'Failed to open chat: $e';
      log('❌ Error opening chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Get current user info
  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    if (_currentUser != null) return _currentUser!;

    await _loadCurrentUser();
    return _currentUser ?? {};
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

  Future<void> sendMessage(
    String text, {
    List<Map<String, dynamic>>? attachments,
    String? orderId,
  }) async {
    log('111 2222 orderId: ${_currentChat!.id}');
    if (text.trim().isEmpty || _currentChat == null) return;

    _isSending = true;
    notifyListeners();

    try {
      log('111 2222 orderId: ${_currentChat!.id}');
      final message = await _chatService.sendMessage(
        // ! *****
        orderId: orderId.toString(),
        message: text.trim(),
        attachments: attachments,
      );

      _currentMessages.add(message);
      // Update chat list
      _updateChatList(text.trim());

      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: $e';
      log('❌ Error sending message: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ✅ Send typing indicator (optional - requires socket)
  Future<void> sendTypingIndicator(bool isTyping) async {
    if (_currentChat == null) return;

    // Socket typing indicator is optional
    // try {
    //   final currentUserId = await getCurrentUserId();
    //   if (currentUserId == null) return;
    //
    //   final otherParticipant = _currentChat!.participants.firstWhere(
    //     (p) => p.userId != currentUserId,
    //     orElse: () => _currentChat!.participants.first,
    //   );
    //
    //   _socketService?.sendTypingIndicator(
    //     chatId: _currentChat!.id,
    //     receiverId: otherParticipant.userId,
    //     isTyping: isTyping,
    //   );
    // } catch (e) {
    //   log('Error sending typing indicator: $e');
    // }
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
      log('Failed to update unread count: $e');
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
      // Socket leave is optional
      // _socketService?.leaveChat(_currentChat!.id);
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
    // Socket dispose is optional
    // _socketService?.dispose();
    super.dispose();
  }
}
