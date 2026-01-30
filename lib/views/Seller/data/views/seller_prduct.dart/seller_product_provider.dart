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
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart'
    as uploaded;
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_services.dart';

class SellerProductProvider extends ChangeNotifier {
  final UnifiedLocalStorageServiceImpl _storage;
  final Dio _dio;
  final UploadedProductService? _productService;

  SellerProductProvider({
    UnifiedLocalStorageServiceImpl? storage,
    Dio? dio,
    UploadedProductService? productService,
  }) : _storage = storage ?? locator<UnifiedLocalStorageServiceImpl>(),
       _dio = dio ?? Dio(),
       _productService = productService {
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
      final token = _storage.getToken();
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
  bool _isEditMode = false;
  final List<String> _existingImageUrls =
      []; // URLs of existing images from server

  // Getters
  SellerProduct get product => _product;
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<File> get selectedImages => _selectedImages;
  File? get featuredImage => _featuredImage;
  bool get isEditMode => _isEditMode;
  List<String> get existingImageUrls => _existingImageUrls;

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

  // This updates the category field (different from productType)
  void updateCategory(String category) {
    log('📝 Updating category to: "$category"');
    log('📝 Category length: ${category.length}');

    // Trim any whitespace or commas
    final trimmedCategory = category.trim();
    if (trimmedCategory != category) {
      log('⚠️ Category was trimmed from "$category" to "$trimmedCategory"');
    }

    _product = _product.copyWith(category: trimmedCategory); // This is correct
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
    // Preserve existing dimensions if not provided
    final existingDimensions = _product.dimensions;
    final dimensions = ProductDimensions(
      length: length ?? existingDimensions?.length ?? 0.0,
      width: width ?? existingDimensions?.width ?? 0.0,
      height: height ?? existingDimensions?.height ?? 0.0,
      specification: specification ?? existingDimensions?.specification,
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

  /// Load product from UploadedProductModel immediately (for instant display)
  void loadProductFromModel(uploaded.UploadedProductModel model) {
    log('📦 Loading product from model immediately: ${model.title}');

    _isEditMode = true;
    _errorMessage = null;

    // Convert variants from UploadedProductModel to SellerProduct format
    final variants = model.variants.map((v) {
      return ProductVariant(
        type: v.type,
        value: v.value,
        priceAdjustment: v.priceAdjustment,
      );
    }).toList();

    // Create SellerProduct from UploadedProductModel
    _product = SellerProduct(
      id: model.id,
      title: model.title,
      shortDescription: model.shortDescription,
      description: model.description,
      category: model.category,
      productType: model.productType,
      tags: model.tags,
      price: model.price,
      salePrice: null, // Will be loaded from API if available
      costPrice: null, // Will be loaded from API if available
      taxRate: model.taxRate,
      currency: model.currency,
      priceUnit: model.priceUnit,
      sku: '', // Will be loaded from API if available
      stockQuantity: model.stockQuantity,
      lowStockAlert: model.lowStockAlert,
      weight: null, // Will be loaded from API if available
      dimensions: null, // Will be loaded from API if available
      variants: variants,
      location: model.location,
      images: [],
    );

    // Store existing image URLs
    _existingImageUrls.clear();
    if (model.featuredImage.isNotEmpty) {
      _existingImageUrls.add(model.featuredImage);
    }
    for (var img in model.images) {
      if (img.isNotEmpty && !_existingImageUrls.contains(img)) {
        _existingImageUrls.add(img);
      }
    }

    _selectedImages.clear();
    _featuredImage = null;
    _currentTabIndex = 0;

    log('✅ Product loaded from model - form is ready for editing');
    notifyListeners();
  }

  /// Load product for editing from API (for full data including salePrice, costPrice, etc.)
  Future<void> loadProductForEditing(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📦 Fetching full product data from API: $productId');

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final response = await _dio.get(
        '/seller/services/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('Product API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Product API response data: ${response.data}');
        final data = response.data;
        if (data['success'] == true) {
          final serviceData =
              data['data']?['service'] ?? data['service'] ?? data['data'];

          // Convert to SellerProduct (this will include salePrice, costPrice, weight, sku, dimensions)
          _product = _convertToSellerProduct(serviceData);

          // Store existing image URLs
          _existingImageUrls.clear();
          if (serviceData['featuredImage'] != null &&
              serviceData['featuredImage'].toString().isNotEmpty) {
            _existingImageUrls.add(serviceData['featuredImage'].toString());
          }
          if (serviceData['images'] != null && serviceData['images'] is List) {
            for (var img in serviceData['images']) {
              final imgUrl = img.toString();
              if (imgUrl.isNotEmpty && !_existingImageUrls.contains(imgUrl)) {
                _existingImageUrls.add(imgUrl);
              }
            }
          }

          _selectedImages.clear();
          _featuredImage = null;
          _currentTabIndex = 0;

          log('✅ Full product data loaded from API');
        } else {
          throw Exception(data['message'] ?? 'Failed to load product');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error loading product: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Convert API response to SellerProduct
  SellerProduct _convertToSellerProduct(Map<String, dynamic> json) {
    // Parse dimensions
    ProductDimensions? dimensions;
    if (json['dimensions'] != null && json['dimensions'] is Map) {
      final dims = json['dimensions'] as Map;
      dimensions = ProductDimensions(
        length: _parseDouble(dims['length']),
        width: _parseDouble(dims['width']),
        height: _parseDouble(dims['height']),
        specification: dims['specification']?.toString(),
      );
    }

    // Parse variants
    final variants = <ProductVariant>[];
    if (json['variants'] != null && json['variants'] is List) {
      for (var variant in json['variants']) {
        if (variant is Map) {
          variants.add(
            ProductVariant(
              type: variant['type']?.toString() ?? '',
              value: variant['value']?.toString() ?? '',
              priceAdjustment: _parseDouble(variant['priceAdjustment']),
            ),
          );
        }
      }
    }

    // Parse tags
    final tags = <String>[];
    if (json['tags'] != null && json['tags'] is List) {
      for (var tag in json['tags']) {
        if (tag != null && tag.toString().isNotEmpty) {
          tags.add(tag.toString());
        }
      }
    }

    return SellerProduct(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      productType: json['productType']?.toString() ?? 'Ready Product',
      tags: tags,
      price: _parseDouble(json['price']),
      salePrice: json['salePrice'] != null
          ? _parseDouble(json['salePrice'])
          : null,
      costPrice: json['costPrice'] != null
          ? _parseDouble(json['costPrice'])
          : null,
      taxRate: _parseDouble(json['taxRate']),
      currency: json['currency']?.toString() ?? 'USD',
      priceUnit: json['priceUnit']?.toString() ?? 'per item',
      sku: json['sku']?.toString() ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      lowStockAlert: json['lowStockAlert'],
      weight: json['weight'] != null ? _parseDouble(json['weight']) : null,
      dimensions: dimensions,
      variants: variants,
      location: json['location']?.toString() ?? '',
      // images handle here
      images: json['images'] != null
          ? json['images'].map((img) => File(img)).toList()
          : [],
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Update product
  Future<bool> updateProduct() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_product.id == null) {
        throw Exception('Product ID is required for update');
      }

      // Validate
      if (_product.title.isEmpty ||
          _product.description.isEmpty ||
          _product.category.isEmpty) {
        throw Exception('Please complete all required fields');
      }

      // Get token
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      // Prepare FormData
      final formData = FormData();

      // Add text fields
      final Map<String, dynamic> apiFields = {
        'title': _product.title,
        'shortDescription': _product.shortDescription,
        'description': _product.description,
        'category': _product.category,
        'productType': _product.productType,
        'tags': jsonEncode(_product.tags),
        'price': _product.price.toString(),
        'taxRate': _product.taxRate.toString(),
        'currency': _product.currency,
        'priceUnit': _product.priceUnit,
        'sku': _product.sku,
        'stockQuantity': _product.stockQuantity.toString(),
        'lowStockAlert': _product.lowStockAlert?.toString() ?? '2',
        'location': _product.location,
      };

      // Add optional price fields (only if they have values)
      if (_product.salePrice != null) {
        apiFields['salePrice'] = _product.salePrice!.toString();
      }
      if (_product.costPrice != null) {
        apiFields['costPrice'] = _product.costPrice!.toString();
      }
      if (_product.weight != null) {
        apiFields['weight'] = _product.weight!.toString();
      }

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

      // Add existing image URLs if any (to keep them)
      // Convert full URLs to paths for the API
      if (_existingImageUrls.isNotEmpty) {
        final imagePaths = _existingImageUrls.map((url) {
          try {
            final uri = Uri.parse(url);
            return uri.path; // Extract just the path part
          } catch (e) {
            return url; // Fallback to original if parsing fails
          }
        }).toList();
        apiFields['existingImages'] = jsonEncode(imagePaths);
        log('📸 Sending existingImages (${imagePaths.length}): $imagePaths');
      }

      // Add all fields to formData
      // Send all fields that are in apiFields (they're already filtered)
      apiFields.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      log('📋 Form Data Fields (${apiFields.length}):');
      apiFields.forEach((key, value) {
        log('   $key: $value');
      });

      // Add new images if any
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              image.path,
              filename:
                  'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            ),
          ),
        );
      }

      log('📸 Existing images: ${_existingImageUrls.length}');
      log('📸 New images: ${_selectedImages.length}');

      log('🌐 Updating product: ${_product.id}');

      final response = await _dio.put(
        '/seller/services/${_product.id}',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      log('✅ Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('🎉 Product updated successfully!');

        // Update existingImageUrls from API response to stay in sync
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          final serviceData =
              responseData['data']['service'] ?? responseData['data'];

          // Update existingImageUrls from the API response
          _existingImageUrls.clear();

          // Add featured image if exists
          if (serviceData['featuredImage'] != null &&
              serviceData['featuredImage'].toString().isNotEmpty) {
            _existingImageUrls.add(serviceData['featuredImage'].toString());
          }

          // Add all images from the images array
          if (serviceData['images'] != null && serviceData['images'] is List) {
            for (var img in serviceData['images']) {
              final imgUrl = img.toString();
              if (imgUrl.isNotEmpty && !_existingImageUrls.contains(imgUrl)) {
                _existingImageUrls.add(imgUrl);
              }
            }
          }

          log(
            '✅ Updated existingImageUrls after product update: ${_existingImageUrls.length} images',
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update product');
      }
    } on DioException catch (e) {
      log('❌ === DIO ERROR ===');
      log('   Type: ${e.type}');
      log('   Status: ${e.response?.statusCode}');
      log('   Response: ${e.response?.data}');
      _errorMessage =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to update product';
    } catch (e) {
      log('❌ === ERROR ===');
      log('   $e');
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Remove existing image URL (for deletion)
  Future<bool> deleteExistingImage(String imageUrl) async {
    final productId = _product.id;
    if (productId == null || productId.isEmpty || _productService == null) {
      // Just remove from UI if no service or product ID
      _existingImageUrls.remove(imageUrl);
      notifyListeners();
      return true;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final success = await _productService.deleteProductImage(
        productId,
        imageUrl,
      );

      if (success) {
        _existingImageUrls.remove(imageUrl);
        log('✅ Image deleted successfully');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      log('❌ Error deleting image: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove existing image URL and delete from server
  Future<void> removeExistingImageUrl(String imageUrl) async {
    final productId = _product.id;
    if (productId == null || productId.isEmpty) {
      // Just remove from UI if no product ID
      _existingImageUrls.remove(imageUrl);
      notifyListeners();
      return;
    }

    try {
      // Extract the path from the full URL
      // e.g., "http://3.27.171.3/uploads/image.jpg" -> "/uploads/image.jpg"
      String imagePath = imageUrl;
      try {
        final uri = Uri.parse(imageUrl);
        imagePath = uri.path; // Get just the path part
      } catch (e) {
        // If parsing fails, use the original URL
        log('⚠️ Could not parse image URL, using as-is: $imageUrl');
      }

      // Get token
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      log('🗑️ Deleting image: $imagePath from product: $productId');

      // Call API to delete image
      final response = await _dio.delete(
        '/seller/services/$productId/images',
        data: {'imageUrl': imagePath},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('✅ Delete image response status: ${response.statusCode}');
      log('✅ Delete image response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update existingImageUrls from API response
        final responseData = response.data;
        log('📦 Delete response data: $responseData');

        if (responseData != null && responseData['success'] == true) {
          final data = responseData['data'];
          if (data != null) {
            final serviceData = data['service'] ?? data;
            log('📦 Service data from delete response: $serviceData');

            // Update existingImageUrls from the API response
            _existingImageUrls.clear();

            // Add featured image if exists
            if (serviceData['featuredImage'] != null &&
                serviceData['featuredImage'].toString().isNotEmpty) {
              final featuredUrl = serviceData['featuredImage'].toString();
              _existingImageUrls.add(featuredUrl);
              log('📸 Added featured image: $featuredUrl');
            }

            // Add all images from the images array
            if (serviceData['images'] != null &&
                serviceData['images'] is List) {
              final imagesList = serviceData['images'] as List;
              log('📸 Images array from API: $imagesList');
              for (var img in imagesList) {
                final imgUrl = img.toString();
                if (imgUrl.isNotEmpty && !_existingImageUrls.contains(imgUrl)) {
                  _existingImageUrls.add(imgUrl);
                  log('📸 Added image: $imgUrl');
                }
              }
            }

            log(
              '✅ Updated existingImageUrls from API: ${_existingImageUrls.length} images',
            );
            log('📸 Current existingImageUrls: $_existingImageUrls');
          } else {
            log('⚠️ No data in response, using fallback');
            // Fallback: just remove the deleted image from local list
            _existingImageUrls.remove(imageUrl);
          }
        } else {
          log('⚠️ Response success is false or null, using fallback');
          // Fallback: just remove the deleted image from local list
          _existingImageUrls.remove(imageUrl);
        }

        log('✅ Image deleted successfully from server');
        notifyListeners();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete image');
      }
    } on DioException catch (e) {
      log('❌ === DIO ERROR deleting image ===');
      log('   Type: ${e.type}');
      log('   Status: ${e.response?.statusCode}');
      log('   Response: ${e.response?.data}');

      _errorMessage =
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to delete image';

      // Don't remove from UI if API call fails - let user retry
      // The error message will be available via errorMessage getter
      notifyListeners();
      rethrow; // Re-throw so UI can show error
    } catch (e) {
      log('❌ === ERROR deleting image ===');
      log('   $e');

      _errorMessage = e.toString();
      notifyListeners();
      rethrow; // Re-throw so UI can show error
    }
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
    _isEditMode = false;
    _existingImageUrls.clear();
    notifyListeners();
  }
}
