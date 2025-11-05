
  // bottomSheet: AnimatedBuilder(
  //       animation: _sheetAnim,
  //       builder: (context, child) {
  //         return Transform.translate(
  //           offset: Offset(0, (1 - _sheetAnim.value) * 100),
  //           child: Opacity(opacity: _sheetAnim.value, child: child),
  //         );
  //       },
  //       child: SafeArea(
  //         child: Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //           padding: const EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(20),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.15),
  //                 blurRadius: 20,
  //                 offset: const Offset(0, 4),
  //               ),
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.1),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //             border: Border.all(color: Colors.grey.shade100, width: 1),
  //           ),
  //           child: Column(
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:wood_service/core/theme/app_colors.dart';
// import 'package:wood_service/data/models/buyer_cart_Item.dart';
// import 'package:wood_service/views/Buyer/Cart/cart_widget.dart';
// import 'package:wood_service/widgets/advance_appbar.dart';
// import 'package:wood_service/widgets/custom_button.dart';

// class BuyerCartScreen extends StatefulWidget {
//   const BuyerCartScreen({super.key});

//   @override
//   State<BuyerCartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<BuyerCartScreen> {
//   double get _subtotal {
//     return buyerCartItems.fold(
//       0,
//       (sum, item) => sum + (item.price * item.quantity),
//     );
//   }

//   double get _shipping {
//     return _subtotal > 100 ? 0 : 49.99;
//   }

//   double get _tax {
//     return _subtotal * 0.08;
//   }

//   double get _total {
//     return _subtotal + _shipping + _tax;
//   }

//   bool get _hasFreeShipping {
//     return _subtotal > 100;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomAppBar(
//         title: 'My Cart',
//         showBackButton: false,
//         actions: [
//           if (buyerCartItems.isNotEmpty)
//             IconButton(
//               // onPressed: _clearCart,
//               onPressed: () {},

//               icon: Icon(Icons.delete_outline, color: Colors.grey.shade700),
//             ),
//         ],
//       ),
//       body: buyerCartItems.isEmpty
//           ? buildEmptyCart(context)
//           : _buildCartWithItems(),
//     );
//   }

//   Widget _buildCartWithItems() {
//     return Column(
//       children: [
//         // Free Shipping Progress
//         if (!_hasFreeShipping) _buildShippingProgress(),

//         // Cart Items List
//         Expanded(
//           child: ListView(
//             padding: const EdgeInsets.only(bottom: 160),
//             children: [
//               // Item Count Header
//               _buildCartHeader(),

//               // Cart Items
//               ...buyerCartItems.map((item) => _buildCartItem(item)).toList(),

//               // Promo Code Section
//               _buildPromoSection(),

//               // Order Summary
//               _buildOrderSummary(),
//             ],
//           ),
//         ),

//         // Fixed Checkout Bar
//         _buildCheckoutBar(),
//       ],
//     );
//   }

//   Widget _buildShippingProgress() {
//     final progress = _subtotal / 100;
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade50, Colors.lightBlue.shade50],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.blue.shade100),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(Icons.local_shipping, color: Colors.blue.shade700, size: 20),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   _subtotal > 0
//                       ? 'Add \$${(100 - _subtotal).toStringAsFixed(2)} for FREE shipping'
//                       : 'Free shipping on orders over \$100',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.blue.shade800,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           LinearProgressIndicator(
//             value: progress > 1 ? 1 : progress,
//             backgroundColor: Colors.blue.shade200,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           const SizedBox(height: 4),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               '\$${_subtotal.toStringAsFixed(2)} / \$100',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.blue.shade700,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCartHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             '${buyerCartItems.length} ${buyerCartItems.length == 1 ? 'Item' : 'Items'}',
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//           TextButton.icon(
//             // onPressed: _clearCart,
//             onPressed: () {},

