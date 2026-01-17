// view_models/add_product_view_model.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/new_storage/unified_local_storage_service_impl.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_model.dart';

class SellerProductProvider extends ChangeNotifier {
  final UnifiedLocalStorageServiceImpl _storage;
  final Dio _dio;

  SellerProductProvider({UnifiedLocalStorageServiceImpl? storage, Dio? dio})
    : _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>(),
      _dio = dio ?? Dio() {
    // Initialize Dio with correct base URL
    _dio.options.baseUrl = 'http://3.27.171.3/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<String?> _getToken() async {
    try {
      final token = await _storage.getToken();
      log(
        '🔑 Token retrieved: ${token != null && token.isNotEmpty ? "Yes" : "No"}',
      );

      if (token == null || token.isEmpty) {
        log('❌ No token found in storage.');
        return null;
      }

      return token;
    } catch (e) {
      log('❌ Error retrieving token: $e');
      return null;
    }
  }

  // Initialize product - Match exactly with screenshot
  SellerProduct _product = SellerProduct(
    title: '',
    shortDescription: '',
    description: '',
    category: '',
    productType:
        'Customize Product', // MUST match: "Customize Product" or "Ready Product"
    tags: [],
    price: 0.0,
    salePrice: null,
    costPrice: null,
    taxRate: 0.0,
    currency: 'USD',
    priceUnit: 'per item', // MUST match: "per item", "per hour", etc.
    sku: '',
    stockQuantity: 0,
    lowStockAlert: 2,
    weight: null,
    dimensions: null,
    variants: [],
    location: '',
    images: [],
  );

  // State
  int _currentTabIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  final List<File> _selectedImages = [];
  File? _featuredImage;

  // Getters
  SellerProduct get product => _product;
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<File> get selectedImages => _selectedImages;
  File? get featuredImage => _featuredImage;

  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Update methods (keep all your existing update methods)
  void updateTitle(String title) {
    _product = _product.copyWith(title: title);
    notifyListeners();
  }

  void updateShortDescription(String desc) {
    _product = _product.copyWith(shortDescription: desc);
    notifyListeners();
  }

  void updateDescription(String desc) {
    _product = _product.copyWith(description: desc);
    notifyListeners();
  }

  // In your updateCategory method
  void updateCategory(String category) {
    log('📝 Updating category to: "$category"');
    log('📝 Category length: ${category.length}');
    log('📝 Category characters: ${category.codeUnits}');

    // Trim any whitespace or commas
    final trimmedCategory = category.trim();
    if (trimmedCategory != category) {
      log('⚠️ Category was trimmed from "$category" to "$trimmedCategory"');
    }

    _product = _product.copyWith(category: trimmedCategory);
    notifyListeners();
  }

  // Add debugging for productType
  void updateProductType(String type) {
    log('📝 Updating productType to: "$type"');
    log('📝 productType length: ${type.length}');

    // Trim any trailing commas or whitespace
    final trimmedType = type.trim().replaceAll(',', '');
    if (trimmedType != type) {
      log('⚠️ productType was trimmed from "$type" to "$trimmedType"');
    }

    _product = _product.copyWith(productType: trimmedType);
    notifyListeners();
  }

  void updateTags(List<String> tags) {
    _product = _product.copyWith(tags: tags);
    notifyListeners();
  }

  void updateLocation(String location) {
    _product = _product.copyWith(location: location);
    notifyListeners();
  }

  void updatePrice(double price) {
    _product = _product.copyWith(price: price);
    notifyListeners();
  }

  void updateSalePrice(double? price) {
    _product = _product.copyWith(salePrice: price);
    notifyListeners();
  }

  void updateCostPrice(double? price) {
    _product = _product.copyWith(costPrice: price);
    notifyListeners();
  }

  void updateTaxRate(double rate) {
    _product = _product.copyWith(taxRate: rate);
    notifyListeners();
  }

  void updateCurrency(String currency) {
    _product = _product.copyWith(currency: currency);
    notifyListeners();
  }

  void updatePriceUnit(String unit) {
    _product = _product.copyWith(priceUnit: unit);
    notifyListeners();
  }

  void updateSku(String sku) {
    _product = _product.copyWith(sku: sku);
    notifyListeners();
  }

