import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/Seller/new_seller_chat/seller_chat_provider.dart';
import 'package:wood_service/chats/Seller/new_seller_chat/seller_chat_screen.dart';

class SellerOuterMessagesScreen extends StatefulWidget {
  const SellerOuterMessagesScreen({super.key});

  @override
  State<SellerOuterMessagesScreen> createState() =>
      _SellerOuterMessagesScreenState();
}

class _SellerOuterMessagesScreenState extends State<SellerOuterMessagesScreen> {
  late SellerChatProvider _chatProvider;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    print('🎯 Seller MessagesScreen initState');

    _chatProvider = Provider.of<SellerChatProvider>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (_isInitializing) return;

    _isInitializing = true;
    print('🔄 Initializing chat for seller...');

    try {
      await _chatProvider.initialize();
      await _chatProvider.loadSellerDashboard();
      print('✅ Seller chat initialized successfully');
    } catch (e) {
      print('❌ Error initializing seller chat: $e');
    } finally {
      _isInitializing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 Building Seller MessagesScreen');

    return Consumer<SellerChatProvider>(
      builder: (context, chatProvider, child) {
        print('🎯 Seller Consumer with ${chatProvider.chats.length} chats');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Seller Messages'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearchDialog(context, chatProvider),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterOptions(context, chatProvider),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await chatProvider.loadSellerChats();
              await chatProvider.loadSellerDashboard();
            },
            child: Column(
              children: [
                // Seller Dashboard Stats
                _buildSellerDashboard(chatProvider),

                // Chat List
                Expanded(child: _buildChatList(chatProvider)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showNewChatDialog(context),
            child: const Icon(Icons.chat_bubble_outline),
          ),
        );
      },
    );
  }

  Widget _buildSellerDashboard(SellerChatProvider chatProvider) {
    if (chatProvider.dashboard == null) return const SizedBox();

    final dashboard = chatProvider.dashboard!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chat Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                icon: Icons.chat,
                value: '${dashboard.totalChats}',
                label: 'Total Chats',
              ),
              _buildStatCard(
                icon: Icons.mark_chat_unread,
                value: '${dashboard.unreadMessages}',
                label: 'Unread',
              ),
              _buildStatCard(
                icon: Icons.today,
                value: '${dashboard.todaysChats}',
                label: 'Today',
              ),
              _buildStatCard(
                icon: Icons.group,
                value: '${dashboard.activeBuyers}',
                label: 'Active Buyers',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildChatList(SellerChatProvider chatProvider) {
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
                chatProvider.loadSellerChats();
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
              'No customer conversations yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'When customers message you, their conversations will appear here',
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
                chat.buyerName.isNotEmpty
                    ? chat.buyerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    chat.buyerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (chat.productId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Product',
                      style: TextStyle(fontSize: 10, color: Colors.blue[700]),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.lastMessageText ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (chat.productName != null)
                  Text(
                    'Product: ${chat.productName}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(chat.updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (chat.sellerUnreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat.sellerUnreadCount}',
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
              print('📱 Seller opening chat with ${chat.buyerName}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerChatScreen(
                    buyerId: chat.buyerId ?? '',
                    buyerName: chat.buyerName,
                    chatId: chat.id,
                    productId: chat.productId,
                    productName: chat.productName,
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

  void _showSearchDialog(BuildContext context, SellerChatProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Chats'),
        content: TextField(
          onChanged: (value) {
            provider.searchChats(value);
          },
          decoration: const InputDecoration(
            hintText: 'Search by customer name or product...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.searchChats('');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context, SellerChatProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_chat_unread),
              title: const Text('Unread Only'),
              trailing: Switch(
                value: provider.filterStatus == 'unread',
                onChanged: (value) {
                  provider.filterChats(value ? 'unread' : 'all');
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archived'),
              trailing: Switch(
                value: provider.filterStatus == 'archived',
                onChanged: (value) {
                  provider.filterChats(value ? 'archived' : 'all');
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Today\'s Chats'),
              onTap: () {
                provider.filterChats('today');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    // Implement dialog to start new chat with existing customer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: const Text('Select an existing customer to chat with'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // You would typically show a list of customers here
        ],
      ),
    );
  }
}
