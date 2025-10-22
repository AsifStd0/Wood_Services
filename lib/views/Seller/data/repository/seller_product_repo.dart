// lib/repositories/product_repository.dart
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product.dart';

abstract class ProductRepository {
  Future<void> saveProduct(SellerProduct product);
  Future<List<SellerProduct>> getProducts();
  Future<SellerProduct?> getProduct(String id);
  Future<void> deleteProduct(String id);
}

class MockProductRepository implements ProductRepository {
  final List<SellerProduct> _products = [];

  @override
  Future<void> saveProduct(SellerProduct product) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call

    if (product.id == null) {
      // New product
      final newProduct = product.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      _products.add(newProduct);
    } else {
      // Update existing product
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      } else {
        _products.add(product);
      }
    }
  }

  @override
  Future<List<SellerProduct>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_products);
  }

  @override
  Future<SellerProduct?> getProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _products.firstWhere((product) => product.id == id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _products.removeWhere((product) => product.id == id);
  }
}
