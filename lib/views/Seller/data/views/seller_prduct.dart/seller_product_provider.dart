// view_models/add_product_view_model.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/services/seller_local_storage_service.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_model.dart';

// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NDM3MTE3MGRjYzgzYTcwNWM0YmZmOCIsImlhdCI6MTc2NjMxMzI0NiwiZXhwIjoxNzY4OTA1MjQ2fQ.jXWiJqFwB6DMTa4CbCEvxcLPdNGqwfA5imge2FtFtCk
class SellerProductProvider extends ChangeNotifier {
  SellerProduct _product = SellerProduct(
    title: '',
    shortDescription: '',
    longDescription: '',
    category: '',
    tags: [],
    basePrice: 0.0,
    salePrice: null,
    costPrice: null,
    taxRate: 0.0,
    currency: 'USD',
    sku: '',
    stockQuantity: 0,
    lowStockAlert: 5,
    weight: null,
    length: null,
    width: null,
    height: null,
    dimensionSpec: '',
    variants: [],
    variantTypes: [],
    images: [],
    videos: [],
    status: 'draft',
    isActive: true,
  );

  // Tab state
  int _currentTabIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Image handling
  final List<File> _selectedImages = [];
  File? _featuredImage;
  final bool _isUploadingImages = false;

  // Getters
  SellerProduct get product => _product;
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<File> get selectedImages => _selectedImages;
  File? get featuredImage => _featuredImage;
  bool get isUploadingImages => _isUploadingImages;

  // Tab navigation
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Basic Tab
  void updateTitle(String title) {
    _product = _product.copyWith(title: title);
    notifyListeners();
  }

  void updateShortDescription(String desc) {
    _product = _product.copyWith(shortDescription: desc);
    notifyListeners();
  }

  void updateLongDescription(String desc) {
    _product = _product.copyWith(longDescription: desc);
    notifyListeners();
  }

  void updateCategory(String category) {
    _product = _product.copyWith(category: category);
    notifyListeners();
  }

  void updateTags(List<String> tags) {
    _product = _product.copyWith(tags: tags);
    notifyListeners();
  }

