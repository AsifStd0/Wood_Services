import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';

/// Ad Status Enum
enum AdStatus {
  pending,
  approved,
  rejected,
  completed;

  String get displayName {
    switch (this) {
      case AdStatus.pending:
        return 'Pending';
      case AdStatus.approved:
        return 'Live';
      case AdStatus.rejected:
        return 'Rejected';
      case AdStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case AdStatus.pending:
        return AppColors.warning;
      case AdStatus.approved:
        return AppColors.success;
      case AdStatus.rejected:
        return AppColors.error;
      case AdStatus.completed:
        return AppColors.textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case AdStatus.pending:
        return Icons.pending_rounded;
      case AdStatus.approved:
        return Icons.check_circle_rounded;
      case AdStatus.rejected:
        return Icons.cancel_rounded;
      case AdStatus.completed:
        return Icons.done_all_rounded;
    }
  }
}

/// Seller Ad Model
class SellerAdModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final AdStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;
  final int? impressions;
  final int? clicks;
  final String? rejectionReason;
  final String? targetAudience;
  final String? category;

  SellerAdModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.startDate,
    this.endDate,
    this.budget,
    this.impressions,
    this.clicks,
    this.rejectionReason,
    this.targetAudience,
    this.category,
  });

  factory SellerAdModel.fromJson(Map<String, dynamic> json) {
    return SellerAdModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      status: _parseStatus(json['status']?.toString() ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      budget: json['budget']?.toDouble(),
      impressions: json['impressions']?.toInt(),
      clicks: json['clicks']?.toInt(),
      rejectionReason: json['rejectionReason']?.toString(),
      targetAudience: json['targetAudience']?.toString(),
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'budget': budget,
      'impressions': impressions,
      'clicks': clicks,
      'rejectionReason': rejectionReason,
      'targetAudience': targetAudience,
      'category': category,
    };
  }

  static AdStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'live':
        return AdStatus.approved;
      case 'rejected':
        return AdStatus.rejected;
      case 'completed':
        return AdStatus.completed;
      case 'pending':
      default:
        return AdStatus.pending;
    }
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedBudget {
    if (budget == null) return 'N/A';
    return '\$${budget!.toStringAsFixed(2)}';
  }

  bool get isActive => status == AdStatus.approved;
  bool get canEdit => status == AdStatus.pending || status == AdStatus.rejected;
  bool get canDelete => status != AdStatus.approved;
}
