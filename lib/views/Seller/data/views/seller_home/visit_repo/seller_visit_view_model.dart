// // view_models/seller_visit_view_model.dart
// import 'package:flutter/material.dart';
// import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/seller_visit_repository.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/seller_visit_request_model.dart';

// enum SellerVisitFilter { all, pending, accepted, declined, cancelled }

// class SellerVisitViewModel extends ChangeNotifier {
//   final SellerVisitRepository _repository;

//   SellerVisitViewModel(this._repository);

//   List<SellerVisitRequest> _visitRequests = [];
//   List<SellerVisitRequest> get visitRequests => _visitRequests;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _error = '';
//   String get error => _error;

//   SellerVisitFilter _currentFilter = SellerVisitFilter.all;
//   SellerVisitFilter get currentFilter => _currentFilter;

//   // Statistics
//   int get totalRequests => _visitRequests.length;
//   int get pendingRequests => _visitRequests.where((r) => r.isPending).length;
//   int get acceptedRequests => _visitRequests.where((r) => r.isAccepted).length;
//   int get declinedRequests => _visitRequests.where((r) => r.isDeclined).length;
//   int get cancelledRequests =>
//       _visitRequests.where((r) => r.isCancelled).length;

//   Future<void> loadVisitRequests({SellerVisitFilter? filter}) async {
//     try {
//       _isLoading = true;
//       _error = '';
//       notifyListeners();

//       // Map filter to status
//       String? status;
//       if (filter == SellerVisitFilter.pending) {
//         status = 'pending';
//       } else if (filter == SellerVisitFilter.accepted) {
//         status = 'accepted';
//       } else if (filter == SellerVisitFilter.declined) {
//         status = 'declined';
//       } else if (filter == SellerVisitFilter.cancelled) {
//         status = 'cancelled';
//       }

//       final data = await _repository.getVisitRequests(status: status);

//       _visitRequests = data;

//       // Sort by date (newest first)
//       _visitRequests.sort((a, b) => b.requestedDate.compareTo(a.requestedDate));
//     } catch (e) {
//       _error = 'Failed to load visit requests: $e';
//       print('❌ Load error: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void setFilter(SellerVisitFilter filter) {
//     _currentFilter = filter;
//     loadVisitRequests(filter: filter);
//   }

//   List<SellerVisitRequest> get filteredRequests {
//     switch (_currentFilter) {
//       case SellerVisitFilter.all:
//         return _visitRequests;
//       case SellerVisitFilter.pending:
//         return _visitRequests.where((r) => r.isPending).toList();
//       case SellerVisitFilter.accepted:
//         return _visitRequests.where((r) => r.isAccepted).toList();
//       case SellerVisitFilter.declined:
//         return _visitRequests.where((r) => r.isDeclined).toList();
//       case SellerVisitFilter.cancelled:
//         return _visitRequests.where((r) => r.isCancelled).toList();
//     }
//   }

//   Future<void> acceptRequest({
//     required String requestId,
//     required BuildContext context,
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

//       await _repository.acceptVisitRequest(
//         requestId: requestId,
//         message: message,
//         suggestedDate: suggestedDate,
//         suggestedTime: suggestedTime,
//         visitDate: visitDate,
//         visitTime: visitTime,
//         duration: duration,
//         location: location,
//       );

//       // Reload requests
//       await loadVisitRequests();

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Visit request accepted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> declineRequest({
//     required String requestId,
//     required BuildContext context,
//     String? message,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _repository.declineVisitRequest(
//         requestId: requestId,
//         message: message,
//       );

//       // Reload requests
//       await loadVisitRequests();

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Visit request declined'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> updateSettings({
//     required BuildContext context,
//     required bool acceptsVisits,
//     String? visitHours,
//     String? visitDays,
//     String? appointmentDuration,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _repository.updateVisitSettings(
//         acceptsVisits: acceptsVisits,
//         visitHours: visitHours,
//         visitDays: visitDays,
//         appointmentDuration: appointmentDuration,
//       );

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Visit settings updated'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
