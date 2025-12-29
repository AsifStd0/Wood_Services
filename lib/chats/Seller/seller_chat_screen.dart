import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/chat_messages.dart';
import 'package:wood_service/chats/chat_provider.dart';
import 'package:wood_service/chats/message_bubble.dart';
import 'package:wood_service/core/theme/app_colors.dart';

class SellerChatScreen extends StatefulWidget {
  final String buyerId;
  final String buyerName;
  final String? buyerImage;
  final String? productId;
  final String? orderId;

  const SellerChatScreen({
    super.key,
    required this.buyerId,
    required this.buyerName,
    this.buyerImage,
    this.productId,
    this.orderId,
  });

  @override
  State<SellerChatScreen> createState() => _SellerChatScreenState();
}

class _SellerChatScreenState extends State<SellerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late ChatProvider _chatProvider;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    try {
      // Get current user info
      final userInfo = await _chatProvider.getCurrentUserInfo();
      final sellerId = userInfo['userId'] as String?;

      if (sellerId == null) {
        throw Exception('Seller ID not found');
      }

      // Open chat with buyer
      await _chatProvider.openChat(
        sellerId: sellerId,
        buyerId: widget.buyerId,
        productId: widget.productId,
        orderId: widget.orderId,
      );

      // Scroll to bottom after messages load
      _scrollToBottom();
    } catch (e) {
      print('Error initializing chat: $e');
      // Handle error - show snackbar or dialog
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTyping() {
    if (_typingTimer != null) {
      _typingTimer!.cancel();
    }

    // Send typing indicator
    _chatProvider.sendTypingIndicator(true);

    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatProvider.sendTypingIndicator(false);
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await _chatProvider.sendMessage(message);
    _messageController.clear();
    _scrollToBottom();

    // Stop typing indicator
    _typingTimer?.cancel();
    await _chatProvider.sendTypingIndicator(false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, chatProvider),
          body: Column(
            children: [
              if (chatProvider.currentChat?.orderId != null)
                _buildOrderInfo(chatProvider.currentChat!),
              Expanded(
                child: chatProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildChatMessages(chatProvider),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildMessageInput(),
        );
      },
    );
  }

  Widget _buildOrderInfo(ChatRoom chat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${chat.orderId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View order details',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to order details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(ChatProvider chatProvider) {
    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        reverse: true,
        itemCount: chatProvider.currentMessages.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(height: 20);
          }

          final messageIndex = index - 1;
          final message = chatProvider.currentMessages[messageIndex];

          return MessageBubble(
            message: message,
            isMe: message.senderType == 'Seller', // Seller perspective
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    final hasText = _messageController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(right: 10, left: 6, bottom: 10),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(
                Icons.attach_file_rounded,
                color: Colors.grey.shade700,
                size: 20,
              ),
              onPressed: () => _showAttachmentOptions(),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasText
                  ? const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: hasText ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ChatProvider chatProvider) {
    final currentChat = chatProvider.currentChat;
    final otherUserOnline = currentChat?.otherUserIsOnline ?? false;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          chatProvider.clearCurrentChat();
          Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              widget.buyerName.isNotEmpty
                  ? widget.buyerName[0].toUpperCase()
                  : 'B',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.buyerName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                otherUserOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: otherUserOnline ? Colors.green : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.black54),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          onPressed: () => _showMoreOptions(),
        ),
      ],
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.image_rounded,
                  label: 'Gallery',
                  onTap: () => _pickImageFromGallery(),
                ),
                _buildAttachmentOption(
                  icon: Icons.description_rounded,
                  label: 'Document',
                  onTap: () => _pickDocument(),
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'File',
                  onTap: () => _pickFile(),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, size: 30, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _pickImageFromGallery() {
    Navigator.pop(context);
    // Implement image picker
  }

  void _pickDocument() {
    Navigator.pop(context);
    // Implement document picker
  }

  void _pickFile() {
    Navigator.pop(context);
    // Implement file picker
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('View Buyer Profile'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to buyer profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block Buyer'),
            onTap: () {
              Navigator.pop(context);
              _showBlockConfirmation();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Chat'),
            onTap: () {
              Navigator.pop(context);
              _showClearChatConfirmation();
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text('Report Buyer'),
            onTap: () {
              Navigator.pop(context);
              // Show report dialog
            },
          ),
        ],
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Buyer'),
        content: const Text('Are you sure you want to block this buyer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement block functionality
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearChatConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement clear chat functionality
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
