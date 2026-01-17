// // screens/seller/seller_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:wood_service/app/index.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';
// import 'package:wood_service/views/Seller/data/views/seller_home/visit_repo/seller_home_screen_widget.dart';
// // import 'package:wood_service/views/Seller/data/views/seller_home/visit_repository.dart';
// import 'package:wood_service/widgets/custom_appbar.dart';

import 'package:flutter/material.dart';
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
      
//       class SellerHomeScreen extends StatefulWidget {
//   const SellerHomeScreen({super.key});

//   @override
//   State<SellerHomeScreen> createState() => _SellerHomeScreenState();
// }

// class _SellerHomeScreenState extends State<SellerHomeScreen> {
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     final viewModel = context.read<VisitRequestsViewModel>();
//   //     viewModel.loadVisitRequests();
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: CustomAppBar(
//         title: 'Visit Requests',
//         showBackButton: false,
//         actions: [
//           IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
//         ],
//       ),
//       body: Consumer<VisitRequestsViewModel>(
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
//               buildHeaderStats(viewModel),

//               // ! seller_home_screen_widget.dart
//               // Filter Tabs
//               // _buildFilterTabs(viewModel),

//               // // Visit Requests List
//               // Expanded(child: _buildVisitList(viewModel)),
//             ],
//           );
//         },
//       ),
//     );
//   }


// }
