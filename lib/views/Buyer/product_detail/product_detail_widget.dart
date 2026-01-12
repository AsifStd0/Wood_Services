import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/car_bottom_sheet.dart';
import 'package:wood_service/views/Buyer/product_detail/seller_shop_info.dart';

import '../../../app/index.dart';

class ProductBasicInfo extends StatelessWidget {
  final BuyerProductModel product;

  const ProductBasicInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        CustomText(
          product.title, // Use actual title
          type: CustomTextType.headingMedium,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),

        const SizedBox(height: 3),

        // Price with discount
        Row(
          children: [
            CustomText(
              '${product.currency} ${product.finalPrice.toStringAsFixed(2)}', // Dynamic currency
              type: CustomTextType.headingMedium,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            if (product.hasDiscount) ...[
              const SizedBox(width: 10),
              CustomText(
                '${product.currency} ${product.basePrice.toStringAsFixed(2)}',
                type: CustomTextType.headingMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
                decoration: TextDecoration.lineThrough,
                fontSize: 16,
              ),
            ],
          ],
        ),

        // Discount percentage
        if (product.hasDiscount)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),

        const SizedBox(height: 8),

        ShopPreviewCard(product: product),
      ],
    );
  }
}

// ! ****

class SizeSelectionWidget extends StatelessWidget {
  final Function(String?) onSizeSelected;

  const SizeSelectionWidget({super.key, required this.onSizeSelected});

  @override
  Widget build(BuildContext context) {
    // Get selected size from Provider
    final selectedSize = context.select<BuyerCartViewModel, String?>(
      (viewModel) => viewModel.selectedSize,
    );

    final List<String> sizes = ['Small', 'Medium', 'Large'];
    final List<String> sizeDimensions = ['80x80cm', '120x120cm', '150x150cm'];

    // Find index of selected size
    int selectedIndex = sizes.indexWhere((size) => size == selectedSize);
    if (selectedIndex == -1) selectedIndex = 1; // Default to Medium

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              'Size',
              type: CustomTextType.buttonMedium,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            Text(
              sizeDimensions[selectedIndex],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < sizes.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _buildSizeOption(sizes[i], i == selectedIndex, i, onSizeSelected),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSizeOption(
    String size,
    bool isSelected,
    int index,
    Function(String?) onSizeSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onSizeSelected(size);
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                size,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ! *****

class MinimalQuantityStockWidget extends StatelessWidget {
  final BuyerProductModel product;
  final Function(int) onQuantityChanged;

  const MinimalQuantityStockWidget({
    super.key,
    required this.product,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.watch<BuyerCartViewModel>();
    final selectedQuantity = cartViewModel.selectedQuantity;
    final totalPrice = cartViewModel.getCurrentProductTotal(product);

    final maxQuantity = product.stockQuantity;

    // Calculate prices
    final double unitPrice = product.finalPrice;
    // final double subtotal = unitPrice * selectedQuantity;
    // final double taxAmount = (product.taxRate ?? 0) * subtotal / 100;
    // final double total = subtotal + taxAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity Selection Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Available: $maxQuantity',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            // Quantity Selector
            Spacer(),
            Text("\$${unitPrice.toStringAsFixed(2)}"),
            SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffF6DCC9),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  // Decrement
                  _buildButton(
                    icon: Icons.remove,
                    isEnabled: selectedQuantity > 1,
                    onTap: () {
                      onQuantityChanged(selectedQuantity - 1);
                    },
                    isLeft: true,
                  ),

                  // Quantity Display
                  SizedBox(
                    width: 40,
                    height: 36,
                    child: Center(
                      child: Text(
                        '$selectedQuantity',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Increment
                  _buildButton(
                    icon: Icons.add,
                    isEnabled: selectedQuantity < maxQuantity,
                    onTap: () {
                      onQuantityChanged(selectedQuantity + 1);
                    },
                    isLeft: false,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Price Breakdown
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              // Show total preview
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total for $selectedQuantity item${selectedQuantity > 1 ? 's' : ''}:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(25) : Radius.zero,
          right: !isLeft ? const Radius.circular(25) : Radius.zero,
        ),
        child: Container(
          width: 40,
          height: 36,
          decoration: BoxDecoration(
            color: isEnabled ? Colors.transparent : Colors.grey[200],
          ),
          child: Icon(
            icon,
            size: 18,
            color: isEnabled ? Colors.black : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

// ! *****
class ProductActionButtons extends StatelessWidget {
  final BuyerProductModel product;
  final BuyerCartViewModel cartViewModel;
  final int selectedQuantity;
  final String? selectedSize;
  final String? selectedVariant;
  final double? totalPrice;

  const ProductActionButtons({
    super.key,
    required this.product,
    required this.cartViewModel,
    required this.selectedQuantity,
    required this.selectedSize,
    required this.selectedVariant,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    log('message $totalPrice');
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          // Add to Cart Button
          Expanded(
            child: CustomButtonUtils.login(
              height: 45,
              // padding: EdgeInsets.all(0),
              title: cartViewModel.isProductInCart(product.id)
                  ? 'Added to Cart'
                  : 'Add to Cart',
              backgroundColor: cartViewModel.isProductInCart(product.id)
                  ? Colors.green
                  : AppColors.orangeLight,
              color: cartViewModel.isProductInCart(product.id)
                  ? Colors.white
                  : AppColors.brightOrange,
              borderRadius: 6,
              onPressed: () async {
                try {
                  log('🛒 Adding to cart with:');
                  log('   Product ID: ${product.id}');
                  log('   Quantity: $selectedQuantity');
                  log('   Size: $selectedSize');
                  log('   Variant: $selectedVariant ');
                  log('totalPrice. ');
                  log('message $totalPrice');

                  await cartViewModel.addToCart(
                    productId: product.id,
                    quantity: selectedQuantity,

                    selectedSize: '',
                    selectedVariant: '',
                    // Quantity, size, variant will be taken from viewModel's state
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add to cart: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButtonUtils.login(
              height: 45,
              // padding: EdgeInsets.all(0),
              title: 'Buy Now',
              backgroundColor: AppColors.brightOrange,
              borderRadius: 6,
              onPressed: () async {
                try {
                  showCartBottomSheet(
                    context,
                    selectedQuantity,
                    product,
                    totalPrice!,
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add to cart: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showCartBottomSheet(
  BuildContext context,
  int count,
  BuyerProductModel buyerProduct,
  double totalPrice,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    builder: (context) => CartBottomSheet(
      count: count,
      buyerProduct: buyerProduct,
      totalPrice: totalPrice,
    ),
  );
}
