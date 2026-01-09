// widgets/visit_request_card.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';
import 'package:wood_service/widgets/seller_custom_widget.dart';

Widget buildFilterTabs(VisitRequestsViewModel viewModel) {
  return Container(
    margin: const EdgeInsets.fromLTRB(20, 5, 10, 0),
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
    ),
    child: Row(
      children: [
        buildFilterTab('All', VisitFilter.all, viewModel),
        buildFilterTab('Pending', VisitFilter.pending, viewModel),
        buildFilterTab('Accepted', VisitFilter.accepted, viewModel),
        buildFilterTab('Cancelled', VisitFilter.cancelled, viewModel),
        buildFilterTab('Completed', VisitFilter.completed, viewModel),
      ],
    ),
  );
}

Widget buildFilterTab(
  String label,
  VisitFilter filter,
  VisitRequestsViewModel viewModel,
) {
  final isActive = viewModel.currentFilter == filter;
  return Expanded(
    child: InkWell(
      onTap: () => viewModel.setFilter(filter),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    ),
  );
}

class VisitRequestCard extends StatelessWidget {
  final VisitRequest visitRequest;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;

  const VisitRequestCard({
    super.key,
    required this.visitRequest,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(visitRequest.status),
                Text(
                  visitRequest.formattedRequestDate,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Buyer Info
            _buildBuyerInfo(),

            const SizedBox(height: 15),

            // Visit Details
            _buildVisitDetails(),

            const SizedBox(height: 15),

            // Items
            if (visitRequest.items.isNotEmpty) ...[
              _buildItemsList(),
              const SizedBox(height: 15),
            ],

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VisitStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            visitRequest.statusColor,
            visitRequest.statusColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: visitRequest.statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        visitRequest.statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBuyerInfo() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: visitRequest.buyerProfileImage.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    visitRequest.buyerProfileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      );
                    },
                  ),
                )
              : const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visitRequest.buyerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              if (visitRequest.buyerPhone.isNotEmpty)
                Text(
                  visitRequest.buyerPhone,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              if (visitRequest.buyerEmail.isNotEmpty)
                Text(
                  visitRequest.buyerEmail,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisitDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visit Type
          Row(
            children: [
              Icon(Icons.category, color: AppColors.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'Type: ${visitRequest.visitTypeText}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
          if (visitRequest.location != null)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    visitRequest.location!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

          if (visitRequest.location != null) const SizedBox(height: 8),

          // Date & Time
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${visitRequest.formattedVisitDate} at ${visitRequest.formattedTime}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),

          // Duration
          if (visitRequest.duration != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${visitRequest.duration}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],

          // Message
          if (visitRequest.message != null &&
              visitRequest.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, color: AppColors.primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Message: ${visitRequest.message!}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requested Items:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...visitRequest.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                if (item.productImage != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(item.productImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = _getActionButtons(context);

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(
      children: buttons.length == 1
          ? [Expanded(child: buttons.first)]
          : [
              Expanded(child: buttons[0]),
              const SizedBox(width: 12),
              Expanded(child: buttons[1]),
            ],
    );
  }

  List<Widget> _getActionButtons(BuildContext context) {
    switch (visitRequest.status) {
      case VisitStatus.pending:
        return [
          _buildActionButton(
            'Accept',
            const Color(0xFF6BCF7F),
            Icons.check,
            onAccept ?? () {},
          ),
          _buildActionButton(
            'Reject',
            const Color(0xFFFF6B6B),
            Icons.close,
            onDecline ?? () {},
          ),
        ];

      case VisitStatus.accepted:
        return [
          _buildActionButton(
            'Mark as Completed',
            const Color(0xFF4D96FF),
            Icons.done_all,
            onComplete ?? () {},
          ),
          _buildActionButton(
            'Cancel',
            const Color(0xFFFF6B6B),
            Icons.cancel,
            onCancel ?? () {},
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return CustomButton(
      onPressed: onPressed,
      backgroundColor: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
// //

// import 'package:flutter/material.dart';
// import 'package:wood_service/app/index.dart';
// import 'package:wood_service/data/models/shop.dart' hide VisitStatus;
// import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';
// import 'package:wood_service/widgets/seller_custom_widget.dart';

// Widget buildFilterTabs(VisitRequestsViewModel viewModel) {
//   return Container(
//     margin: const EdgeInsets.fromLTRB(20, 5, 10, 0),
//     padding: const EdgeInsets.all(6),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
//     ),
//     child: Row(
//       children: [
//         buildFilterTab('Active', VisitFilter.active, viewModel),
//         buildFilterTab('Cancelled', VisitFilter.cancelled, viewModel),
//         buildFilterTab('Completed', VisitFilter.completed, viewModel),
//       ],
//     ),
//   );
// }

// class VisitRequestCard extends StatelessWidget {
//   final VisitRequest visitRequest;

//   const VisitRequestCard({super.key, required this.visitRequest});

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
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with Status and Date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildStatusBadge(visitRequest.status),
//                 Text(
//                   _getFormattedDate(visitRequest),
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
//             AppColors.getStatusColor(status),
//             AppColors.getStatusColor(status).withOpacity(0.8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.getStatusColor(status).withOpacity(0.3),
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
//           child: const Icon(Icons.person, color: Colors.white, size: 24),
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
//               Text(
//                 visitRequest.buyerPhone,
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//               Text(
//                 visitRequest.buyerEmail,
//                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
//               ),
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
//           Row(
//             children: [
//               Icon(Icons.location_on, color: AppColors.primaryColor, size: 18),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   visitRequest.address,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(
//                 Icons.calendar_today,
//                 color: AppColors.primaryColor,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 '${_formatDate(visitRequest.visitDate)} at ${visitRequest.visitTime}',
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ],
//           ),
//           if (visitRequest.instructions != null &&
//               visitRequest.instructions!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.note, color: AppColors.primaryColor, size: 18),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     visitRequest.instructions!,
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
//                       image: DecorationImage(
//                         image: NetworkImage(item.productImage!),
//                         fit: BoxFit.cover,
//                       ),
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
//                         'Qty: ${item.quantity} × \$${item.price}',
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
//               const SizedBox(width: 12),
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
//             () => _handleStatusUpdate(context, VisitStatus.accepted),
//           ),
//           _buildActionButton(
//             'Reject',
//             const Color(0xFFFF6B6B),
//             Icons.close,
//             () => _handleStatusUpdate(context, VisitStatus.rejected),
//           ),
//         ];

//       case VisitStatus.accepted:
//         return [
//           _buildActionButton(
//             'Mark as Completed',
//             const Color(0xFF4D96FF),
//             Icons.done_all,
//             () => _handleStatusUpdate(context, VisitStatus.completed),
//           ),
//           _buildActionButton(
//             'Cancel',
//             const Color(0xFFFF6B6B),
//             Icons.cancel,
//             () => _handleStatusUpdate(context, VisitStatus.cancelled),
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
//           Icon(icon, size: 18, color: Colors.white),
//           const SizedBox(width: 8),
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

//   String _getFormattedDate(VisitRequest visit) {
//     if (visit.status == VisitStatus.pending) {
//       return visit.formattedRequestedDate;
//     } else if (visit.acceptedAt != null) {
//       return visit.formattedAcceptedDate;
//     } else {
//       return _formatDate(visit.requestedAt);
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   void _handleStatusUpdate(BuildContext context, VisitStatus newStatus) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           newStatus == VisitStatus.accepted
//               ? 'Accept Visit Request?'
//               : newStatus == VisitStatus.rejected
//               ? 'Reject Visit Request?'
//               : newStatus == VisitStatus.completed
//               ? 'Mark as Completed?'
//               : 'Cancel Visit?',
//         ),
//         content: Text(
//           newStatus == VisitStatus.accepted
//               ? 'Are you sure you want to accept this visit request?'
//               : newStatus == VisitStatus.rejected
//               ? 'Are you sure you want to reject this visit request?'
//               : newStatus == VisitStatus.completed
//               ? 'Confirm that this visit has been completed.'
//               : 'Are you sure you want to cancel this visit?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               final viewModel = context.read<VisitRequestsViewModel>();
//               try {
//                 await viewModel.updateVisitStatus(
//                   visitRequest.orderId,
//                   newStatus,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       newStatus == VisitStatus.accepted
//                           ? 'Visit request accepted!'
//                           : newStatus == VisitStatus.rejected
//                           ? 'Visit request rejected.'
//                           : newStatus == VisitStatus.completed
//                           ? 'Visit marked as completed.'
//                           : 'Visit cancelled.',
//                     ),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Failed to update status: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             child: Text(
//               newStatus == VisitStatus.accepted
//                   ? 'Accept'
//                   : newStatus == VisitStatus.rejected
//                   ? 'Reject'
//                   : newStatus == VisitStatus.completed
//                   ? 'Complete'
//                   : 'Cancel',
//               style: TextStyle(
//                 color:
//                     newStatus == VisitStatus.rejected ||
//                         newStatus == VisitStatus.cancelled
//                     ? Colors.red
//                     : AppColors.primaryColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
