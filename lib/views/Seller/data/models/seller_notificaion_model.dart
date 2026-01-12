// models/seller_notification_model.dart
import 'package:wood_service/views/Seller/data/views/noification/notification_provider.dart';

class SellerNotificaionModel {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final String? orderId;
  final String? contractId;

  SellerNotificaionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.orderId,
    this.contractId,
  });

  // Time ago getter
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months}m ago';
    }
  }

  // Copy with method
  SellerNotificaionModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    String? orderId,
    String? contractId,
  }) {
    return SellerNotificaionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      orderId: orderId ?? this.orderId,
      contractId: contractId ?? this.contractId,
    );
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'orderId': orderId,
      'contractId': contractId,
    };
  }

  // Create from map for deserialization
  factory SellerNotificaionModel.fromMap(Map<String, dynamic> map) {
    return SellerNotificaionModel(
      id: map['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => NotificationType.all,
      ),
      title: map['title'],
      description: map['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRead: map['isRead'] ?? false,
      orderId: map['orderId'],
      contractId: map['contractId'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SellerNotificaionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
