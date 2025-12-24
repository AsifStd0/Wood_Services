import 'shop_model.dart';
import '../models/visit_request_model.dart';
import '../models/order_model.dart';

class ShopService {
  Future<ShopSeller> getShopData() async {
    await Future.delayed(const Duration(seconds: 1));

    return ShopSeller(
      name: 'Crafty Creations',
      description: 'Handmade goods',
      rating: 4.8,
      reviewCount: 120,
      categories: ['Handmade Jewelry'],
      deliveryLeadTime: '1-3 Business Days',
      returnPolicy: '30-Day Returns',
      isVerified: true,
    );
  }

  Future<void> updateShopData(ShopSeller shop) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<List<VisitRequest>> getVisitRequests() async {
    await Future.delayed(const Duration(seconds: 1));

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
    ];
  }

  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Order(
        id: '1',
        productName: 'Silver Necklace',
        customerName: 'John Doe',
        amount: 49.99,
        orderDate: DateTime(2024, 1, 12),
        status: OrderStatus.active,
      ),
      Order(
        id: '2',
        productName: 'Gold Bracelet',
        customerName: 'Jane Smith',
        amount: 89.99,
        orderDate: DateTime(2024, 1, 10),
        status: OrderStatus.completed,
      ),
    ];
  }

  Future<void> updateVisitRequestStatus(
    String requestId,
    VisitStatus status,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
