import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/widgets/app_input_decoration.dart';

class CartCheckoutBottomSheet extends StatefulWidget {
  const CartCheckoutBottomSheet({super.key});

  @override
  State<CartCheckoutBottomSheet> createState() =>
      _CartCheckoutBottomSheetState();
}

class _CartCheckoutBottomSheetState extends State<CartCheckoutBottomSheet> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _specialRequirementsController = TextEditingController();

  String? _selectedDate;
  String _paymentMethod = 'card';
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _estimatedDurationController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _buildOrderDetails() {
    final details = <String, dynamic>{};

    if (_descriptionController.text.trim().isNotEmpty) {
      details['description'] = _descriptionController.text.trim();
    }
    if (_locationController.text.trim().isNotEmpty) {
      details['location'] = _locationController.text.trim();
    }

    // preferredDate is REQUIRED by backend - use selected date or default to tomorrow
    if (_selectedDate != null && _selectedDate!.trim().isNotEmpty) {
      details['preferredDate'] = _selectedDate!.trim();
    } else {
      // Default to tomorrow if not selected
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      details['preferredDate'] =
          '${tomorrow.year.toString().padLeft(4, '0')}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    }

    if (_estimatedDurationController.text.trim().isNotEmpty) {
      details['estimatedDuration'] = _estimatedDurationController.text.trim();
    }
    if (_specialRequirementsController.text.trim().isNotEmpty) {
      details['specialRequirements'] = _specialRequirementsController.text
          .trim();
    }

    return details.isEmpty ? null : details;
  }

  Future<void> _pickPreferredDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _handleCheckout() async {
    if (_isLoading) return;
    if (_descriptionController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill description and location'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cartViewModel = Provider.of<BuyerCartViewModel>(
        context,
        listen: false,
      );
      final orderDetails = _buildOrderDetails();

      log('🧾 Cart checkout...');
      log('   Items: ${cartViewModel.cartItems.length}');
      log('   Payment: $_paymentMethod');
      log('   OrderDetails: $orderDetails');

      final result = await cartViewModel.checkoutCart(
        paymentMethod: _paymentMethod,
        orderDetails: orderDetails,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final ok = result['success'] == true;
      final msg =
          (result['message'] ??
                  (ok ? 'Checkout successful' : 'Checkout failed'))
              .toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: ok ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      if (ok) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + bottomInset,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Text(
                'Order Details',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              CustomTextFormField(
                controller: _descriptionController,
                hintText: 'Description ',
                prefixIcon: Icon(Icons.description),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                minline: 2,
                maxLines: 4,
              ),

              const SizedBox(height: 10),
              CustomTextFormField(
                controller: _locationController,
                hintText: 'Location ',
                prefixIcon: Icon(Icons.location_on),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 10),

              InkWell(
                onTap: _isLoading ? null : _pickPreferredDate,
                child: InputDecorator(
                  decoration: AppInputDecoration.outlined(
                    context: context,
                    labelText: 'Preferred Date',
                    hintText: 'Preferred Date',
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate ??
                              DateTime.now()
                                  .add(const Duration(days: 1))
                                  .toString()
                                  .split(' ')[0],
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // TextField(
              //   controller: _estimatedDurationController,
              //   textInputAction: TextInputAction.next,
              //   decoration: const InputDecoration(
              //     labelText: 'Estimated Duration (optional)',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              CustomTextFormField(
                controller: _estimatedDurationController,
                hintText: 'Estimated Duration (optional)',
                prefixIcon: Icon(Icons.schedule),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                minline: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: _specialRequirementsController,
                hintText: 'Special Requirements (optional)',
                prefixIcon: Icon(Icons.info),
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                minline: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: const [
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                  // DropdownMenuItem(value: 'cod', child: Text('Cash on Delivery')),
                  // DropdownMenuItem(value: 'mada', child: Text('Mada/SADAD')),
                  // DropdownMenuItem(value: 'apple_pay', child: Text('Apple Pay')),
                ],
                onChanged: _isLoading
                    ? null
                    : (v) => setState(() => _paymentMethod = v ?? 'card'),
                decoration: AppInputDecoration.outlined(
                  context: context,
                  labelText: 'Payment Method',
                  hintText: 'Payment Method',
                ),
              ),

              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      (_descriptionController.text.trim().isNotEmpty &&
                          _locationController.text.trim().isNotEmpty &&
                          !_isLoading)
                      ? _handleCheckout
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
