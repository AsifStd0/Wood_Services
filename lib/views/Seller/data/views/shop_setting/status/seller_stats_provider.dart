// providers/seller_stats_provider.dart
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/models/seller_stats_model.dart';
import 'package:wood_service/views/Seller/data/services/seller_stats_service.dart';

class SellerStatsProvider with ChangeNotifier {
  final SellerStatsService _service = locator<SellerStatsService>();

  // State
  SellerStatsModel? _stats;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRefreshing = false;

  // Getters
  SellerStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get hasStats => _stats != null;

  // Get individual stats
  int get totalServices => _stats?.stats.services.total ?? 0;
  int get activeServices => _stats?.stats.services.active ?? 0;
  int get totalOrders => _stats?.stats.orders.total ?? 0;
  int get pendingOrders => _stats?.stats.orders.pending ?? 0;
  int get inProgressOrders => _stats?.stats.orders.inProgress ?? 0;
  int get completedOrders => _stats?.stats.orders.completed ?? 0;
  double get averageRating => _stats?.stats.averageRating ?? 0.0;
  double get totalRevenue => _stats?.stats.totalRevenue ?? 0.0;

  /// Load seller statistics
  Future<void> loadSellerStats({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    if (refresh) _isRefreshing = true;
    notifyListeners();

    try {
      log('📊 Loading seller statistics...');
      _stats = await _service.getSellerStats();
      _errorMessage = null;
      log('✅ Seller statistics loaded successfully');
    } catch (e) {
      log('❌ Error loading seller stats: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await loadSellerStats(refresh: true);
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
