// views/messages/messages_screen.dart
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Messages'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        children: [
          // Chat list with sellers
          _buildChatItem(
            'John Wood Crafts',
            'Hello, I have teak wood available',
            '2 min ago',
          ),
          _buildChatItem(
            'Premium Timber',
            'Your custom order is ready',
            '1 hour ago',
          ),
          _buildChatItem(
            'Forest Furniture',
            'When do you need delivery?',
            'Yesterday',
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(String name, String lastMessage, String time) {
    return ListTile(
      leading: CircleAvatar(child: Text(name[0])),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        // Navigate to chat detail
      },
    );
  }
}
