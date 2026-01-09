// // widgets/seller_visit_request_card.dart (NEW FILE)
// import 'package:flutter/material.dart';
// import 'package:wood_service/app/index.dart';
// import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/seller_visit_request_model.dart';
// import 'package:wood_service/widgets/seller_custom_widget.dart';

// class SellerVisitRequestCard extends StatelessWidget {
//   final SellerVisitRequest visitRequest;
//   final VoidCallback? onAccept;
//   final VoidCallback? onDecline;

//   const SellerVisitRequestCard({
//     super.key,
//     required this.visitRequest,
//     this.onAccept,
//     this.onDecline,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with status and date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildStatusBadge(visitRequest.status),
//                 Text(
//                   '${visitRequest.formattedVisitDate} at ${visitRequest.formattedTime}',
//                 ),

//                 // Text(
//                 //   visitRequest.formattedRequestDate,
//                 //   style: const TextStyle(color: Colors.grey, fontSize: 12),
//                 // ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Buyer info
//             _buildBuyerInfo(visitRequest),

//             const SizedBox(height: 16),

//             // Request details
//             _buildRequestDetails(visitRequest),

//             const SizedBox(height: 16),

//             // Action buttons if pending
//             if (visitRequest.isPending) _buildActionButtons(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String status) {
//     final color = visitRequest.statusColor;
//     final icon = visitRequest.statusIcon;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: color),
//           const SizedBox(width: 6),
//           Text(
//             visitRequest.statusText,
//             style: TextStyle(
//               color: color,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBuyerInfo(SellerVisitRequest request) {
//     return Row(
//       children: [
//         // Buyer avatar
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             shape: BoxShape.circle,
//           ),
//           child: request.buyerProfileImage.isNotEmpty
//               ? ClipOval(
//                   child: Image.network(
//                     request.buyerProfileImage,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Icon(Icons.person, color: Colors.blue.shade300);
//                     },
//                   ),
//                 )
//               : Icon(Icons.person, size: 30, color: Colors.blue.shade300),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 request.buyerName,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               if (request.buyerEmail.isNotEmpty)
//                 Text(
//                   request.buyerEmail,
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               if (request.buyerPhone.isNotEmpty)
//                 Text(
//                   request.buyerPhone,
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRequestDetails(SellerVisitRequest request) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Message
//           if (request.message != null && request.message!.isNotEmpty) ...[
//             const Text(
//               'Message:',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             Text(request.message!),
//             const SizedBox(height: 12),
//           ],

//           // Preferred visit
//           if (request.preferredDate != null ||
//               request.preferredTime != null) ...[
//             const Text(
//               'Preferred Visit:',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             Text('${request.formattedVisitDate} at ${request.formattedTime}'),
//             const SizedBox(height: 12),
//           ],

//           // Scheduled visit (if accepted)
//           if (request.isAccepted && request.visitDate != null) ...[
//             const Text(
//               'Scheduled Visit:',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             Text('${request.formattedVisitDate} ${request.visitTime ?? ''}'),
//             if (request.duration != null) Text('Duration: ${request.duration}'),
//             if (request.location != null) Text('Location: ${request.location}'),
//             const SizedBox(height: 12),
//           ],

//           // Seller response (if provided)
//           if (request.sellerResponse != null &&
//               request.sellerResponse!['message'] != null) ...[
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Your Response:',
//                     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//                   ),
//                   Text(request.sellerResponse!['message']),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: onDecline,
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.red,
//               side: const BorderSide(color: Colors.red),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//             child: const Text('Decline'),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: onAccept,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//             child: const Text('Accept'),
//           ),
//         ),
//       ],
//     );
//   }
// }
