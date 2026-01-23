// import 'package:flutter/material.dart';
// import '../models/visit_request_model.dart';

// class VisitRequestCard extends StatelessWidget {
//   final VisitRequest request;
//   final VoidCallback? onAccept;
//   final VoidCallback? onCancel;

//   const VisitRequestCard({
//     super.key,
//     required this.request,
//     this.onAccept,
//     this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Visit Request for ${request.address}',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               request.status == VisitStatus.pending
//                   ? 'Requested on ${_formatDate(request.requestedDate)}'
//                   : 'Accepted on ${_formatDate(request.acceptedDate!)}',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(request.status),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Text(
//                     request.status.name.toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 if (request.status == VisitStatus.pending)
//                   ElevatedButton(
//                     onPressed: onAccept,
//                     child: const Text('Accept'),
//                   ),
//                 const SizedBox(width: 8),
//                 OutlinedButton(
//                   onPressed: onCancel,
//                   child: const Text('Cancel'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }

//   Color _getStatusColor(VisitStatus status) {
//     switch (status) {
//       case VisitStatus.pending:
//         return Colors.orange;
//       case VisitStatus.accepted:
//         return Colors.green;
//       case VisitStatus.cancelled:
//         return Colors.red;
//       case VisitStatus.completed:
//         return Colors.blue;
//     }
//   }
// }
