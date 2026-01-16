// import 'package:wood_service/app/locator.dart';
// import 'package:wood_service/core/services/buyer_local_storage_service.dart';
// import 'package:wood_service/core/services/seller_local_storage_service.dart';

// class AuthService {
//   final BuyerLocalStorageService _buyerStorage =
//       locator<BuyerLocalStorageService>();
//   final SellerLocalStorageService _sellerStorage =
//       locator<SellerLocalStorageService>();

//   Future<Map<String, dynamic>> getCurrentUser() async {
//     try {
//       print('🔍 Getting current user for chat...');

//       // Check buyer first since logs show buyer is logged in
//       final isBuyerLoggedIn = await _buyerStorage.isBuyerLoggedIn();
//       if (isBuyerLoggedIn) {
//         final token = await _buyerStorage.getBuyerToken();
//         final data = await _buyerStorage.getBuyerData();

//         print('✅ Buyer logged in: ${data?['_id']}');

//         return {
//           'userId': data?['_id']?.toString(),
//           'userType': 'buyer',
//           'token': token ?? '',
//           'userName': data?['fullName'] ?? data?['businessName'] ?? 'Buyer',
//         };
//       }

//       // Check seller
//       final isSellerLoggedIn = await _sellerStorage.isSellerLoggedIn();
//       if (isSellerLoggedIn) {
//         final token = await _sellerStorage.getSellerToken();
//         final data = await _sellerStorage.getSellerData();

//         print('✅ Seller logged in: ${data?['_id']}');

//         return {
//           'userId': data?['_id']?.toString(),
//           'userType': 'seller',
//           'token': token ?? '',
//           'userName': data?['fullName'] ?? data?['shopName'] ?? 'Seller',
//         };
//       }

//       print('❌ No user logged in');
//       throw Exception('No user logged in');
//     } catch (e) {
//       print('❌ Error in getCurrentUser: $e');
//       throw Exception('Failed to get current user: $e');
//     }
//   }
// }
