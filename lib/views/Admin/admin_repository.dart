// repositories/admin_repository.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/views/Admin/admin_model.dart';

abstract class AdminRepository {
  Future<AdminStats> getDashboardStats();
  Future<List<UserModel>> getSellers({String? filter});
  Future<List<UserModel>> getBuyers({String? filter});
  Future<List<OrderModel>> getAllOrders({String? status});
  Future<List<ProductModel>> getAllProducts({String? category});
  Future<List<VerificationRequest>> getVerificationRequests();
  Future<void> updateVerificationStatus(
    String requestId,
    VerificationStatus status, {
    String? reason,
  });
  Future<List<PlatformEarning>> getPlatformEarnings(
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> updateUserStatus(String userId, bool isActive);
  Future<void> updateProductStatus(String productId, bool isActive);
  Future<Map<String, dynamic>> getAnalyticsData();
  Future<void> approveProduct(String productId);
  Future<void> rejectProduct(String productId, String reason);
}

class MockAdminRepository implements AdminRepository {
  @override
  Future<AdminStats> getDashboardStats() async {
    await Future.delayed(const Duration(seconds: 1));
    return AdminStats(
      totalSellers: 156,
      totalBuyers: 2347,
      totalProducts: 892,
      totalOrders: 543,
      totalRevenue: 125430.50,
      pendingVerifications: 23,
      activeDisputes: 8,
      // pendingOrders: 45,
      // completedOrders: 387,
    );
  }

  @override
  Future<List<UserModel>> getSellers({String? filter}) async {
    await Future.delayed(const Duration(seconds: 1));

    final sellers = [
      UserModel(
        id: 'seller_1',
        email: 'john@woodcraft.com',
        name: 'John Woodcraft',
        phone: '+1234567890',
        role: UserRole.seller,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        isVerified: true,
        isActive: true,
        businessName: 'John Furniture',
        address: '123 Wood Street, Craftville',
      ),
      UserModel(
        id: 'seller_2',
        email: 'sarah@carpentry.com',
        name: 'Sarah Johnson',
        phone: '+1234567891',
        role: UserRole.seller,
        createdAt: DateTime.now().subtract(const Duration(days: 85)),
        isVerified: true,
        isActive: true,
        businessName: 'Sarah Wood Works',
        address: '456 Oak Avenue, Timberland',
      ),
      UserModel(
        id: 'seller_3',
        email: 'mike@furniture.com',
        name: 'Mike Wilson',
        phone: '+1234567892',
        role: UserRole.seller,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        isVerified: false,
        isActive: true,
        businessName: 'Mike Custom Furniture',
        address: '789 Pine Road, Forest City',
      ),
    ];

    if (filter == 'verified') {
      return sellers.where((seller) => seller.isVerified).toList();
    } else if (filter == 'unverified') {
      return sellers.where((seller) => !seller.isVerified).toList();
    }

    return sellers;
  }

