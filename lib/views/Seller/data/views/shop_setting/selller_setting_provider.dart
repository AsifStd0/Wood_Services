// selller_setting_provider.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/shop_model.dart';

class ShopSettingsViewModel extends ChangeNotifier {
  // Personal Information
  String _fullName = '';
  String _email = '';
  String _phoneNumber = '';

  // Business Information
  String _businessName = '';
  String _shopName = '';
  String _description = '';
  String _address = '';

  // Shop Branding
  File? _shopLogo;
  File? _shopBanner;

  // Categories
  List<String> _categories = [];

  // Bank Details
  String _bankName = '';
  String _accountNumber = '';
  String _iban = '';

  // Documents
  List<ShopDocument> _documents = [];

  // UI State
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isVerified = false;
  bool _hasData = false;

  // Getters
  String get fullName => _fullName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get businessName => _businessName;
  String get shopName => _shopName;
  String get description => _description;
  String get address => _address;
  File? get shopLogo => _shopLogo;
  File? get shopBanner => _shopBanner;
  List<String> get categories => _categories;
  String get bankName => _bankName;
  String get accountNumber => _accountNumber;
  String get iban => _iban;
  List<ShopDocument> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  bool get isVerified => _isVerified;
  bool get hasData => _hasData;

  // Load seller data from signup (you need to implement this)
  Future<void> loadSellerDataFromSignup() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual data loading from your storage/API
      // This should load the data that was entered during seller signup

      // Example of loading data:
      // _fullName = await StorageService.getSellerFullName();
      // _email = await StorageService.getSellerEmail();
      // _businessName = await StorageService.getBusinessName();
      // etc...

      await Future.delayed(Duration(seconds: 2)); // Simulate loading

      // Set sample data for demonstration
      _fullName = 'John Doe';
      _email = 'john@example.com';
      _phoneNumber = '+1234567890';
      _businessName = 'Wood Craft Enterprises';
      _shopName = 'Artisan Woodworks';
      _description =
          'Specialized in handmade wooden furniture and home decor items.';
      _address = '123 Main Street, City, State 12345';
      _categories = ['Furniture', 'Home Decor', 'Office Furniture'];
      _bankName = 'City Bank';
      _accountNumber = '****1234';
      _iban = 'US123456789';

