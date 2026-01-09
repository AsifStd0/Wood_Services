// models/seller_visit_request_model.dart
import 'package:flutter/material.dart';

class SellerVisitRequest {
  final String id;
  final String? requestId;
  final Map<String, dynamic> buyer;
  final String? message;
  final String status; // pending, accepted, declined, cancelled
  final DateTime requestedDate;
  final DateTime? preferredDate;
  final String? preferredTime;
  final Map<String, dynamic>? sellerResponse;
  final DateTime? visitDate;
  final String? visitTime;
  final String? duration;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SellerVisitRequest({
    required this.id,
    this.requestId,
    required this.buyer,
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
    this.createdAt,
    this.updatedAt,
  });

  factory SellerVisitRequest.fromJson(Map<String, dynamic> json) {
    return SellerVisitRequest(
      id: json['_id'] ?? json['id'] ?? '',
      requestId: json['_id'] ?? json['id'],
      buyer: json['buyer'] is Map
          ? Map<String, dynamic>.from(json['buyer'])
          : {},
      message: json['message'],
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      requestedDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      preferredDate: json['preferredDate'] != null
          ? DateTime.parse(json['preferredDate']).toLocal()
          : null,
      preferredTime: json['preferredTime'],
      sellerResponse: json['sellerResponse'] is Map
          ? Map<String, dynamic>.from(json['sellerResponse'])
          : null,
      visitDate: json['visitDate'] != null
          ? DateTime.parse(json['visitDate']).toLocal()
          : null,
      visitTime: json['visitTime'],
      duration: json['duration'],
      location: json['location'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt']).toLocal()
          : null,
    );
  }

  // Buyer info getters
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
    return buyer['profileImage'] ?? buyer['avatar'] ?? '';
  }

  // Status checkers
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isCancelled => status == 'cancelled';

  // Date formatters
  String get formattedDate {
    return '${requestedDate.day}/${requestedDate.month}/${requestedDate.year}';
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

  String get formattedTime {
    if (visitTime != null) return visitTime!;
    if (preferredTime != null) return preferredTime!;
    return 'Flexible';
  }

  // Status text for display
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  // UI helpers
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'accepted':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  // Get seller response message if exists
  String? get sellerMessage {
    if (sellerResponse != null && sellerResponse!['message'] != null) {
      return sellerResponse!['message'];
    }
    return null;
  }

  // Get suggested date from seller response
  String? get suggestedDate {
    if (sellerResponse != null && sellerResponse!['suggestedDate'] != null) {
      return sellerResponse!['suggestedDate'];
    }
    return null;
  }

  // Get suggested time from seller response
  String? get suggestedTime {
    if (sellerResponse != null && sellerResponse!['suggestedTime'] != null) {
      return sellerResponse!['suggestedTime'];
    }
    return null;
  }

  // Formatted response date
  String? get formattedResponseDate {
    if (sellerResponse != null && sellerResponse!['respondedAt'] != null) {
      try {
        final date = DateTime.parse(sellerResponse!['respondedAt']).toLocal();
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Check if visit is scheduled
  bool get isScheduled =>
      visitDate != null || (preferredDate != null && isAccepted);

  // Get next action based on status
  String get nextAction {
    switch (status) {
      case 'pending':
        return 'Waiting for your response';
      case 'accepted':
        if (visitDate != null) {
          return 'Visit scheduled';
        }
        return 'Awaiting schedule details';
      case 'declined':
        return 'Request declined';
      case 'cancelled':
        return 'Visit cancelled';
      default:
        return 'Status: $status';
    }
  }

  // Get duration text
  String get durationText {
    if (duration != null) return duration!;
    return 'Not specified';
  }

  // Get location text
  String get locationText {
    if (location != null) return location!;
    return 'Not specified';
  }

  // Get formatted created at
  String get formattedCreatedAt {
    return '${createdAt?.day}/${createdAt?.month}/${createdAt?.year} ${createdAt?.hour}:${createdAt?.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted updated at
  String get formattedUpdatedAt {
    if (updatedAt != null) {
      return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year} ${updatedAt!.hour}:${updatedAt!.minute.toString().padLeft(2, '0')}';
    }
    return 'Not updated';
  }

  // Check if seller has responded
  bool get hasSellerResponded => sellerResponse != null;

  // Get days since request
  int get daysSinceRequest {
    final now = DateTime.now();
    final difference = now.difference(requestedDate);
    return difference.inDays;
  }

  // Get request age text
  String get requestAge {
    final days = daysSinceRequest;
    if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Yesterday';
    } else if (days < 7) {
      return '$days days ago';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (days / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}
