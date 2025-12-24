import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';

class BuyerProductService {
  final String baseUrl = 'http://192.168.1.8:5001/api/buyer/products';

  Future<List<BuyerProductModel>> getProducts() async {
    try {
      print('🌐 API Call: $baseUrl');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Status: ${response.statusCode}');
      print('📊 Response Body: ${response.body}'); // Add this

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 Parsed JSON Data: $data'); // Add this

        if (data['success'] == true) {
          print('✅ API returned success: true');
          if (data['products'] is List) {
            print('📦 Products list length: ${data['products'].length}');

            List<BuyerProductModel> products = [];

            for (var i = 0; i < data['products'].length; i++) {
              try {
                log(
                  'BuyerProductService BuyerProductService BuyerProductService BuyerProductService BuyerProductService🔄 Parsing product ${i + 1}: ${data['products'][i]}',
                );
                final product = BuyerProductModel.fromJson(data['products'][i]);
                products.add(product);
                print('✅ Added product: ${product.title}');
              } catch (e, stackTrace) {
                print('❌ Failed to parse product ${i + 1}: $e');
                print('❌ Stack trace: $stackTrace');
                print('❌ Problematic JSON: ${data['products'][i]}');
              }
            }

            print(
              '\n🎯 Total parsed: ${products.length}/${data['products'].length} products',
            );
            return products;
          } else {
            print(
              '⚠️ products is not a List, it\'s: ${data['products'].runtimeType}',
            );
          }
        } else {
          print('❌ API returned success: false');
          print('❌ Message: ${data['message']}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
      }

      return [];
    } catch (error) {
      print('❌ Network Error: $error');
      print('❌ Stack trace: ${StackTrace.current}');
      return [];
    }
  }
}