      _hasData = true;
    } catch (e) {
      _hasData = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setters
  void setFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void setBusinessName(String value) {
    _businessName = value;
    notifyListeners();
  }

  void setShopName(String value) {
    _shopName = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  void setShopLogo(File? file) {
    _shopLogo = file;
    notifyListeners();
  }

  void setShopBanner(File? file) {
    _shopBanner = file;
    notifyListeners();
  }

  void setBankName(String value) {
    _bankName = value;
    notifyListeners();
  }

  void setAccountNumber(String value) {
    _accountNumber = value;
    notifyListeners();
  }

  void setIban(String value) {
    _iban = value;
    notifyListeners();
  }

  void setEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  void addCategory(String category) {
    _categories.add(category);
    notifyListeners();
  }

  void removeCategory(String category) {
    _categories.remove(category);
    notifyListeners();
  }

  void addDocument(ShopDocument doc) {
    _documents.add(doc);
    notifyListeners();
  }

  void removeDocument(String id) {
    _documents.removeWhere((doc) => doc.id == id);
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual save logic
      await Future.delayed(Duration(seconds: 2));

      _isEditing = false;
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
// // view_models/shop_settings_view_model.dart
// import 'package:flutter/foundation.dart';
// import 'package:wood_service/views/Seller/data/views/shop_setting/shop_model.dart';

// class ShopSettingsViewModel with ChangeNotifier {
//   ShopModel _shop = ShopModel(
//     sellerId: '',
//     shopName: 'Asif Khan',
//     ownerName: 'Asif Khan',
//     description: 'Description is here about ..... shop',
//     categories: ['Handmade Jewelry'],
//     phoneNumber: '+1234567890',
//     email: 'asif@example.com',
//     address: '123 Main Street, City, Country',
//   );

//   ShopModel get shop => _shop;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;

//   bool _isEditing = false;
//   bool get isEditing => _isEditing;

//   // Setters
//   void setShopName(String name) {
//     _shop = _shop.copyWith(shopName: name);
//     notifyListeners();
//   }

//   void setOwnerName(String name) {
//     _shop = _shop.copyWith(ownerName: name);
//     notifyListeners();
//   }

//   void setDescription(String description) {
//     _shop = _shop.copyWith(description: description);
//     notifyListeners();
//   }

//   void setBannerImage(String imageUrl) {
//     _shop = _shop.copyWith(bannerImage: imageUrl);
//     notifyListeners();
//   }

//   void setLogoImage(String imageUrl) {
//     _shop = _shop.copyWith(logoImage: imageUrl);
//     notifyListeners();
//   }

//   void setCategories(List<String> categories) {
//     _shop = _shop.copyWith(categories: categories);
//     notifyListeners();
//   }

//   void setDeliveryLeadTime(int days) {
//     _shop = _shop.copyWith(deliveryLeadTime: days);
//     notifyListeners();
//   }

//   void setReturnPolicy(String policy) {
//     _shop = _shop.copyWith(returnPolicy: policy);
//     notifyListeners();
//   }

//   void setPhoneNumber(String phone) {
//     _shop = _shop.copyWith(phoneNumber: phone);
//     notifyListeners();
//   }

//   void setEmail(String email) {
//     _shop = _shop.copyWith(email: email);
//     notifyListeners();
//   }

//   void setAddress(String address) {
//     _shop = _shop.copyWith(address: address);
//     notifyListeners();
//   }

//   void addDocument(ShopDocument document) {
//     final updatedDocuments = List<ShopDocument>.from(_shop.documents)
//       ..add(document);
//     _shop = _shop.copyWith(documents: updatedDocuments);
//     notifyListeners();
//   }

//   void removeDocument(String documentId) {
//     final updatedDocuments = List<ShopDocument>.from(_shop.documents)
//       ..removeWhere((doc) => doc.id == documentId);
//     _shop = _shop.copyWith(documents: updatedDocuments);
//     notifyListeners();
//   }

//   void setEditing(bool editing) {
//     _isEditing = editing;
//     notifyListeners();
//   }

//   // Validation
//   bool get isFormValid {
//     return _shop.shopName.isNotEmpty &&
//         _shop.ownerName.isNotEmpty &&
//         _shop.description.isNotEmpty &&
//         _shop.phoneNumber.isNotEmpty &&
//         _shop.email.isNotEmpty &&
//         _shop.address.isNotEmpty;
//   }

//   // Actions
//   Future<bool> saveChanges() async {
//     if (!isFormValid) {
//       _errorMessage = 'Please fill all required fields';
//       notifyListeners();
//       return false;
//     }

//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));

//       _shop = _shop.copyWith(updatedAt: DateTime.now());
//       _isEditing = false;
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = 'Failed to save changes: $e';
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> loadShopData() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       // Simulate API call to load shop data
//       await Future.delayed(const Duration(seconds: 1));

//       // Mock data - replace with actual API call
//       _shop = ShopModel(
//         sellerId: 'seller_123',
//         shopName: 'Asif Khan Handmade',
//         ownerName: 'Asif Khan',
//         description:
//             'Specializing in handmade jewelry and custom wood crafts. We create unique pieces with attention to detail and quality craftsmanship.',
//         bannerImage: null,
//         logoImage: null,
//         rating: 4.5,
//         reviewCount: 24,
//         categories: ['Handmade Jewelry', 'Wood Crafts', 'Custom Orders'],
//         deliveryLeadTime: 7,
//         returnPolicy: '30 days',
//         isVerified: true,
//         phoneNumber: '+1 (555) 123-4567',
//         email: 'asif@handmadecrafts.com',
//         address: '123 Artisan Street, Craftville, CA 90210',
//         documents: [
//           ShopDocument(
//             id: 'doc1',
//             name: 'Business License',
//             url: '',
//             type: 'license',
//             uploadDate: DateTime.now().subtract(const Duration(days: 30)),
//             isVerified: true,
//           ),
//           ShopDocument(
//             id: 'doc2',
//             name: 'Tax Certificate',
//             url: '',
//             type: 'tax_certificate',
//             uploadDate: DateTime.now().subtract(const Duration(days: 25)),
//             isVerified: true,
//           ),
//         ],
//       );
//     } catch (e) {
//       _errorMessage = 'Failed to load shop data: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }
