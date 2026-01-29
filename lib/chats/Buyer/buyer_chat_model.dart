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
  List<ChatAttachment> attachments;
  bool isRead;
  DateTime createdAt;
  bool isSentByMe;

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
    this.attachments = const [],
    this.isRead = false,
    required this.createdAt,
    this.isSentByMe = false,
  });

  factory BuyerChatModel.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
    required String chatId,
    required Map<String, dynamic> chatData,
  }) {
    final senderId = json['senderId']?.toString() ?? '';
    final senderName = json['senderName']?.toString() ?? '';

    // Get chat participants from chatData
    final buyerId = _extractUserId(chatData['buyerId']);
    final sellerId = _extractUserId(chatData['sellerId']);

    // Determine sender type by comparing IDs
    final senderType = senderId == buyerId ? 'Buyer' : 'Seller';

    // Determine if sent by current user
    final isSentByMe = senderId == currentUserId;

    // Determine receiver info
    String receiverId;
    String receiverType;

    if (senderType == 'Buyer') {
      receiverId = sellerId;
      receiverType = 'Seller';
    } else {
      receiverId = buyerId;
      receiverType = 'Buyer';
    }

    // Get receiver name from chat data
    final receiverName = _getParticipantName(chatData, receiverId);

    // Handle attachments safely
    List<ChatAttachment> attachments = [];
    final attachmentsData = json['attachments'];

    if (attachmentsData != null && attachmentsData is List) {
      for (var item in attachmentsData) {
        try {
          attachments.add(ChatAttachment.fromJson(item));
        } catch (e) {
          log('Error parsing attachment: $e');
        }
      }
    }

    return BuyerChatModel(
      id: json['_id']?.toString() ?? '',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverType: receiverType,
      message: json['message']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'text',
      attachments: attachments,
      isRead: json['isRead'] ?? false,
      isSentByMe: isSentByMe,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }
  static String _extractUserId(dynamic userIdData) {
    if (userIdData == null) return '';
    if (userIdData is String) return userIdData;
    if (userIdData is Map) return userIdData['_id']?.toString() ?? '';
    return '';
  }

  static String _getParticipantName(
    Map<String, dynamic> chatData,
    String userId,
  ) {
    try {
      final buyerId = _extractUserId(chatData['buyerId']);
      final sellerId = _extractUserId(chatData['sellerId']);

      if (userId == buyerId && chatData['buyerId'] is Map) {
        return (chatData['buyerId'] as Map)['name']?.toString() ?? 'Buyer';
      }
      if (userId == sellerId && chatData['sellerId'] is Map) {
        return (chatData['sellerId'] as Map)['name']?.toString() ?? 'Seller';
      }
    } catch (e) {
      log('Error getting participant name: $e');
    }
    return 'User';
  }

  Map<String, dynamic> toJsonForSend() {
    return {
      'chatId': chatId,
      'receiverId': receiverId,
      'receiverType': receiverType,
      'message': message,
      'messageType': messageType,
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

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
    List<ChatAttachment>? attachments,
    bool? isRead,
    bool? isSentByMe,
    DateTime? createdAt,
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
      attachments: attachments ?? this.attachments,
      isRead: isRead ?? this.isRead,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      createdAt: createdAt ?? this.createdAt,
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

  factory ChatAttachment.fromJson(dynamic json) {
    // Handle different JSON formats
    if (json is String) {
      // If attachment is just a URL string
      return ChatAttachment(
        url: json,
        type: _extractFileType(json),
        name: _extractFileName(json),
        size: 0,
      );
    } else if (json is Map<String, dynamic>) {
      // If attachment is a proper object
      return ChatAttachment(
        url: json['url']?.toString() ?? '',
        type:
            json['type']?.toString() ??
            json['fileType']?.toString() ??
            _extractFileType(json['url']?.toString() ?? ''),
        name:
            json['name']?.toString() ??
            json['fileName']?.toString() ??
            _extractFileName(json['url']?.toString() ?? ''),
        size: (json['size'] as int?) ?? 0,
      );
    } else if (json is Map) {
      // Handle non-typed Map
      final map = Map<String, dynamic>.from(json);
      return ChatAttachment(
        url: map['url']?.toString() ?? '',
        type:
            map['type']?.toString() ??
            _extractFileType(map['url']?.toString() ?? ''),
        name:
            map['name']?.toString() ??
            _extractFileName(map['url']?.toString() ?? ''),
        size: (map['size'] as int?) ?? 0,
      );
    } else {
      // Fallback
      return ChatAttachment(url: '', type: '', name: '', size: 0);
    }
  }

  static String _extractFileType(String url) {
    if (url.isEmpty) return '';

    final extension = url.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'avi', 'mov', 'wmv'].contains(extension)) {
      return 'video';
    } else if (['pdf', 'doc', 'docx'].contains(extension)) {
      return 'document';
    }
    return 'file';
  }

  static String _extractFileName(String url) {
    if (url.isEmpty) return 'file';
    final segments = url.split('/');
    return segments.last;
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type, 'name': name, 'size': size};
  }

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
  String? orderId;
  List<ChatParticipant> participants;
  String? lastMessage;
  String? lastMessageText;
  DateTime updatedAt;
  String? _currentUserId;
  Map<String, dynamic>? orderDetails;

  ChatRoom({
    required this.id,
    this.orderId,
    required this.participants,
    this.lastMessage,
    this.lastMessageText,
    required this.updatedAt,
    String? currentUserId,
    this.orderDetails,
  }) : _currentUserId = currentUserId;

  factory ChatRoom.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    log('🔄 Parsing ChatRoom from JSON');
    log('   Raw JSON keys: ${json.keys}');

    try {
      final chatId = json['_id']?.toString() ?? '';
      log('   Chat ID: $chatId');

      // Extract orderId
      String? orderIdString;
      if (json['orderId'] != null) {
        log('   orderId type: ${json['orderId'].runtimeType}');

        if (json['orderId'] is String) {
          orderIdString = json['orderId'];
          log('   orderId (String): $orderIdString');
        } else if (json['orderId'] is Map) {
          orderIdString = json['orderId']['_id']?.toString();
          log('   orderId (Map) ID: $orderIdString');
        }
      }

      // Extract order details
      Map<String, dynamic>? orderDetails;
      if (json['orderId'] != null && json['orderId'] is Map) {
        try {
          final orderData = json['orderId'] as Map<String, dynamic>;
          log('   orderData keys: ${orderData.keys}');

          orderDetails = {
            'status': orderData['status']?.toString() ?? 'pending',
            'description': orderData['orderDetails']?['description']
                ?.toString(),
            'location': orderData['orderDetails']?['location']?.toString(),
            'preferredDate': orderData['orderDetails']?['preferredDate']
                ?.toString(),
          };
          log('   Parsed orderDetails: $orderDetails');
        } catch (e) {
          log('   Error parsing orderDetails: $e');
        }
      }

      // Extract last message
      String? lastMessageText = '';
      DateTime updatedAt = DateTime.now();

      if (json['lastMessage'] != null) {
        lastMessageText = json['lastMessage']?.toString();
        log('   lastMessage: $lastMessageText');
      }

      if (json['lastMessageAt'] != null) {
        try {
          updatedAt = DateTime.parse(json['lastMessageAt'].toString());
          log('   lastMessageAt: $updatedAt');
        } catch (e) {
          log('   Error parsing lastMessageAt: $e');
        }
      }

      // Build participants
      List<ChatParticipant> participants = [];

      // Add buyer
      if (json['buyerId'] != null) {
        log('   buyerId type: ${json['buyerId'].runtimeType}');
        final buyer = json['buyerId'];
        final buyerId = buyer is Map
            ? buyer['_id']?.toString()
            : buyer.toString();

        if (buyerId != null) {
          participants.add(
            ChatParticipant(
              userId: buyerId,
              userType: 'Buyer',
              name: buyer is Map
                  ? buyer['name']?.toString() ?? 'Buyer'
                  : 'Buyer',
              profileImage: buyer is Map
                  ? buyer['profileImage']?.toString()
                  : null,
              lastSeen: updatedAt,
            ),
          );
          log('   Added buyer: $buyerId');
        }
      }

      // Add seller
      if (json['sellerId'] != null) {
        log('   sellerId type: ${json['sellerId'].runtimeType}');
        final seller = json['sellerId'];
        final sellerId = seller is Map
            ? seller['_id']?.toString()
            : seller.toString();

        if (sellerId != null) {
          participants.add(
            ChatParticipant(
              userId: sellerId,
              userType: 'Seller',
              name: seller is Map
                  ? seller['name']?.toString() ?? 'Seller'
                  : 'Seller',
              profileImage: seller is Map
                  ? seller['profileImage']?.toString()
                  : null,
              lastSeen: updatedAt,
            ),
          );
          log('   Added seller: $sellerId');
        }
      }

      log('   Total participants: ${participants.length}');

      return ChatRoom(
        id: chatId,
        orderId: orderIdString,
        participants: participants,
        lastMessage: lastMessageText,
        lastMessageText: lastMessageText,
        updatedAt: updatedAt,
        currentUserId: currentUserId,
        orderDetails: orderDetails,
      );
    } catch (e, stackTrace) {
      log('❌ ERROR in ChatRoom.fromJson: $e');
      log('❌ Stack trace: $stackTrace');
      log('❌ Problematic JSON: $json');
      rethrow; // Re-throw to see the actual error
    }
  }
  String get otherUserName {
    if (_currentUserId != null && participants.isNotEmpty) {
      try {
        final other = participants.firstWhere(
          (p) => p.userId != _currentUserId,
          orElse: () => participants.first,
        );
        return other.name;
      } catch (e) {
        log('Error finding other user: $e');
      }
    }

    if (participants.isNotEmpty) {
      return participants.length > 1
          ? participants[1].name
          : participants.first.name;
    }

    return 'Unknown';
  }

  ChatRoom copyWith({
    String? id,
    String? orderId,
    List<ChatParticipant>? participants,
    String? lastMessage,
    String? lastMessageText,
    DateTime? updatedAt,
    String? currentUserId,
    Map<String, dynamic>? orderDetails,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      updatedAt: updatedAt ?? this.updatedAt,
      currentUserId: currentUserId ?? _currentUserId,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }
}

class ChatParticipant {
  String userId;
  String userType;
  String name;
  String? profileImage;
  DateTime lastSeen;

  ChatParticipant({
    required this.userId,
    required this.userType,
    required this.name,
    this.profileImage,
    required this.lastSeen,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId']?.toString() ?? json['_id']?.toString() ?? '',
      userType: json['userType']?.toString() ?? 'Unknown',
      name: json['name']?.toString() ?? 'Unknown',
      profileImage: json['profileImage']?.toString(),
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'].toString())
          : DateTime.now(),
    );
  }

  ChatParticipant copyWith({
    String? userId,
    String? userType,
    String? name,
    String? profileImage,
    DateTime? lastSeen,
  }) {
    return ChatParticipant(
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
