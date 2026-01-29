import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_requests_service.dart';

class VisitRequestsProvider with ChangeNotifier {
  final VisitRequestsService _service = locator<VisitRequestsService>();

  // Data
  List<Map<String, dynamic>> _visitRequests = [];
  List<Map<String, dynamic>> get visitRequests => _visitRequests;

  // Pagination
  Map<String, dynamic> _pagination = {};
  Map<String, dynamic> get pagination => _pagination;
  int get currentPage => _pagination['page'] ?? 1;
  int get totalPages => _pagination['pages'] ?? 1;
  int get totalRequests => _pagination['total'] ?? 0;
  bool get hasMore => currentPage < totalPages;

  // Status filter
  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  // Loading and error states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Status-specific lists
  List<Map<String, dynamic>> get pendingRequests => _visitRequests
      .where((req) => req['status']?.toString().toLowerCase() == 'pending')
      .toList();

  List<Map<String, dynamic>> get acceptedRequests => _visitRequests
      .where((req) => req['status']?.toString().toLowerCase() == 'accepted')
      .toList();

  List<Map<String, dynamic>> get rejectedRequests => _visitRequests
      .where((req) => req['status']?.toString().toLowerCase() == 'rejected')
      .toList();

  List<Map<String, dynamic>> get completedRequests => _visitRequests
      .where((req) => req['status']?.toString().toLowerCase() == 'completed')
      .toList();

  List<Map<String, dynamic>> get cancelledRequests => _visitRequests
      .where((req) => req['status']?.toString().toLowerCase() == 'cancelled')
      .toList();

  List<Map<String, dynamic>> get visitedRequests => _visitRequests
      .where((req) => req['status']?.toString().toLowerCase() == 'visited')
      .toList();

  // Counters
  int get pendingCount => pendingRequests.length;
  int get acceptedCount => acceptedRequests.length;
  int get rejectedCount => rejectedRequests.length;
  int get completedCount => completedRequests.length;
  int get cancelledCount => cancelledRequests.length;
  int get visitedCount => visitedRequests.length;

  /// Load visit requests
  Future<void> loadVisitRequests({String? status, bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    if (refresh) _visitRequests = [];
    notifyListeners();

    try {
      log('📋 Loading visit requests...');
      _statusFilter = status;

      final result = await _service.getVisitRequests(
        status: status,
        page: refresh ? 1 : currentPage,
        limit: 10,
      );

      if (result['success'] == true) {
        if (refresh) {
          _visitRequests = List<Map<String, dynamic>>.from(
            result['visitRequests'] ?? [],
          );
        } else {
          _visitRequests.addAll(
            List<Map<String, dynamic>>.from(result['visitRequests'] ?? []),
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

  /// Accept visit request with estimated cost
  Future<bool> acceptRequest({
    required String requestId,
    required double estimatedCost, // REQUIRED
    String? message,
  }) async {
    return await updateStatus(
      requestId: requestId,
      status: 'accepted',
      estimatedCost: estimatedCost,
      message: message,
    );
  }

  /// Reject visit request
  Future<bool> rejectRequest(String requestId, {String? message}) async {
    return await updateStatus(
      requestId: requestId,
      status: 'rejected',
      message: message,
    );
  }

  /// Complete visit request
  Future<bool> completeRequest(String requestId, {String? message}) async {
    return await updateStatus(
      requestId: requestId,
      status: 'completed',
      message: message,
    );
  }

  /// Cancel visit request
  Future<bool> cancelRequest(String requestId, {String? message}) async {
    return await updateStatus(
      requestId: requestId,
      status: 'cancelled',
      message: message,
    );
  }

  /// General status update method
  Future<bool> updateStatus({
    required String requestId,
    required String status,
    double? estimatedCost,
    String? message,
  }) async {
    try {
      log('🔄 Updating status to: $status for request: $requestId');

      // Find request locally
      final requestIndex = _visitRequests.indexWhere(
        (req) => req['_id']?.toString() == requestId,
      );

      if (requestIndex == -1) {
        _errorMessage = 'Request not found in local list';
        notifyListeners();
        return false;
      }

      final currentRequest = _visitRequests[requestIndex];
      final currentStatus =
          currentRequest['status']?.toString().toLowerCase() ?? 'pending';

      // Validate state transitions
      if (!_isValidStatusTransition(currentStatus, status)) {
        _errorMessage = 'Cannot change status from $currentStatus to $status';
        notifyListeners();
        return false;
      }

      // Call API
      final result = await _service.updateVisitRequestStatus(
        requestId: requestId,
        status: status,
        estimatedCost: estimatedCost,
        message: message,
      );

      if (result['success'] == true) {
        // Update local state
        _visitRequests[requestIndex]['status'] = status;

        // Update with full response if available
        if (result['visitRequest'] != null) {
          _visitRequests[requestIndex] = result['visitRequest'];
        }

        _errorMessage = null;
        notifyListeners();
        return true;
      }

      _errorMessage = result['message'] ?? 'Failed to update status';
      notifyListeners();
      return false;
    } catch (e) {
      log('❌ Error updating status: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Validate status transitions
  bool _isValidStatusTransition(String currentStatus, String newStatus) {
    final validTransitions = {
      'pending': ['accepted', 'rejected', 'cancelled'],
      'accepted': ['scheduled', 'cancelled', 'visited'],
      'scheduled': ['visited', 'cancelled'],
      'visited': ['completed', 'cancelled'],
      'completed': [], // Final state
      'rejected': [], // Final state
      'cancelled': [], // Final state
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
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
}
