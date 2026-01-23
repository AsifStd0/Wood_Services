// import 'package:flutter/material.dart';
// import 'package:wood_service/core/theme/app_colors.dart';
// import 'package:wood_service/core/theme/app_test_style.dart';
// import 'package:wood_service/data/models/order.dart';
// import 'package:wood_service/widgets/custom_button.dart';

// class OrderConfirmationScreen extends StatelessWidget {
//   final Order order = Order(
//     orderNumber: '12345678',
//     items: [
//       OrderItem(
//         name: 'Modern Sofa',
//         quantity: 1,
//         price: 299.00,
//         seller: 'Furnishings Co.',
//       ),
//       OrderItem(
//         name: 'Coffee Table',
//         quantity: 1,
//         price: 149.00,
//         seller: 'Furnishings Co.',
//       ),
//       OrderItem(
//         name: 'Accent Chair',
//         quantity: 1,
//         price: 99.00,
//         seller: 'Furnishings Co.',
//       ),
//     ],
//     subtotal: 547.00,
//     shipping: 20.00,
//     tax: 43.76,
//     total: 610.76,
//     deliveryDate: 'Oct 20',
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
//           child: Column(
//             children: [
//               // Header Section
//               _buildHeaderSection(context),
//               SizedBox(height: 32),

//               // Success Message
//               _buildSuccessMessage(),
//               SizedBox(height: 32),

//               // Order Summary Card
//               _buildOrderSummaryCard(),
//               SizedBox(height: 24),

//               // Download Invoice Button
//               _buildDownloadInvoiceButton(context),
//               SizedBox(height: 24),
//               CustomButtonUtils.login(
//                 title: 'Track Order',
//                 backgroundColor: AppColors.brightOrange,
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection(context) {
//     return Row(
//       children: [
//         IconButton(
//           onPressed: () {
//             // Navigate back
//             Navigator.pop(context); // ✅ Go back to previous screen
//           },
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//         ),
//         SizedBox(width: 8),
//         Text(
//           'Order Confirmation',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSuccessMessage() {
//     return Column(
//       children: [
//         Icon(Icons.check_circle, color: AppColors.brightOrange, size: 80),
//         SizedBox(height: 16),
//         Text(
//           'Order Placed!',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           'Your order #${order.orderNumber} has been placed successfully.',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey.shade600,
//             height: 1.4,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildOrderSummaryCard() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Order Summary',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           SizedBox(height: 16),

//           // Order Items
//           Column(
//             children: order.items.map((item) => _buildOrderItem(item)).toList(),
//           ),
//           SizedBox(height: 16),

//           Divider(color: Colors.grey.shade300),
//           SizedBox(height: 16),

//           // Pricing Breakdown
//           _buildPricingRow(
//             'Subtotal',
//             '\$${order.subtotal.toStringAsFixed(2)}',
//           ),
//           SizedBox(height: 8),
//           _buildPricingRow(
//             'Shipping',
//             '\$${order.shipping.toStringAsFixed(2)}',
//           ),
//           SizedBox(height: 8),
//           _buildPricingRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
//           SizedBox(height: 12),

//           Divider(color: Colors.grey.shade300),
//           SizedBox(height: 12),

//           // Total
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Total',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               Text(
//                 '\$${order.total.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderItem(OrderItem item) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(Icons.chair, color: Colors.grey.shade600),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name,
//                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   '${item.quantity}x\$${item.price.toStringAsFixed(2)}',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             '\$${(item.quantity * item.price).toStringAsFixed(2)}',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPricingRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         CustomText(label, type: CustomTextType.subtitleSmall),
//         CustomText(value, type: CustomTextType.subtitleSmall),
//       ],
//     );
//   }

//   Widget _buildDownloadInvoiceButton(context) {
//     return Row(
//       children: [
//         Expanded(
//           child: CustomButtonUtils.login(
//             title: 'Download Invoice',
//             backgroundColor: AppColors.brightOrange,
//             onPressed: () {},
//           ),
//         ),
//         SizedBox(width: 10),
//         Expanded(
//           child: CustomButtonUtils.login(
//             title: 'Track Order',
//             backgroundColor: AppColors.brightOrange,
//             onPressed: () {},
//           ),
//         ),
//       ],
//     );
//   }
// }
