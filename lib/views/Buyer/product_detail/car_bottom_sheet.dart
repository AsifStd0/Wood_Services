// Method to navigate to checkout
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/data/models/cart_Item.dart';
import 'package:wood_service/views/Buyer/payment/checkout.dart';

// Method to navigate to checkout
void showCheckoutScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
  );
}

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Cart Items
            Expanded(child: _buildCartItems()),

            // Footer with Total and Checkout
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Cart',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    final cartItems = [
      CartItem(
        name: 'Modern Sofa',
        seller: 'Home Decor',
        price: 500.00,
        quantity: 1,
      ),
      CartItem(
        name: 'Dining Table',
        seller: 'Furniture World',
        price: 650.00,
        quantity: 1,
      ),
      CartItem(
        name: 'Coffee Table',
        seller: 'Home Decor',
        price: 100.00,
        quantity: 1,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        return _buildCartItem(cartItems[index]);
      },
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chair, color: Colors.grey),
            ),

            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seller: ${item.seller}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 20, child: Center(child: Text('1'))),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subtotal
          _buildTotalRow('Subtotal', '\$1,250.00'),

          const SizedBox(height: 12),

          // Promo Code
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  hintText: 'Enter Promo Code',
                  fillcolor: AppColors.orangeLight,
                  onChanged: (value) {
                    print('Promo Code: $value');
                  },
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        print('Apply promo code');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brightOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Shipping
          _buildTotalRow('Estimated Shipping', '\$50.00'),

          const SizedBox(height: 12),

          // View Full Cart
          TextButton(
            onPressed: () {
              // Navigate to full cart screen
            },
            child: const Text('View Full Cart'),
          ),

          const SizedBox(height: 16),

          // Total
          _buildTotalRow('Total', '\$1,300.00', isTotal: true),

          const SizedBox(height: 16),

          // Proceed to Checkout Button
          // Proceed to Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close cart bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Security Note
          Text(
            'Secure payment. Free returns.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
