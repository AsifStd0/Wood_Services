import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentIndex = 0; // Track selected payment method
  bool _agreeToTerms = false; // Track terms agreement

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      icon: Icons.credit_card,
      title: 'Credit/Debit Card',
      type: 'card',
    ),
    PaymentMethod(
      icon: Icons.account_balance,
      title: 'Mada/SADAD',
      type: 'mada',
    ),
    PaymentMethod(
      icon: Icons.phone_iphone,
      title: 'Apple Pay',
      type: 'apple_pay',
    ),
    PaymentMethod(icon: Icons.money, title: 'Cash on Delivery', type: 'cod'),
  ];

  void _selectPaymentMethod(int index) {
    setState(() {
      _selectedPaymentIndex = index;
    });
    print('Selected payment: ${_paymentMethods[index].title}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildOrderSummary(context),

            const SizedBox(height: 24),

            // Payment Method
            _buildPaymentMethod(),

            const SizedBox(height: 24),

            // Order Total
            _buildOrderTotal(),

            const SizedBox(height: 24),

            // Terms Agreement
            _buildTermsAgreement(),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, color: AppColors.grey, size: 15),
                Text(
                  'Secure Checkout.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Place Order Button
            _buildPlaceOrderButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('View Cart (2 items)'),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  // Navigate back to cart
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  contentPadding: const EdgeInsets.symmetric(
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
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Payment Options
        ..._paymentMethods.asMap().entries.map((entry) {
          final index = entry.key;
          final method = entry.value;
          return _buildPaymentOption(
            icon: method.icon,
            title: method.title,
            isSelected: _selectedPaymentIndex == index,
            onTap: () => _selectPaymentMethod(index),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.05)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.brightOrange : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.brightOrange : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.brightOrange : Colors.black,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.brightOrange,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTotal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Order Total',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _buildTotalRow('Subtotal', '\$249.98'),
          _buildTotalRow('Shipping', 'Free'),

          const Divider(height: 24),

          _buildTotalRow('Total', '\$249.98', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
      ),
    );
  }

  Widget _buildTermsAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: AppColors.brightOrange,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black, // Default text color
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'digital contract',
                  style: const TextStyle(
                    color: AppColors.brightOrange, // Different color
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showDigitalContract(context);
                    },
                ),
                const TextSpan(text: ' and terms of service.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDigitalContract(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Digital Contract'),
        content: const SingleChildScrollView(
          child: Text(
            'This is the digital contract content...\n\n'
            '1. Terms and conditions apply\n'
            '2. Return policy information\n'
            '3. Warranty details\n'
            '4. Privacy policy\n\n'
            'Please read carefully before proceeding.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _agreeToTerms
            ? () {
                // Process payment and place order
                _showOrderConfirmation(context);
              }
            : null, // Disable button if terms not agreed
        style: ElevatedButton.styleFrom(
          backgroundColor: _agreeToTerms ? AppColors.brightOrange : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Place Order',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _agreeToTerms ? Colors.white : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been placed successfully.'),
            const SizedBox(height: 8),
            Text(
              'Payment Method: ${_paymentMethods[_selectedPaymentIndex].title}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog

              // Navigate to order confirmation first
              context
                  .push(
                    // '/order_confirmation'
                    '/order_rating',
                  )
                  .then((_) {
                    // After order confirmation, show rating screen
                    context.push(
                      '/order_rating',
                      extra: {
                        'orderNumber': '12345678', // Pass actual order number
                        'items': [
                          'Modern Sofa',
                          'Coffee Table',
                          'Accent Chair',
                        ],
                      },
                    );
                  });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  // void _showOrderConfirmation(BuildContext context) {
  //   // Show order confirmation dialog or navigate to success screen
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Order Placed!'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text('Your order has been placed successfully.'),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Payment Method: ${_paymentMethods[_selectedPaymentIndex].title}',
  //             style: const TextStyle(
  //               fontWeight: FontWeight.bold,
  //               color: Colors.green,
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             context.push('/order_confirmation');

  //             // Navigator.popUntil(context, (route) => route.isFirst);
  //           },
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class PaymentMethod {
  final IconData icon;
  final String title;
  final String type;

  PaymentMethod({required this.icon, required this.title, required this.type});
}
