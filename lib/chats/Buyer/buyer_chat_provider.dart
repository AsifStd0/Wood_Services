import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_service.dart';
import 'package:wood_service/chats/Buyer/buyer_socket_service.dart';
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
