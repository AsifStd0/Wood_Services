import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart';

/// Ad Status Enum
enum ProductAdStatus {
  pending,
  approved,
  rejected,
  completed;

  String get displayName {
    switch (this) {
      case ProductAdStatus.pending:
        return 'Pending';
      case ProductAdStatus.approved:
        return 'Live';
      case ProductAdStatus.rejected:
        return 'Rejected';
      case ProductAdStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case ProductAdStatus.pending:
        return AppColors.warning;
      case ProductAdStatus.approved:
        return AppColors.success;
      case ProductAdStatus.rejected:
        return AppColors.error;
      case ProductAdStatus.completed:
        return AppColors.textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case ProductAdStatus.pending:
        return Icons.pending_rounded;
      case ProductAdStatus.approved:
        return Icons.check_circle_rounded;
      case ProductAdStatus.rejected:
        return Icons.cancel_rounded;
      case ProductAdStatus.completed:
        return Icons.done_all_rounded;
    }
  }

  static ProductAdStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ProductAdStatus.pending;
      case 'approved':
      case 'live':
        return ProductAdStatus.approved;
      case 'rejected':
        return ProductAdStatus.rejected;
      case 'completed':
        return ProductAdStatus.completed;
      default:
        return ProductAdStatus.pending;
    }
  }
}

/// Seller Own Product Ad Model
/// Represents an advertisement for a seller's own product/service
class SellerOwnAdModel {
  final String id;
  final String serviceId; // The product/service ID this ad is for
  final UploadedProductModel?
  service; // Full product details (optional, loaded separately)
  final ProductAdStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime startDate;
  final DateTime endDate;
  final String? rejectionReason;
  final int? impressions;
  final int? clicks;

  SellerOwnAdModel({
    required this.id,
    required this.serviceId,
    this.service,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    required this.startDate,
    required this.endDate,
    this.rejectionReason,
    this.impressions,
    this.clicks,
  });

  factory SellerOwnAdModel.fromJson(Map<String, dynamic> json) {
    // Parse serviceId - can be a string or an object
    String serviceIdString = '';
    UploadedProductModel? serviceData;

    if (json['serviceId'] != null) {
      if (json['serviceId'] is String) {
        serviceIdString = json['serviceId'].toString();
      } else if (json['serviceId'] is Map) {
        // serviceId is an object with product details
        final serviceIdObj = json['serviceId'] as Map<String, dynamic>;
        serviceIdString =
            serviceIdObj['_id']?.toString() ??
            serviceIdObj['id']?.toString() ??
            '';
        // Parse the service/product data
        serviceData = UploadedProductModel.fromJson(serviceIdObj);
      }
    }

    return SellerOwnAdModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      serviceId: serviceIdString,
      status: ProductAdStatus.fromString(
        json['status']?.toString() ?? 'pending',
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'].toString())
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      rejectionReason:
          (json['rejectionReason'] != null &&
              json['rejectionReason'].toString().isNotEmpty)
          ? json['rejectionReason'].toString()
          : null,
      impressions: json['impressions'] as int?,
      clicks: json['clicks'] as int?,
      // Use parsed service data or try to parse from 'service' field
      service:
          serviceData ??
          (json['service'] != null
              ? UploadedProductModel.fromJson(json['service'])
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rejectionReason': rejectionReason,
      'impressions': impressions,
      'clicks': clicks,
    };
  }

  // Helper getters
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedEndDate {
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }

  bool get isActive => status == ProductAdStatus.approved;
  bool get isPending => status == ProductAdStatus.pending;
  bool get isRejected => status == ProductAdStatus.rejected;
  bool get isCompleted => status == ProductAdStatus.completed;

  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  String get productTitle => service?.title ?? 'Product';
  String get productImage => service?.displayImage ?? '';
  String get productPrice => service?.formattedPrice ?? '';
}
