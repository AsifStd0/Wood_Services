// models/visit_request_model.dart
import 'package:flutter/material.dart';

// models/visit_request_model.dart
enum VisitStatus {
  pending,
  accepted,
  rejected,
  declined, // Add this
  cancelled,
  completed,
  noshow,
  active,
}

enum VisitType { delivery, pickup, inspection, shopVisit }

class VisitRequest {
  final String id;
  final String requestId;
  final Map<String, dynamic> buyer;
  final Map<String, dynamic> seller;
  final String? message;
  final VisitStatus status;
  final DateTime requestedDate;
  final DateTime? preferredDate;
  final String? preferredTime;
  final Map<String, dynamic>? sellerResponse;
  final DateTime? visitDate;
  final String? visitTime;
  final String? duration;
  final String? location;
  final String? instructions;
  final List<VisitItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VisitType? visitType;
  final String? address;

  VisitRequest({
    required this.id,
    required this.requestId,
    required this.buyer,
    required this.seller,
    this.message,
    required this.status,
    required this.requestedDate,
    this.preferredDate,
    this.preferredTime,
    this.sellerResponse,
    this.visitDate,
    this.visitTime,
    this.duration,
    this.location,
    this.instructions,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
    this.visitType,
    this.address,
  });

  factory VisitRequest.fromJson(Map<String, dynamic> json) {
    // Handle buyer data
    Map<String, dynamic> buyerData = {};

    if (json['buyer'] is Map) {
      buyerData = Map<String, dynamic>.from(json['buyer']);

      // Extract name from buyer data
      if (!buyerData.containsKey('name') && json.containsKey('buyerName')) {
        buyerData['name'] = json['buyerName'];
      }
      if (!buyerData.containsKey('email') && json.containsKey('buyerEmail')) {
        buyerData['email'] = json['buyerEmail'];
      }
    } else {
      // Fallback to individual fields
      buyerData = {
        'name': json['buyerName'] ?? 'Unknown Buyer',
        'email': json['buyerEmail'] ?? '',
        'phone': json['buyerPhone'] ?? '',
      };
    }

    // Handle profile image - ensure it's properly structured
    final profileImage = buyerData['profileImage'];
    if (profileImage is String) {
      // If it's a string, convert to map
      buyerData['profileImage'] = {'url': profileImage};
    }

    return VisitRequest(
      id: json['_id'] ?? json['id'] ?? '',
      requestId: json['_id'] ?? json['id'] ?? '',
      buyer: buyerData,
      seller: json['seller'] is Map
          ? Map<String, dynamic>.from(json['seller'])
          : <String, dynamic>{},
      message: json['message'],
      status: _parseStatus(json['status']?.toString() ?? 'pending'),
      requestedDate: json['requestedDate'] != null
          ? DateTime.parse(json['requestedDate']).toLocal()
          : DateTime.parse(
              json['createdAt'] ?? DateTime.now().toString(),
            ).toLocal(),

      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt']).toLocal()
          : null,
      visitType: _parseVisitType(json['visitType'] ?? json['type']),
      address: json['address'] ?? json['location'] ?? '',
    );
  }

