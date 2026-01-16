// // widgets/visit_request_card.dart
// import 'package:flutter/material.dart';
// import 'package:wood_service/app/index.dart';
// import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';
// import 'package:wood_service/widgets/custom_button.dart';

// class VisitRequestCard extends StatelessWidget {
//   final VisitRequest visitRequest;
//   // final VisitRequestsViewModel viewModel; // Add this parameter

//   final VoidCallback? onAccept;
//   final VoidCallback? onDecline;
//   final VoidCallback? onCancel;
//   final VoidCallback? onComplete;

//   const VisitRequestCard({
//     super.key,
//     required this.visitRequest,
//     // required this.viewModel, //   Add this

//     this.onAccept,
//     this.onDecline,
//     this.onCancel,
//     this.onComplete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with Status and Date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildStatusBadge(visitRequest.status),
//                 Text(
//                   visitRequest.formattedRequestDate,
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 15),

//             // Buyer Info
//             _buildBuyerInfo(),

//             const SizedBox(height: 15),

//             // Visit Details
//             _buildVisitDetails(),

//             const SizedBox(height: 15),

//             // Items
//             if (visitRequest.items.isNotEmpty) ...[
//               _buildItemsList(),
//               const SizedBox(height: 15),
//             ],

//             // Action Buttons
//             _buildActionButtons(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusBadge(VisitStatus status) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             visitRequest.statusColor,
//             visitRequest.statusColor.withOpacity(0.8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: visitRequest.statusColor.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Text(
//         visitRequest.statusText,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 12,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }

//   Widget _buildBuyerInfo() {
//     return Row(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             gradient: AppColors.primaryGradient,
//             shape: BoxShape.circle,
//           ),
//           child: visitRequest.buyerProfileImage.isNotEmpty
//               ? ClipOval(
//                   child: const Icon(
//                     Icons.person,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                   // Image.network(
//                   //   visitRequest.buyerProfileImage,
//                   //   fit: BoxFit.cover,
//                   //   errorBuilder: (context, error, stackTrace) {
//                   //     return const Icon(
//                   //       Icons.person,
//                   //       color: Colors.white,
//                   //       size: 24,
//                   //     );
//                   //   },
//                   // ),
//                 )
//               : const Icon(Icons.person, color: Colors.white, size: 24),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 visitRequest.buyerName,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               if (visitRequest.buyerPhone.isNotEmpty)
//                 Text(
//                   visitRequest.buyerPhone,
//                   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                 ),
//               if (visitRequest.buyerEmail.isNotEmpty)
//                 Text(
//                   visitRequest.buyerEmail,
//                   style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildVisitDetails() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Visit Type
//           Row(
//             children: [
//               Icon(Icons.category, color: AppColors.primaryColor, size: 18),
//               const SizedBox(width: 8),
//               Text(
//                 'Type: ${visitRequest.visitTypeText}',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),

//           // Location
//           if (visitRequest.location != null)
//             Row(
//               children: [
//                 Icon(
//                   Icons.location_on,
//                   color: AppColors.primaryColor,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     visitRequest.location!,
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ),
//               ],
//             ),

//           if (visitRequest.location != null) const SizedBox(height: 8),

//           // Date & Time
//           Row(
//             children: [
//               Icon(
//                 Icons.calendar_today,
//                 color: AppColors.primaryColor,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 '${visitRequest.formattedVisitDate} at ${visitRequest.formattedTime}',
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ],
//           ),

