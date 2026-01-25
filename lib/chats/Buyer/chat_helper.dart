import 'package:wood_service/chats/Buyer/buyer_chat_model.dart';

class ChatMessageHelper {
  static BuyerChatModel parseMessageFromChat(
    Map<String, dynamic> messageJson,
    String chatId,
    String currentUserId,
    String currentUserType,
  ) {
    final senderId = messageJson['senderId']?.toString() ?? '';
    final isSentByMe = senderId == currentUserId;
    
    return BuyerChatModel(
      id: messageJson['_id']?.toString() ?? '',
      chatId: chatId,
      senderId: senderId,
      senderName: messageJson['senderName']?.toString() ?? '',
      senderType: isSentByMe ? currentUserType : (currentUserType == 'Buyer' ? 'Seller' : 'Buyer'),
      receiverId: '', // This needs to be determined from chat participants
      receiverName: '',
      receiverType: isSentByMe ? (currentUserType == 'Buyer' ? 'Seller' : 'Buyer') : currentUserType,
      message: messageJson['message']?.toString() ?? '',
      messageType: 'text',
      isRead: messageJson['isRead'] ?? false,
      createdAt: messageJson['createdAt'] != null
          ? DateTime.parse(messageJson['createdAt'])
          : DateTime.now(),
      attachments: messageJson['attachments'] != null && messageJson['attachments'] is List
          ? List<ChatAttachment>.from(
              (messageJson['attachments'] as List).map(
                (x) => ChatAttachment.fromJson(x),
              ),
            )
          : [],
    );
  }
}