class ChatMessage {
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

  ChatMessage({
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
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

  // Map<String, dynamic> toJson() {
  //   return {
  //     'chatId': chatId,
  //     'receiverId': receiverId,
  //     'receiverType': receiverType,
  //     'message': message,
  //     'messageType': messageType,
  //     if (productId != null) 'productId': productId,
  //     if (orderId != null) 'orderId': orderId,
  //     if (attachments.isNotEmpty)
  //       'attachments': attachments.map((x) => x.toJson()).toList(),
  //   };
  // }
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

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['_id'] ?? json['id'] ?? '',
      participants: json['participants'] != null
          ? List<ChatParticipant>.from(
              json['participants'].map((x) => ChatParticipant.fromJson(x)),
            )
          : [],
      lastMessage: json['lastMessage'],
      lastMessageText: json['lastMessageText'] ?? '',
      unreadCount: json['myUnreadCount'] ?? json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      productId: json['productId'],
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
}

class ChatApiResponse {
  bool success;
  String message;
  dynamic data;

  ChatApiResponse({required this.success, required this.message, this.data});

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) {
    return ChatApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
