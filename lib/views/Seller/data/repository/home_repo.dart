// lib/data/repositories/visit_repository.dart
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';

abstract class VisitRepository {
  Future<List<VisitRequest>> getVisitRequests();
  Future<void> updateVisitStatus(String visitId, VisitStatus status);
}

class MockVisitRepository implements VisitRepository {
  @override
  Future<List<VisitRequest>> getVisitRequests() async {
    // Mock data - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      VisitRequest(
        id: '1',
        address: '123 Main St',
        requestedDate: DateTime(2024, 1, 15),
        status: VisitStatus.pending,
      ),
      VisitRequest(
        id: '2',
        address: '456 Oak Ave',
        requestedDate: DateTime(2024, 1, 10),
        acceptedDate: DateTime(2024, 1, 10),
        status: VisitStatus.accepted,
      ),
      VisitRequest(
        id: '3',
        address: '789 Pine Ln',
        requestedDate: DateTime(2024, 1, 5),
        acceptedDate: DateTime(2024, 1, 5),
        status: VisitStatus.contractSent,
      ),
      VisitRequest(
        id: '4',
        address: '101 Elm Rd',
        requestedDate: DateTime(2023, 12, 20),
        acceptedDate: DateTime(2023, 12, 20),
        status: VisitStatus.contractActive,
      ),
    ];
  }

  @override
  Future<void> updateVisitStatus(String visitId, VisitStatus status) async {
    // Mock update - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 300));
    print('Updated visit $visitId to status: $status');
  }
}
