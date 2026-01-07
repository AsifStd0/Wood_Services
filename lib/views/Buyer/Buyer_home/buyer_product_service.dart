// services/buyer_product_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/buyer_local_storage_service.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';

class BuyerProductService {
  static const String baseUrl = 'http://192.168.18.107:5001/api/buyer/products';
  final BuyerLocalStorageService _storage = locator<BuyerLocalStorageService>();

  Future<List<BuyerProductModel>> getProducts() async {
    try {
      final token = await _storage.getBuyerToken();

      if (token == null || token.isEmpty) {
        throw Exception('Buyer not authenticated');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['products'] is List) {
          return _parseProducts(data['products'] as List);
        }
      }

      return [];
    } catch (error) {
      log('❌ Product Service Error: $error');
      return [];
    }
  }

  List<BuyerProductModel> _parseProducts(List<dynamic> productsJson) {
    return productsJson
        .map((json) {
          try {
            return BuyerProductModel.fromJson(json);
          } catch (e) {
            log('Failed to parse product: $e');
            return null;
          }
        })
        .where((product) => product != null)
        .cast<BuyerProductModel>()
        .toList();
  }
}

// ! **********
// import 'dart:convert';
// import 'dart:developer';

// import 'package:http/http.dart' as http;
// import 'package:wood_service/app/locator.dart';
// import 'package:wood_service/core/services/buyer_local_storage_service.dart';
// import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';

// class BuyerProductService {
//   String get baseUrl => 'http://192.168.1.51:5001/api/buyer/products';
//   Future<List<BuyerProductModel>> getProducts() async {
//     final BuyerLocalStorageService buyerStorage =
//         locator<BuyerLocalStorageService>();

//     try {
//       // Get token from storage service
//       final token = await buyerStorage.getBuyerToken();
//       log('token is here: $token');

//       if (token == null || token.isEmpty) {
//         throw Exception('Buyer not authenticated');
//       }
//       log('token is here ???');
//       final response = await http.get(
//         Uri.parse(baseUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
//       log('222 ');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         // print('🔍 Parsed JSON Data: $data'); // Add this

//         if (data['success'] == true) {
//           if (data['products'] is List) {
//             print('📦 Products list length: ${data['products'].length}');

//             List<BuyerProductModel> products = [];

//             for (var i = 0; i < data['products'].length; i++) {
//               try {
//                 log(
//                   'BuyerProductService BuyerProductService BuyerProductService BuyerProductService BuyerProductService🔄 Parsing product ${i + 1}: ${data['products'][i]}',
//                 );
//                 final product = BuyerProductModel.fromJson(data['products'][i]);
//                 products.add(product);
//                 print('✅ Added product: ${product.title}');
//               } catch (e, stackTrace) {
//                 print('❌ Failed to parse product ${i + 1}: $e');
//                 print('❌ Stack trace: $stackTrace');
//                 print('❌ Problematic JSON: ${data['products'][i]}');
//               }
//             }

//             print(
//               '\n🎯 Total parsed: ${products.length}/${data['products'].length} products',
//             );
//             return products;
//           } else {
//             print(
//               '⚠️ products is not a List, it\'s: ${data['products'].runtimeType}',
//             );
//           }
//         } else {
//           print('❌ API returned success: false');
//           print('❌ Message: ${data['message']}');
//         }
//       } else {
//         print('❌ HTTP Error: ${response.statusCode}');
//         print('❌ Response: ${response.body}');
//       }

//       return [];
//     } catch (error) {
//       print('❌ Network Error: $error');
//       print('❌ Stack trace: ${StackTrace.current}');
//       return [];
//     }
//   }
// }
