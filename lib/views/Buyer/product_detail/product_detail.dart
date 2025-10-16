import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/product_detail/product_detail_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // Main Content (Scrollable)
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                ProductDetailContent(),

                // Add extra space at bottom for floating buttons
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Floating Action Buttons positioned above content
          Positioned(
            bottom: 20, // Distance from bottom
            left: 16,
            right: 16,
            child: const ProductActionButtons(),
          ),
        ],
      ),
    );
  }
}

class ProductDetailContent extends StatelessWidget {
  const ProductDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Images with Slider & Thumbnails
        const ProductImageGallery(),

        const SizedBox(height: 24),

        // Product Basic Info
        const ProductBasicInfo(),

        const SizedBox(height: 16),

        // Seller Info
        const SellerInfoCard(),

        const SizedBox(height: 16),

        // Color Selection
        MinimalColorSelectionWidget(),

        // const ColorSelectionWidget(),
        const SizedBox(height: 10),

        // Size Selection
        SizeSelectionWidget(),

        const SizedBox(height: 16),

        // Quantity & Stock
        const MinimalQuantityStockWidget(),

        const SizedBox(height: 24),

        // Product Tabs
        const ProductTabsSection(),

        const SizedBox(height: 16),

        // Reviews Section
        const ReviewsPreviewSection(),

        const SizedBox(height: 24),

        // Related Products
        const RelatedProductsSection(),

        const SizedBox(height: 80), // Space for bottom buttons
      ],
    );
  }
}
