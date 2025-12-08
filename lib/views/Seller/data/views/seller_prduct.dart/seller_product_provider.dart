// view_models/add_product_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/views/Seller/data/repository/seller_product_repo.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product.dart';

class AddProductViewModel with ChangeNotifier {
  final ProductRepository _productRepository;

  AddProductViewModel(this._productRepository);

  SellerProduct _product = SellerProduct(
    title: '',
    shortDescription: '',
    longDescription: '',
    tags: [],
    basePrice: 0.0,
    salePrice: null,
    costPrice: null,
    taxRate: 0.0,
    currency: 'USD',
    sku: '',
    stockQuantity: 0,
    lowStockAlert: null,
    trackStock: true,
    allowBackorders: false,
    soldIndividually: false,
    weight: null,
    length: null,
    width: null,
    height: null,
    images: [],
    videos: [],
    documents: [],
    variants: [],
  );

  SellerProduct get product => _product;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // ============ BASIC TAB METHODS ============
  void setTitle(String title) {
    _product = _product.copyWith(title: title);
    notifyListeners();
  }

  void setShortDescription(String description) {
    _product = _product.copyWith(shortDescription: description);
    notifyListeners();
  }

  void setLongDescription(String description) {
    _product = _product.copyWith(longDescription: description);
    notifyListeners();
  }

  void setCategory(String category) {
    _product = _product.copyWith(category: category);
    notifyListeners();
  }

  void setTags(List<String> tags) {
    _product = _product.copyWith(tags: tags);
    notifyListeners();
  }

  // ============ PRICING TAB METHODS ============
  void setBasePrice(double price) {
    _product = _product.copyWith(basePrice: price);
    notifyListeners();
  }

  void setSalePrice(double? salePrice) {
    _product = _product.copyWith(salePrice: salePrice);
    notifyListeners();
  }

  void setCostPrice(double? costPrice) {
    _product = _product.copyWith(costPrice: costPrice);
    notifyListeners();
  }

  void setTaxRate(double taxRate) {
    _product = _product.copyWith(taxRate: taxRate);
    notifyListeners();
  }

  void setCurrency(String currency) {
    _product = _product.copyWith(currency: currency);
    notifyListeners();
  }

  // Calculate profit margin
  double get profitMargin {
    if (_product.costPrice == null || _product.costPrice == 0) return 0.0;
    final sellingPrice = _product.salePrice ?? _product.basePrice;
    return ((sellingPrice - _product.costPrice!) / _product.costPrice!) * 100;
  }

  // Calculate price after tax
  double get priceAfterTax {
    final sellingPrice = _product.salePrice ?? _product.basePrice;
    return sellingPrice * (1 + (_product.taxRate / 100));
  }

  // ============ INVENTORY TAB METHODS ============
  void setSku(String sku) {
    _product = _product.copyWith(sku: sku);
    notifyListeners();
  }

  void setStockQuantity(int quantity) {
    _product = _product.copyWith(stockQuantity: quantity);
    notifyListeners();
  }

  void setLowStockAlert(int? alertLevel) {
    _product = _product.copyWith(lowStockAlert: alertLevel);
    notifyListeners();
  }

  void setTrackStock(bool trackStock) {
    _product = _product.copyWith(trackStock: trackStock);
    notifyListeners();
  }

  void setAllowBackorders(bool allowBackorders) {
    _product = _product.copyWith(allowBackorders: allowBackorders);
    notifyListeners();
  }

  void setSoldIndividually(bool soldIndividually) {
    _product = _product.copyWith(soldIndividually: soldIndividually);
    notifyListeners();
  }

  void setWeight(double? weight) {
    _product = _product.copyWith(weight: weight);
    notifyListeners();
  }

  void setLength(double? length) {
    _product = _product.copyWith(length: length);
    notifyListeners();
  }

  void setWidth(double? width) {
    _product = _product.copyWith(width: width);
    notifyListeners();
  }

  void setHeight(double? height) {
    _product = _product.copyWith(height: height);
    notifyListeners();
  }

  // Check if stock is low
  bool get isLowStock {
    if (!_product.trackStock || _product.lowStockAlert == null) return false;
    return _product.stockQuantity <= _product.lowStockAlert!;
  }

  // Calculate package volume
  double? get packageVolume {
    if (_product.length == null ||
        _product.width == null ||
        _product.height == null) {
      return null;
    }
    return _product.length! * _product.width! * _product.height!;
  }

  // ============ MEDIA TAB METHODS ============
  void addImage(String imageUrl) {
    final updatedImages = List<String>.from(_product.images)..add(imageUrl);
    _product = _product.copyWith(images: updatedImages);
    notifyListeners();
  }

  void removeImage(String imageUrl) {
    final updatedImages = List<String>.from(_product.images)..remove(imageUrl);
    _product = _product.copyWith(images: updatedImages);
    notifyListeners();
  }

  void setFeaturedImage(String imageUrl) {
    // Move the image to the first position
    final updatedImages = List<String>.from(_product.images);
    updatedImages.remove(imageUrl);
    updatedImages.insert(0, imageUrl);
    _product = _product.copyWith(images: updatedImages);
    notifyListeners();
  }

