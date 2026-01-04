class BuyerChatModel {
  String id;
  String chatId;
  String senderId;
  String senderName;
  String senderType; // 'Seller' or 'Buyer'
  String receiverId;
  String receiverName;
  String receiverType;
  String message;
  String messageType; // 'text', 'image', 'file'
  bool isRead;
  DateTime createdAt;
  DateTime? readAt;
  String? productId;
  String? orderId;
  List<ChatAttachment> attachments;

  BuyerChatModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.receiverId,
    required this.receiverName,
    required this.receiverType,
    required this.message,
    this.messageType = 'text',
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.productId,
    this.orderId,
    this.attachments = const [],
  });

  factory BuyerChatModel.fromJson(Map<String, dynamic> json) {
    return BuyerChatModel(
      id: json['_id'] ?? json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderType: json['senderType'] ?? json['senderModel'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverType: json['receiverType'] ?? json['receiverModel'] ?? '',
      message: json['message'] ?? '',
      messageType: json['messageType'] ?? 'text',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      productId: json['productId'],
      orderId: json['orderId'],
      attachments: json['attachments'] != null
          ? List<ChatAttachment>.from(
              json['attachments'].map((x) => ChatAttachment.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJsonForSend() {
    return {
      'chatId': chatId,
      'receiverId': receiverId,
      'receiverType': receiverType,
      'message': message,
      'messageType': messageType,
      if (productId != null) 'productId': productId,
      if (orderId != null) 'orderId': orderId,
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  bool get isSentByMe => senderType == 'Buyer'; // Adjust based on user role

  // ✅ ADDED: copyWith method
  BuyerChatModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderType,
    String? receiverId,
    String? receiverName,
    String? receiverType,
    String? message,
    String? messageType,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? productId,
    String? orderId,
    List<ChatAttachment>? attachments,
  }) {
    return BuyerChatModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverType: receiverType ?? this.receiverType,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      attachments: attachments ?? this.attachments,
    );
  }
}

class ChatAttachment {
  String url;
  String type;
  String name;
  int size;

  ChatAttachment({
    required this.url,
    required this.type,
    required this.name,
    required this.size,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      url: json['url'] ?? '',
      type: json['type'] ?? json['fileType'] ?? '',
      name: json['name'] ?? json['fileName'] ?? '',
      size: json['size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type, 'name': name, 'size': size};
  }

  // ✅ ADDED: copyWith method
  ChatAttachment copyWith({
    String? url,
    String? type,
    String? name,
    int? size,
  }) {
    return ChatAttachment(
      url: url ?? this.url,
      type: type ?? this.type,
      name: name ?? this.name,
      size: size ?? this.size,
    );
  }
}

class ChatRoom {
  String id;
  List<ChatParticipant> participants;
  String? lastMessage;
  String? lastMessageText;
  int unreadCount;
  DateTime updatedAt;
  String? productId;
  String? orderId;
  Map<String, dynamic>? otherParticipant;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageText,
    this.unreadCount = 0,
    required this.updatedAt,
    this.productId,
    this.orderId,
    this.otherParticipant,
  });

  // In chat_messages.dart - Update the ChatRoom.fromJson factory
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    // Handle productId - it could be String or Map
    String? productIdString;
    if (json['productId'] != null) {
      if (json['productId'] is String) {
        productIdString = json['productId'];
      } else if (json['productId'] is Map) {
        // Extract the ID from the product object
        productIdString =
            json['productId']['_id']?.toString() ??
            json['productId']['id']?.toString();
      }
    }

    // Handle lastMessage similarly
    String? lastMessageString;
    if (json['lastMessage'] != null) {
      if (json['lastMessage'] is String) {
        lastMessageString = json['lastMessage'];
      } else if (json['lastMessage'] is Map) {
        lastMessageString = json['lastMessage']['_id']?.toString();
      }
    }

    return ChatRoom(
      id: json['_id'] ?? json['id'] ?? '',
      participants: json['participants'] != null
          ? List<ChatParticipant>.from(
              json['participants'].map((x) => ChatParticipant.fromJson(x)),
            )
          : [],
      lastMessage: lastMessageString, // Use the extracted string
      lastMessageText: json['lastMessageText'] ?? '',
      unreadCount: json['myUnreadCount'] ?? json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      productId: productIdString, // Use the extracted string
      orderId: json['orderId'],
      otherParticipant: json['otherParticipant'],
    );
  }

  String get otherUserName {
    if (otherParticipant != null) {
      return otherParticipant!['details']['fullName'] ??
          otherParticipant!['details']['shopName'] ??
          otherParticipant!['details']['businessName'] ??
          'Unknown';
    }
    if (participants.length > 1) {
      return participants[1].name;
    }
    return 'Unknown';
  }

  String? get otherUserImage {
    if (otherParticipant != null) {
      return otherParticipant!['details']['profileImage']?['url'];
    }
    return null;
  }

  bool get otherUserIsOnline {
    if (otherParticipant != null) {
      return otherParticipant!['isOnline'] ?? false;
    }
    return false;
  }

  // ✅ ADDED: copyWith method
  ChatRoom copyWith({
    String? id,
    List<ChatParticipant>? participants,
    String? lastMessage,
    String? lastMessageText,
    int? unreadCount,
    DateTime? updatedAt,
    String? productId,
    String? orderId,
    Map<String, dynamic>? otherParticipant,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      otherParticipant: otherParticipant ?? this.otherParticipant,
    );
  }
}

class ChatParticipant {
  String userId;
  String userType;
  String name;
  String? profileImage;
  DateTime lastSeen;
  bool isArchived;
  bool isMuted;

  ChatParticipant({
    required this.userId,
    required this.userType,
    required this.name,
    this.profileImage,
    required this.lastSeen,
    this.isArchived = false,
    this.isMuted = false,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId'] ?? '',
      userType: json['userType'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'],
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : DateTime.now(),
      isArchived: json['isArchived'] ?? false,
      isMuted: json['isMuted'] ?? false,
    );
  }

  // ✅ ADDED: copyWith method
  ChatParticipant copyWith({
    String? userId,
    String? userType,
    String? name,
    String? profileImage,
    DateTime? lastSeen,
    bool? isArchived,
    bool? isMuted,
  }) {
    return ChatParticipant(
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      lastSeen: lastSeen ?? this.lastSeen,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class ChatStartRequest {
  String sellerId;
  String buyerId;
  String? productId;
  String? orderId;

  ChatStartRequest({
    required this.sellerId,
    required this.buyerId,
    this.productId,
    this.orderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'sellerId': sellerId,
      'buyerId': buyerId,
      if (productId != null) 'productId': productId,
      if (orderId != null) 'orderId': orderId,
    };
  }

  // ✅ ADDED: copyWith method
  ChatStartRequest copyWith({
    String? sellerId,
    String? buyerId,
    String? productId,
    String? orderId,
  }) {
    return ChatStartRequest(
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
    );
  }
}
