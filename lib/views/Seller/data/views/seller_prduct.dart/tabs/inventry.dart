import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_model.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class InventoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<SellerProductProvider>();
    final product = productProvider.product;

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
            'SKU (Stock Keeping Unit)',
            'Unique identifier for inventory tracking',
            'e.g., PROD-001-2024',
            Icons.qr_code_rounded,
            product.sku,
            (value) => productProvider.updateSku(value),
          ),
          const SizedBox(height: 24),

          // Stock Quantity
          _buildTextFieldWithLabel(
            'Stock Quantity',
            'Current available stock for this product',
            '0',
            Icons.inventory_2_rounded,
            product.stockQuantity.toString(),
            (value) {
              final stock = int.tryParse(value) ?? 0;
              productProvider.updateStockQuantity(stock);
            },
          ),
          const SizedBox(height: 24),

          // Low Stock Alert
          _buildTextFieldWithLabel(
            'Low Stock Alert',
            'Get notified when stock reaches this level',
            '5',
            Icons.notifications_active_rounded,
            product.lowStockAlert?.toString() ?? '5',
            (value) {
              final alert = value.isEmpty ? null : int.tryParse(value);
              productProvider.updateLowStockAlert(alert);
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
                  'Weight (kg)',
                  Icons.scale_rounded,
                  product.weight?.toString() ?? '',
                  (value) {
                    final weight = value.isEmpty
                        ? null
                        : double.tryParse(value);
                    productProvider.updateWeight(weight);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDimensionField(
                  'Length (cm)',
                  Icons.straighten_rounded,
                  // product.dimensions.length.toString() ?? '',
                  product.dimensions?.length?.toString() ?? '', // ✅ FIXED
                  (value) {
                    final length = value.isEmpty
                        ? null
                        : double.tryParse(value);
                    productProvider.updateDimensions(length: length); // ✅ FIXED
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
                  'Width (cm)',
                  Icons.straighten_rounded,
                  product.dimensions?.width?.toString() ?? '', // ✅ FIXED
                  (value) {
                    final width = value.isEmpty ? null : double.tryParse(value);
                    productProvider.updateDimensions(width: width); // ✅ FIXED
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDimensionField(
                  'Height (cm)',
                  Icons.height_rounded,
                  product.dimensions?.height?.toString() ?? '', // ✅ FIXED
                  (value) {
                    final height = value.isEmpty
                        ? null
                        : double.tryParse(value);
                    productProvider.updateDimensions(height: height); // ✅ FIXED
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dimension Specification
          _buildTextFieldWithLabel(
            'Dimension Specification',
            'Human-readable dimensions (e.g., 180cm x 90cm x 75cm)',
            'Enter dimensions',
            Icons.aspect_ratio_rounded,
            product.dimensions?.specification ?? '', // ✅ FIXED
            (value) => productProvider.updateDimensions(
              specification: value,
            ), // ✅ FIXED
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel(
    String title,
    String subtitle,
    String hintText,
    IconData icon,
    String initialValue,
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
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          textInputType: TextInputType.number,
          initialValue: initialValue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDimensionField(
    String label,
    IconData icon,
    String initialValue,
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
          hintText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
          textInputType: TextInputType.numberWithOptions(decimal: true),
          initialValue: initialValue,
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
