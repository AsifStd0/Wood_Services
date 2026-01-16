import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/payment/cart_data/cart_provider.dart';
import 'package:wood_service/views/Buyer/payment/rating/order_rating_screen.dart';

// class CartBottomSheet extends StatefulWidget {
//   final int count;
//   final BuyerProductModel buyerProduct;
//   final double totalPrice;

//   const CartBottomSheet({
//     super.key,
//     required this.count,
//     required this.buyerProduct,
//     required this.totalPrice,
//   });

//   @override
//   State<CartBottomSheet> createState() => _CartBottomSheetState();
// }

// class _CartBottomSheetState extends State<CartBottomSheet> {
//   // Calculate price breakdown
//   Map<String, double> get priceBreakdown {
//     final unitPrice = widget.buyerProduct.finalPrice;
//     final subtotal = unitPrice * widget.count;
//     final shippingFee = subtotal > 500 ? 0.0 : 49.99;
//     final tax = subtotal * 0.08; // 8% GST
//     final total = subtotal + shippingFee + tax;

//     return {
//       'unitPrice': unitPrice,
//       'subtotal': subtotal,
//       'shippingFee': shippingFee,
//       'tax': tax,
//       'total': total,
//     };
//   }

//   double get unitPrice => priceBreakdown['unitPrice']!;
//   double get subtotal => priceBreakdown['subtotal']!;
//   double get shippingFee => priceBreakdown['shippingFee']!;
//   double get tax => priceBreakdown['tax']!;
//   double get total => priceBreakdown['total']!;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.85,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             buildCartHeader(context),

//             // Cart Content
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     // Product Details
//                     _buildProductDetails(),

//                     // Quantity Controls
//                     _buildQuantityControls(),

//                     // Price Breakdown
//                     _buildPriceBreakdown(),
//                   ],
//                 ),
//               ),
//             ),

//             // Footer with Checkout Button
//             _buildFooter(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductDetails() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Product Image
//           Container(
//             height: 150,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.grey[100],
//             ),
//             child: widget.buyerProduct.featuredImage != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(
//                       widget.buyerProduct.featuredImage!,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Center(
//                           child: Icon(
//                             Icons.inventory_2_outlined,
//                             size: 60,
//                             color: Colors.grey[400],
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                 : Center(
//                     child: Icon(
//                       Icons.image_not_supported_outlined,
//                       size: 60,
//                       color: Colors.grey[400],
//                     ),
//                   ),
//           ),
//           const SizedBox(height: 16),

//           // Product Title
//           Text(
//             widget.buyerProduct.title,
//             style: const TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuantityControls() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.format_list_numbered, size: 20),
//               SizedBox(width: 8),
//               Text(
//                 'Quantity',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Quantity Display
//               Column(
//                 children: [
//                   Text(
//                     "${widget.count}",
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     '× ₹${unitPrice.toStringAsFixed(2)}',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),

