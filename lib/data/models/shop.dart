// // models/shop_model.dart
// class Shop {
//   final String name;
//   final String description;
//   final double rating;
//   final int reviewCount;
//   final List<String> categories;
//   final String deliveryLeadTime;
//   final String returnPolicy;
//   final VerificationStatus verificationStatus;

//   Shop({
//     required this.name,
//     required this.description,
//     required this.rating,
//     required this.reviewCount,
//     required this.categories,
//     required this.deliveryLeadTime,
//     required this.returnPolicy,
//     required this.verificationStatus,
//   });
// }

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
