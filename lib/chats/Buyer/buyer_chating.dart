// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:wood_service/app/index.dart';
// import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
// import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';
// import 'package:wood_service/chats/message_bubble.dart' show MessageBubble;

// class BuyerChatScreen extends StatefulWidget {
//   final String sellerId;
//   final String sellerName;
//   final String? productId;
//   final String? productName;
//   const BuyerChatScreen({
//     super.key,
//     required this.sellerId,
//     required this.sellerName,
//     this.productId,
//     this.productName,
//   });

//   @override
//   State<BuyerChatScreen> createState() => _BuyerChatScreenState();
// }

// class _BuyerChatScreenState extends State<BuyerChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FocusNode _messageFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();
//   late BuyerChatProvider _chatProvider;
//   Timer? _typingTimer;

//   @override
//   void initState() {
//     super.initState();
//     log(
//       'data is here ${widget.sellerId} ${widget.sellerName} ${widget.productId} ',
//     );
//     _chatProvider = Provider.of<BuyerChatProvider>(context, listen: false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeChat();
//     });
//   }

//   Future<void> _initializeChat() async {
//     try {
//       // Get current user info
//       final userInfo = await _chatProvider.getCurrentUserInfo();
//       final buyerId = userInfo['userId'] as String?;

//       if (buyerId == null) {
//         throw Exception('Buyer ID not found');
//       }

//       // Open chat with seller
//       await _chatProvider.openChat(
//         sellerId: widget.sellerId,
//         buyerId: buyerId,
//         productId: widget.productId,
//         // orderId: widget.orderId,
//       );

