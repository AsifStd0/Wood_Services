// lib/buyer_seller_chat.dart (Clean version)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/chat_provider.dart';
import 'package:wood_service/chats/Buyer/messages_screen.dart';
import 'package:wood_service/chats/Seller/seller_messages_screen.dart';

class ChatBuyer extends StatefulWidget {
  const ChatBuyer({super.key});

  @override
  State<ChatBuyer> createState() => _ChatBuyerState();
}

class _ChatBuyerState extends State<ChatBuyer> {
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await _chatProvider.initialize();
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MessagesScreen();
  }
}

class ChatSeller extends StatefulWidget {
  const ChatSeller({super.key});

  @override
  State<ChatSeller> createState() => _ChatSellerState();
}

class _ChatSellerState extends State<ChatSeller> {
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await _chatProvider.initialize();
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chatProvider,
      child: const SellerMessagesScreen(),
    );
  }
}
