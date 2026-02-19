// models/user_model.dart - Update UserModel class

import 'dart:convert';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? password;
  final String? existingPassword;
  final int? phone; // Changed from String? to int?
  final String role;
  final String? address;

  // Seller specific
  final String? businessName;
  final String? shopName;
  final String? businessDescription;
  final String? businessAddress;
  final String? iban;

  // Image URLs (after upload) - SINGLE strings, not arrays
  final String? profileImage;
  final String? shopLogo;
  final String? shopBanner;
  final String? businessLicense;
  final String? taxCertificate;
  final String? identityProof;
  // ! *****
  final bool? isVerified;
  final bool isActive;
  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.existingPassword,
    this.phone,
    required this.role,
    this.address,
    this.businessName,
    this.shopName,
    this.businessDescription,
    this.businessAddress,
    this.iban,
    this.profileImage,
    this.shopLogo,
    this.shopBanner,
    this.businessLicense,
    this.taxCertificate,
    this.identityProof,
    this.isVerified = false,
    this.isActive = true,
  });

  // factory UserModel.fromLoginResponse(Map<String, dynamic> response) {
  //   final userData = response['data']['user'] as Map<String, dynamic>;
  //   return UserModel.fromJson(userData);
  // }
  // models/user_model.dart - Update toJson() method

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      if (existingPassword != null) 'existingPassword': existingPassword,
      if (phone != null) 'phone': phone,
      'role': role,
      if (address != null) 'address': address,
      if (businessName != null) 'businessName': businessName,
      if (shopName != null) 'shopName': shopName,
      if (businessDescription != null)
        'businessDescription': businessDescription,
      if (businessAddress != null) 'businessAddress': businessAddress,
      if (iban != null) 'iban': iban,
      // Ensure these are sent as strings, not arrays
      if (profileImage != null) 'profileImage': _ensureString(profileImage!),
      if (shopLogo != null) 'shopLogo': _ensureString(shopLogo!),
      if (shopBanner != null) 'shopBanner': _ensureString(shopBanner!),
      if (businessLicense != null)
        'businessLicense': _ensureString(businessLicense!),
      if (taxCertificate != null)
        'taxCertificate': _ensureString(taxCertificate!),
      if (identityProof != null) 'identityProof': _ensureString(identityProof!),
      'isVerified': isVerified ?? false,
      'isActive': isActive,
    };
  }

  // models/user_model.dart - Fix the fromJson method

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Helper function to extract string from potential array
      String? extractString(dynamic value) {
        if (value == null) return null;
        if (value is String) return value.isEmpty ? null : value;
        if (value is List) {
          return value.isNotEmpty ? value[0].toString() : null;
        }
        return value.toString();
      }

      // Helper to parse role
      String parseRole(dynamic roleValue) {
        if (roleValue == null) return 'buyer';
        if (roleValue is List) {
          return roleValue.isNotEmpty ? roleValue[0].toString() : 'buyer';
        }
        return roleValue.toString();
      }

      // Helper to parse phone
      int? parsePhone(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is String) {
          final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
          return int.tryParse(digits);
        }
        if (value is num) return value.toInt();
        return null;
      }

      dynamic addressValue = json['address'];
      String? parsedAddress;

      if (addressValue == null) {
        parsedAddress = null;
      } else if (addressValue is String) {
        // Check if it's a JSON string like "{}"
        if (addressValue == '{}' || addressValue.isEmpty) {
          parsedAddress = null;
        } else {
          try {
            // Try to decode as JSON
            final decoded = jsonDecode(addressValue);
            if (decoded is Map && decoded.isEmpty) {
              parsedAddress = null;
            } else {
              parsedAddress = addressValue;
            }
          } catch (e) {
            // If not JSON, use as is
            parsedAddress = addressValue;
          }
        }
      } else if (addressValue is Map) {
        // Convert map to string if needed
        parsedAddress = addressValue.toString();
      } else {
        parsedAddress = addressValue.toString();
      }

      return UserModel(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        password: json['password']?.toString(),
        existingPassword: json['existingPassword']?.toString(),
        phone: parsePhone(json['phone']), // Use helper
        role: parseRole(json['roles'] ?? json['role']), // Use helper
        address: parsedAddress,
        businessName: extractString(json['businessName']),
        shopName: extractString(json['shopName']),
        businessDescription: extractString(json['businessDescription']),
        businessAddress: extractString(json['businessAddress']),
        iban: extractString(json['iban']),
        // Use the helper function to ensure strings, not arrays
        profileImage: extractString(json['profileImage']),
        shopLogo: extractString(json['shopLogo']),
        shopBanner: extractString(json['shopBanner']),
        businessLicense: extractString(json['businessLicense']),
        taxCertificate: extractString(json['taxCertificate']),
        identityProof: extractString(json['identityProof']),
        isVerified: json['isVerified'] ?? false,
        isActive: json['isActive'] ?? true,
      );
    } catch (e) {
      print('❌ Error parsing UserModel: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }
  // Helper method to ensure value is a string, not an array
  static String _ensureString(dynamic value) {
    if (value is String) return value;
    if (value is List) {
      // If it's an array, take the first element and convert to string
      if (value.isNotEmpty) {
        final first = value[0];
        return first.toString();
      }
      return '';
    }
    return value.toString();
  }

  Map<String, dynamic> toFormData() {
    final data = <String, dynamic>{'name': name, 'email': email};

    // Add optional fields if they exist
    if (password != null && password!.isNotEmpty) data['password'] = password!;
    if (existingPassword != null && existingPassword!.isNotEmpty) {
      data['existingPassword'] = existingPassword!;
    }
    if (phone != null) data['phone'] = phone!;
    if (address != null && address!.isNotEmpty) data['address'] = address!;
    if (businessName != null && businessName!.isNotEmpty) {
      data['businessName'] = businessName!;
    }
    if (shopName != null && shopName!.isNotEmpty) data['shopName'] = shopName!;
    if (businessDescription != null && businessDescription!.isNotEmpty) {
      data['businessDescription'] = businessDescription!;
    }
    if (businessAddress != null && businessAddress!.isNotEmpty) {
      data['businessAddress'] = businessAddress!;
    }
    if (iban != null && iban!.isNotEmpty) data['iban'] = iban!;

    return data;
  }

  // Helper methods
  bool get isSeller => role == 'seller';
  bool get isBuyer => role == 'buyer';
  bool get isAdmin => role == 'admin';

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? existingPassword,
    int? phone,
    String? role,
    String? address,
    String? businessName,
    String? shopName,
    String? businessDescription,
    String? businessAddress,
    String? iban,
    String? profileImage,
    String? shopLogo,
    String? shopBanner,
    String? businessLicense,
    String? taxCertificate,
    String? identityProof,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      existingPassword: existingPassword ?? this.existingPassword,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      businessName: businessName ?? this.businessName,
      shopName: shopName ?? this.shopName,
      businessDescription: businessDescription ?? this.businessDescription,
      businessAddress: businessAddress ?? this.businessAddress,
      iban: iban ?? this.iban,
      profileImage: profileImage ?? this.profileImage,
      shopLogo: shopLogo ?? this.shopLogo,
      shopBanner: shopBanner ?? this.shopBanner,
      businessLicense: businessLicense ?? this.businessLicense,
      taxCertificate: taxCertificate ?? this.taxCertificate,
      identityProof: identityProof ?? this.identityProof,
    );
  }
}
