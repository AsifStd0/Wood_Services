// models/seller_stats_model.dart
class SellerStatsModel {
  final Stats stats;

  SellerStatsModel({required this.stats});

  factory SellerStatsModel.fromJson(Map<String, dynamic> json) {
    return SellerStatsModel(stats: Stats.fromJson(json['stats'] ?? {}));
  }
}

class Stats {
  final ServiceStats services;
  final OrderStats orders;
  final double averageRating;
  final double totalRevenue;

  Stats({
    required this.services,
    required this.orders,
    required this.averageRating,
    required this.totalRevenue,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      services: ServiceStats.fromJson(json['services'] ?? {}),
      orders: OrderStats.fromJson(json['orders'] ?? {}),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ServiceStats {
  final int total;
  final int active;

  ServiceStats({required this.total, required this.active});

  factory ServiceStats.fromJson(Map<String, dynamic> json) {
    return ServiceStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderStats {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;

  OrderStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
    );
  }
}
