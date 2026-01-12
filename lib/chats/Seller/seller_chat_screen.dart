import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/Seller/seller_chat_provider.dart';
import 'package:wood_service/chats/message_bubble.dart' show MessageBubble;
import 'package:wood_service/core/theme/app_colors.dart';

class SellerChatScreen extends StatefulWidget {
  final String buyerId;
  final String buyerName;
  final String? chatId;
  final String? productId;
  final String? productName;
  final String? buyerImage;

  const SellerChatScreen({
    super.key,
    required this.buyerId,
    required this.buyerName,
    this.chatId,
    this.productId,
    this.productName,
    this.buyerImage,
  });

  @override
  State<SellerChatScreen> createState() => _SellerChatScreenState();
}

class _SellerChatScreenState extends State<SellerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late SellerChatProvider _chatProvider;
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    log(
      'Seller Chat - Buyer: ${widget.buyerId}, Chat: ${widget.chatId}, Product: ${widget.productId}',
    );

    _chatProvider = Provider.of<SellerChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    try {
      // Get current seller info
      final userInfo = await _chatProvider.getCurrentUserInfo();
      final sellerId = userInfo['userId'] as String?;

      if (sellerId == null) {
        throw Exception('Seller ID not found');
      }

      // Open or load existing chat
      if (widget.chatId != null) {
        // Load existing chat
        await _chatProvider.openExistingChat(widget.chatId!);
      } else {
        // Start new chat
        await _chatProvider.startChat(
          buyerId: widget.buyerId,
          sellerId: sellerId,
          productId: widget.productId,
        );
      }

      // Scroll to bottom
      _scrollToBottom();

      // Setup typing listener
      _setupTypingListener();
    } catch (e) {
      print('Error initializing seller chat: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load chat: $e')));
    }
  }

  void _setupTypingListener() {
    // Listen for buyer typing
    // You would implement this based on your socket setup
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
    setState(() => _isTyping = true);

    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatProvider.sendTypingIndicator(false);
      setState(() => _isTyping = false);
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
    setState(() => _isTyping = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerChatProvider>(
      builder: (context, chatProvider, child) {
        final currentChat = chatProvider.currentChat;

        return Scaffold(
          backgroundColor: Colors.grey[50],

          appBar: _buildAppBar(context, chatProvider),
          body: Column(
            children: [
              // Typing indicator
              if (_isTyping) _buildTypingIndicator(),

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

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.transparent,
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[300],
            child: Text(
              widget.buyerName.isNotEmpty
                  ? widget.buyerName[0].toUpperCase()
                  : '?',
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(SellerChatProvider chatProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          reverse: false,
          itemCount: chatProvider.currentMessages.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SizedBox(height: 20);
            }

            final messageIndex = index - 1;
            final message = chatProvider.currentMessages[messageIndex];

            return MessageBubble(
              message: message,
              isMe: message.senderType == 'Seller', // Seller's messages
            );
          },
        ),
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
              onChanged: (value) {
                _onTyping();
                setState(() {});
              },
              onSubmitted: (value) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type your reply...',
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
                Icons.add_rounded,
                color: Colors.grey.shade700,
                size: 20,
              ),
              onPressed: _showAttachmentOptions,
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
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF2E7D32),
                      ], // Green for seller
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
              boxShadow: hasText
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
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

  AppBar _buildAppBar(BuildContext context, SellerChatProvider chatProvider) {
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
            backgroundColor: Colors.green,
            foregroundImage: widget.buyerImage != null
                ? NetworkImage(widget.buyerImage!)
                : null,
            child: widget.buyerImage == null
                ? Text(
                    widget.buyerName.isNotEmpty
                        ? widget.buyerName[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
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
                'Customer',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[700]),
          onPressed: _showChatOptions,
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
                  icon: Icons.attach_file_rounded,
                  label: 'Document',
                  onTap: () => _pickDocument(),
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Product Photo',
                  onTap: () => _pickProductPhoto(),
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
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: const Color(0xFF4CAF50)),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showChatOptions() {
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
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Chat'),
              onTap: () {
                Navigator.pop(context);
                _chatProvider.toggleArchiveChat(
                  _chatProvider.currentChat?.id ?? '',
                  true,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Implement mute functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Chat'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to chat list
              // Implement delete functionality
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _pickImageFromGallery() {
    Navigator.pop(context);
    print('Seller: Pick image from gallery');
    // Implement image picker
  }

  void _pickDocument() {
    Navigator.pop(context);
    print('Seller: Pick document');
    // Implement document picker
  }

  void _pickProductPhoto() {
    Navigator.pop(context);
    print('Seller: Pick product photo');
    // Implement product photo picker
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }
}
