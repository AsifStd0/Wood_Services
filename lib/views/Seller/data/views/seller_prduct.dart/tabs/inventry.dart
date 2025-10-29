import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';

class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddProductViewModel>();

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
                  'Inventory Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage stock levels, SKU, and inventory tracking',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SKU
          _buildSectionHeader(
            'SKU (Stock Keeping Unit)',
            'Unique identifier for inventory tracking',
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            hintText: 'e.g., PROD-001-2024',
            prefixIcon: Icon(Icons.qr_code_rounded, color: Colors.grey[400]),
            onChanged: (value) {
              viewModel.setSku(value);
            },
          ),
          const SizedBox(height: 24),

          // Stock Quantity
          _buildSectionHeader(
            'Stock Quantity',
            'Current available stock for this product',
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            hintText: '0',
            // keyboardType: TextInputType.number,
            prefixIcon: Icon(
              Icons.inventory_2_rounded,
              color: Colors.grey[400],
            ),
            onChanged: (value) {
              final stock = int.tryParse(value) ?? 0;
              viewModel.setStockQuantity(stock);
            },
          ),
          const SizedBox(height: 24),

          // Weight & Dimensions
          _buildSectionHeader(
            'Weight & Dimensions',
            'Shipping weight and package dimensions',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  hintText: 'Weight (kg)',
                  // keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    Icons.scale_rounded,
                    color: Colors.grey[400],
                  ),
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    viewModel.setWeight(weight);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextFormField(
                  hintText: 'Length (cm)',
                  // keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final length = double.tryParse(value);
                    viewModel.setLength(length);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  hintText: 'Width (cm)',
                  // keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final width = double.tryParse(value);
                    viewModel.setWidth(width);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextFormField(
                  hintText: 'Height (cm)',
                  // keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final height = double.tryParse(value);
                    viewModel.setHeight(height);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Dimensions Specification
          _buildSpecificationField(
            'Dimensions',
            'e.g., 180cm x 90cm x 75cm',
            Icons.aspect_ratio_rounded,
            (value) {
              // Add this method to your ViewModel: setDimensions(value)
              // viewModel.setDimensions(value);
            },
          ),

          const SizedBox(height: 80),
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

  // Add this missing method
  Widget _buildSpecificationField(
    String label,
    String hintText,
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
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