  void addVideo(String videoUrl) {
    final updatedVideos = List<String>.from(_product.videos)..add(videoUrl);
    _product = _product.copyWith(videos: updatedVideos);
    notifyListeners();
  }

  void removeVideo(String videoUrl) {
    final updatedVideos = List<String>.from(_product.videos)..remove(videoUrl);
    _product = _product.copyWith(videos: updatedVideos);
    notifyListeners();
  }

  void addDocument(String documentUrl, String documentName) {
    final document = ProductDocument(
      url: documentUrl,
      name: documentName,
      uploadDate: DateTime.now(),
    );
    final updatedDocuments = List<ProductDocument>.from(_product.documents)
      ..add(document);
    _product = _product.copyWith(documents: updatedDocuments);
    notifyListeners();
  }

  void removeDocument(String documentUrl) {
    final updatedDocuments = List<ProductDocument>.from(_product.documents)
      ..removeWhere((doc) => doc.url == documentUrl);
    _product = _product.copyWith(documents: updatedDocuments);
    notifyListeners();
  }

  // ============ VARIANTS TAB METHODS ============
  void addVariant(ProductVariant variant) {
    final updatedVariants = List<ProductVariant>.from(_product.variants)
      ..add(variant);
    _product = _product.copyWith(variants: updatedVariants);
    notifyListeners();
  }

  void updateVariant(String variantId, ProductVariant updatedVariant) {
    final index = _product.variants.indexWhere((v) => v.id == variantId);
    if (index != -1) {
      final updatedVariants = List<ProductVariant>.from(_product.variants);
      updatedVariants[index] = updatedVariant;
      _product = _product.copyWith(variants: updatedVariants);
      notifyListeners();
    }
  }

  void removeVariant(String variantId) {
    final updatedVariants = List<ProductVariant>.from(_product.variants)
      ..removeWhere((v) => v.id == variantId);
    _product = _product.copyWith(variants: updatedVariants);
    notifyListeners();
  }

  void addVariantOption(
    String variantType,
    String optionName, {
    double? priceAdjustment,
  }) {
    final variant = _product.variants.firstWhere(
      (v) => v.type == variantType,
      orElse: () => ProductVariant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: variantType,
        options: [],
      ),
    );

    final option = VariantOption(
      name: optionName,
      priceAdjustment: priceAdjustment ?? 0.0,
    );

    final updatedOptions = List<VariantOption>.from(variant.options)
      ..add(option);
    final updatedVariant = variant.copyWith(options: updatedOptions);

    if (_product.variants.any((v) => v.type == variantType)) {
      updateVariant(variant.id, updatedVariant);
    } else {
      addVariant(updatedVariant);
    }
  }

  // Get variants by type
  List<VariantOption> getVariantOptions(String variantType) {
    final variant = _product.variants.firstWhere(
      (v) => v.type == variantType,
      orElse: () => ProductVariant(id: '', type: variantType, options: []),
    );
    return variant.options;
  }

  // ============ COMMON METHODS ============
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Validation
  bool get isFormValid {
    return _product.title.isNotEmpty &&
        _product.shortDescription.isNotEmpty &&
        _product.longDescription.isNotEmpty &&
        _product.basePrice > 0;
  }

  // Check if current tab is valid
  bool isCurrentTabValid() {
    switch (_currentTabIndex) {
      case 0: // Basic
        return _product.title.isNotEmpty &&
            _product.shortDescription.isNotEmpty &&
            _product.longDescription.isNotEmpty;
      case 1: // Pricing
        return _product.basePrice > 0;
      case 2: // Inventory
        return _product.sku.isNotEmpty;
      case 3: // Variants
        return true; // Variants are optional
      case 4: // Media
        return _product.images.isNotEmpty; // At least one image required
      default:
        return false;
    }
  }

  // Actions
  Future<bool> saveDraft() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productRepository.saveProduct(
        _product.copyWith(
          isPublished: false,
          updatedAt: DateTime.now(),
          status: ProductStatus.draft,
        ),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save draft: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> publishProduct() async {
    if (!isFormValid) {
      _errorMessage = 'Please fill all required fields';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productRepository.saveProduct(
        _product.copyWith(
          isPublished: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: ProductStatus.published,
        ),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to publish product: $e';
      notifyListeners();
      return false;
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
      tags: [],
      basePrice: 0.0,
      salePrice: null,
      costPrice: null,
      taxRate: 0.0,
      currency: 'USD',
      sku: '',
      stockQuantity: 0,
      lowStockAlert: null,
      trackStock: true,
      allowBackorders: false,
      soldIndividually: false,
      weight: null,
      length: null,
      width: null,
      height: null,
      images: [],
      videos: [],
      documents: [],
      variants: [],
    );
    _currentTabIndex = 0;
    _errorMessage = null;
    notifyListeners();
  }

  // Load product for editing
  void loadProduct(SellerProduct product) {
    _product = product;
    notifyListeners();
  }
}
