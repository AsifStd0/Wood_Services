// view_models/visit_requests_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
import 'package:wood_service/views/Seller/data/repository/home_repo.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_repository.dart';

enum VisitFilter { active, cancelled, completed }

class VisitRequestsViewModel with ChangeNotifier {
  final VisitRepository _repository;

  VisitRequestsViewModel(this._repository);

  List<VisitRequest> _visitRequests = [];
  List<VisitRequest> get visitRequests => _visitRequests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  VisitFilter _currentFilter = VisitFilter.active;
  VisitFilter get currentFilter => _currentFilter;

  void setFilter(VisitFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadVisitRequests() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _visitRequests = await _repository.getVisitRequests();
    } catch (e) {
      _errorMessage = 'Failed to load visit requests: $e';
      print('Error loading visit requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVisitStatus(String orderId, VisitStatus newStatus) async {
    try {
      await _repository.updateVisitStatus(orderId, newStatus);
      await loadVisitRequests(); // Reload to get updated data
    } catch (e) {
      _errorMessage = 'Failed to update visit status: $e';
      notifyListeners();
      rethrow;
    }
  }

  List<VisitRequest> get filteredVisits {
    return _visitRequests.where((visit) {
      switch (_currentFilter) {
        case VisitFilter.active:
          return visit.status != VisitStatus.completed &&
              visit.status != VisitStatus.cancelled &&
              visit.status != VisitStatus.rejected;
        case VisitFilter.cancelled:
          return visit.status == VisitStatus.cancelled ||
              visit.status == VisitStatus.rejected;
        case VisitFilter.completed:
          return visit.status == VisitStatus.completed;
      }
    }).toList();
  }

  int get totalVisits => _visitRequests.length;

  int get pendingVisits => _visitRequests
      .where((visit) => visit.status == VisitStatus.pending)
      .length;

  int get acceptedVisits => _visitRequests
      .where((visit) => visit.status == VisitStatus.accepted)
      .length;
}
