import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/rating/order_rating_screen.dart';

class CartBottomSheet extends StatefulWidget {
  final int count;
  final BuyerProductModel buyerProduct;
  final double totalPrice;

  const CartBottomSheet({
    super.key,
    required this.count,
    required this.buyerProduct,
    required this.totalPrice,
  });

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
            buildCartHeader(context),

            // Cart Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Product Details
                    _buildProductDetails(),

                    // Quantity Controls
                    _buildQuantityControls(),

                    // Price Breakdown
                    _buildPriceBreakdown(widget.totalPrice),
                  ],
                ),
              ),
            ),

            // Footer with Checkout Button
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: widget.buyerProduct.featuredImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.buyerProduct.featuredImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Product Title
          Text(
            widget.buyerProduct.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.format_list_numbered, size: 20),
              SizedBox(width: 8),
              Text(
                'Quantity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity Display
              Column(
                children: [
                  Text(
                    "${widget.count}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '× \$${widget.buyerProduct.finalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(totalPrice) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shipping
          _buildPriceRow(
            'Shipping Fee',
            'Standart',
            // "${widget.buyerProduct.basePrice}",
            "5",
            // _shippingFee == 0 ? 'Free' : 'Standard',
            // _shippingFee == 0 ? 'Free' : '\$${_shippingFee.toStringAsFixed(2)}',
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 2),

          // Total
          _buildPriceRow(
            'Total Amount',
            'Including all charges',
            // '\$${widget.buyerProduct.finalPrice}',
            "\$$totalPrice",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String detail,
    String amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: isTotal ? Colors.black87 : Colors.grey[700],
                ),
              ),
              if (!isTotal && detail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    detail,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.bluePrimary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
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
              // Checkout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      widget.buyerProduct.inStock &&
                          widget.buyerProduct.stockQuantity >= widget.count
                      ? () async {
                          await _handleDirectBuy(context, cartProvider);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.buyerProduct.inStock &&
                            widget.buyerProduct.stockQuantity >= widget.count
                        ? AppColors.brightOrange
                        : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: cartProvider.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.buyerProduct.inStock &&
                                  widget.buyerProduct.stockQuantity >=
                                      widget.count
                              ? 'Buy Now'
                              : 'Out of Stock',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // In CartBottomSheet.dart - _handleDirectBuy method
  Future<void> _handleDirectBuy(
    BuildContext context,
    CartProvider cartProvider,
  ) async {
    try {
      // Show loading
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      log('🛍️ [DIRECT BUY] Starting direct purchase...');

      // Call direct buy API
      final result = await cartProvider.directBuy(
        productId: widget.buyerProduct.id,
        quantity: widget.count,
        buyerNotes: 'Direct purchase from product page',
        deliveryAddress: {
          'street': '123 Main St',
          'city': 'Your City',
          'state': 'Your State',
          'country': 'Your Country',
          'postalCode': '12345',
          'phone': '1234567890',
        },
        paymentMethod: 'cod',
      );

      // Hide loading snackbar
      scaffoldMessenger.hideCurrentSnackBar();

      log('📥 Direct buy result: $result');

      if (result['success'] == true) {
        final order = result['order'];
        final orderId = order?['orderId'];
        final totalAmount = order?['totalAmount'];

        // ✅ Get the actual order item ID from the items array
        String? orderItemId;
        if (order?['items'] != null && order['items'].isNotEmpty) {
          orderItemId = order['items'][0]['itemId']; // This is the correct ID
          log('✅ Found order item ID: $orderItemId');
        } else {
          orderItemId = '${orderId}_ITEM_1'; // Fallback
        }

        if (orderId != null) {
          log(
            ' Total Amount: \$$totalAmount ----   Order Item ID: $orderItemId ---  Order ID: $orderId ',
          );

          // Show success message
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Purchase successful! Order #$orderId'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to rating screen
          await Future.delayed(Duration(milliseconds: 500));

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderRatingScreen(
                orderId: orderId,
                orderItemId: orderItemId
                    .toString(), // ✅ Use actual order item ID
                items: [widget.buyerProduct.title],
                buyerProduct: widget.buyerProduct,
                cartItemId:
                    'DIRECT_BUY_${DateTime.now().millisecondsSinceEpoch}',
                productId: widget.buyerProduct.id,
                quantity: widget.count,
                totalPrice: widget.totalPrice,
              ),
            ),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Purchase completed but no order ID returned'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        log('❌ Direct purchase failed: ${result['message']}');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to complete purchase'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      log('❌ Direct Buy Now error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildCartHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Cart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
