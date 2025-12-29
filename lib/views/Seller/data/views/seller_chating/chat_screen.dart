// // views/seller_chatting_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wood_service/views/Seller/data/views/seller_chating/chat_view_provider.dart';
// import 'package:wood_service/views/Seller/data/views/seller_chating/seller_%20chat_model.dart';
// import 'package:wood_service/views/Seller/data/views/seller_chating/seller_chat_detail.dart';

// class SellerChatingScreen extends StatefulWidget {
//   const SellerChatingScreen({super.key});

//   @override
//   State<SellerChatingScreen> createState() => _SellerChattingState();
// }

// class _SellerChattingState extends State<SellerChatingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => SellerChatViewModel(),
//       child: Scaffold(
//         backgroundColor: Color(0xFFF8FAFC),
//         body: Consumer<SellerChatViewModel>(
//           builder: (context, viewModel, child) {
//             return viewModel.selectedChat == null
//                 ? _ChatListScreen(viewModel: viewModel)
//                 : SellerChatDetail(viewModel: viewModel);
//           },
//         ),
//       ),
//     );
//   }
// }

// class _ChatListScreen extends StatelessWidget {
//   final SellerChatViewModel viewModel;

//   const _ChatListScreen({required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Custom App Bar for Chat List
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 3,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Text(
//                     'Messages',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   const Spacer(),

//                   const SizedBox(width: 16),
//                   IconButton(
//                     icon: Icon(Icons.search_rounded, color: Colors.grey[600]),
//                     onPressed: () {
//                       // Implement search functionality
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // Chat List
//         Expanded(child: _buildChatList(viewModel)),
//       ],
//     );
//   }

//   Widget _buildChatList(SellerChatViewModel viewModel) {
//     if (viewModel.isLoading) {
//       return _buildLoadingState();
//     }

//     if (viewModel.filteredChats.isEmpty) {
//       return _buildEmptyState(viewModel);
//     }

//     return RefreshIndicator(
//       onRefresh: viewModel.refreshChats,
//       child: ListView.builder(
//         padding: const EdgeInsets.only(bottom: 16),
//         itemCount: viewModel.filteredChats.length,
//         itemBuilder: (context, index) {
//           return _ChatListItem(
//             chat: viewModel.filteredChats[index],
//             onTap: () => viewModel.selectChat(viewModel.filteredChats[index]),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               shape: BoxShape.circle,
//             ),
//             child: const CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading Conversations',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(SellerChatViewModel viewModel) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.chat_bubble_outline_rounded,
//                 size: 50,
//                 color: Colors.grey[400],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               viewModel.searchQuery.isEmpty
//                   ? 'No Conversations'
//                   : 'No Results Found',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               viewModel.searchQuery.isEmpty
//                   ? 'When customers message you, conversations will appear here'
//                   : 'No conversations found for "${viewModel.searchQuery}"',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (viewModel.searchQuery.isNotEmpty)
//               ElevatedButton(
//                 onPressed: viewModel.clearSearch,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF667EEA),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 child: Text('Clear Search'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ChatListItem extends StatelessWidget {
//   final SellerChatModel chat;
//   final VoidCallback onTap;

//   const _ChatListItem({required this.chat, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Avatar with Online Indicator
//                 Stack(
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: Color(0xFF667EEA),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.person_rounded,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                     if (chat.isOnline)
//                       Positioned(
//                         right: 0,
//                         bottom: 0,
//                         child: Container(
//                           width: 12,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: Colors.green,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(width: 16),

//                 // Chat Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               chat.buyerName,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[800],
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Text(
//                             chat.timeAgo,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         chat.lastMessage,
//                         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       if (chat.orderId != null) ...[
//                         const SizedBox(height: 4),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             'Order: ${chat.orderId}',
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.blue,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Unread Count
//                 if (chat.unreadCount > 0) ...[
//                   const SizedBox(width: 12),
//                   Container(
//                     width: 20,
//                     height: 20,
//                     decoration: BoxDecoration(
//                       color: Color(0xFF667EEA),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Text(
//                         chat.unreadCount > 9
//                             ? '9+'
//                             : chat.unreadCount.toString(),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
