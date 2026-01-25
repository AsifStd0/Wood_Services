// lib/chats/Buyer/messages_screen.dart (FIXED)
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/chats/Buyer/buyer_chating.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';

class BuyerOuterMessagesScreen extends StatefulWidget {
  const BuyerOuterMessagesScreen({super.key});

  @override
  State<BuyerOuterMessagesScreen> createState() =>
      _BuyerOuterMessagesScreenState();
}

class _BuyerOuterMessagesScreenState extends State<BuyerOuterMessagesScreen> {
  late Future<void> _initialLoadFuture;

  @override
  void initState() {
    super.initState();
    log('🎯 MessagesScreen initState - Buyer Chat List');

    final chatProvider = locator<BuyerChatProvider>();
    _initialLoadFuture = chatProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialLoadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Messages')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initialLoadFuture = locator<BuyerChatProvider>()
                            .initialize();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return _ChatListContent();
      },
    );
  }
}

class _ChatListContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerChatProvider>(
      builder: (context, chatProvider, child) {
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
            child: chatProvider.chats.isEmpty
                ? _buildEmptyState(chatProvider)
                : _buildChatList(chatProvider),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await chatProvider.loadChats();
            },
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuyerChatProvider chatProvider) {
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

  Widget _buildChatList(BuyerChatProvider chatProvider) {
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
              backgroundImage: chat.otherParticipant != null
                  ? NetworkImage(chat.otherParticipant!['profileImage'] ?? '')
                  : null,
              child: chat.otherParticipant == null
                  ? Text(
                      chat.otherUserName.isNotEmpty
                          ? chat.otherUserName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
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
              final sellerParticipant = chat.participants.firstWhere(
                (p) => p.userType == 'Seller',
                orElse: () => chat.participants.first,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerChatScreen(
                    sellerId: sellerParticipant.userId,
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
// class BuyerOuterMessagesScreen extends StatefulWidget {
//   const BuyerOuterMessagesScreen({super.key});

//   @override
//   State<BuyerOuterMessagesScreen> createState() =>
//       _BuyerOuterMessagesScreenState();
// }

// class _BuyerOuterMessagesScreenState extends State<BuyerOuterMessagesScreen> {
//   late BuyerChatProvider _chatProvider;
//   bool _isInitializing = false;

//   @override
//   void initState() {
//     super.initState();
//     print('🎯 MessagesScreen initState - Buyer Chat List');

//     _chatProvider = locator<BuyerChatProvider>();
//     _initializeChat();
//   }

//   Future<void> _initializeChat() async {
//     if (_isInitializing) return;

//     _isInitializing = true;
//     print('🔄 Initializing chat for buyer...');

//     try {
//       await _chatProvider.initialize();
//       print('✅ Chat initialized successfully for buyer');
//     } catch (e) {
//       print('❌ Error initializing chat for buyer: $e');
//     } finally {
//       _isInitializing = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('🎯 Building MessagesScreen (Buyer)');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Messages'),
//         centerTitle: true,
//         actions: [
//           IconButton(icon: const Icon(Icons.search), onPressed: () {}),
//           // Add debug button
//           IconButton(
//             icon: const Icon(Icons.bug_report),
//             onPressed: () {
//               final chatProvider = context.read<BuyerChatProvider>();
//               print('=== DEBUG BUTTON PRESSED ===');
//               print('Provider state:');
//               print('  chats length: ${chatProvider.chats.length}');
//               print('  isLoading: ${chatProvider.isLoading}');
//               print('  error: ${chatProvider.error}');

//               // Force rebuild
//               chatProvider.notifyListeners();
//             },
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await _chatProvider.loadChats();
//         },
//         child: Consumer<BuyerChatProvider>(
//           builder: (context, chatProvider, child) {
//             print(
//               '🎯 Consumer rebuilding with ${chatProvider.chats.length} chats',
//             );

//             // Add this debug print
//             if (chatProvider.chats.isEmpty) {
//               print('⚠️ WARNING: Consumer sees empty chats array!');
//             }

//             return _buildBody(chatProvider);
//           },
//         ),
//       ),
//       // Add floating debug button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           final chatProvider = context.read<BuyerChatProvider>();
//           print('=== FLOATING DEBUG ===');
//           print('Manual check:');
//           print('Chats in memory: ${chatProvider.chats.length}');

//           // Try reloading
//           chatProvider.loadChats();
//         },
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }

//   Widget _buildBody(BuyerChatProvider chatProvider) {
//     print('=== DEBUG: Building chat body ===');
//     print('Chats length: ${chatProvider.chats.length}');
//     print('Is loading: ${chatProvider.isLoading}');
//     print('Has error: ${chatProvider.error != null}');
//     print(
//       'Current user in provider: ${chatProvider.chats.isNotEmpty ? chatProvider.chats[0].otherUserName : "No chats"}',
//     );

//     if (chatProvider.isLoading) {
//       print('Showing loading indicator');
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (chatProvider.error != null) {
//       print('Showing error: ${chatProvider.error}');
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, color: Colors.red, size: 50),
//             const SizedBox(height: 16),
//             Text('Error: ${chatProvider.error}'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => chatProvider.loadChats(),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (chatProvider.chats.isEmpty) {
//       print('Showing empty state - chats array is empty');
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.chat, size: 100, color: Colors.grey[300]),
//             const SizedBox(height: 16),
//             const Text(
//               'No conversations yet',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 'When you message sellers, your conversations will appear here',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//             // Add debug button
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 print('=== MANUAL DEBUG ===');
//                 print('Total chats: ${chatProvider.chats.length}');
//                 for (var i = 0; i < chatProvider.chats.length; i++) {
//                   final chat = chatProvider.chats[i];
//                   print('Chat $i: ${chat.id}');
//                   print('  otherUserName: ${chat.otherUserName}');
//                   print('  lastMessage: ${chat.lastMessageText}');
//                   print('  participants: ${chat.participants.length}');
//                   for (var p in chat.participants) {
//                     print('    - ${p.name} (${p.userType}) ID: ${p.userId}');
//                   }
//                 }
//               },
//               child: const Text('Debug Info'),
//             ),
//           ],
//         ),
//       );
//     }

//     print('Showing ${chatProvider.chats.length} chats in list');

//     // Before building the list, debug first 3 chats
//     for (var i = 0; i < min(3, chatProvider.chats.length); i++) {
//       final chat = chatProvider.chats[i];
//       print(
//         'Chat $i for list: ${chat.otherUserName} - ${chat.lastMessageText}',
//       );
//     }

//     return _buildChatList(chatProvider);
//   }

//   Widget _buildChatList(BuyerChatProvider chatProvider) {
//     print('Building ListView with ${chatProvider.chats.length} items');

//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: chatProvider.chats.length,
//       itemBuilder: (context, index) {
//         final chat = chatProvider.chats[index];
//         print('Building ListTile for index $index: ${chat.otherUserName}');

//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.blue,
//               // backgroundImage: chat.otherUserImage != null
//               //     ? NetworkImage(chat.otherUserImage!)
//               //     : null,
//               // child: chat.otherUserImage == null
//               //     ? Text(
//               //         chat.otherUserName.isNotEmpty
//               //             ? chat.otherUserName[0].toUpperCase()
//               //             : '?',
//               //         style: const TextStyle(color: Colors.white),
//               //       )
//               //     : null,
//             ),
//             title: Text(
//               chat.otherUserName,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text(
//               chat.lastMessageText ?? 'No messages yet',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             trailing: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   _formatTime(chat.updatedAt),
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 if (chat.unreadCount > 0) ...[
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       '${chat.unreadCount}',
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
//               print('📱 Opening chat with ${chat.otherUserName}');
//               // Navigate to ChatScreen
//               final sellerParticipant = chat.participants.firstWhere(
//                 (p) => p.userType == 'Seller',
//                 orElse: () => chat.participants.first,
//               );

//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => BuyerChatScreen(
//                     sellerId: sellerParticipant.userId,
//                     sellerName: chat.otherUserName,
//                     productId: chat.productId,
//                     orderId: chat.orderId,
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
