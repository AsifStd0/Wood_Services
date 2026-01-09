// // screens/seller/visit_requests_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wood_service/app/index.dart';
// import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/seller_visit_request_model.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/seller_visit_view_model.dart';
// import 'package:wood_service/widgets/custom_appbar.dart';
// import 'package:wood_service/widgets/seller_custom_widget.dart';

// class SellerVisitRequestsScreen extends StatefulWidget {
//   const SellerVisitRequestsScreen({super.key});

//   @override
//   State<SellerVisitRequestsScreen> createState() =>
//       _SellerVisitRequestsScreenState();
// }

// class _SellerVisitRequestsScreenState extends State<SellerVisitRequestsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = context.read<SellerVisitViewModel>();
//       viewModel.loadVisitRequests();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: CustomAppBar(
//         title: 'Visit Requests',
//         showBackButton: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () => _showSettingsDialog(context),
//           ),
//         ],
//       ),
//       body: Consumer<SellerVisitViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading && viewModel.visitRequests.isEmpty) {
//             return _buildLoadingState();
//           }

//           if (viewModel.error.isNotEmpty) {
//             return _buildErrorState(viewModel);
//           }

//           return Column(
//             children: [
//               // Header Stats
//               _buildHeaderStats(viewModel),

//               // Filter Tabs
//               _buildFilterTabs(viewModel),

//               // Visit Requests List
//               Expanded(child: _buildRequestsList(viewModel)),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(child: CircularProgressIndicator());
//   }

//   Widget _buildErrorState(SellerVisitViewModel viewModel) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 64, color: Colors.red),
//           const SizedBox(height: 16),
//           Text(
//             viewModel.error,
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

//   Widget _buildHeaderStats(SellerVisitViewModel viewModel) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Total Requests',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 14,
//                     ),
//                   ),
//                   Text(
//                     viewModel.totalRequests.toString(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               // Quick stats
//               Column(
//                 children: [
//                   _buildStatChip(
//                     'Pending',
//                     viewModel.pendingRequests,
//                     Colors.orange,
//                   ),
//                   const SizedBox(height: 8),
//                   _buildStatChip(
//                     'Accepted',
//                     viewModel.acceptedRequests,
//                     Colors.green,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           // Additional stats
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildMiniStat(
//                 'Pending',
//                 viewModel.pendingRequests,
//                 Icons.pending,
//               ),
//               _buildMiniStat(
//                 'Accepted',
//                 viewModel.acceptedRequests,
//                 Icons.check_circle,
//               ),
//               _buildMiniStat(
//                 'Declined',
//                 viewModel.declinedRequests,
//                 Icons.cancel,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatChip(String label, int count, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.5)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             '$label: $count',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMiniStat(String label, int count, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.white, size: 24),
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

//   Widget _buildFilterTabs(SellerVisitViewModel viewModel) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _buildFilterButton('All', SellerVisitFilter.all, viewModel),
//             _buildFilterButton('Pending', SellerVisitFilter.pending, viewModel),
//             _buildFilterButton(
//               'Accepted',
//               SellerVisitFilter.accepted,
//               viewModel,
//             ),
//             _buildFilterButton(
//               'Declined',
//               SellerVisitFilter.declined,
//               viewModel,
//             ),
//             _buildFilterButton(
//               'Cancelled',
//               SellerVisitFilter.cancelled,
//               viewModel,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterButton(
//     String label,
//     SellerVisitFilter filter,
//     SellerVisitViewModel viewModel,
//   ) {
//     final isActive = viewModel.currentFilter == filter;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: ElevatedButton(
//         onPressed: () => viewModel.setFilter(filter),
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

//   Widget _buildRequestsList(SellerVisitViewModel viewModel) {
//     final requests = viewModel.filteredRequests;

//     if (requests.isEmpty) {
//       return _buildEmptyState(viewModel);
//     }

//     return RefreshIndicator(
//       onRefresh: () => viewModel.loadVisitRequests(),
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: requests.length,
//         itemBuilder: (context, index) {
//           return _buildRequestCard(requests[index], viewModel);
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState(SellerVisitViewModel viewModel) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.store_mall_directory_outlined,
//             size: 80,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'No visit requests',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             viewModel.currentFilter == SellerVisitFilter.all
//                 ? 'You have no visit requests yet'
//                 : 'No ${viewModel.currentFilter.name.toLowerCase()} requests',
//             style: TextStyle(color: Colors.grey.shade500),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () => viewModel.loadVisitRequests(),
//             child: const Text('Refresh'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRequestCard(
//     SellerVisitRequest request,
//     SellerVisitViewModel viewModel,
//   ) {
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
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: request.statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: request.statusColor),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         request.statusIcon,
//                         size: 14,
//                         color: request.statusColor,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         request.status.toUpperCase(),
//                         style: TextStyle(
//                           color: request.statusColor,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Text(
//                 //   request.formattedDate,
//                 //   style: const TextStyle(color: Colors.grey, fontSize: 12),
//                 // ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Buyer info
//             _buildBuyerInfo(request),

