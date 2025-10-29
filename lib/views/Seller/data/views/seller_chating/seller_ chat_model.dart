// models/chat_model.dart
class SellerChatModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String? buyerImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? orderId;
  final DateTime createdAt;
  final bool isOnline;

  SellerChatModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    this.buyerImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.orderId,
    required this.createdAt,
    this.isOnline = false,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }

  SellerChatModel copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? buyerImage,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? orderId,
    DateTime? createdAt,
    bool? isOnline,
  }) {
    return SellerChatModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerImage: buyerImage ?? this.buyerImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? productId;
  final String? orderId;
  final String? imageUrl;
  final String? fileUrl;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.productId,
    this.orderId,
    this.imageUrl,
    this.fileUrl,
  });

  String get timeString {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get isSeller => senderId.startsWith('seller_');
}

enum MessageType { text, image, file, order, product, system }
