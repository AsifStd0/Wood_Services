// views/messages/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class ChatScreen extends StatelessWidget {
  final String sellerName;
  final String sellerInitial;

  const ChatScreen({
    super.key,
    required this.sellerName,
    required this.sellerInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // _buildOrderInfo(),
          Expanded(child: _buildChatMessages()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingMessageInput(),
    );
  }

  Widget _buildFloatingMessageInput() {
    return Container(
      padding: const EdgeInsets.only(right: 10, left: 6, bottom: 20),
      child: Row(
        children: [
          // Custom Chat Input Field (without borders/background)
          Expanded(
            child: TextField(
              maxLines: null,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: AppColors.greyLight,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) {},
            ),
          ),

          const SizedBox(width: 6),

          // Attachment Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(
                Icons.add_rounded,
                color: Colors.grey.shade700,
                size: 20,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),

          // Beautiful Send Button

          // 🚀 Send Button (Floating Gradient Circle)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(child: Text(sellerInitial)),
          // Container(
          //   width: 40,
          //   height: 40,
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Center(
          //     child: Text(
          //       sellerInitial,
          //       style: const TextStyle(
          //         color: Colors.white,
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sellerName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Last seen 2 min ago',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.black54),
          onPressed: () {},
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('View Profile')),
            const PopupMenuItem(child: Text('Search')),
          ],
        ),
      ],
    );
  }

  // Widget _buildOrderInfo() {
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.purple.withOpacity(0.2),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.white.withOpacity(0.2),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: const Icon(
  //             Icons.shopping_bag,
  //             color: Colors.white,
  //             size: 24,
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 'Active Order #12345',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 'Teak Wood • 50 pieces • \$1,200',
  //                 style: TextStyle(
  //                   color: Colors.white.withOpacity(0.9),
  //                   fontSize: 12,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: const Text(
  //             'Track',
  //             style: TextStyle(
  //               color: Color(0xFF667eea),
  //               fontSize: 12,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildChatMessages() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          reverse: true,
          children: [
            _buildMessageBubble(
              isMe: true,
              message: 'Yes, that works for me! When can you deliver?',
              time: '2:30 PM',
              isDelivered: true,
              isRead: true,
            ),
            _buildMessageBubble(
              isMe: false,
              message:
                  'Great! I can deliver tomorrow between 2-4 PM. Does that work for you?',
              time: '2:28 PM',
            ),
            _buildMessageBubble(
              isMe: true,
              message:
                  'The quality looks amazing in the photos. Can you confirm it\'s grade A teak?',
              time: '2:25 PM',
              isDelivered: true,
              isRead: true,
            ),
            _buildMessageBubble(
              isMe: false,
              message:
                  'Absolutely! All our teak wood is premium grade A quality. I\'ve attached some close-up photos.',
              time: '2:22 PM',
            ),
            _buildMessageBubble(
              isMe: false,
              message:
                  'Hello! I have teak wood available. You were interested in 50 pieces, right?',
              time: '2:20 PM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required String message,
    required String time,
    bool isDelivered = false,
    bool isRead = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(child: Text(sellerInitial)),
            // Container(
            //   width: 32,
            //   height: 32,
            //   decoration: BoxDecoration(
            //     gradient: const LinearGradient(
            //       colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Center(
            //     child: Text(
            //       sellerInitial,
            //       style: const TextStyle(
            //         color: Colors.white,
            //         fontSize: 12,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF667eea) : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: isRead ? Colors.blue[100] : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