  @override
  Future<List<UserModel>> getBuyers({String? filter}) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      UserModel(
        id: 'buyer_1',
        email: 'emily@example.com',
        name: 'Emily Davis',
        phone: '+1234567893',
        role: UserRole.buyer,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        isVerified: true,
        isActive: true,
        address: '321 Customer Street, Buyerville',
      ),
      UserModel(
        id: 'buyer_2',
        email: 'robert@example.com',
        name: 'Robert Brown',
        phone: '+1234567894',
        role: UserRole.buyer,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        isVerified: true,
        isActive: true,
        address: '654 Shopper Avenue, Purchase City',
      ),
    ];
  }

  @override
  Future<List<OrderModel>> getAllOrders({String? status}) async {
    await Future.delayed(const Duration(seconds: 1));

    final orders = [
      OrderModel(
        id: 'order_1',
        orderNumber: 'ORD-12345',
        buyerId: 'buyer_1',
        buyerName: 'Emily Davis',
        sellerId: 'seller_1',
        sellerName: 'John Woodcraft',
        items: [
          OrderItem(
            productId: 'prod_1',
            productName: 'Oak Dining Table',
            quantity: 1,
            price: 1200.00,
          ),
        ],
        totalAmount: 1200.00,
        status: OrderStatus.delivered,
        paymentStatus: PaymentStatus.completed,
        shippingAddress: '321 Customer Street, Buyerville',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        deliveryDate: DateTime.now().subtract(const Duration(days: 2)),
        platformCommission: 60.00,
      ),
      OrderModel(
        id: 'order_2',
        orderNumber: 'ORD-12346',
        buyerId: 'buyer_2',
        buyerName: 'Robert Brown',
        sellerId: 'seller_2',
        sellerName: 'Sarah Johnson',
        items: [
          OrderItem(
            productId: 'prod_2',
            productName: 'Teak Wood Chair',
            quantity: 4,
            price: 250.00,
          ),
        ],
        totalAmount: 1000.00,
        status: OrderStatus.processing,
        paymentStatus: PaymentStatus.completed,
        shippingAddress: '654 Shopper Avenue, Purchase City',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        platformCommission: 50.00,
      ),
    ];

    if (status != null) {
      final orderStatus = OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status.toLowerCase(),
        orElse: () => OrderStatus.pending,
      );
      return orders.where((order) => order.status == orderStatus).toList();
    }

    return orders;
  }

  @override
  Future<List<ProductModel>> getAllProducts({String? category}) async {
    await Future.delayed(const Duration(seconds: 1));

    final products = [
      ProductModel(
        id: 'prod_1',
        sellerId: 'seller_1',
        sellerName: 'John Woodcraft',
        name: 'Premium Oak Dining Table',
        description: 'Handcrafted solid oak dining table with exquisite finish',
        category: 'Furniture',
        price: 1200.00,
        originalPrice: 1500.00,
        stock: 5,
        images: [],
        rating: 4.8,
        totalReviews: 23,
        isActive: true,
        isApproved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        woodType: 'Oak',
        dimensions: '180cm x 90cm x 75cm',
        material: 'Solid Oak Wood',
      ),
      ProductModel(
        id: 'prod_2',
        sellerId: 'seller_2',
        sellerName: 'Sarah Johnson',
        name: 'Teak Wood Dining Chairs (Set of 4)',
        description: 'Elegant teak wood chairs with comfortable cushioning',
        category: 'Furniture',
        price: 1000.00,
        stock: 10,
        images: [],
        rating: 4.6,
        totalReviews: 15,
        isActive: true,
        isApproved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        woodType: 'Teak',
        dimensions: '45cm x 45cm x 85cm',
        material: 'Solid Teak Wood',
      ),
    ];

    if (category != null) {
      return products
          .where(
            (product) =>
                product.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }

    return products;
  }

  @override
  Future<List<VerificationRequest>> getVerificationRequests() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      VerificationRequest(
        id: 'v1',
        sellerId: 'seller_3',
        sellerName: 'Mike Wilson',
        businessName: 'Mike Custom Furniture',
        documents: [
          'business_license.pdf',
          'tax_certificate.pdf',
          'identity_proof.pdf',
        ],
        status: VerificationStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      VerificationRequest(
        id: 'v2',
        sellerId: 'seller_4',
        sellerName: 'Lisa Thompson',
        businessName: 'Lisa Wood Arts',
        documents: ['business_registration.pdf', 'bank_statement.pdf'],
        status: VerificationStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  @override
  Future<void> updateVerificationStatus(
    String requestId,
    VerificationStatus status, {
    String? reason,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // In real implementation, update the verification status in database
    if (kDebugMode) {
      print('Verification $requestId updated to $status');
    }
  }

  @override
  Future<List<PlatformEarning>> getPlatformEarnings(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      PlatformEarning(
        id: 'earn_1',
        orderId: 'ORD-12345',
        orderAmount: 1200.00,
        commissionRate: 5.0,
        commissionAmount: 60.00,
        earningDate: DateTime.now().subtract(const Duration(days: 5)),
        sellerId: 'seller_1',
        sellerName: 'John Woodcraft',
      ),
      PlatformEarning(
        id: 'earn_2',
        orderId: 'ORD-12346',
        orderAmount: 1000.00,
        commissionRate: 5.0,
        commissionAmount: 50.00,
        earningDate: DateTime.now().subtract(const Duration(days: 1)),
        sellerId: 'seller_2',
        sellerName: 'Sarah Johnson',
      ),
    ];
  }

  @override
  Future<void> updateUserStatus(String userId, bool isActive) async {
    await Future.delayed(const Duration(seconds: 1));
    // In real implementation, update user status in database
    if (kDebugMode) {
      print(
        'User $userId status updated to ${isActive ? 'Active' : 'Inactive'}',
      );
    }
  }

  @override
  Future<void> updateProductStatus(String productId, bool isActive) async {
    await Future.delayed(const Duration(seconds: 1));
    // In real implementation, update product status in database
    if (kDebugMode) {
      print(
        'Product $productId status updated to ${isActive ? 'Active' : 'Inactive'}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getAnalyticsData() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'revenue_trend': [1200, 1800, 1500, 2000, 2500, 3000, 2800],
      'user_growth': [100, 150, 200, 280, 350, 420, 500],
      'top_categories': [
        'Furniture',
        'Flooring',
        'Decorative',
        'Doors & Windows',
      ],
      'category_revenue': [65000, 35000, 15000, 8000],
    };
  }

  @override
  Future<void> approveProduct(String productId) async {
    await Future.delayed(const Duration(seconds: 1));
    if (kDebugMode) {
      print('Product $productId approved');
    }
  }

  @override
  Future<void> rejectProduct(String productId, String reason) async {
    await Future.delayed(const Duration(seconds: 1));
    if (kDebugMode) {
      print('Product $productId rejected: $reason');
    }
  }
}
