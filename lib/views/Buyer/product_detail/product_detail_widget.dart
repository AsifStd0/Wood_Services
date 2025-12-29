import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/car_bottom_sheet.dart';

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

        // Rating from seller
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.brightOrange,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  CustomText(
                    '4.5',
                    type: CustomTextType.buttonMedium,
                    color: AppColors.brightOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            CustomText(
              '0 reviews', // Real review count
              type: CustomTextType.buttonMedium,
              color: AppColors.grey,
            ),
          ],
        ),
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

    final List<String> _sizes = ['Small', 'Medium', 'Large'];
    final List<String> _sizeDimensions = ['80x80cm', '120x120cm', '150x150cm'];

    // Find index of selected size
    int selectedIndex = _sizes.indexWhere((size) => size == selectedSize);
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
              _sizeDimensions[selectedIndex],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < _sizes.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _buildSizeOption(
                _sizes[i],
                i == selectedIndex,
                i,
                onSizeSelected,
              ),
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
    // Get selected quantity from Provider
    final selectedQuantity = context.select<BuyerCartViewModel, int>(
      (viewModel) => viewModel.selectedQuantity,
    );

    final maxQuantity = product.stockQuantity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Quantity',
              type: CustomTextType.buttonMedium,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),

        // Quantity Selector
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
              Container(
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
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled ? null : Colors.transparent,
          borderRadius: isLeft
              ? const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.black : Colors.grey[400],
          size: 18,
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

  const ProductActionButtons({
    super.key,
    required this.product,
    required this.cartViewModel,
    required this.selectedQuantity,
    required this.selectedSize,
    required this.selectedVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          // Add to Cart Button
          Expanded(
            child: CustomButtonUtils.login(
              height: 45,
              padding: EdgeInsets.all(0),
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
                  log('   Variant: $selectedVariant');

                  await cartViewModel.addToCart(
                    productId: product.id,
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
              padding: EdgeInsets.all(0),
              title: 'Buy Now',
              backgroundColor: AppColors.brightOrange,
              borderRadius: 6,
              onPressed: () async {
                try {
                  showCartBottomSheet(context, selectedQuantity, product);
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

class ProductTabsSection extends StatefulWidget {
  final BuyerProductModel product;

  const ProductTabsSection({super.key, required this.product});

  @override
  State<ProductTabsSection> createState() => _ProductTabsSectionState();
}

class _ProductTabsSectionState extends State<ProductTabsSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // Get selected variant from Provider
    final selectedVariant = context.select<BuyerCartViewModel, String?>(
      (viewModel) => viewModel.selectedVariant,
    );

    final cartViewModel = Provider.of<BuyerCartViewModel>(
      context,
      listen: false,
    );

    return Column(
      children: [
        // Tab Headers
        Row(
          children: [
            _buildTab('Description', 0),
            _buildTab('Specifications', 1),
            _buildTab('Variants', 2),
          ],
        ),
        const SizedBox(height: 16),

        // Tab Content with REAL DATA
        _buildTabContent(cartViewModel, selectedVariant),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: _selectedTab == index
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _selectedTab == index ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuyerCartViewModel cartViewModel,
    String? selectedVariant,
  ) {
    switch (_selectedTab) {
      case 2: // Variants
        if (widget.product.variants.isEmpty) {
          return const Text('No variants available');
        }

        return Column(
          children: widget.product.variants.map((variant) {
            final isSelected = selectedVariant == variant.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (bool? selected) {
                    cartViewModel.updateVariant(
                      selected == true ? variant.value : null,
                    );
                  },
                ),
                title: Text('${variant.type}: ${variant.name}'),
                subtitle: Text(
                  variant.priceAdjustment > 0
                      ? '+ \$${variant.priceAdjustment.toStringAsFixed(2)}'
                      : 'No extra charge',
                ),
                trailing: Text(
                  variant.priceAdjustment > 0
                      ? '+ \$${variant.priceAdjustment.toStringAsFixed(2)}'
                      : '',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  cartViewModel.updateVariant(
                    isSelected ? null : variant.value,
                  );
                },
              ),
            );
          }).toList(),
        );

      default:
        return const SizedBox();
    }
  }
}

class ReviewsPreviewSection extends StatelessWidget {
  const ReviewsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews (120)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all reviews
              },
              child: const Text('View All Reviews'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Review 1
        const ReviewItem(
          name: 'Sophia Bennett',
          rating: 5,
          comment:
              'Absolutely love this sofa! It\'s incredibly comfortable and looks fantastic in my living room. The quality is top-notch.',
        ),

        const SizedBox(height: 16),

        // Review 2
        const ReviewItem(
          name: 'Ethan Carter',
          rating: 5,
          comment:
              'Great sofa for the price. It\'s stylish and comfortable, although the cushions could be a bit firmer. Overall, very satisfied.',
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;

  const ReviewItem({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 8),

          // Stars
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                color: index < rating ? Colors.amber : Colors.grey[300],
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(comment, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}

void showCartBottomSheet(
  BuildContext context,
  int count,
  BuyerProductModel buyerProduct,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    builder: (context) =>
        CartBottomSheet(count: count, buyerProduct: buyerProduct),
  );
}
