import 'dart:convert';
import 'dart:io';

class SellerModel {
  final PersonalInfo personalInfo;
  final BusinessInfo businessInfo;
  final BankDetails bankDetails;
  final ShopBrandingImages shopBrandingImages;
  final SellerDocuments documentsImage;

  SellerModel({
    required this.personalInfo,
    required this.businessInfo,
    required this.bankDetails,
    required this.shopBrandingImages,
    required this.documentsImage,
  });

  // ========== copyWith METHOD ==========
  SellerModel copyWith({
    PersonalInfo? personalInfo,
    BusinessInfo? businessInfo,
    BankDetails? bankDetails,
    ShopBrandingImages? shopBrandingImages,
    SellerDocuments? documentsImage,
  }) {
    return SellerModel(
      personalInfo: personalInfo ?? this.personalInfo,
      businessInfo: businessInfo ?? this.businessInfo,
      bankDetails: bankDetails ?? this.bankDetails,
      shopBrandingImages: shopBrandingImages ?? this.shopBrandingImages,
      documentsImage: documentsImage ?? this.documentsImage,
    );
  }

  // For LOCAL STORAGE (saving to shared preferences)
  Map<String, dynamic> toJson() {
    return {
      // Personal Info
      'fullName': personalInfo.fullName,
      'email': personalInfo.email,
      'phone': personalInfo.phone,
      'countryCode': personalInfo.countryCode,
      'password': personalInfo.password,

      // Business Info
      'businessName': businessInfo.businessName,
      'shopName': businessInfo.shopName,
      'businessDescription': businessInfo.description,
      'businessAddress': businessInfo.address,
      'categories': businessInfo.categories,

      // Bank Details
      'bankName': bankDetails.bankName,
      'accountNumber': bankDetails.accountNumber,
      'iban': bankDetails.iban,

      // Image paths (store as strings for local storage)
      'shopLogoPath': shopBrandingImages.shopLogo?.path,
      'shopBannerPath': shopBrandingImages.shopBanner?.path,
      'businessLicensePath': documentsImage.businessLicense?.path,
      'taxCertificatePath': documentsImage.taxCertificate?.path,
      'identityProofPath': documentsImage.identityProof?.path,
    };
  }

