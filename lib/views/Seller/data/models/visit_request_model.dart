// lib/domain/models/visit_request.dart
class VisitRequest {
  final String id;
  final String address;
  final DateTime requestedDate;
  final VisitStatus status;
  final DateTime? acceptedDate;

  VisitRequest({
    required this.id,
    required this.address,
    required this.requestedDate,
    required this.status,
    this.acceptedDate,
  });

  String get statusText {
    switch (status) {
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.accepted:
        return 'Accepted';
      case VisitStatus.contractSent:
        return 'Contract Sent';
      case VisitStatus.contractActive:
        return 'Contract Active';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get formattedRequestedDate {
    return 'Requested on ${_formatDate(requestedDate)}';
  }

  String get formattedAcceptedDate {
    return acceptedDate != null
        ? 'Accepted on ${_formatDate(acceptedDate!)}'
        : '';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

enum VisitStatus {
  pending,
  accepted,
  contractSent,
  contractActive,
  completed,
  cancelled,
}
