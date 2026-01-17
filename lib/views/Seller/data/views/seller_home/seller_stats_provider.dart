// seller_stats_provider.dart
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/seller_stats_service.dart';

class SellerStatsProvider with ChangeNotifier {
  final SellerStatsService _service = locator<SellerStatsService>();

  // Stats data
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> get stats => _stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Getters for easy access to stats
  int get totalServices => _stats['services']?['total'] ?? 0;
  int get activeServices => _stats['services']?['active'] ?? 0;

  int get totalOrders => _stats['orders']?['total'] ?? 0;
  int get pendingOrders => _stats['orders']?['pending'] ?? 0;
  int get inProgressOrders => _stats['orders']?['inProgress'] ?? 0;
  int get completedOrders => _stats['orders']?['completed'] ?? 0;

  double get averageRating => (_stats['averageRating'] ?? 0).toDouble();
  double get totalRevenue => (_stats['totalRevenue'] ?? 0).toDouble();

  /// Load seller statistics
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📊 Loading seller stats...');
      _stats = await _service.getSellerStats();
      log('✅ Stats loaded successfully: $_stats');
      _errorMessage = null;
    } catch (e) {
      log('❌ Error loading stats: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh stats
  Future<void> refresh() async {
    await loadStats();
  }
}