//               // Subtotal
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'Subtotal',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                   Text(
//                     '₹${subtotal.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.bluePrimary,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceBreakdown() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Subtotal
//           _buildPriceRow(
//             'Subtotal',
//             '${widget.count} × ₹${unitPrice.toStringAsFixed(2)}',
//             '₹${subtotal.toStringAsFixed(2)}',
//           ),

//           const SizedBox(height: 8),

//           // Shipping Fee
//           _buildPriceRow(
//             'Shipping Fee',
//             shippingFee == 0
//                 ? 'Free shipping on orders above ₹500'
//                 : 'Standard delivery',
//             shippingFee == 0 ? 'FREE' : '₹${shippingFee.toStringAsFixed(2)}',
//           ),

//           const SizedBox(height: 8),

//           // Tax
//           _buildPriceRow(
//             'Tax (8%)',
//             'GST included',
//             '₹${tax.toStringAsFixed(2)}',
//           ),

//           const SizedBox(height: 12),
//           const Divider(height: 1, thickness: 2),

//           // Total
//           _buildPriceRow(
//             'Total Amount',
//             'Including all charges',
//             '₹${total.toStringAsFixed(2)}',
//             isTotal: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceRow(
//     String label,
//     String detail,
//     String amount, {
//     bool isTotal = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: isTotal ? 16 : 14,
//                   fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//                   color: isTotal ? Colors.black87 : Colors.grey[700],
//                 ),
//               ),
//               if (!isTotal && detail.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 2),
//                   child: Text(
//                     detail,
//                     style: TextStyle(fontSize: 11, color: Colors.grey[500]),
//                   ),
//                 ),
//             ],
//           ),
//           Text(
//             amount,
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
//               color: isTotal ? AppColors.bluePrimary : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFooter(BuildContext context) {
//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, child) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border(top: BorderSide(color: Colors.grey[200]!)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Total Preview
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Total:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     Text(
//                       '₹${total.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.bluePrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Checkout Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed:
//                       widget.buyerProduct.inStock &&
//                           widget.buyerProduct.stockQuantity >= widget.count
//                       ? () async {
//                           await _handleDirectBuy(context, cartProvider);
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         widget.buyerProduct.inStock &&
//                             widget.buyerProduct.stockQuantity >= widget.count
//                         ? AppColors.brightOrange
//                         : Colors.grey[400],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: cartProvider.isLoading
//                       ? SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         )
//                       : Text(
//                           widget.buyerProduct.inStock &&
//                                   widget.buyerProduct.stockQuantity >=
//                                       widget.count
//                               ? 'Buy Now - ₹${total.toStringAsFixed(2)}'
//                               : 'Out of Stock',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _handleDirectBuy(
//     BuildContext context,
//     CartProvider cartProvider,
//   ) async {
//     try {
//       final scaffoldMessenger = ScaffoldMessenger.of(context);

//       // Show price details
//       log('🛍️ [DIRECT BUY] Starting direct purchase...');
//       log('📊 Price Breakdown:');
//       log('  Unit Price: ₹${unitPrice.toStringAsFixed(2)}');
//       log('  Quantity: ${widget.count}');
//       log('  Subtotal: ₹${subtotal.toStringAsFixed(2)}');
//       log(
//         '  Shipping: ${shippingFee == 0 ? "FREE" : "₹${shippingFee.toStringAsFixed(2)}"}',
//       );
//       log('  Tax (8%): ₹${tax.toStringAsFixed(2)}');
//       log('  Total: ₹${total.toStringAsFixed(2)}');

//       // Call direct buy API
//       final result = await cartProvider.directBuy(
//         productId: widget.buyerProduct.id,
//         quantity: widget.count,
//         buyerNotes: 'Direct purchase from product page',
//         deliveryAddress: {
//           'street': '123 Main St',
//           'city': 'Your City',
//           'state': 'Your State',
//           'country': 'Your Country',
//           'postalCode': '12345',
//           'phone': '1234567890',
//         },
//         paymentMethod: 'cod',
//       );

//       scaffoldMessenger.hideCurrentSnackBar();

//       log('📥 Direct buy result: $result');

//       if (result['success'] == true) {
//         final order = result['order'];
//         final orderId = order?['orderId'];
//         final totalAmount = order?['totalAmount'];
//         final List<dynamic> orderItems = order?['items'] ?? [];

//         // Get the actual order item ID from the items array
//         String orderItemId = '';
//         if (orderItems.isNotEmpty) {
//           orderItemId =
//               orderItems[0]['itemId']?.toString() ??
//               orderItems[0]['_id']?.toString() ??
//               '${orderId}_ITEM_1';
//           log('✅ Found order item ID: $orderItemId');
//         }

//         if (orderId != null) {
//           // Show success message
//           scaffoldMessenger.showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   Icon(Icons.check_circle, color: Colors.white),
//                   SizedBox(width: 8),
//                   Text('Purchase successful! Order #$orderId'),
//                 ],
//               ),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 3),
//             ),
//           );

//           // Navigate to rating screen
//           await Future.delayed(Duration(milliseconds: 1500));
//           log('priceBreakdown. $priceBreakdown');
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (_) => OrderRatingScreen(
//                 orderId: orderId,
//                 orderItemId: orderItemId,
//                 items: [widget.buyerProduct.title],
//                 buyerProduct: widget.buyerProduct,
//                 cartItemId:
//                     'DIRECT_BUY_${DateTime.now().millisecondsSinceEpoch}',
//                 productId: widget.buyerProduct.id,
//                 quantity: widget.count,
//                 totalPrice: total,
//                 // priceBreakdown: priceBreakdown,
//               ),
//             ),
//           );
//         }
//       } else {
//         log('❌ Direct purchase failed: ${result['message']}');
//         scaffoldMessenger.showSnackBar(
//           SnackBar(
//             content: Text(result['message'] ?? 'Failed to complete purchase'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//       log('❌ Direct Buy Now error: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${error.toString()}'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Widget buildCartHeader(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             'Checkout',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close, size: 24),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }
// }
