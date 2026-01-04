import 'package:wood_service/chats/Buyer/buyer_chat_model.dart' as buyer_models;
import 'package:wood_service/chats/Seller/new_seller_chat/seller_chat_model.dart';

// Re-export original models for compatibility
export 'package:wood_service/chats/Buyer/buyer_chat_model.dart'
    show ChatParticipant, ChatAttachment, ChatStartRequest;

class SellerChatRoom {
  String id;
  List<ChatParticipant> participants;
  String? lastMessage;
  String? lastMessageText;
  int sellerUnreadCount; // Specific for seller
  DateTime updatedAt;
  String? productId;
  String? productName; // Added
  String? orderId;
  SellerBuyerInfo? buyer; // Added for seller view

  SellerChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageText,
    this.sellerUnreadCount = 0,
    required this.updatedAt,
    this.productId,
    this.productName,
    this.orderId,
    this.buyer,
  });
  factory SellerChatRoom.fromJson(Map<String, dynamic> json) {
    // Handle productId - it could be String or Map
    String? productIdString;
    String? productNameString;

    if (json['productId'] != null) {
      if (json['productId'] is String) {
        productIdString = json['productId'];
      } else if (json['productId'] is Map<String, dynamic>) {
        productIdString = json['productId']['_id']?.toString();
        productNameString = json['productId']['name'];
      } else if (json['productId'] is Map<dynamic, dynamic>) {
        // Cast dynamic map to string map
        final productMap = Map<String, dynamic>.from(
          json['productId'] as Map<dynamic, dynamic>,
        );
        productIdString = productMap['_id']?.toString();
        productNameString = productMap['name'];
      }
    }

    // Handle lastMessage
    String? lastMessageString;
    if (json['lastMessage'] != null) {
      if (json['lastMessage'] is String) {
        lastMessageString = json['lastMessage'];
      } else if (json['lastMessage'] is Map<String, dynamic>) {
        lastMessageString = json['lastMessage']['_id']?.toString();
      } else if (json['lastMessage'] is Map<dynamic, dynamic>) {
        final messageMap = Map<String, dynamic>.from(
          json['lastMessage'] as Map<dynamic, dynamic>,
        );
        lastMessageString = messageMap['_id']?.toString();
      }
    }

    // Extract buyer information - FIXED TYPE CASTING
    SellerBuyerInfo? buyerInfo;
    if (json['buyer'] != null || json['otherParticipant'] != null) {
      final buyerData = json['buyer'] ?? json['otherParticipant'];

      if (buyerData is Map<String, dynamic>) {
        buyerInfo = SellerBuyerInfo.fromJson(buyerData);
      } else if (buyerData is Map<dynamic, dynamic>) {
        // Cast dynamic map to string map
        final buyerMap = Map<String, dynamic>.from(buyerData);
        buyerInfo = SellerBuyerInfo.fromJson(buyerMap);
      }
    }

    return SellerChatRoom(
      id: json['_id'] ?? json['id'] ?? '',
      participants: json['participants'] != null
          ? List<ChatParticipant>.from(
              json['participants'].map((x) => ChatParticipant.fromJson(x)),
            )
          : [],
      lastMessage: lastMessageString,
      lastMessageText: json['lastMessageText'] ?? '',
      sellerUnreadCount:
          json['sellerUnreadCount'] ??
          json['myUnreadCount'] ??
          json['unreadCount'] ??
          0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      productId: productIdString,
      productName: productNameString ?? json['productName'],
      orderId: json['orderId'],
      buyer: buyerInfo,
    );
  }

  // Helper getters
  String get buyerName {
    if (buyer != null) {
      return buyer!.name;
    }

    // Fallback to participants
    final buyerParticipant = participants.firstWhere(
      (p) => p.userType == 'Buyer',
      orElse: () => participants.isNotEmpty
          ? participants[0]
          : ChatParticipant(
              userId: '',
              userType: '',
              name: 'Customer',
              lastSeen: DateTime.now(),
            ),
    );

    return buyerParticipant.name;
  }

  String? get buyerId {
    if (buyer != null) {
      return buyer!.userId;
    }

    final buyerParticipant = participants.firstWhere(
      (p) => p.userType == 'Buyer',
      orElse: () => ChatParticipant(
        userId: '',
        userType: '',
        name: '',
        lastSeen: DateTime.now(),
      ),
    );

    return buyerParticipant.userId.isNotEmpty ? buyerParticipant.userId : null;
  }

  // Convert to regular ChatRoom for compatibility
  buyer_models.ChatRoom toChatRoom() {
    return buyer_models.ChatRoom(
      id: id,
      participants: participants,
      lastMessage: lastMessage,
      lastMessageText: lastMessageText,
      unreadCount: sellerUnreadCount,
      updatedAt: updatedAt,
      productId: productId,
      orderId: orderId,
    );
  }
}

class SellerBuyerInfo {
  String userId;
  String userType;
  String name;
  String? profileImage;
  String? email;
  String? phone;
  String? businessName;
  bool isActive;

  SellerBuyerInfo({
    required this.userId,
    required this.userType,
    required this.name,
    this.profileImage,
    this.email,
    this.phone,
    this.businessName,
    this.isActive = true,
  });

  factory SellerBuyerInfo.fromJson(Map<String, dynamic> json) {
    // Handle nested details with proper type casting
    Map<String, dynamic> details = {};

    if (json['details'] != null) {
      if (json['details'] is Map<String, dynamic>) {
        details = json['details'];
      } else if (json['details'] is Map<dynamic, dynamic>) {
        details = Map<String, dynamic>.from(
          json['details'] as Map<dynamic, dynamic>,
        );
      }
    }

    // Handle profileImage which might be a map
    String? profileImageUrl;
    if (json['profileImage'] != null) {
      if (json['profileImage'] is String) {
        profileImageUrl = json['profileImage'];
      } else if (json['profileImage'] is Map<String, dynamic>) {
        profileImageUrl = json['profileImage']['url'];
      } else if (json['profileImage'] is Map<dynamic, dynamic>) {
        final profileMap = Map<String, dynamic>.from(
          json['profileImage'] as Map<dynamic, dynamic>,
        );
        profileImageUrl = profileMap['url'];
      }
    }

    // Handle details profileImage similarly
    if (profileImageUrl == null && details['profileImage'] != null) {
      if (details['profileImage'] is String) {
        profileImageUrl = details['profileImage'];
      } else if (details['profileImage'] is Map<String, dynamic>) {
        profileImageUrl = details['profileImage']['url'];
      } else if (details['profileImage'] is Map<dynamic, dynamic>) {
        final detailsProfileMap = Map<String, dynamic>.from(
          details['profileImage'] as Map<dynamic, dynamic>,
        );
        profileImageUrl = detailsProfileMap['url'];
      }
    }

    return SellerBuyerInfo(
      userId: json['userId']?.toString() ?? details['_id']?.toString() ?? '',
      userType: json['userType'] ?? 'Buyer',
      name:
          json['name'] ??
          details['fullName'] ??
          details['businessName'] ??
          details['contactName'] ??
          'Customer',
      profileImage: profileImageUrl,
      email: json['email'] ?? details['email'],
      phone: json['phone'] ?? details['phone'],
      businessName: json['businessName'] ?? details['businessName'],
      isActive: json['isActive'] ?? details['isActive'] ?? true,
    );
  }
}
