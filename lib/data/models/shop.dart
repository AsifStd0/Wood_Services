enum VerificationStatus { verified, pending, unverified }

// models/visit_model.dart
class Visit {
  final String id;
  final String address;
  final DateTime requestedDate;
  final VisitStatus status;
  final VisitType type;

  Visit({
    required this.id,
    required this.address,
    required this.requestedDate,
    required this.status,
    required this.type,
  });
}

enum VisitStatus { pending, accepted, active, cancelled, completed }

enum VisitType { delivery, pickup, inspection }
