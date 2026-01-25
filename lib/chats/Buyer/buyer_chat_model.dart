import 'dart:developer';

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
  bool isSentByMe; // Add this field

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
    this.isSentByMe = false, // Add this
  });

  factory BuyerChatModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    // Extract sender info from the API response structure
    final senderId = json['senderId']?.toString() ?? '';
    final senderName = json['senderName']?.toString() ?? '';

    // Determine if sent by current user using isSentByMe from API or by comparing IDs
    final isSentByMe =
        json['isSentByMe'] ??
        (currentUserId != null && senderId == currentUserId);

    // Determine sender/receiver types based on isSentByMe
    // If isSentByMe is true, sender is Buyer, receiver is Seller
    // If isSentByMe is false, sender is Seller, receiver is Buyer
    final senderType =
        json['senderType']?.toString() ?? (isSentByMe ? 'Buyer' : 'Seller');
    final receiverType =
        json['receiverType']?.toString() ?? (isSentByMe ? 'Seller' : 'Buyer');

    return BuyerChatModel(
      id: json['_id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? json['_id']?.toString() ?? '',
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      receiverId: json['receiverId']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      receiverType: receiverType,
      message: json['message']?.toString() ?? '',
      messageType: json['messageType'] ?? 'text',
      isRead: json['isRead'] ?? false,
      isSentByMe: isSentByMe,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      orderId: json['orderId']?.toString(),
      attachments: json['attachments'] != null && json['attachments'] is List
          ? List<ChatAttachment>.from(
              (json['attachments'] as List).map(
                (x) => ChatAttachment.fromJson(x),
              ),
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

  // bool get isSentByMe => senderType == 'Buyer'; // Adjust based on user role

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
    bool? isSentByMe,
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
      isSentByMe: isSentByMe ?? this.isSentByMe,
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
  String? _currentUserId; // Add this

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
    String? currentUserId, // Add this parameter
  }) : _currentUserId = currentUserId;

  // Updated ChatRoom.fromJson with more logging
  factory ChatRoom.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    log('🔄 Parsing ChatRoom from JSON');
    log('JSON keys: ${json.keys}');

    // Extract basic info
    final chatId = json['_id']?.toString() ?? '';
    log('Chat ID: $chatId');

    // Handle orderId
    String? orderIdString;
    if (json['orderId'] != null) {
      log('orderId type: ${json['orderId'].runtimeType}');
      log('orderId value: ${json['orderId']}');

      if (json['orderId'] is String) {
        orderIdString = json['orderId'];
      } else if (json['orderId'] is Map) {
        orderIdString = json['orderId']['_id']?.toString();
      }
      log('Parsed orderId: $orderIdString');
    }

    // Handle lastMessage from messages array
    String? lastMessageText = '';
    DateTime updatedAt = DateTime.now();

    if (json['messages'] != null && json['messages'] is List) {
      final messages = json['messages'] as List;
      log('Found ${messages.length} messages in chat');

      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        log('Last message: $lastMessage');

        if (lastMessage is Map) {
          lastMessageText = lastMessage['message']?.toString() ?? '';
          final createdAt = lastMessage['createdAt']?.toString();
          if (createdAt != null) {
            try {
              updatedAt = DateTime.parse(createdAt);
            } catch (e) {
              log('Error parsing createdAt: $e');
            }
          }
        }
      }
    }

    log('Last message text: $lastMessageText');
    log('Updated at: $updatedAt');

    // Build participants
    List<ChatParticipant> participants = [];

    // Add buyer participant
    if (json['buyerId'] != null) {
      log('BuyerId found: ${json['buyerId']}');
      final buyer = json['buyerId'] is Map
          ? json['buyerId']
          : {'_id': json['buyerId']};
      participants.add(
        ChatParticipant(
          userId: buyer['_id']?.toString() ?? '',
          userType: 'Buyer',
          name: buyer['name']?.toString() ?? 'Unknown Buyer',
          profileImage: buyer['profileImage']?.toString(),
          lastSeen: updatedAt,
        ),
      );
    }

    // Add seller participant
    if (json['sellerId'] != null) {
      log('SellerId found: ${json['sellerId']}');
      final seller = json['sellerId'] is Map
          ? json['sellerId']
          : {'_id': json['sellerId']};
      participants.add(
        ChatParticipant(
          userId: seller['_id']?.toString() ?? '',
          userType: 'Seller',
          name: seller['name']?.toString() ?? 'Unknown Seller',
          profileImage: seller['profileImage']?.toString(),
          lastSeen: updatedAt,
        ),
      );
    }

    log('Created ${participants.length} participants');

    return ChatRoom(
      id: chatId,
      participants: participants,
      lastMessage: lastMessageText,
      lastMessageText: lastMessageText,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: updatedAt,
      productId: json['productId']?.toString(),
      orderId: orderIdString,
      currentUserId: currentUserId, // Pass current user ID
    );
  }

  String get otherUserName {
    log('🔄 Getting otherUserName for chat $id');
    log('  _currentUserId: $_currentUserId');
    log('  participants: ${participants.length}');

    for (var p in participants) {
      log('    - ${p.name} (${p.userType}) ID: ${p.userId}');
    }

    if (otherParticipant != null) {
      final name =
          otherParticipant!['details']?['fullName'] ??
          otherParticipant!['details']?['shopName'] ??
          otherParticipant!['details']?['businessName'] ??
          'Unknown';
      log('  Using otherParticipant: $name');
      return name;
    }

    // If we have currentUserId, find the other participant
    if (_currentUserId != null && participants.isNotEmpty) {
      try {
        final other = participants.firstWhere(
          (p) => p.userId != _currentUserId,
          orElse: () => participants.first,
        );
        log('  Found other by ID: ${other.name}');
        return other.name;
      } catch (e) {
        log('  Error finding by ID: $e');
      }
    }

    // Fallback: return the participant that's not the current user
    if (participants.length > 1) {
      log('  Using participant[1]: ${participants[1].name}');
      return participants[1].name;
    }
    if (participants.isNotEmpty) {
      log('  Using first participant: ${participants.first.name}');
      return participants.first.name;
    }

    log('  No participants found, returning Unknown');
    return 'Unknown';
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
    log('🎭 Parsing ChatParticipant');
    log('Participant JSON: $json');

    return ChatParticipant(
      userId: json['userId']?.toString() ?? json['_id']?.toString() ?? '',
      userType: json['userType'] ?? 'Unknown',
      name: json['name']?.toString() ?? 'Unknown User',
      profileImage: json['profileImage']?.toString(),
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
