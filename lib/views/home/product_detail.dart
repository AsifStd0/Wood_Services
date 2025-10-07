import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/data/models/product_feature.dart';
import 'package:wood_service/views/home/home_widgets.dart';

// Assuming you have this data source somewhere

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // Fetch product details based on productId
    final product = AppData.featuredProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => AppData.featuredProducts.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareProduct(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () => _toggleFavorite(context, product),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Product Image
              Center(child: Image.asset(product.image, height: 240)),

              const SizedBox(height: 16),

              // Color variants
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: product.availableColors
                    .map(
                      (color) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ColorOption(color: color),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Product Title + Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),

              const SizedBox(height: 24),

              // Key Features
              const Text(
                'Key features',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...product.keyFeatures
                  .map((feature) => FeaturePoint(text: feature))
                  .toList(),

              const SizedBox(height: 24),

              // Add to cart button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addToCart(context, product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recommendations
              const SectionHeader(
                title: 'Recommendation',
                actionText: 'view all',
              ),
              const SizedBox(height: 12),
              ProductsHorizontalList(
                products: AppData.featuredProducts,
                onProductTap: (productId) {
                  context.push('/productDetail/$productId');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareProduct(BuildContext context) {
    // Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product shared!')));
  }

  void _toggleFavorite(BuildContext context, Product product) {
    // Implement favorite functionality with the actual product
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to favorites!')),
    );
  }

  void _addToCart(BuildContext context, Product product) {
    // Implement add to cart functionality with the actual product
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.name} added to cart!')));
  }
}
