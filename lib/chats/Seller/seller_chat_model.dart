import 'package:wood_service/chats/Seller/seller_chat_model.dart';

// Re-export original models for compatibility
export 'package:wood_service/chats/Buyer/buyer_chat_model.dart'
    show ChatParticipant, ChatAttachment;

class SellerChatRoom {
  String id;
  List<ChatParticipant> participants;
  String? lastMessage;
  String? lastMessageText;
  int sellerUnreadCount;
  DateTime updatedAt;
  String? productId;
  String? productName;
  String? orderId;
  SellerBuyerInfo? buyer;
  String? productImage; // Added for product image

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
    this.productImage,
  });

  factory SellerChatRoom.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing SellerChatRoom JSON: ${json.keys.toList()}');

    // Extract product information
    String? productIdString;
    String? productNameString;
    String? productImageString;

    if (json['productId'] != null) {
      print('📦 ProductId data type: ${json['productId'].runtimeType}');

      if (json['productId'] is String) {
        productIdString = json['productId'];
      } else if (json['productId'] is Map<String, dynamic>) {
        final productMap = json['productId'] as Map<String, dynamic>;
        productIdString = productMap['_id']?.toString();
        productNameString = productMap['name']?.toString();
        productImageString = _getProductImage(productMap);
      } else if (json['productId'] is Map<dynamic, dynamic>) {
        final productMap = Map<String, dynamic>.from(
          json['productId'] as Map<dynamic, dynamic>,
        );
        productIdString = productMap['_id']?.toString();
        productNameString = productMap['name']?.toString();
        productImageString = _getProductImage(productMap);
      }
    }

    print('📦 ProductId: $productIdString');
    print('📦 ProductName: $productNameString');

    // Handle unread count safely
    int sellerUnreadCount = 0;
    final currentUserId = ''; // This should come from your auth context

    if (json['sellerUnreadCount'] != null) {
      sellerUnreadCount = json['sellerUnreadCount'] is int
          ? json['sellerUnreadCount']
          : 0;
    } else if (json['unreadCount'] != null) {
      print('📊 UnreadCount type: ${json['unreadCount'].runtimeType}');

      if (json['unreadCount'] is Map<String, dynamic>) {
        final unreadMap = json['unreadCount'] as Map<String, dynamic>;
        // Try to find seller's unread count
        for (final key in unreadMap.keys) {
          if (key.contains('6956adddff9f52790cf674f2')) {
            // Your seller ID from logs
            sellerUnreadCount = (unreadMap[key] is int) ? unreadMap[key] : 0;
            break;
          }
        }
      } else if (json['unreadCount'] is Map<dynamic, dynamic>) {
        final unreadMap = Map<String, dynamic>.from(
          json['unreadCount'] as Map<dynamic, dynamic>,
        );
        for (final key in unreadMap.keys) {
          if (key.contains('6956adddff9f52790cf674f2')) {
            sellerUnreadCount = (unreadMap[key] is int) ? unreadMap[key] : 0;
            break;
          }
        }
      }
    }

    print('📊 SellerUnreadCount: $sellerUnreadCount');

    // Extract buyer information from participants
    SellerBuyerInfo? buyerInfo;
    List<dynamic> participantsList = json['participants'] ?? [];

    for (var participant in participantsList) {
      if (participant is Map && participant['userType'] == 'Buyer') {
        buyerInfo = SellerBuyerInfo.fromJson(participant);
        break;
      }
    }

    // Also check if there's a separate buyer field
    if (json['buyer'] != null && buyerInfo == null) {
      buyerInfo = SellerBuyerInfo.fromJson(json['buyer']);
    }

    print('👤 Buyer info: ${buyerInfo?.name ?? "Not found"}');

    return SellerChatRoom(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      participants: participantsList.isNotEmpty
          ? List<ChatParticipant>.from(
              participantsList.map((x) => ChatParticipant.fromJson(x)),
            )
          : [],
      lastMessage:
          json['lastMessage']?['_id']?.toString() ?? json['lastMessage'],
      lastMessageText:
          json['lastMessageText']?.toString() ??
          json['lastMessage']?['message']?.toString() ??
          '',
      sellerUnreadCount: sellerUnreadCount,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : json['lastMessage']?['createdAt'] != null
          ? DateTime.parse(json['lastMessage']['createdAt'].toString())
          : DateTime.now(),
      productId: productIdString,
      productName: productNameString,
      orderId: json['orderId']?.toString(),
      buyer: buyerInfo,
      productImage: productImageString,
    );
  }

  static String? _getProductImage(Map<String, dynamic> productMap) {
    if (productMap['images'] != null) {
      if (productMap['images'] is List && productMap['images'].isNotEmpty) {
        final firstImage = productMap['images'][0];
        if (firstImage is String) return firstImage;
        if (firstImage is Map) return firstImage['url']?.toString();
      }
    }
    return null;
  }

  // Helper getters
  String get buyerName {
    if (buyer != null) {
      return buyer!.name;
    }

    // Fallback to participants
    for (final participant in participants) {
      if (participant.userType == 'Buyer') {
        return participant.name;
      }
    }

    return 'Customer';
  }

  String? get buyerId {
    if (buyer != null) {
      return buyer!.userId;
    }

    for (final participant in participants) {
      if (participant.userType == 'Buyer') {
        return participant.userId;
      }
    }

    return null;
  }

  // For debugging
  @override
  String toString() {
    return 'SellerChatRoom{id: $id, buyerName: $buyerName, unreadCount: $sellerUnreadCount, product: $productName}';
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

  factory SellerBuyerInfo.fromJson(dynamic json) {
    print('👤 Parsing SellerBuyerInfo: ${json.runtimeType}');

    if (json is Map<String, dynamic>) {
      return _fromMap(json);
    } else if (json is Map<dynamic, dynamic>) {
      return _fromMap(Map<String, dynamic>.from(json));
    } else {
      print('❌ Unexpected type for SellerBuyerInfo: ${json.runtimeType}');
      return SellerBuyerInfo(userId: '', userType: 'Buyer', name: 'Customer');
    }
  }

  static SellerBuyerInfo _fromMap(Map<String, dynamic> map) {
    return SellerBuyerInfo(
      userId: map['userId']?.toString() ?? '',
      userType: map['userType']?.toString() ?? 'Buyer',
      name: map['name']?.toString() ?? 'Customer',
      profileImage: map['profileImage']?.toString(),
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      businessName: map['businessName']?.toString(),
      isActive: map['isActive'] ?? true,
    );
  }
}