  // Pricing Tab
  void updateBasePrice(double price) {
    _product = _product.copyWith(basePrice: price);
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

  // Inventory Tab
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

  void updateLength(double? length) {
    _product = _product.copyWith(length: length);
    notifyListeners();
  }

  void updateWidth(double? width) {
    _product = _product.copyWith(width: width);
    notifyListeners();
  }

  void updateHeight(double? height) {
    _product = _product.copyWith(height: height);
    notifyListeners();
  }

  void updateDimensionSpec(String spec) {
    _product = _product.copyWith(dimensionSpec: spec);
    notifyListeners();
  }

  // Variants
  void addVariant(ProductVariant variant) {
    final updatedVariants = List<ProductVariant>.from(_product.variants)
      ..add(variant);
    _product = _product.copyWith(variants: updatedVariants);
    notifyListeners();
  }

  void removeVariant(String variantId) {
    final updatedVariants = List<ProductVariant>.from(_product.variants)
      ..removeWhere((v) => v.id == variantId);
    _product = _product.copyWith(variants: updatedVariants);
    notifyListeners();
  }

  void updateVariantTypes(List<String> types) {
    _product = _product.copyWith(variantTypes: types);
    notifyListeners();
  }

  // Image handling methods
  void addImage(File image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  void setFeaturedImage(File image) {
    _featuredImage = image;
    if (!_selectedImages.any((file) => file.path == image.path)) {
      _selectedImages.insert(0, image); // Insert at beginning as featured
    }
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      // If removing featured image, clear it
      if (_featuredImage != null &&
          _selectedImages[index].path == _featuredImage!.path) {
        _featuredImage = null;
      }
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  void clearImages() {
    _selectedImages.clear();
    _featuredImage = null;
    notifyListeners();
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

  // Validation
  bool validateCurrentTab() {
    switch (_currentTabIndex) {
      case 0: // Basic
        return _product.title.isNotEmpty &&
            _product.shortDescription.isNotEmpty &&
            _product.longDescription.isNotEmpty &&
            _product.category.isNotEmpty;
      case 1: // Pricing
        return _product.basePrice > 0;
      case 2: // Inventory
        return true; // Optional
      case 3: // Variants
        return true; // Optional
      case 4: // Media
        return _selectedImages.isNotEmpty;
      default:
        return false;
    }
  }

  Future<bool> publishProduct() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate all required fields
      if (!validateCurrentTab()) {
        throw Exception('Please complete all required fields');
      }

      // Validate images
      if (_selectedImages.isEmpty) {
        throw Exception('Please upload at least one product image');
      }

      // Get token
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Get the Dio instance
      final dio = locator<Dio>();

      // Prepare FormData for multipart upload
      final formData = FormData();

      // Add all product data as individual fields
      formData.fields.add(MapEntry('title', _product.title));
      formData.fields.add(
        MapEntry('shortDescription', _product.shortDescription),
      );
      formData.fields.add(
        MapEntry('longDescription', _product.longDescription),
      );
      formData.fields.add(MapEntry('category', _product.category));
      formData.fields.add(MapEntry('basePrice', _product.basePrice.toString()));
      formData.fields.add(MapEntry('taxRate', _product.taxRate.toString()));
      formData.fields.add(MapEntry('currency', _product.currency));
      formData.fields.add(MapEntry('sku', _product.sku));
      formData.fields.add(
        MapEntry('stockQuantity', _product.stockQuantity.toString()),
      );
      formData.fields.add(
        MapEntry('lowStockAlert', (_product.lowStockAlert ?? 5).toString()),
      );
      formData.fields.add(MapEntry('status', 'draft'));

      // Add optional fields if they exist
      if (_product.salePrice != null) {
        formData.fields.add(
          MapEntry('salePrice', _product.salePrice.toString()),
        );
      }
      if (_product.costPrice != null) {
        formData.fields.add(
          MapEntry('costPrice', _product.costPrice.toString()),
        );
      }
      if (_product.weight != null) {
        formData.fields.add(MapEntry('weight', _product.weight.toString()));
      }
      if (_product.length != null) {
        formData.fields.add(MapEntry('length', _product.length.toString()));
      }
      if (_product.width != null) {
        formData.fields.add(MapEntry('width', _product.width.toString()));
      }
      if (_product.height != null) {
        formData.fields.add(MapEntry('height', _product.height.toString()));
      }
      if (_product.dimensionSpec.isNotEmpty) {
        formData.fields.add(MapEntry('dimensionSpec', _product.dimensionSpec));
      }

      // Add lists as JSON strings
      if (_product.tags.isNotEmpty) {
        formData.fields.add(MapEntry('tags', jsonEncode(_product.tags)));
      }
      if (_product.variants.isNotEmpty) {
        formData.fields.add(
          MapEntry(
            'variants',
            jsonEncode(_product.variants.map((v) => v.toJson()).toList()),
          ),
        );
      }
      if (_product.variantTypes.isNotEmpty) {
        formData.fields.add(
          MapEntry('variantTypes', jsonEncode(_product.variantTypes)),
        );
      }

      // ========== ADD IMAGES AS FILES ==========
      // First image is featured image
      if (_selectedImages.isNotEmpty && _featuredImage != null) {
        formData.files.add(
          MapEntry(
            'featuredImage',
            await MultipartFile.fromFile(
              _featuredImage!.path,
              filename: 'featured_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );

        log('📸 Added featured image: ${_featuredImage!.path}');
      }

      // Remaining images as gallery images
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];

        // Skip if this is the featured image (already added)
        if (_featuredImage != null && image.path == _featuredImage!.path) {
          continue;
        }

        formData.files.add(
          MapEntry(
            'galleryImages',
            await MultipartFile.fromFile(
              image.path,
              filename:
                  'gallery_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            ),
          ),
        );

        log('📸 Added gallery image $i: ${image.path}');
      }

      log('=== UPLOAD DETAILS ===');
      log('Total images: ${_selectedImages.length}');
      log('Featured image: ${_featuredImage != null ? "Yes" : "No"}');

      // Debug what we're sending
      log('=== FORM DATA FIELDS ===');
      for (var field in formData.fields) {
        log('${field.key}: ${field.value}');
      }

      // Call API
      final response = await dio.post(
        '/api/seller/products',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      // Debug response
      log('Response Data is here: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        resetForm(); // Clear form after successful publish
        notifyListeners();
        return true;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to publish product',
        );
      }
    } catch (e) {
      log('=== ERROR ===');
      log(e.toString());
      if (e is DioException) {
        log('Dio Error Type: ${e.type}');
        log('Dio Error Message: ${e.message}');
        log('Response Data: ${e.response?.data}');
        log('Status Code: ${e.response?.statusCode}');
        log('Request URL: ${e.requestOptions.path}');
      }
      log('=============');

      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> _getToken() async {
    try {
      final localStorage = locator<SellerLocalStorageService>();

      // First try to get seller token
      final sellerToken = await localStorage.getSellerToken();

      // Debug token retrieval
      log('=== TOKEN RETRIEVAL ===');
      log('Seller Token retrieved: ${sellerToken != null}');

      if (sellerToken != null && sellerToken.isNotEmpty) {
        return sellerToken;
      }

      // Fallback to general token
      final generalToken = await localStorage.getSellerToken();
      log('General Token retrieved: ${generalToken != null}');
      if (generalToken != null && generalToken.isNotEmpty) {
        return generalToken;
      }

      log('❌ No token found in storage');

      return null;
    } catch (e) {
      log('Error retrieving token: $e');
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetForm() {
    _product = SellerProduct(
      title: '',
      shortDescription: '',
      longDescription: '',
      category: '',
      tags: [],
      basePrice: 0.0,
      salePrice: null,
      costPrice: null,
      taxRate: 0.0,
      currency: 'USD',
      sku: '',
      stockQuantity: 0,
      lowStockAlert: 5,
      weight: null,
      length: null,
      width: null,
      height: null,
      dimensionSpec: '',
      variants: [],
      variantTypes: [],
      images: [],
      videos: [],
      // documents: [],
      status: 'draft',
    );
    _currentTabIndex = 0;
    _selectedImages.clear();
    _featuredImage = null;
    _errorMessage = null;
    notifyListeners();
  }
}
