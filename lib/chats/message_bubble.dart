// In your message_bubble.dart file, update to handle attachments

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';

class MessageBubble extends StatelessWidget {
  final BuyerChatModel message;
  final bool isSentByMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSentByMe ? Colors.blue[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display attachments if any
              if (message.attachments.isNotEmpty) ...[
                ...message.attachments.map((attachment) {
                  return _buildAttachmentWidget(attachment, context);
                }).toList(),
                const SizedBox(height: 8),
              ],

              // Display message text
              if (message.message.isNotEmpty)
                Text(
                  message.message,
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),

              // Timestamp
              const SizedBox(height: 4),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentWidget(
    ChatAttachment attachment,
    BuildContext context,
  ) {
    if (attachment.type == 'image' ||
        attachment.url.endsWith('.jpg') ||
        attachment.url.endsWith('.jpeg') ||
        attachment.url.endsWith('.png')) {
      return GestureDetector(
        onTap: () {
          // Show image in full screen
          _showFullScreenImage(attachment.url, context);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: attachment.url,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
      );
    } else {
      // Generic file attachment
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(_getFileIcon(attachment.type), color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${(attachment.size / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              onPressed: () {
                // Download file
                _downloadFile(attachment.url, attachment.name);
              },
            ),
          ],
        ),
      );
    }
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showFullScreenImage(String url, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black87,
            child: Center(
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  void _downloadFile(String url, String fileName) {
    // Implement file download logic
    // You can use dio or http to download the file
    print('Downloading file: $fileName from $url');
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
