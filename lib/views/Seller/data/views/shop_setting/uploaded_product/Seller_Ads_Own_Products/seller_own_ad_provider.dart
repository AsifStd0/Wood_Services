import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Seller_Ads_Own_Products/seller_own_ad_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Seller_Ads_Own_Products/seller_own_ad_service.dart';

/// Seller Own Ad Provider
/// Manages state for seller product ads
class SellerOwnAdProvider extends ChangeNotifier {
  final SellerOwnAdService _service;

  // State
  List<SellerOwnAdModel> _ads = [];
  bool _isLoading = false;
  String? _errorMessage;
  ProductAdStatus? _statusFilter;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalAds = 0;
  final int _limit = 10;
  bool _hasMore = true;

  // Getters
  List<SellerOwnAdModel> get ads => _ads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  ProductAdStatus? get statusFilter => _statusFilter;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalAds => _totalAds;
  bool get hasMore => _hasMore;
  bool get isEmpty => _ads.isEmpty && !_isLoading;

  List<SellerOwnAdModel> get filteredAds {
    if (_statusFilter == null) return _ads;
    return _ads.where((ad) => ad.status == _statusFilter).toList();
  }

  // Statistics
  int get pendingAds => _ads.where((ad) => ad.isPending).length;
  int get liveAds => _ads.where((ad) => ad.isActive).length;
  int get rejectedAds => _ads.where((ad) => ad.isRejected).length;
  int get completedAds => _ads.where((ad) => ad.isCompleted).length;

  SellerOwnAdProvider({SellerOwnAdService? service})
    : _service =
          service ??
          SellerOwnAdService(
            storage: locator<UnifiedLocalStorageServiceImpl>(),
          );

  /// Load ads
  Future<void> loadAds({ProductAdStatus? status, bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    _statusFilter = status;

    if (refresh) {
      _currentPage = 1;
      _ads.clear();
      _hasMore = true;
    }

    notifyListeners();

    try {
      log('📢 Loading seller ads (Page: $_currentPage, Status: $status)');

      // API only supports: pending, approved, rejected
      // For 'completed' status, we'll fetch all and filter client-side
      final apiStatus = (status == ProductAdStatus.completed) ? null : status;

      final result = await _service.getMyAds(
        page: _currentPage,
        limit: _limit,
        status: apiStatus,
      );

      if (result['success'] == true) {
        var newAds = result['ads'] as List<SellerOwnAdModel>;
        final pagination = result['pagination'] as Map<String, dynamic>;

        // Filter by 'completed' status client-side if needed
        if (status == ProductAdStatus.completed) {
          newAds = newAds
              .where((ad) => ad.status == ProductAdStatus.completed)
              .toList();
        }

        if (refresh) {
          _ads = newAds;
        } else {
          _ads.addAll(newAds);
        }

        _totalAds = pagination['total'] ?? 0;
        _totalPages = pagination['totalPages'] ?? 1;
        _currentPage = pagination['currentPage'] ?? 1;
        _hasMore = _currentPage < _totalPages;

        log('✅ Loaded ${_ads.length} ads (Total: $_totalAds)');
        _errorMessage = null;
      } else {
        throw Exception(result['message'] ?? 'Failed to load ads');
      }
    } catch (e) {
      log('❌ Error loading ads: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more ads (pagination)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _currentPage++;
    await loadAds(status: _statusFilter);
  }

  /// Refresh ads
  Future<void> refresh() async {
    await loadAds(status: _statusFilter, refresh: true);
  }

  /// Create ad for a product/service
  Future<Map<String, dynamic>> createAd({
    required String serviceId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      log('📢 Creating ad for service: $serviceId');

      final result = await _service.createAd(
        serviceId: serviceId,
        startDate: startDate,
        endDate: endDate,
      );

      if (result['success'] == true) {
        final newAd = result['ad'] as SellerOwnAdModel;
        _ads.insert(0, newAd);
        _totalAds++;
        log('✅ Ad created successfully');
        return {'success': true, 'message': result['message']};
      } else {
        throw Exception(result['message'] ?? 'Failed to create ad');
      }
    } catch (e) {
      log('❌ Error creating ad: $e');
      _errorMessage = e.toString();
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete ad
  Future<bool> deleteAd(String adId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      log('📢 Deleting ad: $adId');

      final success = await _service.deleteAd(adId);

      if (success) {
        _ads.removeWhere((ad) => ad.id == adId);
        _totalAds--;
        log('✅ Ad deleted successfully');
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to delete ad');
      }
    } catch (e) {
      log('❌ Error deleting ad: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by status
  Future<void> filterByStatus(ProductAdStatus? status) async {
    await loadAds(status: status, refresh: true);
  }

  /// Set status filter
  void setStatusFilter(ProductAdStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
