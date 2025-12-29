// lib/chats/Buyer/messages_screen.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/Buyer/buyer_chating.dart';
import 'package:wood_service/chats/chat_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late ChatProvider _chatProvider;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    print('🎯 MessagesScreen initState - Buyer Chat List');

    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (_isInitializing) return;

    _isInitializing = true;
    print('🔄 Initializing chat for buyer...');

    try {
      await _chatProvider.initialize();
      print('✅ Chat initialized successfully for buyer');
    } catch (e) {
      print('❌ Error initializing chat for buyer: $e');
    } finally {
      _isInitializing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 Building MessagesScreen (Buyer)');

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
                'When you message sellers, your conversations will appear here',
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
              backgroundColor: Colors.blue,
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
              // Navigate to ChatScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    sellerId: chat.participants
                        .firstWhere((p) => p.userType == 'Seller')
                        .userId,
                    sellerName: chat.otherUserName,
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
// import 'package:wood_service/chats/Buyer/buyer_chating.dart';
// import 'package:wood_service/chats/chat_list_item.dart';
// import 'package:wood_service/chats/chat_messages.dart';
// import 'package:wood_service/chats/chat_provider.dart';
// import 'package:wood_service/views/Buyer/Messages/chat_screen.dart';

// class MessagesScreen extends StatefulWidget {
//   const MessagesScreen({super.key});

//   @override
//   State<MessagesScreen> createState() => _MessagesScreenState();
// }

// class _MessagesScreenState extends State<MessagesScreen> {
//   late ChatProvider _chatProvider;

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
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             centerTitle: true,
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text('Messages'),
//                 if (chatProvider.unreadCount > 0) ...[
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF667EEA),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       chatProvider.unreadCount.toString(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () => _showSearchDialog(chatProvider),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.more_vert),
//                 onPressed: () => _showMoreOptions(chatProvider),
//               ),
//             ],
//           ),
//           body: RefreshIndicator(
//             onRefresh: () async => await chatProvider.loadChats(),
//             child: chatProvider.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : chatProvider.filteredChats.isEmpty
//                 ? _buildEmptyState()
//                 : ListView.builder(
//                     padding: const EdgeInsets.only(top: 8),
//                     itemCount: chatProvider.filteredChats.length,
//                     itemBuilder: (context, index) {
//                       final chat = chatProvider.filteredChats[index];
//                       return ChatListItem(
//                         chat: chat,
//                         onTap: () => _openChat(context, chat),
//                       );
//                     },
//                   ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
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
//             const Text(
//               'No Conversations',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 'When you message sellers, your conversations will appear here',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // FIXED: Proper data passing for Buyer
//   void _openChat(BuildContext context, ChatRoom chat) async {
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false);

//     // Get current user info
//     final currentUserInfo = await chatProvider.getCurrentUserInfo();
//     final currentUserId = currentUserInfo['userId'] as String?;
//     final currentUserType = currentUserInfo['userType'] as String?;

//     // Find seller participant
//     final sellerParticipant = chat.participants.firstWhere(
//       (p) => p.userType == 'Seller',
//       orElse: () => chat.participants.first,
//     );

//     // Find buyer participant (current user or other)
//     String buyerId;
//     String buyerName;

//     if (currentUserType == 'buyer') {
//       // Current user is buyer, use current user's info
//       buyerId = currentUserId ?? '';
//       buyerName = currentUserInfo['userName'] as String? ?? 'Buyer';
//     } else {
//       // Find buyer from participants
//       final buyerParticipant = chat.participants.firstWhere(
//         (p) => p.userType == 'Buyer',
//         orElse: () => chat.participants.last,
//       );
//       buyerId = buyerParticipant.userId;
//       buyerName = buyerParticipant.name;
//     }

//     // Open the chat
//     await chatProvider.openChat(
//       sellerId: sellerParticipant.userId,
//       buyerId: buyerId,
//       productId: chat.productId,
//       orderId: chat.orderId,
//     );

//     // Navigate to chat screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(
//           sellerId: sellerParticipant.userId,
//           sellerName: sellerParticipant.name,
//           sellerImage: sellerParticipant.profileImage.toString(),
//           productId: chat.productId,
//           orderId: chat.orderId,
//         ),
//       ),
//     ).then((_) {
//       // Clear chat when returning
//       chatProvider.clearCurrentChat();
//     });
//   }

//   void _showSearchDialog(ChatProvider chatProvider) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Search Conversations'),
//         content: TextField(
//           autofocus: true,
//           decoration: const InputDecoration(
//             hintText: 'Search by name or message...',
//             prefixIcon: Icon(Icons.search),
//           ),
//           onChanged: (value) {
//             chatProvider.searchChats(value);
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               chatProvider.searchChats('');
//               Navigator.pop(context);
//             },
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showMoreOptions(ChatProvider chatProvider) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.archive_outlined),
//             title: const Text('Archived Conversations'),
//             onTap: () {
//               Navigator.pop(context);
//               // Navigate to archived chats
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.notifications_off_outlined),
//             title: const Text('Muted Conversations'),
//             onTap: () {
//               Navigator.pop(context);
//               // Navigate to muted chats
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.delete_outline),
//             title: const Text('Clear All Chats'),
//             onTap: () {
//               Navigator.pop(context);
//               // Clear all chats
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings_outlined),
//             title: const Text('Chat Settings'),
//             onTap: () {
//               Navigator.pop(context);
//               // Navigate to chat settings
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
