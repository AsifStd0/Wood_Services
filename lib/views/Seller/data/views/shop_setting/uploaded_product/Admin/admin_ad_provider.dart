import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Admin/admin_ad_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Admin/admin_ad_service.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/SellerAds/seller_ad_model.dart';

/// Admin Ad Provider
/// Manages state for admin ads management
class AdminAdProvider with ChangeNotifier {
  final AdminAdService _service;

  AdminAdProvider({AdminAdService? service})
    : _service = service ?? AdminAdService();

  // State
  List<AdminAdModel> _ads = [];
  bool _isLoading = false;
  String? _errorMessage;
  AdStatus? _statusFilter;
  Map<String, dynamic> _stats = {};

  // Getters
  List<AdminAdModel> get ads => _ads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  AdStatus? get statusFilter => _statusFilter;
  Map<String, dynamic> get stats => _stats;

  List<AdminAdModel> get filteredAds {
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
  int get totalSellers => _stats['totalSellers'] ?? 0;

  /// Load ads
  Future<void> loadAds({AdStatus? status}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _statusFilter = status;
      notifyListeners();

      log('📢 [ADMIN] Loading ads...');
      _ads = await _service.getAds(status: status);
      _stats = await _service.getAdStats();

      _errorMessage = null;
      log('✅ [ADMIN] Loaded ${_ads.length} ads');
    } catch (e) {
      log('❌ [ADMIN] Error loading ads: $e');
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

  /// Approve ad
  Future<bool> approveAd(String id, {String? note}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      log('📢 [ADMIN] Approving ad: $id');
      final approvedAd = await _service.approveAd(id, note: note);

      final index = _ads.indexWhere((ad) => ad.id == id);
      if (index != -1) {
        _ads[index] = approvedAd;
      }

      _stats = await _service.getAdStats();

      log('✅ [ADMIN] Ad approved successfully');
      return true;
    } catch (e) {
      log('❌ [ADMIN] Error approving ad: $e');
      _errorMessage = 'Failed to approve ad: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reject ad
  Future<bool> rejectAd(String id, {required String reason}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      log('📢 [ADMIN] Rejecting ad: $id');
      final rejectedAd = await _service.rejectAd(id, reason: reason);

      final index = _ads.indexWhere((ad) => ad.id == id);
      if (index != -1) {
        _ads[index] = rejectedAd;
      }

      _stats = await _service.getAdStats();

      log('✅ [ADMIN] Ad rejected successfully');
      return true;
    } catch (e) {
      log('❌ [ADMIN] Error rejecting ad: $e');
      _errorMessage = 'Failed to reject ad: $e';
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

      log('📢 [ADMIN] Updating ad: $id');
      final updatedAd = await _service.updateAd(id, updates);

      final index = _ads.indexWhere((ad) => ad.id == id);
      if (index != -1) {
        _ads[index] = updatedAd;
      }

      _stats = await _service.getAdStats();

      log('✅ [ADMIN] Ad updated successfully');
      return true;
    } catch (e) {
      log('❌ [ADMIN] Error updating ad: $e');
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

      log('📢 [ADMIN] Deleting ad: $id');
      final success = await _service.deleteAd(id);

      if (success) {
        _ads.removeWhere((ad) => ad.id == id);
        _stats = await _service.getAdStats();
        log('✅ [ADMIN] Ad deleted successfully');
      }

      return success;
    } catch (e) {
      log('❌ [ADMIN] Error deleting ad: $e');
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
