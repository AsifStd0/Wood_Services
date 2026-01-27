import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/payment/rating/order_rating_screen.dart';
import 'package:wood_service/widgets/app_input_decoration.dart';

class BuyNowBottomSheet extends StatefulWidget {
  final BuyerProductModel product;
  final int quantity;
  final String? selectedSize;
  final String? selectedVariant;
  final double totalPrice;

  const BuyNowBottomSheet({
    super.key,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedVariant,
    required this.totalPrice,
  });

  @override
  State<BuyNowBottomSheet> createState() => _BuyNowBottomSheetState();
}

class _BuyNowBottomSheetState extends State<BuyNowBottomSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _estimatedDurationController =
      TextEditingController();
  final TextEditingController _specialRequirementsController =
      TextEditingController();
  String? _selectedDate;
  String? _paymentMethod = 'card';
  bool _useSalePrice = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _estimatedDurationController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  // Calculate price breakdown
  Map<String, double> get priceBreakdown {
    final unitPrice = _useSalePrice && widget.product.salePrice != null
        ? widget.product.salePrice!
        : widget.product.basePrice;
    final subtotal = unitPrice * widget.quantity;
    final tax = (widget.product.taxRate ?? 0) * subtotal / 100;
    final total = subtotal + tax;

    return {
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
    };
  }

  double get unitPrice => priceBreakdown['unitPrice']!;
  double get subtotal => priceBreakdown['subtotal']!;
  double get tax => priceBreakdown['tax']!;
  double get total => priceBreakdown['total']!;

  // Build selectedVariants array
  List<Map<String, String>> _buildSelectedVariants() {
    final variants = <Map<String, String>>[];
    if (widget.selectedSize != null && widget.selectedSize!.isNotEmpty) {
      variants.add({'type': 'size', 'value': widget.selectedSize!});
    }
    if (widget.selectedVariant != null && widget.selectedVariant!.isNotEmpty) {
      // Determine variant type based on context
      final variantType =
          widget.selectedVariant!.toLowerCase().contains('color')
          ? 'color'
          : widget.selectedVariant!.toLowerCase().contains('finish')
          ? 'finish'
          : 'variant';
      variants.add({'type': variantType, 'value': widget.selectedVariant!});
    }
    return variants;
  }

  // Build orderDetails map
  Map<String, dynamic>? _buildOrderDetails() {
    final details = <String, dynamic>{};

    if (_descriptionController.text.isNotEmpty) {
      details['description'] = _descriptionController.text;
    }
    if (_locationController.text.isNotEmpty) {
      details['location'] = _locationController.text;
    }

    // preferredDate is REQUIRED by backend - use selected date or default to tomorrow
    if (_selectedDate != null && _selectedDate!.isNotEmpty) {
      details['preferredDate'] = _selectedDate!;
    } else {
      // Default to tomorrow if not selected
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      details['preferredDate'] =
          '${tomorrow.year.toString().padLeft(4, '0')}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    }

    if (_estimatedDurationController.text.isNotEmpty) {
      details['estimatedDuration'] = _estimatedDurationController.text;
    }
    if (_specialRequirementsController.text.isNotEmpty) {
      details['specialRequirements'] = _specialRequirementsController.text;
    }

    return details.isEmpty ? null : details;
  }

  Future<void> _handlePlaceOrder() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cartViewModel = Provider.of<BuyerCartViewModel>(
        context,
        listen: false,
      );

      final selectedVariants = _buildSelectedVariants();
      final orderDetails = _buildOrderDetails();

      log('🛒 Placing order   111111...');
      log('   Service ID: ${widget.product.id}');
      log('   Quantity: ${widget.quantity}');
      log('   Use Sale Price: $_useSalePrice');
      log('   Payment Method: $_paymentMethod');
      log('   Selected Variants: $selectedVariants');
      log('   Order Details: $orderDetails');

      final result = await cartViewModel.buyNow(
        serviceId: widget.product.id,
        quantity: widget.quantity,
        useSalePrice: _useSalePrice,
        paymentMethod: _paymentMethod ?? 'card',
        selectedVariants: selectedVariants.isEmpty ? null : selectedVariants,
        orderDetails: orderDetails,
      );

      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
        log('asif khan afridi');
        if (result['success'] == true) {
          // Extract order ID from response
          final orderId = result['orderId'] ?? result['order']['_id'];
          log('✅ Order placed! ID: $orderId');
          log('message');
          log(' ---------- 1111111$orderId');

          if (orderId != null) {
            log(' ---------- $orderId');
            // Navigate to review screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderRatingScreen(
                  orderId: orderId,
                  orderItemId: orderId, // Using orderId as fallback
                  items: [widget.product.title],
                  buyerProduct: widget.product,
                  cartItemId: orderId,
                  productId: widget.product.id,
                  quantity: widget.quantity,
                  totalPrice: total.toDouble(),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order placed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(
              context,
              true,
            ); // Close bottom sheet and return to product
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to place order'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (error) {
      log('❌ Place order error: $error');
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Details
                    _buildProductDetails(),

                    const SizedBox(height: 20),

                    // Variants Summary
                    if (widget.selectedSize != null ||
                        widget.selectedVariant != null)
                      _buildVariantsSummary(),

                    const SizedBox(height: 20),

                    // Order Details Form
                    _buildOrderDetailsForm(),

                    const SizedBox(height: 20),

                    // Payment Options
                    _buildPaymentOptions(),

                    const SizedBox(height: 20),

                    // Price Breakdown
                    _buildPriceBreakdown(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Footer with Place Order Button
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text(
            'Place Order',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.product.featuredImage ??
                  widget.product.imageGallery.firstOrNull ??
                  'https://via.placeholder.com/80',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${widget.quantity}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${unitPrice.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Options',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (widget.selectedSize != null) Text('Size: ${widget.selectedSize}'),
          if (widget.selectedVariant != null)
            Text('Variant: ${widget.selectedVariant}'),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        CustomTextFormField(
          controller: _descriptionController,
          hintText: 'Describe your order requirements...',
          maxLines: 3,
          validator: (value) => value?.isEmpty == true ? 'Required' : null,
          prefixIcon: Icon(Icons.description),
          textInputType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          textAlign: TextAlign.start,
          minline: 3,
          fillcolor: Colors.white,
        ),

        const SizedBox(height: 12),

        CustomTextFormField(
          controller: _locationController,
          hintText: '123 Main St, New York, NY',
          prefixIcon: Icon(Icons.location_on),
          textInputType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.start,
          fillcolor: Colors.white,
        ),

        const SizedBox(height: 12),

        // Preferred Date
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: now.add(const Duration(days: 1)),
              firstDate: now,
              lastDate: now.add(const Duration(days: 365)),
            );
            if (selectedDate != null && mounted) {
              setState(() {
                _selectedDate =
                    '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
              });
            }
          },
          child: InputDecorator(
            decoration: AppInputDecoration.outlined(
              context: context,
              labelText: 'Preferred Date',
              hintText: 'Preferred Date',
            ),
            child: Text(
              _selectedDate ??
                  DateTime.now()
                      .add(const Duration(days: 1))
                      .toString()
                      .split(' ')[0],
              style: TextStyle(
                color: _selectedDate != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Estimated Duration
        CustomTextFormField(
          controller: _estimatedDurationController,
          hintText: 'e.g., 2 weeks, 1 month',
          prefixIcon: Icon(Icons.schedule),
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.start,
          fillcolor: Colors.white,
        ),

        const SizedBox(height: 12),

        CustomTextFormField(
          controller: _specialRequirementsController,
          hintText: 'Any special instructions or requirements...',
          maxLines: 2,
          prefixIcon: Icon(Icons.info),
          textInputType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          textAlign: TextAlign.start,
          fillcolor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Use Sale Price
        CheckboxListTile(
          title: const Text('Use Sale Price'),
          subtitle: Text(
            _useSalePrice && widget.product.salePrice != null
                ? 'Sale Price: \$${widget.product.salePrice!.toStringAsFixed(2)}'
                : 'Base Price: \$${widget.product.basePrice.toStringAsFixed(2)}',
          ),
          value: _useSalePrice,
          onChanged: widget.product.salePrice != null
              ? (value) {
                  setState(() {
                    _useSalePrice = value ?? false;
                  });
                }
              : null,
          activeColor: AppColors.brightOrange,
        ),

        const SizedBox(height: 8),

        // Payment Method
        const Text(
          'Payment Method:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Card'),
                value: 'card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value;
                  });
                },
                activeColor: AppColors.brightOrange,
              ),
            ),
            // Expanded(
            //   child: RadioListTile<String>(
            //     title: const Text('Cash on Delivery'),
            //     value: 'cod',
            //     groupValue: _paymentMethod,
            //     onChanged: (value) {
            //       setState(() {
            //         _paymentMethod = value;
            //       });
            //     },
            //     activeColor: AppColors.brightOrange,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Unit Price', '\$${unitPrice.toStringAsFixed(2)}'),
          _buildPriceRow('Quantity', '${widget.quantity}'),
          _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _buildPriceRow(
            'Tax (${widget.product.taxRate ?? 0}%)',
            '\$${tax.toStringAsFixed(2)}',
          ),
          const Divider(),
          _buildPriceRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.brown : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.brown : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Place Order Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  (_descriptionController.text.isNotEmpty &&
                      _locationController.text.isNotEmpty &&
                      !_isLoading)
                  ? _handlePlaceOrder
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