  static VisitStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return VisitStatus.pending;
      case 'accepted':
        return VisitStatus.accepted;
      case 'rejected':
        return VisitStatus.rejected;
      case 'declined':
        return VisitStatus.declined; // Add this case
      case 'cancelled':
        return VisitStatus.cancelled;
      case 'completed':
        return VisitStatus.completed;
      case 'noshow':
        return VisitStatus.noshow;
      case 'active':
        return VisitStatus.active;
      default:
        return VisitStatus.pending;
    }
  }

  static VisitType? _parseVisitType(dynamic type) {
    if (type == null) return null;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'delivery':
        return VisitType.delivery;
      case 'pickup':
        return VisitType.pickup;
      case 'inspection':
        return VisitType.inspection;
      case 'shopvisit':
      case 'shop_visit':
      case 'shop-visit':
        return VisitType.shopVisit;
      default:
        return null;
    }
  }

  // Helper methods
  String get buyerName {
    return buyer['name'] ??
        buyer['fullName'] ??
        buyer['username'] ??
        'Unknown Buyer';
  }

  String get buyerEmail {
    return buyer['email'] ?? '';
  }

  String get buyerPhone {
    return buyer['phone'] ?? buyer['mobile'] ?? '';
  }

  String get buyerProfileImage {
    final profileImage = buyer['profileImage'];

    if (profileImage is Map<String, dynamic>) {
      return profileImage['url'] ?? profileImage['path'] ?? '';
    } else if (profileImage is String) {
      return profileImage;
    }

    return '';
  }

  String get sellerName {
    return seller['businessName'] ??
        seller['shopName'] ??
        seller['name'] ??
        'Unknown Seller';
  }

  bool get isPending => status == VisitStatus.pending;
  bool get isAccepted => status == VisitStatus.accepted;
  bool get isRejected => status == VisitStatus.rejected;
  bool get isCancelled => status == VisitStatus.cancelled;
  bool get isCompleted => status == VisitStatus.completed;

  String get formattedRequestDate {
    return '${requestedDate.day}/${requestedDate.month}/${requestedDate.year}';
  }

  String get formattedTime {
    if (visitTime != null) return visitTime!;
    if (preferredTime != null) return preferredTime!;
    return 'Flexible';
  }

  String get formattedVisitDate {
    if (visitDate != null) {
      return '${visitDate!.day}/${visitDate!.month}/${visitDate!.year}';
    }
    if (preferredDate != null) {
      return '${preferredDate!.day}/${preferredDate!.month}/${preferredDate!.year}';
    }
    return 'Not scheduled';
  }

  // In VisitRequest class
  Color get statusColor {
    switch (status) {
      case VisitStatus.pending:
        return Colors.orange;
      case VisitStatus.accepted:
        return Colors.green;
      case VisitStatus.rejected:
      case VisitStatus.declined:
        return Colors.red;
      case VisitStatus.cancelled:
        return Colors.grey;
      case VisitStatus.completed:
        return Colors.blue;
      case VisitStatus.noshow:
        return Colors.purple;
      case VisitStatus.active:
        return Colors.amber;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case VisitStatus.pending:
        return Icons.pending;
      case VisitStatus.accepted:
        return Icons.check_circle;
      case VisitStatus.rejected:
      case VisitStatus.declined:
        return Icons.cancel;
      case VisitStatus.cancelled:
        return Icons.block;
      case VisitStatus.completed:
        return Icons.done_all;
      case VisitStatus.noshow:
        return Icons.person_off;
      case VisitStatus.active:
        return Icons.access_time;
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
      case VisitStatus.declined:
        return 'Declined';
      case VisitStatus.cancelled:
        return 'Cancelled';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.noshow:
        return 'No Show';
      case VisitStatus.active:
        return 'Active';
    }
  }

  String get visitTypeText {
    switch (visitType) {
      case VisitType.delivery:
        return 'Delivery';
      case VisitType.pickup:
        return 'Pickup';
      case VisitType.inspection:
        return 'Inspection';
      case VisitType.shopVisit:
        return 'Shop Visit';
      default:
        return 'Visit';
    }
  }
}

class VisitItem {
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;

  VisitItem({
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
  });

  factory VisitItem.fromJson(Map<String, dynamic> json) {
    return VisitItem(
      productName: json['productName'] ?? json['name'] ?? 'Unknown Product',
      productImage: json['productImage'] ?? json['image'],
      quantity: (json['quantity'] ?? 1).toInt(),
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}

// For backward compatibility with your existing code
extension VisitRequestExtension on VisitRequest {
  String get orderId => id;
  String get formattedAcceptedDate => formattedRequestDate;
  String get formattedRequestedDate => formattedRequestDate;
}
