// screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/seller_home_screen_widget.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repository.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Visit Requests',
        showBackButton: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Text('Visit Requests '),
    );
  }
}
    
  

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     final viewModel = context.read<VisitRequestsViewModel>();
//   //     viewModel.loadVisitRequests();
//   //   });
//   // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFFF8FAFC),
  //     appBar: CustomAppBar(
  //       title: 'Visit Requests',
  //       showBackButton: false,
  //       actions: [
  //         IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
  //       ],
  //     ),
  //     body: Consumer<VisitRequestsViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading && viewModel.visitRequests.isEmpty) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (viewModel.hasError) {
//             return _buildErrorState(viewModel);
//           }

//           return Column(
//             children: [
//               // Header with Stats
//               _buildHeaderStats(viewModel),
//               // Filter Tabs
//               _buildFilterTabs(viewModel),

//               // Visit Requests List
//               Expanded(child: _buildVisitList(viewModel)),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildErrorState(VisitRequestsViewModel viewModel) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 64, color: Colors.red),
//           const SizedBox(height: 16),
//           Text(
//             viewModel.errorMessage,
//             style: const TextStyle(color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () => viewModel.loadVisitRequests(),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderStats(VisitRequestsViewModel viewModel) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Colors.blue.shade800, Colors.blue.shade600],
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Total visits
//           Text(
//             '${viewModel.totalVisits}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 42,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Text(
//             'Total Visit Requests',
//             style: TextStyle(color: Colors.white, fontSize: 14),
//           ),
//           const SizedBox(height: 10),

//           // Stats row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatChip(
//                 'Active',
//                 viewModel.activeVisits,
//                 Icons.access_time,
//                 Colors.orange,
//               ),
//               _buildStatChip(
//                 'Pending',
//                 viewModel.pendingVisits,
//                 Icons.pending,
//                 Colors.amber,
//               ),
//               _buildStatChip(
//                 'Accepted',
//                 viewModel.acceptedVisits,
//                 Icons.check_circle,
//                 Colors.green,
//               ),
//               _buildStatChip(
//                 'Cancelled',
//                 viewModel.cancelledVisits,
//                 Icons.cancel,
//                 Colors.red,
//               ),
//               _buildStatChip(
//                 'Completed',
//                 viewModel.completedVisits,
//                 Icons.done_all,
//                 Colors.blue,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatChip(String label, int count, IconData icon, Color color) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.white.withOpacity(0.3)),
//           ),
//           child: Icon(icon, color: Colors.white, size: 24),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           count.toString(),
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
//         ),
//       ],
//     );
//   }

//   Widget _buildFilterTabs(VisitRequestsViewModel viewModel) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _buildFilterButton('All', VisitFilter.all, viewModel),
//             _buildFilterButton(
//               'Active',
//               VisitFilter.all,
//               viewModel,
//             ), // Custom logic for active
//             _buildFilterButton('Pending', VisitFilter.pending, viewModel),
//             _buildFilterButton('Accepted', VisitFilter.accepted, viewModel),
//             _buildFilterButton('Cancelled', VisitFilter.cancelled, viewModel),
//             _buildFilterButton('Completed', VisitFilter.completed, viewModel),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterButton(
//     String label,
//     VisitFilter filter,
//     VisitRequestsViewModel viewModel,
//   ) {
//     // Special case for "Active" which shows pending + accepted
//     final bool isActive;
//     if (label == 'Active') {
//       isActive =
//           viewModel.currentFilter == VisitFilter.all &&
//           viewModel.filteredVisits.every((v) => v.isPending || v.isAccepted);
//     } else {
//       isActive = viewModel.currentFilter == filter;
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: ElevatedButton(
//         onPressed: () => _handleFilterTap(label, filter, viewModel),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isActive
//               ? AppColors.primaryColor
//               : Colors.transparent,
//           foregroundColor: isActive ? Colors.white : Colors.grey,
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         ),
//         child: Text(label),
//       ),
//     );
//   }

//   void _handleFilterTap(
//     String label,
//     VisitFilter filter,
//     VisitRequestsViewModel viewModel,
//   ) {
//     if (label == 'Active') {
//       // Custom logic for active filter
//       viewModel.setFilter(VisitFilter.all);
//       // We'll filter in the filteredVisits getter
//     } else {
//       viewModel.setFilter(filter);
//     }
//   }

//   Widget _buildVisitList(VisitRequestsViewModel viewModel) {
//     final visits = viewModel.filteredVisits;

//     if (visits.isEmpty) {
//       return _buildEmptyStateWithGuidance(viewModel);
//     }

//     return RefreshIndicator(
//       onRefresh: () => viewModel.loadVisitRequests(),
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: visits.length,
//         itemBuilder: (context, index) {
//           final request = visits[index];

//           // Show a demo badge for converted orders
//           if (request.id.startsWith('mock_') ||
//               request.id.startsWith('demo_')) {
//             return Column(
//               children: [
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.info, color: Colors.blue.shade600, size: 16),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Demo Data - Create real visit requests from buyer app',
//                           style: TextStyle(
//                             color: Colors.blue.shade800,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 VisitRequestCard(
//                   visitRequest: request,
//                   viewModel: viewModel,
//                 ), // Pass viewModel
//               ],
//             );
//           }

//           return VisitRequestCard(visitRequest: request, viewModel: viewModel);
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyStateWithGuidance(VisitRequestsViewModel viewModel) {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.store_mall_directory_outlined,
//               size: 80,
//               color: Colors.grey.shade300,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'No Visit Requests Yet',
//               style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.grey.shade700,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.blue.shade100),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'How to Get Visit Requests:',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.blue.shade800,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildStepItem('1️⃣', 'Buyers visit your shop in the app'),
//                   _buildStepItem('2️⃣', 'They click "Request Visit" button'),
//                   _buildStepItem('3️⃣', 'You\'ll see their requests here'),
//                   _buildStepItem('4️⃣', 'Accept, decline, or schedule visits'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStepItem(String icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(icon, style: const TextStyle(fontSize: 16)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
