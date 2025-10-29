import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class VariantsTab extends StatelessWidget {
  const VariantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddProductViewModel>();
    final product = viewModel.product;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Variants',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add sizes, colors, materials, and other options',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Variant Types
          _buildSectionHeader(
            'Variant Types',
            'Select the types of variants for your product',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildVariantChip('Size'),
              _buildVariantChip('Color'),
              _buildVariantChip('Material'),
            ],
          ),
          const SizedBox(height: 24),

          // Size Variants
          _buildSectionHeader(
            'Size Options',
            'Add different sizes for your product',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildVariantItem('Small', '+ \$0.00'),
                const SizedBox(height: 12),
                _buildVariantItem('Medium', '+ \$10.00'),
                const SizedBox(height: 12),
                _buildVariantItem('Large', '+ \$20.00'),
                const SizedBox(height: 12),
                _buildAddVariantButton('Add Size'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Color Variants
          _buildSectionHeader(
            'Color Options',
            'Add different colors for your product',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildColorVariantItem('Natural Wood', Colors.brown),
                const SizedBox(height: 12),
                _buildColorVariantItem('Dark Walnut', Color(0xFF5D4037)),
                const SizedBox(height: 12),
                _buildColorVariantItem('White', Colors.white),
                const SizedBox(height: 12),
                _buildAddVariantButton('Add Color'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Material Variants
          _buildSectionHeader(
            'Material Options',
            'Add different materials for your product',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildVariantItem('Solid Oak', '+ \$50.00'),
                const SizedBox(height: 12),
                _buildVariantItem('Pine Wood', '+ \$0.00'),
                const SizedBox(height: 12),
                _buildVariantItem('Teak Wood', '+ \$100.00'),
                const SizedBox(height: 12),
                _buildAddVariantButton('Add Material'),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildVariantChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.add_rounded, size: 14, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildVariantItem(String name, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 13,
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.edit_rounded, size: 16, color: Colors.grey[500]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: Colors.grey[500],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildColorVariantItem(String name, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: color == Colors.white ? 1 : 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded, size: 16, color: Colors.grey[500]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: Colors.grey[500],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAddVariantButton(String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          // style: BorderStyle.dashed,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.add_rounded, color: Colors.grey[500], size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
