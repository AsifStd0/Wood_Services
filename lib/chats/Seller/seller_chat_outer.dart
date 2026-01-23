// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wood_service/chats/Seller/seller_chat_provider.dart';
// import 'package:wood_service/chats/Seller/seller_chat_screen.dart';

// class SellerOuterMessagesScreen extends StatefulWidget {
//   const SellerOuterMessagesScreen({super.key});

//   @override
//   State<SellerOuterMessagesScreen> createState() =>
//       _SellerOuterMessagesScreenState();
// }

// class _SellerOuterMessagesScreenState extends State<SellerOuterMessagesScreen> {
//   late SellerChatProvider _chatProvider;
//   bool _isInitializing = false;

//   @override
//   void initState() {
//     super.initState();
//     print('🎯 Seller MessagesScreen initState');

//     _chatProvider = Provider.of<SellerChatProvider>(context, listen: false);
//     _initializeChat();
//   }

//   Future<void> _initializeChat() async {
//     if (_isInitializing) return;

//     _isInitializing = true;
//     print('🔄 Initializing chat for seller...');

//     try {
//       await _chatProvider.initialize();
//       await _chatProvider.loadSellerDashboard();
//       print('✅ Seller chat initialized successfully');
//     } catch (e) {
//       print('❌ Error initializing seller chat: $e');
//     } finally {
//       _isInitializing = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('🎯 Building Seller MessagesScreen');

//     return Consumer<SellerChatProvider>(
//       builder: (context, chatProvider, child) {
//         print('🎯 Seller Consumer with ${chatProvider.chats.length} chats');

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Seller Messages'),
//             centerTitle: true,
//           ),
//           body: RefreshIndicator(
//             onRefresh: () async {
//               await chatProvider.loadSellerChats();
//               await chatProvider.loadSellerDashboard();
//             },
//             child: _buildBody(chatProvider), // This might be the issue
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildBody(SellerChatProvider chatProvider) {
//     if (chatProvider.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (chatProvider.error != null) {
//       print('❌ Showing error widget: ${chatProvider.error}');
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, color: Colors.red, size: 50),
//             const SizedBox(height: 16),
//             Text('Error: ${chatProvider.error}'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 chatProvider.loadSellerChats();
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (chatProvider.chats.isEmpty) {
//       print('📱 Showing empty state widget');
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.chat, size: 100, color: Colors.grey[300]),
//             const SizedBox(height: 16),
//             const Text(
//               'No customer conversations yet',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 'When customers message you, their conversations will appear here',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     print('✅ Building chat list with ${chatProvider.chats.length} chats');
//     return _buildChatList(chatProvider);
//   }

//   Widget _buildChatList(SellerChatProvider chatProvider) {
//     if (chatProvider.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (chatProvider.error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, color: Colors.red, size: 50),
//             const SizedBox(height: 16),
//             Text('Error: ${chatProvider.error}'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 chatProvider.loadSellerChats();
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (chatProvider.chats.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.chat, size: 100, color: Colors.grey[300]),
//             const SizedBox(height: 16),
//             const Text(
//               'No customer conversations yet',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 'When customers message you, their conversations will appear here',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: chatProvider.chats.length,
//       itemBuilder: (context, index) {
//         final chat = chatProvider.chats[index];

//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.green,
//               child: Text(
//                 chat.buyerName.isNotEmpty
//                     ? chat.buyerName[0].toUpperCase()
//                     : '?',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//             title: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     chat.buyerName,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   chat.lastMessageText ?? 'No messages yet',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (chat.productName != null)
//                   Text(
//                     'Product: ${chat.productName}',
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//               ],
//             ),
//             trailing: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   _formatTime(chat.updatedAt),
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 if (chat.sellerUnreadCount > 0) ...[
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       '${chat.sellerUnreadCount}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//             onTap: () {
//               print('📱 Seller opening chat with ${chat.buyerName}');
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SellerChatScreen(
//                     buyerId: chat.buyerId ?? '',
//                     buyerName: chat.buyerName,
//                     chatId: chat.id,
//                     productId: chat.productId,
//                     productName: chat.productName,
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     final difference = now.difference(time);

//     if (difference.inMinutes < 1) return 'Just now';
//     if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
//     if (difference.inHours < 24) return '${difference.inHours}h ago';
//     if (difference.inDays < 7) return '${difference.inDays}d ago';
//     return '${(difference.inDays / 7).floor()}w ago';
//   }
// }
