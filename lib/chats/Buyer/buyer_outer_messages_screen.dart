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
        title: Text(
          'Messages',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          // Handle error state
          if (chatProvider.error != null && chatProvider.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${chatProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => chatProvider.loadChats(),
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 100,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              SizedBox(height: 16),
              Text(
                'No conversations yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your conversations with sellers will appear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              sellerParticipant.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              chat.lastMessageText ?? 'Start conversation',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chat.lastMessageText != null
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(chat.updatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (chat.orderDetails?['status'] != null) ...[
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(chat.orderDetails!['status']),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${chat.orderDetails!['status']}'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimary,
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
        return Theme.of(context).colorScheme.primary;
      case 'pending':
        return Theme.of(context).colorScheme.primary;
      case 'cancelled':
        return Theme.of(context).colorScheme.primary;
      case 'accepted':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final chatDate = DateTime(time.year, time.month, time.day);

    if (chatDate == today) {
      return 'Today';
    } else if (chatDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[chatDate.weekday - 1];
    } else {
      return '${time.day}/${time.month}/${time.year % 100}';
    }
  }
}
