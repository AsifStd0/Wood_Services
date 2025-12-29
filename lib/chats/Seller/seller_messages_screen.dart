// lib/chats/Seller/seller_messages_screen.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/Seller/seller_chat_screen.dart';
import 'package:wood_service/chats/chat_provider.dart';

class SellerMessagesScreen extends StatefulWidget {
  const SellerMessagesScreen({super.key});

  @override
  State<SellerMessagesScreen> createState() => _SellerMessagesScreenState();
}

class _SellerMessagesScreenState extends State<SellerMessagesScreen> {
  late ChatProvider _chatProvider;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    print('🎯 SellerMessagesScreen initState - Seller Chat List');

    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (_isInitializing) return;

    _isInitializing = true;
    print('🔄 Initializing chat for seller...');

    try {
      await _chatProvider.initialize();
      print('✅ Chat initialized successfully for seller');
    } catch (e) {
      print('❌ Error initializing chat for seller: $e');
    } finally {
      _isInitializing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 Building SellerMessagesScreen (Seller)');

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        print('🎯 Consumer rebuilding with ${chatProvider.chats.length} chats');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages'),
            centerTitle: true,
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await chatProvider.loadChats();
            },
            child: _buildBody(chatProvider),
          ),
        );
      },
    );
  }

  Widget _buildBody(ChatProvider chatProvider) {
    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text('Error: ${chatProvider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                chatProvider.loadChats();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (chatProvider.chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No conversations yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'When buyers message you, conversations will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: chatProvider.chats.length,
      itemBuilder: (context, index) {
        final chat = chatProvider.chats[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                chat.otherUserName.isNotEmpty
                    ? chat.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              chat.otherUserName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat.lastMessageText ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(chat.updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              print('📱 Opening chat with ${chat.otherUserName}');
              // Navigate to SellerChatScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerChatScreen(
                    buyerId: chat.participants
                        .firstWhere((p) => p.userType == 'Buyer')
                        .userId,
                    buyerName: chat.otherUserName,
                    productId: chat.productId,
                    orderId: chat.orderId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }
}
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wood_service/chats/Seller/seller_chat_screen.dart';
// import 'package:wood_service/chats/chat_list_item.dart';
// import 'package:wood_service/chats/chat_messages.dart';
// import 'package:wood_service/chats/chat_provider.dart';

// class SellerMessagesScreen extends StatefulWidget {
//   const SellerMessagesScreen({super.key});

//   @override
//   State<SellerMessagesScreen> createState() => _SellerMessagesScreenState();
// }

// class _SellerMessagesScreenState extends State<SellerMessagesScreen> {
//   late ChatProvider _chatProvider;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _chatProvider = Provider.of<ChatProvider>(context, listen: false);
//     _initializeChat();
//   }

//   Future<void> _initializeChat() async {
//     await _chatProvider.loadChats();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ChatProvider>(
//       builder: (context, chatProvider, child) {
//         return Scaffold(
//           backgroundColor: const Color(0xFFF8FAFC),
//           body: Column(
//             children: [
//               // Custom App Bar
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       blurRadius: 3,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: SafeArea(
//                   bottom: false,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               'Messages',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                             const Spacer(),
//                             if (chatProvider.unreadCount > 0)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF667EEA),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   chatProvider.unreadCount.toString(),
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         TextField(
//                           controller: _searchController,
//                           onChanged: (value) => chatProvider.searchChats(value),
//                           decoration: InputDecoration(
//                             hintText: 'Search conversations...',
//                             prefixIcon: const Icon(Icons.search_rounded),
//                             suffixIcon: _searchController.text.isNotEmpty
//                                 ? IconButton(
//                                     icon: const Icon(Icons.clear_rounded),
//                                     onPressed: () {
//                                       _searchController.clear();
//                                       chatProvider.searchChats('');
//                                     },
//                                   )
//                                 : null,
//                             filled: true,
//                             fillColor: Colors.grey[50],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // Chat List
//               Expanded(
//                 child: RefreshIndicator(
//                   onRefresh: () async => await chatProvider.loadChats(),
//                   child: chatProvider.isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : chatProvider.filteredChats.isEmpty
//                       ? _buildEmptyState(chatProvider)
//                       : ListView.builder(
//                           padding: const EdgeInsets.only(top: 8, bottom: 16),
//                           itemCount: chatProvider.filteredChats.length,
//                           itemBuilder: (context, index) {
//                             final chat = chatProvider.filteredChats[index];
//                             return ChatListItem(
//                               chat: chat,
//                               onTap: () => _openChat(context, chat),
//                               isSeller: true,
//                             );
//                           },
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState(ChatProvider chatProvider) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.chat_bubble_outline_rounded,
//                 size: 50,
//                 color: Colors.grey[400],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               chatProvider.searchQuery.isEmpty
//                   ? 'No Conversations'
//                   : 'No Results Found',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 chatProvider.searchQuery.isEmpty
//                     ? 'When customers message you, conversations will appear here'
//                     : 'No conversations found for "${chatProvider.searchQuery}"',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[500],
//                   height: 1.4,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (chatProvider.searchQuery.isNotEmpty)
//               ElevatedButton(
//                 onPressed: () {
//                   _searchController.clear();
//                   chatProvider.searchChats('');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF667EEA),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 child: const Text('Clear Search'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // FIXED: Proper data passing for Seller
//   void _openChat(BuildContext context, ChatRoom chat) async {
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false);

//     // Get current user info
//     final currentUserInfo = await chatProvider.getCurrentUserInfo();
//     final currentUserId = currentUserInfo['userId'] as String?;
//     final currentUserType = currentUserInfo['userType'] as String?;

//     // Find buyer participant
//     final buyerParticipant = chat.participants.firstWhere(
//       (p) => p.userType == 'Buyer',
//       orElse: () => chat.participants.last,
//     );

//     // Find seller participant (current user or other)
//     String sellerId;
//     String sellerName;

//     if (currentUserType == 'seller') {
//       // Current user is seller, use current user's info
//       sellerId = currentUserId ?? '';
//       sellerName = currentUserInfo['userName'] as String? ?? 'Seller';
//     } else {
//       // Find seller from participants
//       final sellerParticipant = chat.participants.firstWhere(
//         (p) => p.userType == 'Seller',
//         orElse: () => chat.participants.first,
//       );
//       sellerId = sellerParticipant.userId;
//       sellerName = sellerParticipant.name;
//     }

//     // Open the chat
//     await chatProvider.openChat(
//       sellerId: sellerId,
//       buyerId: buyerParticipant.userId,
//       productId: chat.productId,
//       orderId: chat.orderId,
//     );

//     // Navigate to chat screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SellerChatScreen(
//           buyerId: buyerParticipant.userId,
//           buyerName: buyerParticipant.name,
//           buyerImage: buyerParticipant.profileImage,
//           productId: chat.productId,
//           orderId: chat.orderId,
//         ),
//       ),
//     ).then((_) {
//       // Clear chat when returning
//       chatProvider.clearCurrentChat();
//     });
//   }
// }
