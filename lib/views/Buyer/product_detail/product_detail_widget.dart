import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/car_bottom_sheet.dart';
import 'package:wood_service/views/Buyer/product_detail/buy_now_bottom_sheet.dart';
import 'package:wood_service/views/Buyer/product_detail/seller_shop_info.dart';
import 'package:wood_service/widgets/custom_button.dart';

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
          product.title,
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
                fontSize: 16,
              ),
            ],
          ],
        ),

        if (product.hasDiscount)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        const SizedBox(height: 8),

        ShopPreviewCard(product: product),
      ],
    );
  }
}

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
    // Use context.watch to rebuild when quantity changes
    final cartViewModel = context.watch<BuyerCartViewModel>();
    final selectedQuantity = cartViewModel.selectedQuantity;
    final totalPrice = cartViewModel.getCurrentProductTotal(product);

    final maxQuantity = product.stockQuantity;

    // Calculate prices
    final double unitPrice = product.finalPrice;
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
                Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Available: $maxQuantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              "\$${unitPrice.toStringAsFixed(2)}",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  _buildButton(
                    context: context,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  _buildButton(
                    context: context,
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

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brightOrange.withOpacity(0.5),
                  // color: Theme.of(
                  //   context,
                  // ).colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total for $selectedQuantity item${selectedQuantity > 1 ? 's' : ''}:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
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
    required BuildContext context,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
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
            color: isEnabled
                ? Colors.transparent
                : colorScheme.surfaceContainerHighest,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ! *****
class ProductActionButtons extends StatefulWidget {
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
  State<ProductActionButtons> createState() => _ProductActionButtonsState();
}

class _ProductActionButtonsState extends State<ProductActionButtons> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedDate;
  String? _selectedTime;
  bool _isRequestingVisit = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('message ${widget.totalPrice}');

    // Check if product is Customize Product (handle both singular and plural)
    final productType = widget.product.productType ?? 'Ready Product';
    final isCustomizeProduct = productType.toLowerCase().contains('customize');

    log('🔍 Product Action Buttons Check:');
    log('   Product Type: $productType');
    log('   Is Customize Product: $isCustomizeProduct');
    log(
      '   Showing: ${isCustomizeProduct ? "Request Visit" : "Add to Cart + Buy Now"}',
    );

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: isCustomizeProduct
          ? _buildRequestVisitButton(context)
          : _buildCartButtons(context),
    );
  }

  Widget _buildRequestVisitButton(BuildContext context) {
    return CustomButtonUtils.login(
      height: 45,
      title: 'Request Visit',
      backgroundColor: AppColors.brightOrange,
      color: AppColors.white,
      borderRadius: 6,
      onPressed: () => _showVisitRequestDialog(context),
    );
  }

  Widget _buildCartButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inCart = widget.cartViewModel.isProductInCart(widget.product.id);
    return Row(
      children: [
        Expanded(
          child: CustomButtonUtils.login(
            height: 45,
            title: inCart ? 'Added to Cart' : 'Add to Cart',
            backgroundColor: inCart
                ? AppColors.brightOrange
                : colorScheme.primaryContainer,
            color: inCart
                ? colorScheme.onTertiary
                : colorScheme.onPrimaryContainer,
            borderRadius: 6,
            onPressed: () async {
              try {
                final productType =
                    widget.product.productType ?? 'Ready Product';

                log('🛒 Adding to cart with:');
                log('   Product ID: ${widget.product.id}');
                log('   Product Type: $productType');
                log('   Quantity: ${widget.selectedQuantity}');
                log('   Size: ${widget.selectedSize}');
                log('   Variant: ${widget.selectedVariant}');
                log('   Total Price: ${widget.totalPrice}');

                await widget.cartViewModel.addToCart(
                  serviceId: widget.product.id,
                  quantity: widget.selectedQuantity,
                  selectedSize: widget.selectedSize,
                  selectedVariant: widget.selectedVariant,
                  productType: productType,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (error) {
                log('❌ Add to cart error: $error');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add to cart: $error'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButtonUtils.login(
            height: 45,
            title: 'Buy Now',
            backgroundColor: AppColors.brightOrange,
            color: AppColors.white,

            borderRadius: 6,
            onPressed: () {
              showBuyNowBottomSheet(
                context,
                widget.product,
                widget.selectedQuantity,
                widget.selectedSize,
                widget.selectedVariant,
                widget.totalPrice ??
                    widget.product.finalPrice * widget.selectedQuantity,
              );
            },
          ),
        ),
      ],
    );
  }

  // Show Visit Request Dialog
  void _showVisitRequestDialog(BuildContext context) {
    final shopName =
        widget.product.sellerInfo?['businessName'] ?? 'Unknown Shop';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.schedule, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Request Shop Visit',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Request to visit: $shopName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Message field
                TextField(
                  // dark light mode
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Message (Optional)',
                    hintText: 'Tell the seller why you want to visit...',
                    border: OutlineInputBorder(),
                    // fillColor: AppColors.white,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    filled: true,
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Date picker
                ElevatedButton.icon(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: dialogContext,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (selectedDate != null && mounted) {
                      setState(() {
                        _selectedDate =
                            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate ?? 'Select Preferred Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: dialogContext,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null && mounted) {
                      setState(() {
                        _selectedTime =
                            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime ?? 'Select Preferred Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: _isRequestingVisit
                  ? null
                  : () => _requestVisit(context, dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightOrange,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isRequestingVisit
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }

  // Request Visit Function
  Future<void> _requestVisit(
    BuildContext context,
    BuildContext dialogContext,
  ) async {
    final serviceId = widget.product.id;
    final shopName =
        widget.product.sellerInfo?['businessName'] ?? 'Unknown Shop';

    if (serviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isRequestingVisit = true;
    });

    try {
      final viewModel = Provider.of<BuyerHomeViewProvider>(
        context,
        listen: false,
      );

      // Get description from message controller
      final description = _messageController.text.isNotEmpty
          ? _messageController.text
          : null;

      // Build address - API requires street, city, and country
      Map<String, dynamic> address = _buildAddressObject();

      final result = await viewModel.requestVisitToShop(
        serviceId: serviceId,
        shopName: shopName,
        description: description,
        address: address,
        preferredDate: _selectedDate,
        preferredTime: _selectedTime,
        context: context,
      );

      // Check if there's an existing request
      if (result['hasExistingRequest'] == true) {
        if (context.mounted) {
          Navigator.of(dialogContext).pop(); // Close form dialog
          _showExistingRequestDialog(context, shopName);
        }
        return;
      }

      // Close the dialog
      if (context.mounted) {
        Navigator.of(dialogContext).pop();
      }

      // Clear form
      _messageController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });

      // Success message is shown in requestVisitToShop
    } catch (error) {
      log('❌ Request visit error: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingVisit = false;
        });
      }
    }
  }

  // Build address object for API
  Map<String, dynamic> _buildAddressObject() {
    final sellerInfo = widget.product.sellerInfo;
    if (sellerInfo?['address'] != null && sellerInfo!['address'] is Map) {
      final sellerAddress = Map<String, dynamic>.from(sellerInfo['address']);
      return {
        'street': sellerAddress['street']?.toString() ?? 'Not specified',
        'city': sellerAddress['city']?.toString() ?? 'Not specified',
        'state': sellerAddress['state']?.toString(),
        'zipCode': sellerAddress['zipCode']?.toString(),
        'country': sellerAddress['country']?.toString() ?? 'Not specified',
      };
    }

    // Default address
    return {
      'street': 'Address to be confirmed',
      'city': 'To be specified',
      'state': null,
      'zipCode': null,
      'country': 'Pakistan',
    };
  }

  // Show existing request dialog
  void _showExistingRequestDialog(BuildContext context, String shopName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Existing Request Found'),
        content: Text(
          'You already have a pending visit request for $shopName.\n\n'
          'Would you like to cancel it first?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep It'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Please cancel the existing request first',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Cancel & Retry'),
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

void showBuyNowBottomSheet(
  BuildContext context,
  BuyerProductModel product,
  int quantity,
  String? selectedSize,
  String? selectedVariant,
  double totalPrice,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    builder: (context) => BuyNowBottomSheet(
      product: product,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedVariant: selectedVariant,
      totalPrice: totalPrice,
    ),
  );
}