//       // Scroll to bottom after messages load
//       _scrollToBottom();
//     } catch (e) {
//       print('Error initializing chat: $e');
//       // Handle error - show snackbar or dialog
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.minScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   void _onTyping() {
//     if (_typingTimer != null) {
//       _typingTimer!.cancel();
//     }

//     // Send typing indicator
//     _chatProvider.sendTypingIndicator(true);

//     _typingTimer = Timer(const Duration(seconds: 2), () {
//       _chatProvider.sendTypingIndicator(false);
//     });
//   }

//   Future<void> _sendMessage() async {
//     final message = _messageController.text.trim();
//     if (message.isEmpty) return;

//     await _chatProvider.sendMessage(message);
//     _messageController.clear();
//     _scrollToBottom();

//     // Stop typing indicator
//     _typingTimer?.cancel();
//     await _chatProvider.sendTypingIndicator(false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<BuyerChatProvider>(
//       builder: (context, chatProvider, child) {
//         final currentChat = chatProvider.currentChat;

//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: _buildAppBar(context, chatProvider),
//           body: Column(
//             children: [
//               // Order info banner if exists
//               if (currentChat?.orderId != null) _buildOrderInfo(currentChat!),

//               Expanded(
//                 child: chatProvider.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _buildChatMessages(chatProvider),
//               ),
//             ],
//           ),
//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.centerDocked,
//           floatingActionButton: _buildMessageInput(),
//         );
//       },
//     );
//   }

//   Widget _buildOrderInfo(ChatRoom chat) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.05),
//         border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'Order ${chat.orderId}',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[700],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               // Navigate to order details
//             },
//             style: TextButton.styleFrom(
//               padding: EdgeInsets.zero,
//               minimumSize: Size.zero,
//             ),
//             child: Text(
//               'View Order',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatMessages(BuyerChatProvider chatProvider) {
//     return Container(
//       padding: EdgeInsets.only(bottom: 60),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//         child: ListView.builder(
//           controller: _scrollController,
//           padding: const EdgeInsets.all(16),
//           reverse: false,
//           itemCount: chatProvider.currentMessages.length + 1,
//           itemBuilder: (context, index) {
//             if (index == 0) {
//               return const SizedBox(height: 20);
//             }

//             final messageIndex = index - 1;
//             final message = chatProvider.currentMessages[messageIndex];

//             return MessageBubble(
//               message: message,
//               isMe: message.senderType == 'Buyer', // Adjust based on user role
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     final hasText = _messageController.text.trim().isNotEmpty;

//     return Container(
//       padding: const EdgeInsets.only(right: 10, left: 6, bottom: 10),
//       color: AppColors.white,
//       child: Row(
//         children: [
//           Expanded(
//             child: CustomTextFormField(
//               controller: _messageController,
//               focusNode: _messageFocusNode,
//               textFieldType: TextFieldType.text,
//               hintText: 'Type a message...',
//               minline: 1,
//               maxLines: 3,
//               isDialogField: true,
//               validate: false, // Disable validation for chat
//               fillcolor: Colors.white,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//               onChanged: (value) {
//                 _onTyping();
//                 setState(() {});
//               },
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.add_rounded,
//                 color: Colors.grey.shade700,
//                 size: 20,
//               ),
//               onPressed: _showAttachmentOptions,
//               padding: EdgeInsets.zero,
//             ),
//           ),
//           const SizedBox(width: 12),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: hasText
//                   ? const LinearGradient(
//                       colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     )
//                   : LinearGradient(
//                       colors: [Colors.grey.shade300, Colors.grey.shade400],
//                     ),
//               boxShadow: hasText
//                   ? [
//                       BoxShadow(
//                         color: const Color(0xFF667EEA).withOpacity(0.4),
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.send_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               onPressed: hasText ? _sendMessage : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   AppBar _buildAppBar(BuildContext context, BuyerChatProvider chatProvider) {
//     final currentChat = chatProvider.currentChat;
//     final otherUserOnline = currentChat?.otherUserIsOnline ?? false;

//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 1,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () {
//           chatProvider.clearCurrentChat();
//           Navigator.pop(context);
//         },
//       ),
//       title: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: AppColors.primary,
//             // foregroundImage: currentChat?.otherUserImage != null
//             //     ? NetworkImage(currentChat!.otherUserImage!)
//             //     : null,
//             // child: currentChat?.otherUserImage == null
//             //     ? Text(
//             //         widget.sellerName.isNotEmpty
//             //             ? widget.sellerName[0].toUpperCase()
//             //             : 'S',
//             //         style: const TextStyle(color: Colors.white),
//             //       )
//             //     : null,
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 currentChat?.otherUserName ?? widget.sellerName,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 otherUserOnline ? 'Online' : 'Offline',
//                 style: TextStyle(
//                   color: otherUserOnline ? Colors.green : Colors.grey,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAttachmentOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Send File',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildAttachmentOption(
//                   icon: Icons.image_rounded,
//                   label: 'Gallery',
//                   onTap: () => _pickImageFromGallery(),
//                 ),
//                 _buildAttachmentOption(
//                   icon: Icons.description_rounded,
//                   label: 'Document',
//                   onTap: () => _pickDocument(),
//                 ),
//                 _buildAttachmentOption(
//                   icon: Icons.folder_rounded,
//                   label: 'File',
//                   onTap: () => _pickFile(),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttachmentOption({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return Column(
//       children: [
//         IconButton(
//           icon: Icon(icon, size: 30, color: Color(0xFF667EEA)),
//           onPressed: onTap,
//         ),
//         Text(label, style: TextStyle(fontSize: 12)),
//       ],
//     );
//   }

//   void _pickImageFromGallery() {
//     Navigator.pop(context);
//     // Implement image picker
//     print('Pick image from gallery');
//   }

//   void _pickDocument() {
//     Navigator.pop(context);
//     // Implement document picker
//     print('Pick document');
//   }

//   void _pickFile() {
//     Navigator.pop(context);
//     // Implement file picker
//     print('Pick file');
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _messageFocusNode.dispose();
//     _scrollController.dispose();
//     _typingTimer?.cancel();
//     super.dispose();
//   }
// }
