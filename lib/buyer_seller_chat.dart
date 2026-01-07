// lib/buyer_seller_chat.dart (Clean version)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_provider.dart';
import 'package:wood_service/chats/Buyer/buyer_outer_messages_screen.dart';
import 'package:wood_service/chats/Seller/new_seller_chat/seller_chat_outer.dart';
import 'package:wood_service/chats/Seller/new_seller_chat/seller_chat_provider.dart';

class ChatBuyer extends StatefulWidget {
  const ChatBuyer({super.key});

  @override
  State<ChatBuyer> createState() => _ChatBuyerState();
}

class _ChatBuyerState extends State<ChatBuyer> {
  late BuyerChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<BuyerChatProvider>(context, listen: false);
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
    return BuyerOuterMessagesScreen();
  }
}

class SellerChat extends StatefulWidget {
  const SellerChat({super.key});

  @override
  State<SellerChat> createState() => _SellerChatState();
}

class _SellerChatState extends State<SellerChat> {
  late SellerChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<SellerChatProvider>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await _chatProvider.initialize();
    } catch (e) {
      print('Error initializing seller chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SellerOuterMessagesScreen();
  }
}
