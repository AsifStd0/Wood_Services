// // view_models/visit_requests_view_model.dart
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';

// enum VisitFilter { all, pending, accepted, cancelled, completed }

// class VisitRequestsViewModel with ChangeNotifier {
//   final VisitRepository
//   _visitService; // Use VisitService instead of VisitRepository

//   VisitRequestsViewModel(this._visitService);

//   List<VisitRequest> _visitRequests = [];
//   List<VisitRequest> get visitRequests => _visitRequests;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _errorMessage = '';
//   String get errorMessage => _errorMessage;
//   bool get hasError => _errorMessage.isNotEmpty;

//   VisitFilter _currentFilter = VisitFilter.all;
//   VisitFilter get currentFilter => _currentFilter;

//   void setFilter(VisitFilter filter) {
//     _currentFilter = filter;
//     notifyListeners();
//   }

//   Future<void> loadVisitRequests() async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       // Load all visit requests
//       _visitRequests = await _visitService.getVisitRequests();
//       // Sort by date (newest first)
//       _visitRequests.sort((a, b) => b.requestedDate.compareTo(a.requestedDate));
//     } catch (e) {
//       _errorMessage = 'Failed to load visit requests: $e';
//       print('❌ Error loading visit requests: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> updateVisitStatus(
//     String requestId,
//     VisitStatus newStatus,
//   ) async {
//     try {
//       await _visitService.updateVisitStatus(requestId, newStatus);
//       await loadVisitRequests(); // Reload to get updated data
//     } catch (e) {
//       _errorMessage = 'Failed to update visit status: $e';
//       notifyListeners();
//       rethrow;
//     }
//   }

//   Future<void> declineVisitRequest({
//     required String requestId,
//     String? message,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _visitService.declineVisitRequest(
//         requestId: requestId,
//         message: message,
//       );

//       await loadVisitRequests();
//     } catch (e) {
//       _errorMessage = 'Failed to decline request: $e';
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // VisitRequestsViewModel class
//   Future<void> acceptVisitRequest({
//     required String requestId,
//     String? message,
//     String? suggestedDate,
//     String? suggestedTime,
//     String? visitDate,
//     String? visitTime,
//     String? duration,
//     String? location,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _visitService.acceptVisitRequest(
//         requestId: requestId,
//         message: message,
//         suggestedDate: suggestedDate,
//         suggestedTime: suggestedTime,
//         visitDate: visitDate,
//         visitTime: visitTime,
//         duration: duration,
//         location: location,
//       );

//       // Refresh the list after accepting
//       await loadVisitRequests();
//     } catch (e) {
//       _errorMessage = 'Failed to accept request: $e';
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> cancelVisitRequest(String requestId) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       // You might need to adjust this based on your API
//       await _visitService.updateVisitStatus(requestId, VisitStatus.cancelled);

//       // Refresh the list after cancelling
//       await loadVisitRequests();
//     } catch (e) {
//       _errorMessage = 'Failed to cancel request: $e';
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> completeVisitRequest(String requestId) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _visitService.updateVisitStatus(requestId, VisitStatus.completed);

//       // Refresh the list after completing
//       await loadVisitRequests();
//     } catch (e) {
//       _errorMessage = 'Failed to complete request: $e';
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Get filtered visits based on current filter
//   List<VisitRequest> get filteredVisits {
//     return _visitRequests.where((visit) {
//       switch (_currentFilter) {
//         case VisitFilter.all:
//           return true;
//         case VisitFilter.pending:
//           return visit.isPending;
//         case VisitFilter.accepted:
//           return visit.isAccepted;
//         case VisitFilter.cancelled:
//           return visit.isCancelled || visit.isRejected;
//         case VisitFilter.completed:
//           return visit.isCompleted;
//       }
//     }).toList();
//   }

//   // Statistics getters
//   int get totalVisits => _visitRequests.length;

//   int get pendingVisits =>
//       _visitRequests.where((visit) => visit.isPending).length;

//   int get acceptedVisits =>
//       _visitRequests.where((visit) => visit.isAccepted).length;

//   int get cancelledVisits => _visitRequests
//       .where((visit) => visit.isCancelled || visit.isRejected)
//       .length;

//   int get completedVisits =>
//       _visitRequests.where((visit) => visit.isCompleted).length;

//   int get activeVisits => pendingVisits + acceptedVisits;
// }