  void updateStockQuantity(int quantity) {
    _product = _product.copyWith(stockQuantity: quantity);
    notifyListeners();
  }

  void updateLowStockAlert(int? alert) {
    _product = _product.copyWith(lowStockAlert: alert);
    notifyListeners();
  }

  void updateWeight(double? weight) {
    _product = _product.copyWith(weight: weight);
    notifyListeners();
  }

  void updateDimensions({
    double? length,
    double? width,
    double? height,
    String? specification,
  }) {
    final dimensions = ProductDimensions(
      length: length ?? 0.0,
      width: width ?? 0.0,
      height: height ?? 0.0,
      specification: specification,
    );
    _product = _product.copyWith(dimensions: dimensions);
    notifyListeners();
  }

  void addVariant(ProductVariant variant) {
    final updatedVariants = List<ProductVariant>.from(_product.variants)
      ..add(variant);
    _product = _product.copyWith(variants: updatedVariants);
    notifyListeners();
  }

  void removeVariant(int index) {
    if (index >= 0 && index < _product.variants.length) {
      final updatedVariants = List<ProductVariant>.from(_product.variants)
        ..removeAt(index);
      _product = _product.copyWith(variants: updatedVariants);
      notifyListeners();
    }
  }

  // Image handling
  void addImage(File image) {
    if (_selectedImages.length < 10) {
      _selectedImages.add(image);
      _product = _product.copyWith(images: [..._selectedImages]);
      notifyListeners();
    }
  }

