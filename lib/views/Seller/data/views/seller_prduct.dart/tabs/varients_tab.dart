import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_model.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class VariantsTab extends StatefulWidget {
  const VariantsTab({super.key});

  @override
  State<VariantsTab> createState() => _VariantsTabState();
}

class _VariantsTabState extends State<VariantsTab> {
  final _variantNameController = TextEditingController();
  final _variantColorController = TextEditingController();
  final _variantPriceController = TextEditingController();
  String _selectedType = 'Size';

  @override
  void dispose() {
    _variantNameController.dispose();
    _variantColorController.dispose();
    _variantPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SellerProductProvider>();
    // Get the product from viewModel - adjust based on your actual model name
    final product =
        viewModel.product; // or viewModel.sellerProduct based on your model

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Product Variants',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add different options like sizes, colors, or materials',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Add Variant Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: [
                // Type selection
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Variant Type',
                      hintText: 'Select a category',
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    items: ['Size', 'Color', 'Material'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Variant Name
                CustomTextFormField(
                  controller: _variantColorController,
                  hintText: 'e.g., Small, Red, Wood',
                ),
                const SizedBox(height: 16),

                // Price adjustment
                CustomTextFormField(
                  controller: _variantPriceController,
                  hintText: 'e.g., 10.00 or -5.00',
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _addVariant(context, viewModel);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add Variant'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Add Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickButton('Add Sizes (S, M, L)', () {
                _addSizeTemplate(context, viewModel);
              }),
              _buildQuickButton('Add Colors', () {
                _addColorTemplate(context, viewModel);
              }),
              _buildQuickButton('Add Materials', () {
                _addMaterialTemplate(context, viewModel);
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Current Variants
          if (product.variants.isNotEmpty) ...[
            Text(
              'Current Variants (${product.variants.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...product.variants.map((variant) {
              return _buildVariantItem(variant, viewModel, context);
            }),
          ] else ...[
            // Empty state
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 60,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No variants added yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add variants like sizes, colors, or materials',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[700],
      ),
      child: Text(label),
    );
  }

  Widget _buildVariantItem(
    ProductVariant variant,
    SellerProductProvider viewModel,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          // Type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor(variant.type),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              variant.type.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Variant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${variant.type}: ${variant.value}', // ✅ Use type and value
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Price Adjustment: \$${variant.priceAdjustment}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Price
          Text(
            variant.priceAdjustment != 0
                ? '${variant.priceAdjustment > 0 ? '+' : ''}\$${variant.priceAdjustment.toStringAsFixed(2)}'
                : 'Base',
            style: TextStyle(
              color: variant.priceAdjustment > 0
                  ? Colors.green
                  : variant.priceAdjustment < 0
                  ? Colors.red
                  : Colors.grey,
            ),
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            color: Colors.grey,
            onPressed: () {
              // Since your model doesn't have ID, remove by index
              final index = viewModel.product.variants.indexOf(variant);
              if (index != -1) {
                viewModel.removeVariant(index); // ✅ FIXED: remove by index
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Removed ${variant.type}: ${variant.value}',
                  ), // ✅ FIXED: use type and value
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'size':
        return Colors.blue;
      case 'color':
        return Colors.purple;
      case 'material':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _addVariant(BuildContext context, SellerProductProvider viewModel) {
    if (_variantColorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter variant value')),
      );
      return;
    }

    if (_variantPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter price adjustment')),
      );
      return;
    }

    final price = double.tryParse(_variantPriceController.text) ?? 0.0;

    final variant = ProductVariant(
      type: _selectedType,
      value: _variantColorController.text, // ✅ FIXED: 'value' not 'name'
      priceAdjustment: price,
    );

    viewModel.addVariant(variant);

    // Clear form
    _variantColorController.clear();
    _variantPriceController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_selectedType variant'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Template methods - add only one variant per button click
  void _addSizeTemplate(BuildContext context, SellerProductProvider viewModel) {
      final variant = ProductVariant(
      type: 'Size',
      value: 'Medium',
      priceAdjustment: 0.0,
      );
      viewModel.addVariant(variant);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added Size variant'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addColorTemplate(
    BuildContext context,
    SellerProductProvider viewModel,
  ) {
      final variant = ProductVariant(
      type: 'Color',
      value: 'Red',
        priceAdjustment: 0.0,
      );
      viewModel.addVariant(variant);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added Color variant'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addMaterialTemplate(
    BuildContext context,
    SellerProductProvider viewModel,
  ) {
      final variant = ProductVariant(
      type: 'Material',
      value: 'Wood',
      priceAdjustment: 0.0,
      );
      viewModel.addVariant(variant);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added Material variant'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
