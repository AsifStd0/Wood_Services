// models/seller_notification_model.dart
import 'dart:developer';
import 'package:wood_service/views/Seller/data/views/noification_seller/notification_provider.dart';

class SellerNotificaionModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message; // API uses 'message' not 'description'
  final String? relatedId;
  final String? relatedModel;
  final DateTime timestamp;
  final bool isRead;

  SellerNotificaionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    this.relatedModel,
    required this.timestamp,
    this.isRead = false,
  });

  // Getter for description (for backward compatibility)
  String get description => message;

  // Getter for orderId (if relatedModel is Order)
  String? get orderId => relatedModel == 'Order' ? relatedId : null;

  // Getter for contractId (if relatedModel is Contract)
  String? get contractId => relatedModel == 'Contract' ? relatedId : null;

  // Factory to parse from API JSON
  factory SellerNotificaionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse ID
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

      // Parse userId
      final userId = json['userId']?.toString() ?? '';

      // Parse type - API returns string like "order", "visit", etc.
      final typeString = json['type']?.toString().toLowerCase() ?? '';
      NotificationType type;
      switch (typeString) {
        case 'order':
        case 'orders':
          type = NotificationType.contracts; // Map orders to contracts for now
          break;
        case 'visit':
        case 'visits':
        case 'visit_request':
          type = NotificationType.visits;
          break;
        default:
          type = NotificationType.all;
      }

      // Parse timestamp
      DateTime timestamp;
      try {
        if (json['createdAt'] != null) {
          timestamp = DateTime.parse(json['createdAt'].toString()).toLocal();
        } else {
          timestamp = DateTime.now();
        }
      } catch (e) {
        log('⚠️ Error parsing timestamp: $e');
        timestamp = DateTime.now();
      }

      return SellerNotificaionModel(
        id: id,
        userId: userId,
        type: type,
        title: json['title']?.toString() ?? 'Notification',
        message: json['message']?.toString() ?? '',
        relatedId: json['relatedId']?.toString(),
        relatedModel: json['relatedModel']?.toString(),
        timestamp: timestamp,
        isRead: json['isRead'] ?? false,
      );
    } catch (e) {
      log('❌ Error parsing SellerNotificaionModel: $e');
      log('   JSON: $json');
      rethrow;
    }
  }

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
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? relatedId,
    String? relatedModel,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return SellerNotificaionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedId: relatedId ?? this.relatedId,
      relatedModel: relatedModel ?? this.relatedModel,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'title': title,
      'message': message,
      'relatedId': relatedId,
      'relatedModel': relatedModel,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SellerNotificaionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
