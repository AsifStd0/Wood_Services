import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/SellerAds/seller_ad_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/SellerAds/seller_ad_service.dart';

/// Seller Ad Provider
/// Manages state for seller ads
class SellerAdProvider with ChangeNotifier {
  final SellerAdService _service;

  SellerAdProvider({SellerAdService? service})
    : _service = service ?? SellerAdService();

  // State
  List<SellerAdModel> _ads = [];
  bool _isLoading = false;
  String? _errorMessage;
  AdStatus? _statusFilter;
  Map<String, dynamic> _stats = {};

  // Getters
  List<SellerAdModel> get ads => _ads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  AdStatus? get statusFilter => _statusFilter;
  Map<String, dynamic> get stats => _stats;

  List<SellerAdModel> get filteredAds {
    if (_statusFilter == null) return _ads;
    return _ads.where((ad) => ad.status == _statusFilter).toList();
  }

  // Statistics getters
  int get totalAds => _stats['total'] ?? 0;
  int get pendingAds => _stats['pending'] ?? 0;
  int get approvedAds => _stats['approved'] ?? 0;
  int get rejectedAds => _stats['rejected'] ?? 0;
  int get completedAds => _stats['completed'] ?? 0;
  int get totalImpressions => _stats['totalImpressions'] ?? 0;
  int get totalClicks => _stats['totalClicks'] ?? 0;
  double get totalBudget => (_stats['totalBudget'] ?? 0).toDouble();

  /// Load ads
  Future<void> loadAds({AdStatus? status}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _statusFilter = status;
      notifyListeners();

      log('📢 Loading ads...');
      _ads = await _service.getAds(status: status);
      _stats = await _service.getAdStats();

      _errorMessage = null;
      log('✅ Loaded ${_ads.length} ads');
    } catch (e) {
      log('❌ Error loading ads: $e');
      _errorMessage = 'Failed to load ads: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh ads
  Future<void> refresh() async {
    await loadAds(status: _statusFilter);
  }

  /// Create new ad
  Future<bool> createAd({
    required String title,
    required String description,
    String? imageUrl,
    String? videoUrl,
    double? budget,
    String? targetAudience,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      log('📢 Creating ad: $title');
      final newAd = await _service.createAd(
        title: title,
        description: description,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        budget: budget,
        targetAudience: targetAudience,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );

      _ads.insert(0, newAd);
      _stats = await _service.getAdStats();

      log('✅ Ad created successfully');
      return true;
    } catch (e) {
      log('❌ Error creating ad: $e');
      _errorMessage = 'Failed to create ad: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update ad
  Future<bool> updateAd(String id, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      log('📢 Updating ad: $id');
      final updatedAd = await _service.updateAd(id, updates);

      final index = _ads.indexWhere((ad) => ad.id == id);
      if (index != -1) {
        _ads[index] = updatedAd;
      }

      _stats = await _service.getAdStats();

      log('✅ Ad updated successfully');
      return true;
    } catch (e) {
      log('❌ Error updating ad: $e');
      _errorMessage = 'Failed to update ad: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete ad
  Future<bool> deleteAd(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      log('📢 Deleting ad: $id');
      final success = await _service.deleteAd(id);

      if (success) {
        _ads.removeWhere((ad) => ad.id == id);
        _stats = await _service.getAdStats();
        log('✅ Ad deleted successfully');
      }

      return success;
    } catch (e) {
      log('❌ Error deleting ad: $e');
      _errorMessage = 'Failed to delete ad: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set status filter
  void setStatusFilter(AdStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