//             const SizedBox(height: 16),

//             // Request details
//             _buildRequestDetails(request),

//             const SizedBox(height: 16),

//             // Actions based on status
//             _buildActionButtons(request, viewModel),
//           ],
//         ),
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
//           if (request.message != null && request.message!.isNotEmpty) ...[
//             const Text(
//               'Message:',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             Text(request.message!, style: const TextStyle(fontSize: 14)),
//             const SizedBox(height: 12),
//           ],

//           if (request.preferredDate != null ||
//               request.preferredTime != null) ...[
//             const Text(
//               'Preferred Visit:',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             // Text(
//             //   '${request.formattedDate} at ${request.formattedTime}',
//             //   style: const TextStyle(fontSize: 14),
//             // ),
//             const SizedBox(height: 12),
//           ],

//           if (request.visitDate != null) ...[
//             const Text(
//               'Scheduled Visit:',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '${request.visitDate!.day}/${request.visitDate!.month}/${request.visitDate!.year} ${request.visitTime ?? ''}',
//               style: const TextStyle(fontSize: 14),
//             ),
//             if (request.duration != null || request.location != null) ...[
//               const SizedBox(height: 4),
//               if (request.duration != null)
//                 Text('Duration: ${request.duration}'),
//               if (request.location != null)
//                 Text('Location: ${request.location}'),
//             ],
//           ],

