// import 'package:flutter/material.dart';
// import 'package:wood_service/app/index.dart';
// import 'package:wood_service/views/Seller/data/views/seller_chating/chat_view_provider.dart';
// import 'package:wood_service/views/Seller/data/views/seller_chating/message_%20bubble.dart';

// class SellerChatDetail extends StatefulWidget {
//   final SellerChatViewModel viewModel;

//   const SellerChatDetail({required this.viewModel});

//   @override
//   State<SellerChatDetail> createState() => _ChatDetailScreenState();
// }

// class _ChatDetailScreenState extends State<SellerChatDetail> {
//   final TextEditingController _messageController = TextEditingController();
//   final FocusNode _messageFocusNode = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     final chat = widget.viewModel.selectedChat!;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_rounded),
//           onPressed: widget.viewModel.goBack,
//         ),
//         title: Row(
//           children: [
//             // Avatar
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: Color(0xFF667EEA),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     chat.buyerName,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     chat.isOnline ? 'Online' : 'Last seen ${chat.timeAgo}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600]),
//             onPressed: () {
//               // Show more options
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Main Content
//           Column(
//             children: [
//               // Order Info Banner (if exists)
//               if (chat.orderId != null)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   color: Colors.blue.withOpacity(0.05),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.shopping_bag_rounded,
//                         size: 16,
//                         color: Colors.blue,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Order ${chat.orderId}',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.blue[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () {
//                           // Navigate to order details
//                         },
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 8),
//                           minimumSize: Size.zero,
//                         ),
//                         child: Text(
//                           'View Order',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.blue[700],
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//               // Messages List with bottom padding for input
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 80), // Safe padding
//                   child: _buildMessagesList(),
//                 ),
//               ),
//               // Expanded(child: _buildMessagesList()),
//             ],
//           ),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: _buildFloatingMessageInput(),
//     );
//   }

//   Widget _buildMessagesList() {
//     if (widget.viewModel.isLoading) {
//       return Center(child: CircularProgressIndicator(color: Color(0xFF667EEA)));
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: widget.viewModel.currentMessages.length,
//       itemBuilder: (context, index) {
//         final message = widget.viewModel.currentMessages[index];
//         return MessageBubble(message: message);
//       },
//     );
//   }

//   Widget _buildFloatingMessageInput() {
//     final hasText = _messageController.text.trim().isNotEmpty;

//     return Container(
//       padding: const EdgeInsets.only(right: 10, left: 6, bottom: 10),
//       color: AppColors.white,

//       child: Row(
//         children: [
//           // Custom Chat Input Field (without borders/background)
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               focusNode: _messageFocusNode,
//               maxLines: null,
//               textInputAction: TextInputAction.send,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: const BorderSide(
//                     color: AppColors.greyLight,
//                     width: 1.5,
//                   ),
//                 ),
//               ),
//               onChanged: (value) => setState(() {}),
//               onSubmitted: (value) {
//                 if (value.trim().isNotEmpty) _sendMessage();
//               },
//             ),
//           ),

//           const SizedBox(width: 6),

//           // Attachment Button
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

//           // Beautiful Send Button

//           // 🚀 Send Button (Floating Gradient Circle)
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF667EEA).withOpacity(0.4),
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.send_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               onPressed: _messageController.text.trim().isNotEmpty
//                   ? _sendMessage
//                   : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _sendMessage() {
//     final message = _messageController.text.trim();
//     if (message.isNotEmpty) {
//       widget.viewModel.sendMessage(message);
//       _messageController.clear();
//       setState(() {}); // Update send button state
//     }
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
//     super.dispose();
//   }
// }
