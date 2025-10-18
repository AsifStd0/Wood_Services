// lib/domain/models/shop_model.dart
class SellerShopModel {
  final String id;
  final String name;
  final String description;
  final String? bannerImageUrl;
  final List<String> categories;
  final String deliveryLeadTime;
  final String returnPolicy;
  final bool isVerified;
  final List<String> documents;
  final ShopContact contact;
  final ShopSettings settings;

  SellerShopModel({
    required this.id,
    required this.name,
    required this.description,
    this.bannerImageUrl,
    required this.categories,
    required this.deliveryLeadTime,
    required this.returnPolicy,
    required this.isVerified,
    required this.documents,
    required this.contact,
    required this.settings,
  });

  SellerShopModel copyWith({
    String? name,
    String? description,
    String? bannerImageUrl,
    List<String>? categories,
    String? deliveryLeadTime,
    String? returnPolicy,
    List<String>? documents,
    ShopContact? contact,
    ShopSettings? settings,
  }) {
    return SellerShopModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      categories: categories ?? this.categories,
      deliveryLeadTime: deliveryLeadTime ?? this.deliveryLeadTime,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      isVerified: isVerified,
      documents: documents ?? this.documents,
      contact: contact ?? this.contact,
      settings: settings ?? this.settings,
    );
  }
}

class ShopContact {
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String zipCode;

  ShopContact({
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
  });
}

class ShopSettings {
  final bool receiveNotifications;
  final bool emailMarketing;
  final bool smsNotifications;
  final bool lowStockAlerts;
  final bool newOrderAlerts;

  ShopSettings({
    required this.receiveNotifications,
    required this.emailMarketing,
    required this.smsNotifications,
    required this.lowStockAlerts,
    required this.newOrderAlerts,
  });
}
