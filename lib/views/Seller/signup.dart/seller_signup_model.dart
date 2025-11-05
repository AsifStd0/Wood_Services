// models/seller_model.dart
import 'dart:io';

class SellerModel {
  final PersonalInfo personalInfo;
  final BusinessInfo businessInfo;
  final BankDetails bankDetails;
  final ShopBranding shopBranding;

  SellerModel({
    required this.personalInfo,
    required this.businessInfo,
    required this.bankDetails,
    required this.shopBranding,
  });

  Map<String, dynamic> toJson() {
    return {
      'personalInfo': personalInfo.toJson(),
      'businessInfo': businessInfo.toJson(),
      'bankDetails': bankDetails.toJson(),
      'shopBranding': shopBranding.toJson(),
    };
  }
}

class PersonalInfo {
  final String fullName;
  final String email;
  final String phone;
  final String countryCode;
  final String password;

  PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'countryCode': countryCode,
    };
  }
}

class BusinessInfo {
  final String businessName;
  final String shopName;
  final String description;
  final String address;
  final List<String> categories;

  BusinessInfo({
    required this.businessName,
    required this.shopName,
    required this.description,
    required this.address,
    required this.categories,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'shopName': shopName,
      'description': description,
      'address': address,
      'categories': categories,
    };
  }
}

class BankDetails {
  final String bankName;
  final String accountNumber;
  final String iban;

  BankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.iban,
  });

  Map<String, dynamic> toJson() {
    return {'bankName': bankName, 'accountNumber': accountNumber, 'iban': iban};
  }
}

class ShopBranding {
  final File? shopLogo;
  final File? shopBanner;

  ShopBranding({this.shopLogo, this.shopBanner});

  Map<String, dynamic> toJson() {
    return {'shopLogo': shopLogo?.path, 'shopBanner': shopBanner?.path};
  }
}
