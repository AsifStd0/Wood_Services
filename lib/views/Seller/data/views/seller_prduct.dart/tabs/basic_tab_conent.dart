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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
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
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the basic details about your product',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          // _buildSectionTitle('Category'),
          CustomText('Category', type: CustomTextType.subtitleLarge),

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
          const SizedBox(height: 14),

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
          const SizedBox(height: 12),
          if (product.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.tags.map((tag) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            final newTags = List<String>.from(product.tags)
                              ..remove(tag);
                            viewModel.setTags(newTags);
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