//             icon: Icon(Icons.delete_outline, size: 18, color: Colors.red),
//             label: Text(
//               'Clear All',
//               style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCartItem(BuyerCartItem item) {
//     return Dismissible(
//       key: Key(item.id),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.red.shade50,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: Icon(Icons.delete, color: Colors.red, size: 28),
//       ),
//       confirmDismiss: (direction) async {
//         return await _showDeleteConfirmation(item);
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//           border: Border.all(color: Colors.grey.shade100),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Product Image with Badge
//                   Stack(
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           image: DecorationImage(
//                             image: NetworkImage(item.imageUrl),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       if (!item.inStock)
//                         Positioned(
//                           top: 4,
//                           left: 4,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               'OUT OF STOCK',
//                               style: TextStyle(
//                                 fontSize: 8,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(width: 16),

//                   // Product Details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Product Name and Price
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 item.name,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                   height: 1.3,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Text(
//                               '\$${item.price.toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.brightOrange,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 4),

//                         // Description
//                         Text(
//                           item.description,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey.shade600,
//                             height: 1.2,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),

//                         const SizedBox(height: 8),

//                         // Seller Info
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.storefront_outlined,
//                               size: 14,
//                               color: Colors.grey.shade500,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               item.seller,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey.shade600,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         // Quantity and Actions
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Quantity Selector
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade50,
//                                 borderRadius: BorderRadius.circular(25),
//                                 border: Border.all(color: Colors.grey.shade300),
//                               ),
//                               child: Row(
//                                 children: [
//                                   IconButton(
//                                     icon: Icon(Icons.remove, size: 18),
//                                     onPressed: () {},

//                                     // onPressed: () => _updateQuantity(
//                                     //   item.id,
//                                     //   item.quantity - 1,
//                                     // ),
//                                     padding: const EdgeInsets.all(6),
//                                     constraints: const BoxConstraints(),
//                                     color: Colors.grey.shade700,
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                     child: Text(
//                                       item.quantity.toString(),
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: Icon(Icons.add, size: 18),
//                                     onPressed: () {},
//                                     // onPressed: () => _updateQuantity(
//                                     //   item.id,
//                                     //   item.quantity + 1,
//                                     // ),
//                                     padding: const EdgeInsets.all(6),
//                                     constraints: const BoxConstraints(),
//                                     color: Colors.grey.shade700,
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // Item Total
//                             Text(
//                               '\$${(item.price * item.quantity).toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPromoSection() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Promo Code',
//             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 45,
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Enter promo code',
//                       border: InputBorder.none,
//                       hintStyle: TextStyle(color: Colors.grey.shade500),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Container(
//                 height: 45,
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.brightOrange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                   ),
//                   child: const Text(
//                     'Apply',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderSummary() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade100),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Order Summary',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           _buildSummaryRow('Subtotal', _subtotal),
//           _buildSummaryRow('Shipping', _shipping, isFree: _hasFreeShipping),
//           _buildSummaryRow('Tax', _tax),
//           const SizedBox(height: 12),
//           Container(height: 1, color: Colors.grey.shade200),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Total',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 '\$${_total.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.brightOrange,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryRow(String label, double amount, {bool isFree = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//           ),
//           Text(
//             isFree ? 'FREE' : '\$${amount.toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: isFree ? Colors.green : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCheckoutBar() {
//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 0,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Quick Total
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Total Amount',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   Text(
//                     '\$${_total.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.brightOrange,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               CustomButtonUtils.login(
//                 title: 'Proceed to Checkout',
//                 backgroundColor: AppColors.brightOrange,
//                 // onPressed: _proceedToCheckout,
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Action Methods
//   Future<bool> _showDeleteConfirmation(BuyerCartItem item) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Remove Item?'),
//         content: Text('Remove "${item.name}" from your cart?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Remove', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (result == true) {
//       setState(() {
//         buyerCartItems.removeWhere((cartItem) => cartItem.id == item.id);
//       });
//       // _showSnackBar('Item removed from cart');
//     }
//     return result ?? false;
//   }

//   // Keep your existing methods: _updateQuantity, _clearCart, _proceedToCheckout,
//   // _showOutOfStockDialog, _showSnackBar, etc.
//   // ... (Your existing methods remain the same)
// }
