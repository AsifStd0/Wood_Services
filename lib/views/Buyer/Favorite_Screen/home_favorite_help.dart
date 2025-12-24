// // Add this helper function
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
// import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';

// BuyerHomeViewModel getViewModel(BuildContext context) {
//   return Provider.of<BuyerHomeViewModel>(context, listen: false);
// }

// // Then in your build method:
// void onFavoriteTap(BuildContext context, BuyerProductModel product) async {
//   final viewModel = getViewModel(context);

//   // Show loading
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(product.isFavorited ? 'Removing...' : 'Adding...')),
//   );

//   try {
//     await viewModel.toggleFavorite(product.id);

//     // Show success
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(product.isFavorited ? 'Removed!' : 'Added!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   } catch (e) {
//     // Show error
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Error: ${e.toString()}'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }
