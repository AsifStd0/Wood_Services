// import 'package:flutter/material.dart';
// import 'package:wood_service/views/Seller/data/views/seller_chating/seller_%20chat_model.dart';

// class MessageBubble extends StatelessWidget {
//   final MessageModel message;

//   const MessageBubble({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     final isSeller = message.isSeller;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: isSeller
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         children: [
//           if (!isSeller) ...[
//             // Buyer avatar for received messages
//             Container(
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.person_rounded,
//                 color: Colors.grey[600],
//                 size: 14,
//               ),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isSeller ? Color(0xFF667EEA) : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(16).copyWith(
//                   bottomLeft: isSeller
//                       ? const Radius.circular(16)
//                       : const Radius.circular(4),
//                   bottomRight: isSeller
//                       ? const Radius.circular(4)
//                       : const Radius.circular(16),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (!isSeller)
//                     Text(
//                       message.senderName,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   Text(
//                     message.message,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: isSeller ? Colors.white : Colors.grey[800],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     message.timeString,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: isSeller
//                           ? Colors.white.withOpacity(0.7)
//                           : Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isSeller) ...[
//             const SizedBox(width: 8),
//             // Read status for seller's messages
//             Icon(
//               message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
//               size: 14,
//               color: message.isRead ? Colors.blue : Colors.grey[400],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
