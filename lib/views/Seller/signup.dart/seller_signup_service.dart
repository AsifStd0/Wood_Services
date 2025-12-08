// services/seller_signup_service.dart
import 'package:wood_service/views/Seller/signup.dart/seller_signup_model.dart';

class SellerSignupService {
  Future<bool> registerSeller(SellerModel sellerData) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Print data for verification (replace with actual API call)
    print('Seller Registration Data:');
    print(sellerData.toJson());

    // Simulate successful registration
    return true;

    // For actual implementation:
    // final response = await http.post(
    //   Uri.parse('your-api-endpoint'),
    //   body: jsonEncode(sellerData.toJson()),
    //   headers: {'Content-Type': 'application/json'},
    // );
    //
    // return response.statusCode == 200;
  }
}
