// lib/chats/Buyer/messages_screen.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/Buyer/buyer_chating.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';

class BuyerOuterMessagesScreen extends StatefulWidget {
  const BuyerOuterMessagesScreen({super.key});

  @override
  State<BuyerOuterMessagesScreen> createState() =>
      _BuyerOuterMessagesScreenState();
}

class _BuyerOuterMessagesScreenState extends State<BuyerOuterMessagesScreen> {
  late BuyerChatProvider _chatProvider;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    print('🎯 MessagesScreen initState - Buyer Chat List');

    _chatProvider = Provider.of<BuyerChatProvider>(context, listen: false);
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

    return Consumer<BuyerChatProvider>(
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

  Widget _buildBody(BuyerChatProvider chatProvider) {
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
                  builder: (context) => BuyerChatScreen(
                    sellerId: chat.participants
                        .firstWhere((p) => p.userType == 'Seller')
                        .userId,
                    sellerName: chat.otherUserName,
                    productId: chat.productId,
                    // orderId: chat.orderId,
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