//           // Duration
//           if (visitRequest.duration != null) ...[
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(
//                   Icons.access_time,
//                   color: AppColors.primaryColor,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Duration: ${visitRequest.duration}',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ],
//             ),
//           ],

//           // Message
//           if (visitRequest.message != null &&
//               visitRequest.message!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.note, color: AppColors.primaryColor, size: 18),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Message: ${visitRequest.message!}',
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildItemsList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Requested Items:',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         ...visitRequest.items.map((item) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(
//               children: [
//                 if (item.productImage != null) ...[
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       // image: DecorationImage(
//                       //   image: NetworkImage(item.productImage!),
//                       //   fit: BoxFit.cover,
//                       // ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.productName,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       Text(
//                         'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     final buttons = _getActionButtons(context);

//     if (buttons.isEmpty) return const SizedBox.shrink();

//     return Row(
//       children: buttons.length == 1
//           ? [Expanded(child: buttons.first)]
//           : [
//               Expanded(child: buttons[0]),
//               const SizedBox(width: 6),
//               Expanded(child: buttons[1]),
//             ],
//     );
//   }

//   List<Widget> _getActionButtons(BuildContext context) {
//     switch (visitRequest.status) {
//       case VisitStatus.pending:
//         return [
//           _buildActionButton(
//             'Accept',
//             const Color(0xFF6BCF7F),
//             Icons.check,
//             () => _showAcceptDialog(context),
//           ),
//           _buildActionButton(
//             'Reject',
//             const Color(0xFFFF6B6B),
//             Icons.close,
//             () => _showRejectDialog(context),
//           ),
//         ];

//       case VisitStatus.accepted:
//         return [
//           _buildActionButton(
//             'Complete',
//             const Color(0xFF4D96FF),
//             Icons.done_all,
//             () => _showCompleteDialog(context),
//           ),
//           _buildActionButton(
//             'Cancel',
//             const Color(0xFFFF6B6B),
//             Icons.cancel,
//             () => _showCancelDialog(context),
//           ),
//         ];

//       default:
//         return [];
//     }
//   }

//   Widget _buildActionButton(
//     String text,
//     Color color,
//     IconData icon,
//     VoidCallback onPressed,
//   ) {
//     return CustomButton(
//       onPressed: onPressed,
//       backgroundColor: color,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 17, color: Colors.white),
//           const SizedBox(width: 3),
//           Text(
//             text,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAcceptDialog(BuildContext context) {
//     String message = '';
//     String? visitDate;
//     String? visitTime;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text('Accept Visit Request'),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Accept visit request from ${visitRequest.buyerName}?'),
//                   const SizedBox(height: 16),
//                   TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Message to buyer (optional)',
//                       border: OutlineInputBorder(),
//                       hintText: 'e.g., Welcome to our shop!',
//                     ),
//                     maxLines: 3,
//                     onChanged: (value) => message = value,
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Visit Date (YYYY-MM-DD)',
//                       border: OutlineInputBorder(),
//                       hintText: 'e.g., 2024-01-15',
//                     ),
//                     onChanged: (value) => visitDate = value,
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Visit Time (HH:MM)',
//                       border: OutlineInputBorder(),
//                       hintText: 'e.g., 14:30',
//                     ),
//                     onChanged: (value) => visitTime = value,
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     Navigator.pop(context);

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Accepting visit request...'),
//                         duration: Duration(seconds: 2),
//                       ),
//                     );

//                     await viewModel.acceptVisitRequest(
//                       requestId: visitRequest.id,
//                       message: message,
//                       visitDate: visitDate,
//                       visitTime: visitTime,
//                     );

//                     // Show success message
//                     if (!context.mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Visit request accepted!'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );

//                     // Call the onAccept callback if provided
//                     onAccept?.call();
//                   } catch (e) {
//                     if (!context.mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Error: $e'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 },
//                 child: const Text('Accept'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   void _showRejectDialog(BuildContext context) {
//     String message = '';

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text('Reject Visit Request'),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Reject visit request from ${visitRequest.buyerName}?'),
//                   const SizedBox(height: 16),
//                   TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Reason (optional)',
//                       border: OutlineInputBorder(),
//                       hintText: 'e.g., We are closed on that day',
//                     ),
//                     maxLines: 3,
//                     onChanged: (value) => message = value,
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     Navigator.pop(context);

//                     // Show loading
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Rejecting visit request...'),
//                         duration: Duration(seconds: 2),
//                       ),
//                     );

//                     await viewModel.declineVisitRequest(
//                       requestId: visitRequest.id,
//                       message: message.isNotEmpty
//                           ? message
//                           : 'Visit request declined',
//                     );

//                     // Show success message
//                     if (!context.mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Visit request rejected!'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );

//                     // Call the onDecline callback if provided
//                     onDecline?.call();
//                   } catch (e) {
//                     if (!context.mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Error: $e'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Reject'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   void _showCancelDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Cancel Visit Request'),
//         content: Text('Cancel visit request from ${visitRequest.buyerName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 Navigator.pop(context);

//                 // Show loading
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Cancelling visit request...'),
//                     duration: Duration(seconds: 2),
//                   ),
//                 );

//                 // Since there's no specific "cancel" endpoint, use decline
//                 // or updateVisitStatus depending on your backend
//                 await viewModel.updateVisitStatus(
//                   visitRequest.id,
//                   VisitStatus.cancelled,
//                 );

//                 // Show success message
//                 if (!context.mounted) return;
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Visit request cancelled!'),
//                     backgroundColor: Colors.orange,
//                   ),
//                 );

//                 // Call the onCancel callback if provided
//                 onCancel?.call();
//               } catch (e) {
//                 if (!context.mounted) return;
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Error: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Yes, Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCompleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Complete'),
//         content: Text(
//           'Mark visit request from ${visitRequest.buyerName} as completed?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 Navigator.pop(context);

//                 // Show loading
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Marking as completed...'),
//                     duration: Duration(seconds: 2),
//                   ),
//                 );

//                 await viewModel.updateVisitStatus(
//                   visitRequest.id,
//                   VisitStatus.completed,
//                 );

//                 // Show success message
//                 if (!context.mounted) return;
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Visit marked as completed!'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );

//                 // Call the onComplete callback if provided
//                 onComplete?.call();
//               } catch (e) {
//                 if (!context.mounted) return;
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Error: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             child: const Text('Mark Complete'),
//           ),
//         ],
//       ),
//     );
//   }
// }
