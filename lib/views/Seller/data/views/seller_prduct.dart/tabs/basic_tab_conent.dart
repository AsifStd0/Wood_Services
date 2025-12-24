import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_model.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class BasicTab extends StatelessWidget {
  const BasicTab({Key? key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<SellerProductProvider>();
    final product = productProvider.product;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionHeader(
            'Basic Information',
            'Enter the basic details about your product',
          ),

          // Product Title
          Text('Product Title *', style: _buildLabelStyle()),
          const SizedBox(height: 8),
          CustomTextFormField(
            hintText: 'e.g., Handmade Leather Wallet',
            initialValue: product.title,
            onChanged: (value) => productProvider.updateTitle(value),
          ),
          const SizedBox(height: 24),

          // Short Description
          Text('Short Description *', style: _buildLabelStyle()),
          const SizedBox(height: 8),
          Text('Briefly describe your product', style: _buildSubtitleStyle()),
          const SizedBox(height: 8),
          CustomTextFormField(
            minline: 3,
            maxLines: 3,
            hintText: 'Enter short description...',
            initialValue: product.shortDescription,
            onChanged: (value) => productProvider.updateShortDescription(value),
          ),
          const SizedBox(height: 24),

          // Long Description
          Text('Long Description *', style: _buildLabelStyle()),
          const SizedBox(height: 8),
          Text('Detailed product information', style: _buildSubtitleStyle()),
          const SizedBox(height: 8),
          CustomTextFormField(
            minline: 6,
            maxLines: 6,
            hintText: 'Enter detailed description...',
            initialValue: product.longDescription,
            onChanged: (value) => productProvider.updateLongDescription(value),
          ),
          const SizedBox(height: 24),

          // Category
          Text('Category *', style: _buildLabelStyle()),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),

            child: DropdownButtonFormField<String>(
              value: product.category.isNotEmpty ? product.category : null,
              decoration: InputDecoration(
                hintText: 'Select a category',
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
                DropdownMenuItem(
                  value: 'Electronics',
                  child: Text('Electronics'),
                ),
                DropdownMenuItem(
                  value: 'Home & Garden',
                  child: Text('Home & Garden'),
                ),
                DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                DropdownMenuItem(value: 'Beauty', child: Text('Beauty')),
                DropdownMenuItem(value: 'Toys', child: Text('Toys')),
                DropdownMenuItem(value: 'Books', child: Text('Books')),
                DropdownMenuItem(
                  value: 'Food & Beverages',
                  child: Text('Food & Beverages'),
                ),
              ],
              onChanged: (value) {
                if (value != null) productProvider.updateCategory(value);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Tags
          Text('Tags', style: _buildLabelStyle()),
          const SizedBox(height: 8),
          Text(
            'Add keywords to help customers find your product',
            style: _buildSubtitleStyle(),
          ),
          const SizedBox(height: 8),
          _buildTagInput(productProvider, product),
          const SizedBox(height: 12),
          _buildTagChips(productProvider, product),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTagInput(SellerProductProvider provider, SellerProduct product) {
    final TextEditingController _tagController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            controller: _tagController,
            hintText: 'e.g., handmade, organic, premium',
            onChanged: (value) {},
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            final tag = _tagController.text.trim();
            if (tag.isNotEmpty) {
              final newTags = List<String>.from(product.tags)..add(tag);
              provider.updateTags(newTags);
              _tagController.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF667EEA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildTagChips(SellerProductProvider provider, SellerProduct product) {
    if (product.tags.isEmpty) return Container();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.tags.map((tag) {
        return Chip(
          label: Text(tag),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            final newTags = List<String>.from(product.tags)..remove(tag);
            provider.updateTags(newTags);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
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

  TextStyle _buildLabelStyle({double fontSize = 16}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
    );
  }

  TextStyle _buildSubtitleStyle() {
    return TextStyle(fontSize: 14, color: Colors.grey[600]);
  }
}
