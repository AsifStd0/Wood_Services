import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/rating/order_rating_screen.dart';
import 'package:wood_service/widgets/custom_widget.dart';

// CartServices
// CartProvider
class CartBottomSheet extends StatefulWidget {
  final int count;
  final BuyerProductModel buyerProduct;

  CartBottomSheet({Key? key, required this.count, required this.buyerProduct})
    : super(key: key);

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
                    _buildPriceBreakdown(),
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
          const SizedBox(height: 8),

          // Seller Info
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Seller: ${widget.buyerProduct.sellerName}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                    // _currentQuantity.toString(),
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

  Widget _buildPriceBreakdown() {
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
            '\$${widget.buyerProduct.finalPrice}',
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

  // Update your CartBottomSheet's _buildFooter method:
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
                  // Replace the onPressed in your ElevatedButton:
                  onPressed:
                      widget.buyerProduct.inStock &&
                          widget.buyerProduct.stockQuantity > 0
                      ? () async {
                          // 1. Add to cart first
                          final cartResult = await cartProvider.addToCart(
                            productId: widget.buyerProduct.id,
                            quantity: widget.count,
                            selectedVariant: '',
                            selectedSize: '',
                          );

                          if (cartResult['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(cartResult['message']),
                                backgroundColor: Colors.green,
                              ),
                            );

                            final cartItemData =
                                cartResult['data']?['cartItem'];
                            final cartItemId = cartItemData?['_id'];

                            // 2. IMMEDIATELY request buy to create order
                            final requestResult = await cartProvider.requestBuy(
                              itemIds: [cartItemId], // ✅ CORRECT parameter name
                              buyerNotes: 'Quick purchase for rating',
                              deliveryAddress: json.encode({
                                'street': 'Test Street',
                                'city': 'Test City',
                                'state': 'Test State',
                                'country': 'Test Country',
                                'postalCode': '12345',
                              }),
                              paymentMethod: 'cod',
                            );

                            if (requestResult['success'] == true) {
                              // Get the orderId from the response
                              final orders = requestResult['orders'] ?? [];
                              if (orders.isNotEmpty) {
                                final orderId = orders[0]['orderId'];

                                // Get order item ID from the order details
                                String orderItemId = '${orderId}_ITEM';

                                // Optionally fetch order details to get actual orderItemId
                                try {
                                  final orderDetails = await cartProvider
                                      .getRequestDetails(orderId);
                                  if (orderDetails['success'] == true &&
                                      orderDetails['request']?['items'] !=
                                          null &&
                                      orderDetails['request']['items']
                                          .isNotEmpty) {
                                    orderItemId =
                                        orderDetails['request']['items'][0]['_id'] ??
                                        orderItemId;
                                  }
                                } catch (e) {
                                  log('⚠️ Could not fetch order details: $e');
                                }

                                log(
                                  '📦 Order created: $orderId.  📦 Order item ID: $orderItemId',
                                );

                                // Navigate to rating screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OrderRatingScreen(
                                      orderId: orderId, // ORDER ITEM ID
                                      orderItemId: orderItemId,
                                      items: [widget.buyerProduct.title],
                                      buyerProduct: widget.buyerProduct,
                                      cartItemId: cartItemId,
                                      productId: widget.buyerProduct.id,
                                      quantity: widget.count,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to create order - no order ID returned',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(requestResult['message']),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(cartResult['message']),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.buyerProduct.inStock &&
                            widget.buyerProduct.stockQuantity > 0
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
                                  widget.buyerProduct.stockQuantity > 0
                              ? 'Add to Cart & Checkout'
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
}