  void setFeaturedImage(File image) {
    _featuredImage = image;
    if (!_selectedImages.any((file) => file.path == image.path)) {
      _selectedImages.insert(0, image);
      _product = _product.copyWith(images: [..._selectedImages]);
    }
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      if (_featuredImage != null &&
          _selectedImages[index].path == _featuredImage!.path) {
        _featuredImage = null;
      }
      _selectedImages.removeAt(index);
      _product = _product.copyWith(images: [..._selectedImages]);
      notifyListeners();
    }
  }

  Future<void> pickFeaturedImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setFeaturedImage(File(image.path));
    }
  }

  Future<void> pickMultipleImages() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      for (var image in images) {
        if (_selectedImages.length < 10) {
          final file = File(image.path);
          if (!_selectedImages.any((f) => f.path == file.path)) {
            addImage(file);
          }
        }
      }
    }
  }

  // ! ========== PUBLISH PRODUCT - CORRECTED VERSION ==========

  Future<bool> publishProduct() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // In your publishProduct() method, add this at the beginning:
      log('🔍 === DEBUG BEFORE VALIDATION ===');
      log('🔍 Category: "${_product.category}"');
      log('🔍 Category type: ${_product.category.runtimeType}');
      log('🔍 productType: "${_product.productType}"');
      log('🔍 productType type: ${_product.productType.runtimeType}');
      log('🔍 Category trimmed: "${_product.category.trim()}"');
      log('🔍 productType trimmed: "${_product.productType.trim()}"');
      log('🔍 === END DEBUG ===');

      // Then check what your formData contains

      // Validate
      if (_product.title.isEmpty ||
          _product.description.isEmpty ||
          _product.category.isEmpty) {
        throw Exception('Please complete all required fields');
      }

      if (_selectedImages.isEmpty) {
        throw Exception('Please upload at least one product image');
      }

      // Get token
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      // Prepare FormData
      final formData = FormData();

      // ========== ADD TEXT FIELDS ==========
      // Use EXACT camelCase field names from your screenshot
      final Map<String, dynamic> apiFields = {
        'title': _product.title,
        'shortDescription': _product.shortDescription,
        'description': _product.description,
        'category': _product.category,
        'productType': _product
            .productType, // Must be "Customize Product" or "Ready Product"
        'tags': jsonEncode(_product.tags), // JSON array string
        'price': _product.price.toString(),
        'salePrice': _product.salePrice?.toString() ?? '',
        'costPrice': _product.costPrice?.toString() ?? '',
        'taxRate': _product.taxRate.toString(),
        'currency': _product.currency,
        'priceUnit': _product.priceUnit, // Must be "per item", "per hour", etc.
        'sku': _product.sku,
        'stockQuantity': _product.stockQuantity.toString(),
        'lowStockAlert': _product.lowStockAlert?.toString() ?? '2',
        'weight': _product.weight?.toString() ?? '',
        'location': 'peshawar pakitan',
      };
      log('📋 === FORM DATA FIELDS ===');
      apiFields.forEach((key, value) {
        if (key == 'category' || key == 'productType') {
          log('   $key: "$value" (length: ${value.toString().length})');
          log('   $key chars: ${value.toString().codeUnits}');
        } else {
          log('   $key: $value');
        }
      });

      // Add dimensions if available
      if (_product.dimensions != null) {
        apiFields['dimensions'] = jsonEncode({
          'length': _product.dimensions!.length,
          'width': _product.dimensions!.width,
          'height': _product.dimensions!.height,
          'specification': _product.dimensions!.specification ?? '',
        });
      }

      // Add variants if available
      if (_product.variants.isNotEmpty) {
        apiFields['variants'] = jsonEncode(
          _product.variants.map((v) => v.toJson()).toList(),
        );
      }

      // Add all fields to formData
      log('📋 === FORM DATA FIELDS ===');
      apiFields.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          formData.fields.add(MapEntry(key, value.toString()));
          log('   $key: $value');
        }
      });
      log('📋 =======================');

      // ========== ADD IMAGES ==========
      // According to screenshot: "images" field (plural)
      // "First image in the list would be featured image"
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];

        // Use 'images' as field name for all images
        formData.files.add(
          MapEntry(
            'images', // SINGLE field name for ALL images
            await MultipartFile.fromFile(
              image.path,
              filename:
                  'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            ),
          ),
        );

        log('📸 Added image $i to "images" field');
      }

      log('📁 Total files: ${formData.files.length}');

      // ========== SEND REQUEST ==========
      log('🌐 === API REQUEST ===');
      log('   Endpoint: /seller/services');
      log('   Method: POST');
      log('   Fields: ${formData.fields.length}');
      log('   Files: ${formData.files.length}');
      log('🌐 ===================');

      final response = await _dio.post(
        '/seller/services',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('✅ === API RESPONSE ===');
      log('   Status: ${response.statusCode}');
      log('   Data: ${response.data}');
      log('✅ ===================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('🎉 Product published successfully!');
        _isLoading = false;
        resetForm();
        notifyListeners();
        return true;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to publish product',
        );
      }
    } on DioException catch (e) {
      log('❌ === DIO ERROR ===');
      log('   Type: ${e.type}');
      log('   Status: ${e.response?.statusCode}');
      log('   Response: ${e.response?.data}');
      log('❌ =================');

      if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?['message']?.toString() ?? '';
        if (errorMsg.contains('Unexpected field')) {
          _errorMessage = 'Server rejected a field. Check field names.';

          // Debug: Print what we're actually sending
          log('⚠️ Server says "Unexpected field". Checking...');
          // log('   Sending ${formData.fields.length} fields:');
          // for (var field in formData.fields) {
          //   log('     ${field.key}: ${field.value}');
          // }
          // log('   Sending ${formData.files.length} files:');
          // for (var file in formData.files) {
          //   log('     ${file.key}: ${file.value}');
          // }
        } else {
          _errorMessage = 'Server error: $errorMsg';
        }
      } else {
        _errorMessage =
            'Error ${e.response?.statusCode}: ${e.response?.data?['message']}';
      }
    } catch (e) {
      log('❌ === ERROR ===');
      log('   $e');
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void resetForm() {
    _product = SellerProduct(
      title: '',
      shortDescription: '',
      description: '',
      category: '',
      productType: 'Customize Product',
      tags: [],
      price: 0.0,
      salePrice: null,
      costPrice: null,
      taxRate: 0.0,
      currency: 'USD',
      priceUnit: 'per item',
      sku: '',
      stockQuantity: 0,
      lowStockAlert: 2,
      weight: null,
      dimensions: null,
      variants: [],
      location: '',
      images: [],
    );
    _currentTabIndex = 0;
    _selectedImages.clear();
    _featuredImage = null;
    _errorMessage = null;
    notifyListeners();
  }
}