  // Factory constructor that handles BOTH:
  // 1. LOCAL STORAGE format (from shared preferences)
  // 2. API RESPONSE format (from server)
  factory SellerModel.fromJson(Map<String, dynamic> json) {
    // ========== 1. Handle PHONE ==========
    String phone = '';
    String countryCode = '+1';

    if (json['phone'] != null) {
      if (json['phone'] is Map<String, dynamic>) {
        // API RESPONSE format: {"countryCode":"+1","number":"123456"}
        final phoneObj = json['phone'] as Map<String, dynamic>;
        countryCode = phoneObj['countryCode']?.toString() ?? '+1';
        final number = phoneObj['number']?.toString() ?? '';
        phone = '$countryCode$number';
      } else if (json['phone'] is String) {
        // LOCAL STORAGE format: "+11234567890"
        phone = json['phone'] as String;
      }
    } else {
      // Try to get phone from direct fields
      phone = json['phone']?.toString() ?? '';
      countryCode = json['countryCode']?.toString() ?? '+1';
    }

    // ========== 2. Handle CATEGORIES ==========
    List<String> categories = [];
    if (json['categories'] != null) {
      if (json['categories'] is List) {
        // API RESPONSE format: ["category1", "category2"]
        categories = List<String>.from(json['categories']);
        // print('🏷️ Categories from list: $categories');
      } else if (json['categories'] is String) {
        // LOCAL STORAGE format: JSON string or comma-separated
        try {
          final parsed = jsonDecode(json['categories'] as String);
          if (parsed is List) {
            categories = List<String>.from(parsed);
          }
        } catch (e) {
          // If can't parse, treat as single category
          categories = [json['categories'] as String];
        }
        // print('🏷️ Categories from string: $categories');
      }
    }

    // ========== 3. Handle BANK DETAILS ==========
    String bankName = '';
    String accountNumber = '';
    String iban = '';

    if (json['bankDetails'] != null &&
        json['bankDetails'] is Map<String, dynamic>) {
      // API RESPONSE format: {"bankName":"...","accountNumber":"...","iban":"..."}
      final bankDetails = json['bankDetails'] as Map<String, dynamic>;
      bankName = bankDetails['bankName']?.toString() ?? '';
      accountNumber = bankDetails['accountNumber']?.toString() ?? '';
      iban = bankDetails['iban']?.toString() ?? '';
      // print('🏦 Bank details from API object');
    } else {
      // LOCAL STORAGE format: direct fields
      bankName = json['bankName']?.toString() ?? '';
      accountNumber = json['accountNumber']?.toString() ?? '';
      iban = json['iban']?.toString() ?? '';
      // print('🏦 Bank details from direct fields');
    }

    // ========== 4. Handle SHOP LOGO (File from path or URL) ==========
    File? shopLogo;
    if (json['shopLogo'] != null) {
      if (json['shopLogo'] is Map<String, dynamic>) {
        // API RESPONSE format: {"url":"/uploads/sellers/...","publicId":"..."}
        final logoObj = json['shopLogo'] as Map<String, dynamic>;
        final logoUrl = logoObj['url']?.toString();
        if (logoUrl != null && logoUrl.isNotEmpty) {
          // For API response, we might not want to create a File from URL
          // But we can store the URL for display
          // print('🖼️ Shop logo URL from API: $logoUrl');
          // shopLogo = File(logoUrl); // Only if you want to download it
        }
      } else if (json['shopLogo'] is String) {
        // LOCAL STORAGE format: file path string
        shopLogo = File(json['shopLogo'] as String);
        // print('🖼️ Shop logo from path: ${shopLogo?.path}');
      }
    } else if (json['shopLogoPath'] != null) {
      // Fallback to local storage path
      shopLogo = File(json['shopLogoPath'] as String);
      // print('🖼️ Shop logo from shopLogoPath: ${shopLogo?.path}');
    }

    // ========== 5. Handle SHOP BANNER ==========
    File? shopBanner;
    if (json['shopBanner'] != null) {
      if (json['shopBanner'] is Map<String, dynamic>) {
        final bannerObj = json['shopBanner'] as Map<String, dynamic>;
        final bannerUrl = bannerObj['url']?.toString();
        if (bannerUrl != null && bannerUrl.isNotEmpty) {
          // print('🖼️ Shop banner URL from API: $bannerUrl');
        }
      } else if (json['shopBanner'] is String) {
        shopBanner = File(json['shopBanner'] as String);
        // print('🖼️ Shop banner from path: ${shopBanner?.path}');
      }
    } else if (json['shopBannerPath'] != null) {
      shopBanner = File(json['shopBannerPath'] as String);
      // print('🖼️ Shop banner from shopBannerPath: ${shopBanner?.path}');
    }

    // ========== 6. Handle DOCUMENTS ==========
    SellerDocuments documentsImage = SellerDocuments();

    // Try API format first
    if (json['documents'] != null &&
        json['documents'] is Map<String, dynamic>) {
      final docs = json['documents'] as Map<String, dynamic>;
      print('📄 Documents from API: ${docs.keys.toList()}');

      File? businessLicense;
      File? taxCertificate;
      File? identityProof;

      if (docs['businessLicense'] != null &&
          docs['businessLicense'] is Map<String, dynamic>) {
        final license = docs['businessLicense'] as Map<String, dynamic>;
        final licenseUrl = license['url']?.toString();
        if (licenseUrl != null && licenseUrl.isNotEmpty) {
          print('📄 Business license URL: $licenseUrl');
          // businessLicense = File(licenseUrl);
        }
      }

      if (docs['taxCertificate'] != null &&
          docs['taxCertificate'] is Map<String, dynamic>) {
        final tax = docs['taxCertificate'] as Map<String, dynamic>;
        final taxUrl = tax['url']?.toString();
        if (taxUrl != null && taxUrl.isNotEmpty) {
          print('📄 Tax certificate URL: $taxUrl');
          // taxCertificate = File(taxUrl);
        }
      }

      if (docs['identityProof'] != null &&
          docs['identityProof'] is Map<String, dynamic>) {
        final identity = docs['identityProof'] as Map<String, dynamic>;
        final identityUrl = identity['url']?.toString();
        if (identityUrl != null && identityUrl.isNotEmpty) {
          print('📄 Identity proof URL: $identityUrl');
          // identityProof = File(identityUrl);
        }
      }

      documentsImage = SellerDocuments(
        businessLicense: businessLicense,
        taxCertificate: taxCertificate,
        identityProof: identityProof,
      );
    } else {
      // Try LOCAL STORAGE format
      documentsImage = SellerDocuments(
        businessLicense: json['businessLicensePath'] != null
            ? File(json['businessLicensePath'] as String)
            : null,
        taxCertificate: json['taxCertificatePath'] != null
            ? File(json['taxCertificatePath'] as String)
            : null,
        identityProof: json['identityProofPath'] != null
            ? File(json['identityProofPath'] as String)
            : null,
      );
      print('📄 Documents from local storage paths');
    }

    // ========== 7. Create SellerModel ==========
    return SellerModel(
      personalInfo: PersonalInfo(
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: phone,
        countryCode: countryCode,
        password: json['password']?.toString() ?? '',
      ),
      businessInfo: BusinessInfo(
        businessName: json['businessName']?.toString() ?? '',
        shopName: json['shopName']?.toString() ?? '',
        description:
            json['businessDescription']?.toString() ??
            json['description']?.toString() ??
            '',
        address:
            json['businessAddress']?.toString() ??
            json['address']?.toString() ??
            '',
        categories: categories,
      ),
      bankDetails: BankDetails(
        bankName: bankName,
        accountNumber: accountNumber,
        iban: iban,
      ),
      shopBrandingImages: ShopBrandingImages(
        shopLogo: shopLogo,
        shopBanner: shopBanner,
      ),
      documentsImage: documentsImage,
    );
  }

