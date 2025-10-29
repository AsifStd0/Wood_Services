// views/messages/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Messages/chat_screen.dart';

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
            'John Wood',
            'Hello, I have teak wood available',
            '2 min ago',
            context,
          ),
          _buildChatItem(
            'Premium Timber',
            'Your custom order is ready',
            '1 hour ago',
            context,
          ),
          _buildChatItem(
            'Forest Furniture',
            'When do you need delivery?',
            'Yesterday',
            context,
          ),
        ],
      ),
    );
  }

  // Update the onTap in your MessagesScreen
  Widget _buildChatItem(
    String name,
    String lastMessage,
    String time,
    BuildContext context,
  ) {
    return ListTile(
      leading: CircleAvatar(child: Text(name[0])),
      // leading: Container(
      //   width: 50,
      //   height: 50,
      //   decoration: BoxDecoration(
      //     gradient: const LinearGradient(
      //       colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //     borderRadius: BorderRadius.circular(25),
      //   ),
      //   child: Center(
      //     child: Text(
      //       name[0],
      //       style: const TextStyle(
      //         color: Colors.white,
      //         fontSize: 16,
      //         fontWeight: FontWeight.bold,
      //       ),
      //     ),
      //   ),
      // ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatScreen(sellerName: name, sellerInitial: name[0]),
          ),
        );
      },
    );
  }
}
