// lib/data/repositories/shop_repository.dart
import 'package:wood_service/views/Seller/data/models/seller_shop_model.dart';

abstract class ShopRepository {
  Future<SellerShopModel> getShopData();
  Future<void> updateShopData(SellerShopModel shop);
  Future<String> uploadBannerImage(String imagePath);
  Future<String> uploadDocument(String documentPath);
  Future<void> deleteDocument(String documentUrl);
}

class FirebaseShopRepository implements ShopRepository {
  @override
  Future<SellerShopModel> getShopData() async {
    // Implement Firebase call
    await Future.delayed(const Duration(seconds: 1));

    return SellerShopModel(
      id: 'shop_001',
      name: 'Premium Wood Crafts',
      description:
          'Specialized in handmade wooden furniture and crafts with 10+ years of experience.',
      bannerImageUrl: null,
      categories: ['Furniture', 'Handicrafts', 'Construction Wood'],
      deliveryLeadTime: '3-5 Business Days',
      returnPolicy: '14-Day Return Policy',
      isVerified: true,
      documents: [],
      contact: ShopContact(
        phone: '+1234567890',
        email: 'contact@premiumwood.com',
        address: '123 Woodcraft Street',
        city: 'Lumberton',
        state: 'Woodland',
        zipCode: '12345',
      ),
      settings: ShopSettings(
        receiveNotifications: true,
        emailMarketing: false,
        smsNotifications: true,
        lowStockAlerts: true,
        newOrderAlerts: true,
      ),
    );
  }

  @override
  Future<void> updateShopData(SellerShopModel shop) async {
    await Future.delayed(const Duration(seconds: 2));
    // Implement update logic
  }

  @override
  Future<String> uploadBannerImage(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/banner.jpg';
  }

  @override
  Future<String> uploadDocument(String documentPath) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/document.pdf';
  }

  @override
  Future<void> deleteDocument(String documentUrl) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
