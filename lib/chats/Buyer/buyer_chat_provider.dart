import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_service.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';

class BuyerChatProvider extends ChangeNotifier {
  final BuyerChatService _chatService;
  final UnifiedLocalStorageServiceImpl _storage =
      locator<UnifiedLocalStorageServiceImpl>();

  List<ChatRoom> _chats = [];
  List<BuyerChatModel> _currentMessages = [];
  ChatRoom? _currentChat;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  // Current user info
  Map<String, dynamic>? _currentUser;

  // Getters
  List<ChatRoom> get chats => _chats;
  List<BuyerChatModel> get currentMessages => _currentMessages;
  ChatRoom? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  BuyerChatProvider({required BuyerChatService chatService})
    : _chatService = chatService;

  Future<void> initialize() async {
    try {
      await _loadCurrentUser();
      await loadChats();
    } catch (e) {
      _error = 'Failed to initialize: $e';
      log('Error initializing chat: $e');
      notifyListeners();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userData = _storage.getUserData();
      _currentUser = {
        'userId':
            userData?['_id']?.toString() ?? userData?['id']?.toString() ?? '',
        'userType': userData?['userType']?.toString() ?? 'Buyer',
        'userName':
            userData?['fullName']?.toString() ??
            userData?['businessName']?.toString() ??
            userData?['name']?.toString() ??
            'User',
      };
      log('Current user loaded: ${_currentUser?['userId']}');
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
      log('Loaded ${_chats.length} chats');
    } catch (e) {
      _error = 'Failed to load chats: $e';
      log('Error loading chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openChat({
    required String sellerId,
    required String orderId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      log('🔄 Opening chat - Seller: $sellerId, Order: $orderId');

      final session = await _chatService.openChat(
        sellerId: sellerId,
        orderId: orderId,
      );

      _currentChat = session.chat;
      _currentMessages = session.messages;

      log(
        '✅ Opened chat ${_currentChat?.id} with ${_currentMessages.length} messages',
      );
    } catch (e) {
      _error = 'Failed to open chat: $e';
      log('❌ Error opening chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    String message, {
    String? orderId,
    String? sellerId, // Add sellerId parameter
    List<Map<String, dynamic>>? attachments,
  }) async {
    if (message.trim().isEmpty &&
        (attachments == null || attachments.isEmpty)) {
      return;
    }
    // Use current chat's orderId or provided orderId
    final targetOrderId = _currentChat?.orderId ?? orderId;
    if (targetOrderId == null) {
      _error = 'No orderId available for sending message';
      notifyListeners();
      return;
    }

    // Get sellerId from current chat or parameter
    final targetSellerId = _getSellerIdFromChat() ?? sellerId;
    if (targetSellerId == null) {
      _error = 'No sellerId available for sending message';
      notifyListeners();
      return;
    }

    _isSending = true;
    notifyListeners();

    try {
      final sentMessage = await _chatService.sendMessage(
        orderId: targetOrderId,
        sellerId: targetSellerId, // Pass sellerId
        message: message.trim(),
        attachments: attachments,
      );

      _currentMessages.add(sentMessage);

      // Update chat list
      _updateChatList(message.trim());

      log('✅ Message sent successfully');
    } catch (e) {
      _error = 'Failed to send message: $e';
      log('❌ Error sending message: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // Helper method to extract sellerId from current chat
  String? _getSellerIdFromChat() {
    if (_currentChat == null || _currentChat!.participants.isEmpty) {
      return null;
    }

    // Find seller participant
    final seller = _currentChat!.participants.firstWhere(
      (p) => p.userType == 'Seller',
      orElse: () => _currentChat!.participants.first,
    );

    return seller.userId;
  }

  void _updateChatList(String lastMessage) {
    if (_currentChat == null) return;

    final index = _chats.indexWhere((c) => c.id == _currentChat!.id);

    if (index != -1) {
      String displayText = lastMessage;
      if (lastMessage.isEmpty) {
        displayText = '📷 Image'; // or '📎 Attachment' for files
      }

      _chats[index] = _chats[index].copyWith(
        lastMessageText: displayText,
        updatedAt: DateTime.now(),
      );
      _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }
  // void _updateChatList(String lastMessage) {
  //   if (_currentChat == null) return;

  //   final index = _chats.indexWhere((c) => c.id == _currentChat!.id);

  //   if (index != -1) {
  //     _chats[index] = _chats[index].copyWith(
  //       lastMessageText: lastMessage,
  //       updatedAt: DateTime.now(),
  //     );
  //     _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  //   }
  // }

  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    if (_currentUser != null) return _currentUser!;
    await _loadCurrentUser();
    return _currentUser ?? {};
  }

  Future<String?> getCurrentUserId() async {
    final user = await getCurrentUserInfo();
    return user['userId'];
  }

  Future<String?> getCurrentUserName() async {
    final user = await getCurrentUserInfo();
    return user['userName'];
  }

  void clearCurrentChat() {
    _currentChat = null;
    _currentMessages.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
