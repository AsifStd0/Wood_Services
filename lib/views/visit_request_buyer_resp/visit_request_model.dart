// models/buyer_visit_request_model.dart
import 'dart:developer';
import 'package:flutter/material.dart';

enum BuyerVisitRequestStatus {
  pending,
  accepted,
  rejected,
  declined,
  completed,
  cancelled,
  visited,
}

class BuyerVisitRequest {
  final String id;
  final String buyerId;
  final Map<String, dynamic> sellerInfo;
  final Map<String, dynamic> serviceInfo;
  final Map<String, dynamic> requestDetails;
  final Map<String, dynamic> timeline;
  final Map<String, dynamic>? estimatedCost;
  final Map<String, dynamic>? actualCost;
  final BuyerVisitRequestStatus status;
  final List<String> images;
  final List<Map<String, dynamic>> notes; // Seller notes
  final DateTime createdAt;
  final DateTime updatedAt;

  BuyerVisitRequest({
    required this.id,
    required this.buyerId,
    required this.sellerInfo,
    required this.serviceInfo,
    required this.requestDetails,
    required this.timeline,
    this.estimatedCost,
    this.actualCost,
    required this.status,
    this.images = const [],
    this.notes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory BuyerVisitRequest.fromJson(Map<String, dynamic> json) {
    try {
      // Parse seller info
      final sellerIdObj = json['sellerId'];
      Map<String, dynamic> sellerInfo = {};
      if (sellerIdObj is Map) {
        sellerInfo = {
          'id': sellerIdObj['_id']?.toString() ?? '',
          'name': sellerIdObj['name']?.toString() ?? 'Unknown Seller',
          'email': sellerIdObj['email']?.toString(),
          'phone': sellerIdObj['phone']?.toString(),
          'profileImage': sellerIdObj['profileImage']?.toString(),
          'businessName': sellerIdObj['businessName']?.toString(),
          'shopName': sellerIdObj['shopName']?.toString(),
          'shopLogo': sellerIdObj['shopLogo']?.toString(),
          'shopBanner': sellerIdObj['shopBanner']?.toString(),
        };
      }

      // Parse service info
      final serviceIdObj = json['serviceId'];
      Map<String, dynamic> serviceInfo = {};
      if (serviceIdObj is Map) {
        serviceInfo = {
          'id': serviceIdObj['_id']?.toString() ?? '',
          'title': serviceIdObj['title']?.toString() ?? 'Unknown Service',
          'productType': serviceIdObj['productType']?.toString(),
          'price': serviceIdObj['price'],
          'featuredImage': serviceIdObj['featuredImage']?.toString(),
        };
      }

      // Parse request details
      final requestDetailsObj = json['requestDetails'] ?? {};
      Map<String, dynamic> requestDetails = {};
      if (requestDetailsObj is Map) {
        requestDetails = {
          'description': requestDetailsObj['description']?.toString(),
          'preferredDate': requestDetailsObj['preferredDate']?.toString(),
          'preferredTime': requestDetailsObj['preferredTime']?.toString(),
          'address': requestDetailsObj['address'] is Map
              ? Map<String, dynamic>.from(requestDetailsObj['address'])
              : {},
        };
      }

      // Parse timeline
      final timelineObj = json['timeline'] ?? {};
      Map<String, dynamic> timeline = {};
      if (timelineObj is Map) {
        timeline = {
          'requestedAt': timelineObj['requestedAt']?.toString(),
          'acceptedAt': timelineObj['acceptedAt']?.toString(),
          'rejectedAt': timelineObj['rejectedAt']?.toString(),
          'completedAt': timelineObj['completedAt']?.toString(),
          'cancelledAt': timelineObj['cancelledAt']?.toString(),
          'visitedAt': timelineObj['visitedAt']?.toString(),
        };
      }

      // Parse status
      final statusStr = json['status']?.toString().toLowerCase() ?? 'pending';
      BuyerVisitRequestStatus status;
      switch (statusStr) {
        case 'accepted':
          status = BuyerVisitRequestStatus.accepted;
          break;
        case 'rejected':
        case 'declined':
          status = BuyerVisitRequestStatus.rejected;
          break;
        case 'completed':
          status = BuyerVisitRequestStatus.completed;
          break;
        case 'cancelled':
          status = BuyerVisitRequestStatus.cancelled;
          break;
        case 'visited':
          status = BuyerVisitRequestStatus.visited;
          break;
        default:
          status = BuyerVisitRequestStatus.pending;
      }

      // Parse notes
      List<Map<String, dynamic>> notes = [];
      if (json['notes'] is List) {
        notes = (json['notes'] as List)
            .map((note) => note is Map ? Map<String, dynamic>.from(note) : <String, dynamic>{})
            .where((note) => note.isNotEmpty)
            .cast<Map<String, dynamic>>()
            .toList();
      }

      // Parse images
      List<String> images = [];
      if (json['images'] is List) {
        images = (json['images'] as List)
            .map((img) => img?.toString() ?? '')
            .where((img) => img.isNotEmpty)
            .toList();
      }

      // Parse dates
      DateTime createdAt;
      try {
        createdAt = DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String());
      } catch (e) {
        log('⚠️ Error parsing createdAt: $e');
        createdAt = DateTime.now();
      }

      DateTime updatedAt;
      try {
        updatedAt = DateTime.parse(json['updatedAt']?.toString() ?? json['createdAt']?.toString() ?? DateTime.now().toIso8601String());
      } catch (e) {
        log('⚠️ Error parsing updatedAt: $e');
        updatedAt = DateTime.now();
      }

      return BuyerVisitRequest(
        id: json['_id']?.toString() ?? '',
        buyerId: json['buyerId']?.toString() ?? '',
        sellerInfo: sellerInfo,
        serviceInfo: serviceInfo,
        requestDetails: requestDetails,
        timeline: timeline,
        estimatedCost: json['estimatedCost'] is Map
            ? Map<String, dynamic>.from(json['estimatedCost'])
            : null,
        actualCost: json['actualCost'] is Map
            ? Map<String, dynamic>.from(json['actualCost'])
            : null,
        status: status,
        images: images,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e, stackTrace) {
      log('❌ Error parsing BuyerVisitRequest: $e');
      log('   Stack trace: $stackTrace');
      log('   JSON: $json');
      rethrow;
    }
  }

  // Helper getters
  String get sellerName => sellerInfo['name']?.toString() ?? 'Unknown Seller';
  String get shopName => sellerInfo['shopName']?.toString() ?? sellerInfo['businessName']?.toString() ?? '';
  String? get shopLogo => sellerInfo['shopLogo']?.toString();
  String get serviceTitle => serviceInfo['title']?.toString() ?? 'Unknown Service';
  String? get serviceImage => serviceInfo['featuredImage']?.toString();
  String? get description => requestDetails['description']?.toString();
  String? get preferredDate => requestDetails['preferredDate']?.toString();
  String? get preferredTime => requestDetails['preferredTime']?.toString();
  Map<String, dynamic> get address => requestDetails['address'] is Map
      ? Map<String, dynamic>.from(requestDetails['address'])
      : {};

  DateTime? get requestedAt {
    try {
      final dateStr = timeline['requestedAt']?.toString();
      return dateStr != null ? DateTime.parse(dateStr) : null;
    } catch (e) {
      return null;
    }
  }

  DateTime? get acceptedAt {
    try {
      final dateStr = timeline['acceptedAt']?.toString();
      return dateStr != null ? DateTime.parse(dateStr) : null;
    } catch (e) {
      return null;
    }
  }

  DateTime? get rejectedAt {
    try {
      final dateStr = timeline['rejectedAt']?.toString();
      return dateStr != null ? DateTime.parse(dateStr) : null;
    } catch (e) {
      return null;
    }
  }

  DateTime? get completedAt {
    try {
      final dateStr = timeline['completedAt']?.toString();
      return dateStr != null ? DateTime.parse(dateStr) : null;
    } catch (e) {
      return null;
    }
  }

  String get statusText {
    switch (status) {
      case BuyerVisitRequestStatus.pending:
        return 'Pending';
      case BuyerVisitRequestStatus.accepted:
        return 'Accepted';
      case BuyerVisitRequestStatus.rejected:
        return 'Rejected';
      case BuyerVisitRequestStatus.completed:
        return 'Completed';
      case BuyerVisitRequestStatus.cancelled:
        return 'Cancelled';
      case BuyerVisitRequestStatus.visited:
        return 'Visited';
      case BuyerVisitRequestStatus.declined:
        return 'Declined';
    }
  }

  Color get statusColor {
    switch (status) {
      case BuyerVisitRequestStatus.pending:
        return Colors.orange;
      case BuyerVisitRequestStatus.accepted:
        return Colors.blue;
      case BuyerVisitRequestStatus.rejected:
      case BuyerVisitRequestStatus.declined:
        return Colors.red;
      case BuyerVisitRequestStatus.completed:
        return Colors.green;
      case BuyerVisitRequestStatus.cancelled:
        return Colors.grey;
      case BuyerVisitRequestStatus.visited:
        return Colors.purple;
    }
  }

  String? get estimatedCostAmount {
    if (estimatedCost == null) return null;
    final amount = estimatedCost!['amount'];
    final currency = estimatedCost!['currency']?.toString() ?? 'USD';
    if (amount == null) return null;
    return '${_getCurrencySymbol(currency)}${amount.toStringAsFixed(2)}';
  }

  String? get actualCostAmount {
    if (actualCost == null) return null;
    final amount = actualCost!['amount'];
    final currency = actualCost!['currency']?.toString() ?? 'USD';
    if (amount == null) return null;
    return '${_getCurrencySymbol(currency)}${amount.toStringAsFixed(2)}';
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return '$currencyCode ';
    }
  }

  String get formattedAddress {
    final addr = address;
    if (addr.isEmpty) return 'Address to be confirmed';
    
    final parts = <String>[];
    if (addr['street'] != null && addr['street'].toString().isNotEmpty) {
      parts.add(addr['street'].toString());
    }
    if (addr['city'] != null && addr['city'].toString().isNotEmpty) {
      parts.add(addr['city'].toString());
    }
    if (addr['state'] != null && addr['state'].toString().isNotEmpty) {
      parts.add(addr['state'].toString());
    }
    if (addr['country'] != null && addr['country'].toString().isNotEmpty) {
      parts.add(addr['country'].toString());
    }
    
    return parts.isEmpty ? 'Address to be confirmed' : parts.join(', ');
  }
}
