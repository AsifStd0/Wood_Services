// models/admin_models.dart
class AdminModel {
  final String id;
  final String email;
  final String name;
  final String role; // super_admin, moderator, support
  final DateTime createdAt;
  final bool isActive;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });
}

class AdminStats {
  final int totalSellers;
  final int totalBuyers;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final int pendingVerifications;
  final int activeDisputes;

  AdminStats({
    required this.totalSellers,
    required this.totalBuyers,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingVerifications,
    required this.activeDisputes,
  });
}

class PlatformEarning {
  final String id;
  final String orderId;
  final double orderAmount;
  final double commissionRate;
  final double commissionAmount;
  final DateTime earningDate;
  final String sellerId;
  final String sellerName;

  PlatformEarning({
    required this.id,
    required this.orderId,
    required this.orderAmount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.earningDate,
    required this.sellerId,
    required this.sellerName,
  });
}

// models/admin_models.dart

// Base User Model
class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;
  final String? profileImage;
  final String? businessName;
  final String? address;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.isVerified = false,
    this.isActive = true,
    this.profileImage,
    this.businessName,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.toString(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
      'isActive': isActive,
      'profileImage': profileImage,
      'businessName': businessName,
      'address': address,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == map['role'],
        orElse: () => UserRole.buyer,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      profileImage: map['profileImage'],
      businessName: map['businessName'],
      address: map['address'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    bool? isVerified,
    bool? isActive,
    String? profileImage,
    String? businessName,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
    );
  }
}

enum UserRole { admin, seller, buyer }

// Product Model
class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? originalPrice;
  final int stock;
  final List<String> images;
  final double rating;
  final int totalReviews;
  final bool isActive;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? woodType;
  final String? dimensions;
  final String? material;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.stock,
    required this.images,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    this.isApproved = false,
    required this.createdAt,
    required this.updatedAt,
    this.woodType,
    this.dimensions,
    this.material,
  });

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? name,
    String? description,
    String? category,
    double? price,
    double? originalPrice,
    int? stock,
    List<String>? images,
    double? rating,
    int? totalReviews,
    bool? isActive,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? woodType,
    String? dimensions,
    String? material,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      woodType: woodType ?? this.woodType,
      dimensions: dimensions ?? this.dimensions,
      material: material ?? this.material,
    );
  }
}

// Order Model
class OrderModel {
  final String id;
  final String orderNumber;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String shippingAddress;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? trackingNumber;
  final double platformCommission;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.orderDate,
    this.deliveryDate,
    this.trackingNumber,
    this.platformCommission = 0.0,
  });

  double get sellerAmount => totalAmount - platformCommission;
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.image,
  });
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentStatus { pending, completed, failed, refunded }

class VerificationRequest {
  final String id;
  final String sellerId;
  final String sellerName;
  final String businessName;
  final List<String> documents;
  final VerificationStatus status;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  VerificationRequest({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.businessName,
    required this.documents,
    required this.status,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
  });

  VerificationRequest copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? businessName,
    List<String>? documents,
    VerificationStatus? status,
    DateTime? submittedAt,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      businessName: businessName ?? this.businessName,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

enum VerificationStatus { pending, approved, rejected }

class Dispute {
  final String id;
  final String orderId;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String reason;
  final DisputeStatus status;
  final DateTime createdAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolution;

  Dispute({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.resolvedBy,
    this.resolvedAt,
    this.resolution,
  });
}

enum DisputeStatus { open, in_progress, resolved, closed }
