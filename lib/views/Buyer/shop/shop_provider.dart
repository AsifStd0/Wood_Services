// view_models/visits_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/data/models/shop.dart';
// view_models/shop_view_model.dart
import 'package:flutter/foundation.dart';

class ShopViewModel with ChangeNotifier {
  Shop _shop = Shop(
    name: "Crafty Creations",
    description: "Tell us about your shop...",
    rating: 4.8,
    reviewCount: 120,
    categories: ["Handmade Jewelry"],
    deliveryLeadTime: "1-3 Business Days",
    returnPolicy: "30-Day Returns",
    verificationStatus: VerificationStatus.pending,
  );

  Shop get shop => _shop;

  void updateShopDescription(String description) {
    _shop = _shop.copyWith(description: description);
    notifyListeners();
  }

  void updateCategories(List<String> categories) {
    _shop = _shop.copyWith(categories: categories);
    notifyListeners();
  }

  void uploadBanner() {
    // Implement banner upload logic
    notifyListeners();
  }

  void saveChanges() {
    // Implement save to backend
    notifyListeners();
  }
}

class VisitsViewModel with ChangeNotifier {
  List<Visit> _visits = [
    Visit(
      id: "1",
      address: "123 Main St",
      requestedDate: DateTime(2024, 1, 15),
      status: VisitStatus.pending,
      type: VisitType.delivery,
    ),
    Visit(
      id: "2",
      address: "33 Oak Ave",
      requestedDate: DateTime(2024, 1, 14),
      status: VisitStatus.accepted,
      type: VisitType.pickup,
    ),
  ];

  VisitStatus _selectedFilter = VisitStatus.pending;

  List<Visit> get visits => _visits;
  VisitStatus get selectedFilter => _selectedFilter;

  List<Visit> get filteredVisits {
    return _visits.where((visit) => visit.status == _selectedFilter).toList();
  }

  void setFilter(VisitStatus status) {
    _selectedFilter = status;
    notifyListeners();
  }

  void loadVisits() {
    // Implement API call to load visits
    notifyListeners();
  }
}

// Extension for copyWith method
extension ShopCopyWith on Shop {
  Shop copyWith({
    String? name,
    String? description,
    double? rating,
    int? reviewCount,
    List<String>? categories,
    String? deliveryLeadTime,
    String? returnPolicy,
    VerificationStatus? verificationStatus,
  }) {
    return Shop(
      name: name ?? this.name,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      categories: categories ?? this.categories,
      deliveryLeadTime: deliveryLeadTime ?? this.deliveryLeadTime,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}
