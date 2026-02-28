import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';
import 'package:wood_service/chats/message_bubble.dart' show MessageBubble;

class BuyerChatScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final String? productId;
  final String? productName;
  final String? orderId;

  const BuyerChatScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
    this.productId,
    this.productName,
    this.orderId,
  });

  @override
  State<BuyerChatScreen> createState() => _BuyerChatScreenState();
}

class _BuyerChatScreenState extends State<BuyerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late BuyerChatProvider _chatProvider;

  // For file picking
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedFile;
  String? _selectedFileName;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    print(
      'BuyerChatScreen init - Seller: ${widget.sellerId}, Order: ${widget.orderId}',
    );
    _chatProvider = Provider.of<BuyerChatProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    try {
      final userInfo = await _chatProvider.getCurrentUserInfo();
      final buyerId = userInfo['userId'] as String?;

      if (buyerId == null) {
        throw Exception('Buyer ID not found');
      }

      print(
        'Opening chat - Buyer: $buyerId, Seller: ${widget.sellerId}, Order: ${widget.orderId}',
      );

      await _chatProvider.openChat(
        sellerId: widget.sellerId,
        orderId: widget.orderId ?? '',
      );

      // Scroll to bottom AFTER messages load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error initializing chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    // Don't send if no message and no file
    if (message.isEmpty && _selectedFile == null) return;

    print(
      'Sending message: $message, OrderId: ${widget.orderId}, SellerId: ${widget.sellerId}',
    );

    try {
      List<Map<String, dynamic>>? attachments;

      // Prepare attachments if file is selected
      if (_selectedFile != null) {
        attachments = [
          {
            'file': _selectedFile!,
            'name': _selectedFileName ?? 'attachment',
            'type': _getFileType(_selectedFile!.path),
          },
        ];
      }

      setState(() {
        _isUploading = true;
      });

      await _chatProvider.sendMessage(
        message,
        orderId: widget.orderId,
        sellerId: widget.sellerId, // PASS SELLER ID HERE
        attachments: attachments,
      );

      _messageController.clear();

      // Clear selected file
      setState(() {
        _selectedFile = null;
        _selectedFileName = null;
        _isUploading = false;
      });

      // Scroll to bottom to show new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _getFileType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) {
      return 'video';
    } else if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) {
      return 'document';
    } else {
      return 'file';
    }
  }

  // File picking methods
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _selectedFileName = image.name;
        });

        // Show preview or indicator that file is selected
        _showFileSelectedSnackbar();
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _pickDocument() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
  //     );

  //     if (result != null && result.files.single.path != null) {
  //       setState(() {
  //         _selectedFile = File(result.files.single.path!);
  //         _selectedFileName = result.files.single.name;
  //       });

  //       _showFileSelectedSnackbar();
  //     }
  //   } catch (e) {
  //     print('Error picking document: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to pick document: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _selectedFileName =
              'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        });

        _showFileSelectedSnackbar();
      }
    } catch (e) {
      print('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFileSelectedSnackbar() {
    if (mounted && _selectedFileName != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File selected: $_selectedFileName'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Remove',
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _selectedFileName = null;
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerChatProvider>(
      builder: (context, chatProvider, child) {
        final currentChat = chatProvider.currentChat;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          appBar: _buildAppBar(context, chatProvider),
          body: Column(
            children: [
              if (currentChat?.orderId != null) _buildOrderInfo(currentChat!),

              // Show selected file preview
              if (_selectedFile != null) _buildFilePreview(),

              Expanded(
                child: chatProvider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : _buildChatMessages(chatProvider),
              ),
            ],
          ),
          bottomSheet: _buildMessageInput(chatProvider),
        );
      },
    );
  }

  Widget _buildFilePreview() {
    final fileType = _getFileType(_selectedFile!.path);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              fileType == 'image'
                  ? Icons.image
                  : fileType == 'video'
                  ? Icons.videocam
                  : fileType == 'document'
                  ? Icons.description
                  : Icons.insert_drive_file,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFileName ?? 'File',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                Text(
                  '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _selectedFileName = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(ChatRoom chat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_bag_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Order: ${chat.orderId ?? 'Unknown'}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (chat.orderDetails?['status'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(chat.orderDetails!['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${chat.orderDetails!['status']}'.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Theme.of(context).colorScheme.primary;
      case 'pending':
        return Theme.of(context).colorScheme.primary;
      case 'cancelled':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildChatMessages(BuyerChatProvider chatProvider) {
    final messages = chatProvider.currentMessages;

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 80),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final messageIndex = messages.length - 1 - index;
          final message = messages[messageIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: MessageBubble(
              message: message,
              isSentByMe: message.isSentByMe,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput(BuyerChatProvider chatProvider) {
    final hasContent =
        _messageController.text.trim().isNotEmpty || _selectedFile != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isUploading) _buildUploadingIndicator(),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          // i dont want textfield border
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),

                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
                          ),
                          maxLines: null,
                          onChanged: (value) {
                            setState(() {});
                          },
                          // onSubmitted: (_) => _sendMessage(),
                          onFieldSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.attach_file,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _showAttachmentOptions,
                      ),
                      if (_selectedFile != null)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Icon(
                              Icons.attachment,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasContent
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: _isUploading
                    ? Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: hasContent && !chatProvider.isSending
                            ? _sendMessage
                            : null,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Uploading...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, BuyerChatProvider chatProvider) {
    final currentChat = chatProvider.currentChat;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          chatProvider.clearCurrentChat();
          Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              (currentChat?.otherUserName ?? widget.sellerName).isNotEmpty
                  ? (currentChat?.otherUserName ?? widget.sellerName)[0]
                        .toUpperCase()
                  : 'S',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentChat?.otherUserName ?? widget.sellerName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Online',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
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
            Text(
              'Send File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.image,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                // _buildAttachmentOption(
                //   icon: Icons.description,
                //   label: 'Document',
                //   onTap: () {
                //     Navigator.pop(context);
                //     _pickDocument();
                //   },
                // ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedFile != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedFile = null;
                    _selectedFileName = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Clear Selected File',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
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
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
