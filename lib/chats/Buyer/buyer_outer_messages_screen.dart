import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';
import 'package:wood_service/chats/Buyer/buyer_chating.dart';

class BuyerOuterMessagesScreen extends StatefulWidget {
  const BuyerOuterMessagesScreen({super.key});

  @override
  State<BuyerOuterMessagesScreen> createState() =>
      _BuyerOuterMessagesScreenState();
}

class _BuyerOuterMessagesScreenState extends State<BuyerOuterMessagesScreen> {
  @override
  void initState() {
    super.initState();
    log('🎯 MessagesScreen initState - Buyer Chat List');

    // Trigger initial load after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<BuyerChatProvider>();
      if (chatProvider.chats.isEmpty) {
        chatProvider.loadChats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final chatProvider = context.read<BuyerChatProvider>();
              chatProvider.loadChats();
            },
          ),
        ],
      ),
      body: Consumer<BuyerChatProvider>(
        builder: (context, chatProvider, child) {
          log(
            '🔄 Consumer rebuilt, chats count: ${chatProvider.chats.length}, isLoading: ${chatProvider.isLoading}',
          );

          // Show loading only when truly loading and empty
          if (chatProvider.isLoading && chatProvider.chats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (chatProvider.error != null && chatProvider.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${chatProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => chatProvider.loadChats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show empty state or chat list
          return RefreshIndicator(
            onRefresh: () async {
              await chatProvider.loadChats();
            },
            child: chatProvider.chats.isEmpty
                ? _buildEmptyState()
                : _buildChatList(chatProvider),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your conversations with sellers will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(BuyerChatProvider chatProvider) {
    final chats = chatProvider.chats;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];

        // Find seller participant
        ChatParticipant? sellerParticipant;
        try {
          sellerParticipant = chat.participants.firstWhere(
            (p) => p.userType == 'Seller',
          );
        } catch (e) {
          sellerParticipant = chat.participants.isNotEmpty
              ? chat.participants.first
              : null;
        }

        if (sellerParticipant == null) {
          return const SizedBox();
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              backgroundImage:
                  sellerParticipant.profileImage != null &&
                      sellerParticipant.profileImage!.isNotEmpty
                  ? NetworkImage(sellerParticipant.profileImage!)
                  : null,
              child:
                  sellerParticipant.profileImage == null ||
                      sellerParticipant.profileImage!.isEmpty
                  ? Text(
                      sellerParticipant.name.isNotEmpty
                          ? sellerParticipant.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            title: Text(
              sellerParticipant.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat.lastMessageText ?? 'Start conversation',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chat.lastMessageText != null
                    ? Colors.grey[700]
                    : Colors.grey[500],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(chat.updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (chat.orderDetails?['status'] != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(chat.orderDetails!['status']),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${chat.orderDetails!['status']}'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerChatScreen(
                    sellerId: sellerParticipant!.userId,
                    sellerName: sellerParticipant.name,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'accepted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final chatDate = DateTime(time.year, time.month, time.day);

    if (chatDate == today) {
      return 'Today';
    } else if (chatDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[chatDate.weekday - 1];
    } else {
      return '${time.day}/${time.month}/${time.year % 100}';
    }
  }
}