//           if (request.sellerResponse != null) ...[
//             const SizedBox(height: 12),
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
//                   if (request.sellerResponse?['message'] != null)
//                     Text(request.sellerResponse!['message']),
//                   if (request.sellerResponse?['suggestedDate'] != null)
//                     Text(
//                       'Suggested: ${request.sellerResponse!['suggestedDate']}',
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(
//     SellerVisitRequest request,
//     SellerVisitViewModel viewModel,
//   ) {
//     if (request.isAccepted) {
//       return const SizedBox.shrink(); // No actions for accepted requests
//     }

//     if (request.isPending) {
//       return Row(
//         children: [
//           Expanded(
//             child: OutlinedButton(
//               onPressed: () => _showDeclineDialog(context, request, viewModel),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.red,
//                 side: const BorderSide(color: Colors.red),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               child: const Text('Decline'),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () => _showAcceptDialog(context, request, viewModel),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               child: const Text('Accept'),
//             ),
//           ),
//         ],
//       );
//     }

//     return const SizedBox.shrink();
//   }

//   void _showAcceptDialog(
//     BuildContext context,
//     SellerVisitRequest request,
//     SellerVisitViewModel viewModel,
//   ) {
//     final messageController = TextEditingController();
//     final dateController = TextEditingController();
//     final timeController = TextEditingController();
//     final durationController = TextEditingController(text: '1 hour');
//     final locationController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Accept Visit Request'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Accept request from ${request.buyerName}'),
//               const SizedBox(height: 16),

//               // Message
//               TextField(
//                 controller: messageController,
//                 decoration: const InputDecoration(
//                   labelText: 'Message (Optional)',
//                   hintText: 'Add a welcome message...',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),

//               const SizedBox(height: 12),

//               // Visit date
//               TextField(
//                 controller: dateController,
//                 decoration: const InputDecoration(
//                   labelText: 'Visit Date',
//                   suffixIcon: Icon(Icons.calendar_today),
//                   border: OutlineInputBorder(),
//                 ),
//                 readOnly: true,
//                 onTap: () async {
//                   final date = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now().add(const Duration(days: 1)),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(const Duration(days: 365)),
//                   );
//                   if (date != null) {
//                     dateController.text =
//                         '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//                   }
//                 },
//               ),

//               const SizedBox(height: 12),

//               // Visit time
//               TextField(
//                 controller: timeController,
//                 decoration: const InputDecoration(
//                   labelText: 'Visit Time',
//                   suffixIcon: Icon(Icons.access_time),
//                   border: OutlineInputBorder(),
//                 ),
//                 readOnly: true,
//                 onTap: () async {
//                   final time = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.now(),
//                   );
//                   if (time != null) {
//                     timeController.text =
//                         '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
//                   }
//                 },
//               ),

//               const SizedBox(height: 12),

//               // Duration
//               TextField(
//                 controller: durationController,
//                 decoration: const InputDecoration(
//                   labelText: 'Duration',
//                   hintText: 'e.g., 1 hour',
//                   border: OutlineInputBorder(),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Location
//               TextField(
//                 controller: locationController,
//                 decoration: const InputDecoration(
//                   labelText: 'Location (Optional)',
//                   hintText: 'Shop address or meeting point',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await viewModel.acceptRequest(
//                 requestId: request.id,
//                 context: context,
//                 message: messageController.text.isNotEmpty
//                     ? messageController.text
//                     : null,
//                 visitDate: dateController.text.isNotEmpty
//                     ? dateController.text
//                     : null,
//                 visitTime: timeController.text.isNotEmpty
//                     ? timeController.text
//                     : null,
//                 duration: durationController.text.isNotEmpty
//                     ? durationController.text
//                     : null,
//                 location: locationController.text.isNotEmpty
//                     ? locationController.text
//                     : null,
//               );
//               if (context.mounted) Navigator.pop(context);
//             },
//             child: const Text('Accept'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeclineDialog(
//     BuildContext context,
//     SellerVisitRequest request,
//     SellerVisitViewModel viewModel,
//   ) {
//     final messageController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Decline Visit Request'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Decline request from ${request.buyerName}?'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: messageController,
//               decoration: const InputDecoration(
//                 labelText: 'Reason (Optional)',
//                 hintText: 'Why are you declining this request?',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await viewModel.declineRequest(
//                 requestId: request.id,
//                 context: context,
//                 message: messageController.text.isNotEmpty
//                     ? messageController.text
//                     : null,
//               );
//               if (context.mounted) Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Decline'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSettingsDialog(BuildContext context) {
//     final acceptsVisits = ValueNotifier<bool>(true);
//     final hoursController = TextEditingController(text: '9 AM - 6 PM');
//     final daysController = TextEditingController(text: 'Monday - Saturday');
//     final durationController = TextEditingController(text: '1 hour');

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Visit Settings'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Accept visits toggle
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Accept Visit Requests'),
//                   Switch(
//                     value: acceptsVisits.value,
//                     onChanged: (value) => acceptsVisits.value = value,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Visit hours
//               TextField(
//                 controller: hoursController,
//                 decoration: const InputDecoration(
//                   labelText: 'Visit Hours',
//                   hintText: 'e.g., 9 AM - 6 PM',
//                   border: OutlineInputBorder(),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Visit days
//               TextField(
//                 controller: daysController,
//                 decoration: const InputDecoration(
//                   labelText: 'Visit Days',
//                   hintText: 'e.g., Monday - Saturday',
//                   border: OutlineInputBorder(),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Appointment duration
//               TextField(
//                 controller: durationController,
//                 decoration: const InputDecoration(
//                   labelText: 'Appointment Duration',
//                   hintText: 'e.g., 1 hour',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final viewModel = context.read<SellerVisitViewModel>();
//               viewModel.updateSettings(
//                 context: context,
//                 acceptsVisits: acceptsVisits.value,
//                 visitHours: hoursController.text,
//                 visitDays: daysController.text,
//                 appointmentDuration: durationController.text,
//               );
//               Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
// }
