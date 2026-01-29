// provider/buyer_visit_request_provider.dart
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_request_model.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_services.dart';

class BuyerVisitRequestProvider with ChangeNotifier {
  final BuyerVisitRequestService _service;

  List<BuyerVisitRequest> _visitRequests = [];
  List<BuyerVisitRequest> get visitRequests => _visitRequests;

  // Pagination
  Map<String, dynamic> _pagination = {};
  Map<String, dynamic> get pagination => _pagination;
  int get currentPage => _pagination['page'] ?? 1;
  int get totalPages => _pagination['pages'] ?? 1;
  int get totalRequests => _pagination['total'] ?? 0;
  bool get hasMore => currentPage < totalPages;

  // Status filter
  BuyerVisitRequestStatus? _statusFilter;
  BuyerVisitRequestStatus? get statusFilter => _statusFilter;

  // Loading and error states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  BuyerVisitRequestProvider({BuyerVisitRequestService? service})
    : _service = service ?? locator<BuyerVisitRequestService>();

  // Status-specific lists
  List<BuyerVisitRequest> get pendingRequests => _visitRequests
      .where((req) => req.status == BuyerVisitRequestStatus.pending)
      .toList();

  List<BuyerVisitRequest> get acceptedRequests => _visitRequests
      .where((req) => req.status == BuyerVisitRequestStatus.accepted)
      .toList();

  List<BuyerVisitRequest> get rejectedRequests => _visitRequests
      .where(
        (req) =>
            req.status == BuyerVisitRequestStatus.rejected ||
            req.status == BuyerVisitRequestStatus.declined,
      )
      .toList();

  List<BuyerVisitRequest> get completedRequests => _visitRequests
      .where((req) => req.status == BuyerVisitRequestStatus.completed)
      .toList();

  List<BuyerVisitRequest> get cancelledRequests => _visitRequests
      .where((req) => req.status == BuyerVisitRequestStatus.cancelled)
      .toList();

  // Counters
  int get pendingCount => pendingRequests.length;
  int get acceptedCount => acceptedRequests.length;
  int get rejectedCount => rejectedRequests.length;
  int get completedCount => completedRequests.length;
  int get cancelledCount => cancelledRequests.length;
  int get totalCount => _visitRequests.length;

  /// Load visit requests
  Future<void> loadVisitRequests({
    BuyerVisitRequestStatus? status,
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    if (refresh) _visitRequests = [];
    notifyListeners();

    try {
      log('📋 Loading buyer visit requests...');
      _statusFilter = status;

      String? statusParam;
      if (status != null) {
        statusParam = status.toString().split('.').last;
      }

      final result = await _service.getBuyerVisitRequests(
        status: statusParam,
        page: refresh ? 1 : currentPage,
        limit: 10,
      );

      if (result['success'] == true) {
        if (refresh) {
          _visitRequests = List<BuyerVisitRequest>.from(
            result['visitRequests'] ?? [],
          );
        } else {
          _visitRequests.addAll(
            List<BuyerVisitRequest>.from(result['visitRequests'] ?? []),
          );
        }
        _pagination = Map<String, dynamic>.from(result['pagination'] ?? {});
        _errorMessage = null;
        log('✅ Loaded ${_visitRequests.length} visit requests');
      } else {
        throw Exception('Failed to load visit requests');
      }
    } catch (e) {
      log('❌ Error loading visit requests: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel visit request
  Future<bool> cancelVisitRequest(String requestId) async {
    try {
      log(
        '------ buyer visit request provider ❌ Cancelling visit request: $requestId',
      );

      // Optimistically update UI
      final requestIndex = _visitRequests.indexWhere(
        (req) => req.id == requestId,
      );
      if (requestIndex != -1) {
        final originalRequest = _visitRequests[requestIndex];
        _visitRequests[requestIndex] = BuyerVisitRequest(
          id: originalRequest.id,
          buyerId: originalRequest.buyerId,
          sellerInfo: originalRequest.sellerInfo,
          serviceInfo: originalRequest.serviceInfo,
          requestDetails: originalRequest.requestDetails,
          timeline: originalRequest.timeline,
          estimatedCost: originalRequest.estimatedCost,
          actualCost: originalRequest.actualCost,
          status: BuyerVisitRequestStatus.cancelled,
          images: originalRequest.images,
          notes: originalRequest.notes,
          createdAt: originalRequest.createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      // Call API
      final success = await _service.cancelVisitRequest(requestId);

      if (!success && requestIndex != -1) {
        // Revert if API call failed
        await loadVisitRequests(status: _statusFilter, refresh: true);
      }

      return success;
    } catch (e) {
      log('❌ Error cancelling visit request: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Refresh visit requests
  Future<void> refresh() async {
    await loadVisitRequests(status: _statusFilter, refresh: true);
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get filtered requests by status
  List<BuyerVisitRequest> getFilteredRequests(BuyerVisitRequestStatus status) {
    return _visitRequests.where((req) => req.status == status).toList();
  }
}
