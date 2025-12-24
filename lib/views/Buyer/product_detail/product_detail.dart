import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/product_detail/product_detail_second_widget.dart';
import 'package:wood_service/views/Buyer/product_detail/product_detail_widget.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

import '../../../app/index.dart';

class ProductDetailScreen extends StatelessWidget {
  final BuyerProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Get cartViewModel from Provider
    final cartViewModel = Provider.of<BuyerCartViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Product Details'),
      body: Stack(
        children: [
          /// MAIN CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Images
                const ProductImageGallery(),
                const SizedBox(height: 14),

                /// Basic Info
                ProductBasicInfo(product: product),
                const SizedBox(height: 16),

                /// Size - Use Provider to update
                SizeSelectionWidget(
                  onSizeSelected: (size) {
                    cartViewModel.updateSize(size);
                  },
                ),
                const SizedBox(height: 16),

                /// Quantity & Stock - Use Provider to update
                MinimalQuantityStockWidget(
                  product: product,
                  onQuantityChanged: (quantity) {
                    cartViewModel.updateQuantity(quantity);
                  },
                ),
                const SizedBox(height: 24),

                /// Tabs
                ProductTabsSection(product: product),
                const SizedBox(height: 16),

                /// Reviews
                const ReviewsPreviewSection(),

                /// Space for bottom buttons
                const SizedBox(height: 50),
              ],
            ),
          ),

          /// BOTTOM ACTION BUTTONS - Get values from Provider
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Consumer<BuyerCartViewModel>(
              builder: (context, cartViewModel, child) {
                return ProductActionButtons(
                  product: product,
                  cartViewModel: cartViewModel,
                  selectedQuantity: cartViewModel.selectedQuantity,
                  selectedSize: cartViewModel.selectedSize,
                  selectedVariant: cartViewModel.selectedVariant,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
