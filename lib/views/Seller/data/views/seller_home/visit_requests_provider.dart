// visit_requests_provider.dart
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_requests_service.dart';

class VisitRequestsProvider with ChangeNotifier {
  final VisitRequestsService _service = locator<VisitRequestsService>();

  // Visit requests data
  List<Map<String, dynamic>> _visitRequests = [];
  List<Map<String, dynamic>> get visitRequests => _visitRequests;

  // Pagination
  Map<String, dynamic> _pagination = {};
  Map<String, dynamic> get pagination => _pagination;
  int get currentPage => _pagination['page'] ?? 1;
  int get totalPages => _pagination['pages'] ?? 1;
  int get totalRequests => _pagination['total'] ?? 0;
  bool get hasMore => currentPage < totalPages;

  // Filter
  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  // Loading and error states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Getters for filtered lists
  List<Map<String, dynamic>> get pendingRequests {
    return _visitRequests
        .where((req) => req['status']?.toString().toLowerCase() == 'pending')
        .toList();
  }

  List<Map<String, dynamic>> get acceptedRequests {
    return _visitRequests
        .where((req) => req['status']?.toString().toLowerCase() == 'accepted')
        .toList();
  }

  List<Map<String, dynamic>> get rejectedRequests {
    return _visitRequests
        .where(
          (req) =>
              req['status']?.toString().toLowerCase() == 'rejected' ||
              req['status']?.toString().toLowerCase() == 'declined',
        )
        .toList();
  }

  List<Map<String, dynamic>> get completedRequests {
    return _visitRequests
        .where((req) => req['status']?.toString().toLowerCase() == 'completed')
        .toList();
  }

  int get pendingCount => pendingRequests.length;
  int get acceptedCount => acceptedRequests.length;
  int get rejectedCount => rejectedRequests.length;
  int get completedCount => completedRequests.length;

  // Add these counters
  int _pendingCount = 0;
  int _acceptedCount = 0;
  int _rejectedCount = 0;
  int _completedCount = 0;

  // Update the load method to calculate counts
  Future<void> loadVisitRequests({String? status, bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    if (refresh) {
      _visitRequests = [];
    }
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

        // 🔥 CALCULATE COUNTS HERE
        _calculateCounts();

        log('✅ Loaded ${_visitRequests.length} visit requests');
        _errorMessage = null;
      } else {
        throw Exception(result['message'] ?? 'Failed to load visit requests');
      }
    } catch (e) {
      log('❌ Error loading visit requests: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateCounts() {
    _pendingCount = _visitRequests
        .where((req) => req['status']?.toString().toLowerCase() == 'pending')
        .length;
    _acceptedCount = _visitRequests
        .where((req) => req['status']?.toString().toLowerCase() == 'accepted')
        .length;
    _rejectedCount = _visitRequests
        .where(
          (req) =>
              req['status']?.toString().toLowerCase() == 'rejected' ||
              req['status']?.toString().toLowerCase() == 'declined',
        )
        .length;
    _completedCount = _visitRequests
        .where((req) => req['status']?.toString().toLowerCase() == 'completed')
        .length;
  }

  // Also update when status changes
  Future<bool> updateStatus({
    required String requestId,
    required String status,
    String? message,
  }) async {
    try {
      log('🔄 Updating visit request status...');
      final result = await _service.updateVisitRequestStatus(
        requestId: requestId,
        status: status,
        message: message,
      );

      if (result['success'] == true) {
        // Update local state
        final index = _visitRequests.indexWhere(
          (req) => req['_id']?.toString() == requestId,
        );
        if (index != -1) {
          _visitRequests[index]['status'] = status;
          if (result['visitRequest'] != null) {
            _visitRequests[index] = result['visitRequest'];
          }
        }

        // 🔥 RECALCULATE COUNTS
        _calculateCounts();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      log('❌ Error updating status: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Accept visit request
  Future<bool> acceptRequest(String requestId, {String? message}) async {
    return await updateStatus(
      requestId: requestId,
      status: 'accepted',
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

  /// Refresh visit requests
  Future<void> refresh() async {
    await loadVisitRequests(status: _statusFilter, refresh: true);
  }
}
