import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
import 'package:wood_service/views/Seller/data/repository/home_repo.dart';

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

  // State management for filter
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVisitStatus(String visitId, VisitStatus newStatus) async {
    try {
      await _repository.updateVisitStatus(visitId, newStatus);
      await loadVisitRequests(); // Reload to get updated data
    } catch (e) {
      _errorMessage = 'Failed to update visit status: $e';
      notifyListeners();
    }
  }

  List<VisitRequest> get filteredVisits {
    return _visitRequests.where((visit) {
      switch (_currentFilter) {
        case VisitFilter.active:
          return visit.status != VisitStatus.completed &&
              visit.status != VisitStatus.cancelled;
        case VisitFilter.cancelled:
          return visit.status == VisitStatus.cancelled;
        case VisitFilter.completed:
          return visit.status == VisitStatus.completed;
      }
    }).toList();
  }
}

enum VisitFilter { active, cancelled, completed }
