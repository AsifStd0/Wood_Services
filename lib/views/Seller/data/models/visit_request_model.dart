// models/visit_request_model.dart
enum VisitStatus { pending, accepted, rejected, completed, cancelled, noshow }

class VisitRequest {
  final String id;
  final String orderId;
  final String buyerName;
  final String buyerPhone;
  final String buyerEmail;
  final String address;
  final DateTime visitDate;
  final String visitTime;
  final VisitStatus status;
  final String? instructions;
  final List<OrderItem> items;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  VisitRequest({
    required this.id,
    required this.orderId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerEmail,
    required this.address,
    required this.visitDate,
    required this.visitTime,
    required this.status,
    this.instructions,
    required this.items,
    required this.requestedAt,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory VisitRequest.fromJson(Map<String, dynamic> json) {
    // Debug log to see what data you're getting
    print('📥 Parsing order data: ${json.keys.toList()}');
    print('📥 Order ID: ${json['orderId']}');
    print('📥 Request Type: ${json['requestType']}');
    print('📥 isVisitRequest: ${json['isVisitRequest']}');
    print('📥 Visit Status: ${json['visitStatus']}');

    // Handle address - could be String or Map
    String address;
    if (json['visitAddress'] is String) {
      address = json['visitAddress'];
    } else if (json['visitAddress'] is Map) {
      final addr = json['visitAddress'] as Map<String, dynamic>;
      address = '${addr['street'] ?? ''}, ${addr['city'] ?? ''}';
    } else if (json['deliveryAddress'] is Map) {
      final addr = json['deliveryAddress'] as Map<String, dynamic>;
      address = '${addr['street'] ?? ''}, ${addr['city'] ?? ''}';
    } else {
      address = 'Address not specified';
    }

    // Handle date - could be string or already DateTime
    DateTime visitDate;
    if (json['visitDate'] is String) {
      visitDate = DateTime.parse(json['visitDate']);
    } else if (json['visitDate'] is DateTime) {
      visitDate = json['visitDate'];
    } else {
      visitDate = DateTime.now().add(const Duration(days: 1));
    }

    return VisitRequest(
      id: json['_id'] ?? json['orderId'] ?? 'unknown',
      orderId: json['orderId'] ?? 'unknown',
      buyerName: json['buyerName'] ?? 'Unknown Buyer',
      buyerPhone: json['buyerPhone'] ?? '',
      buyerEmail: json['buyerEmail'] ?? '',
      address: address,
      visitDate: visitDate,
      visitTime: json['visitTime'] ?? '10:00 AM',
      status: _parseVisitStatus(
        json['visitStatus'] ?? json['status'] ?? 'pending',
      ),
      instructions: json['visitInstructions'] ?? json['deliveryInstructions'],
      items:
          (json['items'] as List<dynamic>?)?.map((item) {
            // Handle both product object and simple data
            final productId =
                item['productId']?['_id'] ?? item['productId'] ?? '';
            final productName =
                item['productName'] ??
                item['productId']?['title'] ??
                'Unknown Product';

            return OrderItem(
              productId: productId.toString(),
              productName: productName.toString(),
              productImage:
                  item['productImage'] ??
                  item['productId']?['featuredImage']?.toString(),
              quantity: item['quantity'] ?? 1,
              price: (item['unitPrice'] ?? item['price'] ?? 0).toDouble(),
            );
          }).toList() ??
          [],
      requestedAt: DateTime.parse(
        json['requestedAt'] ?? DateTime.now().toIso8601String(),
      ),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
    );
  }

  static VisitStatus _parseVisitStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return VisitStatus.pending;
      case 'accepted':
      case 'scheduled':
        return VisitStatus.accepted;
      case 'completed':
        return VisitStatus.completed;
      case 'cancelled':
        return VisitStatus.cancelled;
      case 'noshow':
        return VisitStatus.noshow;
      case 'rejected':
        return VisitStatus.rejected;
      default:
        return VisitStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.accepted:
        return 'Accepted';
      case VisitStatus.rejected:
        return 'Rejected';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancelled:
        return 'Cancelled';
      case VisitStatus.noshow:
        return 'No Show';
    }
  }

  String get formattedRequestedDate {
    final now = DateTime.now();
    final difference = now.difference(requestedAt);

    if (difference.inDays > 7) {
      return '${requestedAt.day}/${requestedAt.month}/${requestedAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedAcceptedDate {
    if (acceptedAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(acceptedAt!);

    if (difference.inDays > 7) {
      return '${acceptedAt!.day}/${acceptedAt!.month}/${acceptedAt!.year}';
    } else if (difference.inDays > 0) {
      return 'Accepted ${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return 'Accepted ${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return 'Accepted ${difference.inMinutes}m ago';
    } else {
      return 'Accepted just now';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerEmail': buyerEmail,
      'address': address,
      'visitDate': visitDate.toIso8601String(),
      'visitTime': visitTime,
      'status': statusText.toLowerCase(),
      'instructions': instructions,
      'items': items.map((item) => item.toJson()).toList(),
      'requestedAt': requestedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? 'Unknown Product',
      productImage: json['productImage'],
      quantity: json['quantity'] ?? 1,
      price: (json['unitPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'unitPrice': price,
    };
  }
}
