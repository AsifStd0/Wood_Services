import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  late TextEditingController _skuController;
  late TextEditingController _stockQuantityController;
  late TextEditingController _lowStockAlertController;
  late TextEditingController _weightController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _specificationController;

  late FocusNode _skuFocusNode;
  late FocusNode _stockQuantityFocusNode;
  late FocusNode _lowStockAlertFocusNode;
  late FocusNode _weightFocusNode;
  late FocusNode _lengthFocusNode;
  late FocusNode _widthFocusNode;
  late FocusNode _heightFocusNode;
  late FocusNode _specificationFocusNode;

  String? _lastProductId;
  bool _isInitialized = false;
  bool _lastLoadingState = false;

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController();
    _stockQuantityController = TextEditingController();
    _lowStockAlertController = TextEditingController();
    _weightController = TextEditingController();
    _lengthController = TextEditingController();
    _widthController = TextEditingController();
    _heightController = TextEditingController();
    _specificationController = TextEditingController();

    _skuFocusNode = FocusNode();
    _stockQuantityFocusNode = FocusNode();
    _lowStockAlertFocusNode = FocusNode();
    _weightFocusNode = FocusNode();
    _lengthFocusNode = FocusNode();
    _widthFocusNode = FocusNode();
    _heightFocusNode = FocusNode();
    _specificationFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _skuController.dispose();
    _stockQuantityController.dispose();
    _lowStockAlertController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _specificationController.dispose();

    _skuFocusNode.dispose();
    _stockQuantityFocusNode.dispose();
    _lowStockAlertFocusNode.dispose();
    _weightFocusNode.dispose();
    _lengthFocusNode.dispose();
    _widthFocusNode.dispose();
    _heightFocusNode.dispose();
    _specificationFocusNode.dispose();
    super.dispose();
  }

  void _updateControllers(
    SellerProductProvider provider, {
    bool force = false,
  }) {
    final product = provider.product;

    // Update product ID tracking
    final currentProductId = product.id ?? '';
    if (_lastProductId != currentProductId) {
      _lastProductId = currentProductId;
      _isInitialized = false;
    }

    // Only update controllers if product changed or on initial load
    // AND field is not currently focused (user not typing)
    if (force || !_isInitialized) {
      // Update SKU only if not focused
      if (!_skuFocusNode.hasFocus) {
        if (_skuController.text != product.sku) {
          _skuController.text = product.sku;
        }
      }

      // Update Stock Quantity only if not focused
      if (!_stockQuantityFocusNode.hasFocus) {
        final stockText = product.stockQuantity.toString();
        if (_stockQuantityController.text != stockText) {
          _stockQuantityController.text = stockText;
        }
      }

      // Update Low Stock Alert only if not focused
      if (!_lowStockAlertFocusNode.hasFocus) {
        final alertText = product.lowStockAlert?.toString() ?? '5';
        if (_lowStockAlertController.text != alertText) {
          _lowStockAlertController.text = alertText;
        }
      }

      // Update Weight only if not focused
      if (!_weightFocusNode.hasFocus) {
        final weightText = product.weight?.toString() ?? '';
        if (_weightController.text != weightText) {
          _weightController.text = weightText;
        }
      }

      // Update Length only if not focused
      if (!_lengthFocusNode.hasFocus) {
        final lengthText = product.dimensions?.length.toString() ?? '';
        if (_lengthController.text != lengthText) {
          _lengthController.text = lengthText;
        }
      }

      // Update Width only if not focused
      if (!_widthFocusNode.hasFocus) {
        final widthText = product.dimensions?.width.toString() ?? '';
        if (_widthController.text != widthText) {
          _widthController.text = widthText;
        }
      }

      // Update Height only if not focused
      if (!_heightFocusNode.hasFocus) {
        final heightText = product.dimensions?.height.toString() ?? '';
        if (_heightController.text != heightText) {
          _heightController.text = heightText;
        }
      }

      // Update Specification only if not focused
      if (!_specificationFocusNode.hasFocus) {
        final specText = product.dimensions?.specification ?? '';
        if (_specificationController.text != specText) {
          _specificationController.text = specText;
        }
      }

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<SellerProductProvider>();
    final product = productProvider.product;

    // Update controllers when:
    // 1. Product ID changes (new product loaded)
    // 2. Loading state changes from true to false (API data just loaded)
    final currentProductId = product.id ?? '';
    final currentLoadingState = productProvider.isLoading;
    final productIdChanged = _lastProductId != currentProductId;
    final loadingJustFinished = _lastLoadingState && !currentLoadingState;

    if (productIdChanged || loadingJustFinished) {
      if (productIdChanged) {
        _lastProductId = currentProductId;
        _isInitialized = false; // Reset initialization when product changes
      }
      if (loadingJustFinished) {
        _isInitialized = false; // Reset initialization when API data loads
      }
      _lastLoadingState = currentLoadingState;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateControllers(productProvider, force: true);
        }
      });
    } else {
      _lastLoadingState = currentLoadingState;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Inventory Management',
            'Manage stock levels, SKU, and inventory tracking',
          ),

          // SKU
          _buildTextFieldWithLabel(
            _skuController,
            _skuFocusNode,
            'SKU (Stock Keeping Unit)',
            'Unique identifier for inventory tracking',
            'e.g., PROD-001-2024',
            Icons.qr_code_rounded,
            (value) => productProvider.updateSku(value),
          ),
          const SizedBox(height: 24),

          // Stock Quantity
          _buildTextFieldWithLabel(
            _stockQuantityController,
            _stockQuantityFocusNode,
            'Stock Quantity',
            'Current available stock for this product',
            '0',
            Icons.inventory_2_rounded,
            (value) {
              if (value.isEmpty) {
                productProvider.updateStockQuantity(0);
              } else {
                final stock = int.tryParse(value);
                if (stock != null) {
                  productProvider.updateStockQuantity(stock);
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // Low Stock Alert
          _buildTextFieldWithLabel(
            _lowStockAlertController,
            _lowStockAlertFocusNode,
            'Low Stock Alert',
            'Get notified when stock reaches this level',
            '5',
            Icons.notifications_active_rounded,
            (value) {
              if (value.isEmpty) {
                productProvider.updateLowStockAlert(null);
              } else {
                final alert = int.tryParse(value);
                if (alert != null) {
                  productProvider.updateLowStockAlert(alert);
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // Weight & Dimensions
          _buildSectionSubHeader(
            'Weight & Dimensions',
            'Shipping weight and package dimensions',
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDimensionField(
                  _weightController,
                  _weightFocusNode,
                  'Weight (kg)',
                  Icons.scale_rounded,
                  (value) {
                    if (value.isEmpty) {
                      productProvider.updateWeight(null);
                    } else {
                      final weight = double.tryParse(value);
                      if (weight != null) {
                        productProvider.updateWeight(weight);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDimensionField(
                  _lengthController,
                  _lengthFocusNode,
                  'Length (cm)',
                  Icons.straighten_rounded,
                  (value) {
                    if (value.isEmpty) {
                      productProvider.updateDimensions(length: null);
                    } else {
                      final length = double.tryParse(value);
                      if (length != null) {
                        productProvider.updateDimensions(length: length);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDimensionField(
                  _widthController,
                  _widthFocusNode,
                  'Width (cm)',
                  Icons.straighten_rounded,
                  (value) {
                    if (value.isEmpty) {
                      productProvider.updateDimensions(width: null);
                    } else {
                      final width = double.tryParse(value);
                      if (width != null) {
                        productProvider.updateDimensions(width: width);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDimensionField(
                  _heightController,
                  _heightFocusNode,
                  'Height (cm)',
                  Icons.height_rounded,
                  (value) {
                    if (value.isEmpty) {
                      productProvider.updateDimensions(height: null);
                    } else {
                      final height = double.tryParse(value);
                      if (height != null) {
                        productProvider.updateDimensions(height: height);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dimension Specification
          _buildTextFieldWithLabel(
            _specificationController,
            _specificationFocusNode,
            'Dimension Specification',
            'Human-readable dimensions (e.g., 180cm x 90cm x 75cm)',
            'Enter dimensions',
            Icons.aspect_ratio_rounded,
            (value) => productProvider.updateDimensions(specification: value),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel(
    TextEditingController controller,
    FocusNode focusNode,
    String title,
    String subtitle,
    String hintText,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _buildLabelStyle()),
        const SizedBox(height: 4),
        Text(subtitle, style: _buildSubtitleStyle()),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: controller,
          focusNode: focusNode,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          textInputType: TextInputType.number,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDimensionField(
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        CustomTextFormField(
          controller: controller,
          focusNode: focusNode,
          hintText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
          textInputType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _buildLabelStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle, style: _buildSubtitleStyle()),
        ],
      ),
    );
  }

  Widget _buildSectionSubHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _buildLabelStyle()),
        const SizedBox(height: 4),
        Text(subtitle, style: _buildSubtitleStyle()),
      ],
    );
  }

  TextStyle _buildLabelStyle({double fontSize = 16, Color? color}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.grey[800],
    );
  }

  TextStyle _buildSubtitleStyle() {
    return TextStyle(fontSize: 14, color: Colors.grey[600]);
  }
}