  // ========== Helper method for API responses ==========
  // Use this when you get response from API update
  factory SellerModel.fromApiResponse(Map<String, dynamic> json) {
    return SellerModel.fromJson(json);
  }

  // ========== Helper method for local storage ==========
  // Use this when loading from shared preferences
  factory SellerModel.fromLocalStorage(Map<String, dynamic> json) {
    return SellerModel.fromJson(json);
  }

  @override
  String toString() {
    return '''
SellerModel{
  personalInfo: {
    fullName: ${personalInfo.fullName},
    email: ${personalInfo.email},
    phone: ${personalInfo.phone},
    countryCode: ${personalInfo.countryCode}
  },
  businessInfo: {
    businessName: ${businessInfo.businessName},
    shopName: ${businessInfo.shopName},
    description: ${businessInfo.description},
    address: ${businessInfo.address},
    categories: ${businessInfo.categories}
  },
  bankDetails: {
    bankName: ${bankDetails.bankName},
    accountNumber: ${bankDetails.accountNumber},
    iban: ${bankDetails.iban}
  },
  shopBrandingImages: {
    shopLogo: ${shopBrandingImages.shopLogo?.path ?? 'null'},
    shopBanner: ${shopBrandingImages.shopBanner?.path ?? 'null'}
  },
  documentsImage: {
    businessLicense: ${documentsImage.businessLicense?.path ?? 'null'},
    taxCertificate: ${documentsImage.taxCertificate?.path ?? 'null'},
    identityProof: ${documentsImage.identityProof?.path ?? 'null'}
  }
}
''';
  }
}

// ========== OTHER CLASSES (keep as is) ==========

class SellerDocuments {
  File? businessLicense;
  File? taxCertificate;
  File? identityProof;

  SellerDocuments({
    this.businessLicense,
    this.taxCertificate,
    this.identityProof,
  });
}

class PersonalInfo {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String countryCode;

  PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.countryCode,
  });

  PersonalInfo copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? countryCode,
  }) {
    return PersonalInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      countryCode: countryCode ?? this.countryCode,
    );
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

  BusinessInfo copyWith({
    String? businessName,
    String? shopName,
    String? description,
    String? address,
    List<String>? categories,
  }) {
    return BusinessInfo(
      businessName: businessName ?? this.businessName,
      shopName: shopName ?? this.shopName,
      description: description ?? this.description,
      address: address ?? this.address,
      categories: categories ?? this.categories,
    );
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

  BankDetails copyWith({
    String? bankName,
    String? accountNumber,
    String? iban,
  }) {
    return BankDetails(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
    );
  }
}

class ShopBrandingImages {
  final File? shopLogo;
  final File? shopBanner;

  ShopBrandingImages({this.shopLogo, this.shopBanner});

  ShopBrandingImages copyWith({File? shopLogo, File? shopBanner}) {
    return ShopBrandingImages(
      shopLogo: shopLogo ?? this.shopLogo,
      shopBanner: shopBanner ?? this.shopBanner,
    );
  }
}
