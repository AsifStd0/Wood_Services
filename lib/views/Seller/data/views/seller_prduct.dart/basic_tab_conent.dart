// lib/views/basic_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class BasicTab extends StatelessWidget {
  const BasicTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddProductViewModel>();
    final product = viewModel.product;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Title
          // _buildSectionTitle('Product Title'),
          CustomText('Product Title', type: CustomTextType.subtitleLarge),
          const SizedBox(height: 8),
          CustomTextFormField(
            // controller: _emailController,
            hintText: 'e.g., Handmade Leather Wallet',
            onChanged: (value) {
              print('Email: $value');
            },
            // focusNode: _emailFocusNode,
          ),
          const SizedBox(height: 24),
          CustomText('Short Description', type: CustomTextType.subtitleLarge),

          const SizedBox(height: 8),

          CustomText(
            'Briefly describe your product',
            type: CustomTextType.subtitleSmall,
          ),

          const SizedBox(height: 8),
          Container(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 16),

          CustomTextFormField(
            minline: 3,
            maxLines: 3,

            // controller: _descriptionController,
            hintText: 'Enter short description...',
            onChanged: (value) {},
            // focusNode: _descriptionFocusNode,
          ),

          const SizedBox(height: 24),

          // Long Description
          // _buildSectionTitle('Long Description'),
          CustomText('Long Description', type: CustomTextType.subtitleLarge),

          const SizedBox(height: 8),
          CustomText(
            'Detailed product information',
            type: CustomTextType.subtitleSmall,
          ),
          // Text(
          //   'Detailed product information',
          //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
          // ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 16),

          CustomTextFormField(
            minline: 6,
            maxLines: 6,

            // controller: _descriptionController,
            hintText: 'Enter detailed description...',
            onChanged: (value) {},
            // focusNode: _descriptionFocusNode,
          ),
          const SizedBox(height: 24),

          // Category
          _buildSectionTitle('Category'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Select a category',

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),

              // Normal border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.grey, // Border color when not focused
                  width: 0.6, // Border width when focused
                ),
              ),

              // Border when focused
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.grey, // Border color when focused
                  width: 0.6, // Border width when focused
                ),
              ),
            ),

            items: const [
              DropdownMenuItem(value: 'Fashion', child: Text('Fashion')),
              DropdownMenuItem(
                value: 'Electronics',
                child: Text('Electronics'),
              ),
              DropdownMenuItem(
                value: 'Home & Garden',
                child: Text('Home & Garden'),
              ),
              DropdownMenuItem(value: 'Sports', child: Text('Sports')),
            ],

            onChanged: (value) {
              if (value != null) viewModel.setCategory(value);
            },
          ),
          const SizedBox(height: 24),

          // Tags
          _buildSectionTitle('Tags'),
          const SizedBox(height: 8),
          CustomText(
            'e.g., leather, wallet, handmade',
            type: CustomTextType.subtitleSmall,
          ),
          // Text(
          //   'e.g., leather, wallet, handmade',
          //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
          // ),
          const SizedBox(height: 8),
          CustomTextFormField(
            minline: 2,
            maxLines: 2,

            // controller: _descriptionController,
            hintText: 'Add tags separated by commas',
            onChanged: (value) {},
            // focusNode: _descriptionFocusNode,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                final tags = value.split(',').map((tag) => tag.trim()).toList();
                viewModel.setTags([...product.tags, ...tags]);
              }
            },
          ),

          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    onDeleted: () {
                      final newTags = List<String>.from(product.tags)
                        ..remove(tag);
                      viewModel.setTags(newTags);
                    },
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

// Placeholder tabs for other sections
class _PricingTab extends StatelessWidget {
  const _PricingTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Pricing Tab - Under Development'));
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Inventory Tab - Under Development'));
  }
}

class _VariantsTab extends StatelessWidget {
  const _VariantsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Variants Tab - Under Development'));
  }
}

class _MediaTab extends StatelessWidget {
  const _MediaTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Media Tab - Under Development'));
  }
}
