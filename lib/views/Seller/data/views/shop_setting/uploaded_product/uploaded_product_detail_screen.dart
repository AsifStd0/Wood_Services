// screens/uploaded_product_detail_screen.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/edit_products/edit_product_screen.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class UploadedProductDetailScreen extends StatelessWidget {
  final UploadedProductModel product;

  const UploadedProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    log('product is here \n ${product.title}');
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            _buildImageSection(context),

            const SizedBox(height: 24),

            // Basic Info
            _buildInfoCard(
              title: 'Basic Information',
              children: [
                _buildInfoRow('Title', product.title),
                _buildInfoRow('Category', product.category),
                _buildInfoRow('Product Type', product.productType),
                _buildInfoRow('Location', product.location),
                _buildInfoRow('Status', product.statusText, isStatus: true),
              ],
            ),

            const SizedBox(height: 16),

            // Pricing
            _buildInfoCard(
              title: 'Pricing',
              children: [
                _buildInfoRow('Price', product.formattedPrice),
                _buildInfoRow('Currency', product.currency),
                _buildInfoRow('Price Unit', product.priceUnit),
                _buildInfoRow('Tax Rate', '${product.taxRate}%'),
              ],
            ),

            const SizedBox(height: 16),

            // Inventory
            _buildInfoCard(
              title: 'Inventory',
              children: [
                _buildInfoRow(
                  'Stock Quantity',
                  product.stockQuantity.toString(),
                ),
                _buildInfoRow(
                  'Low Stock Alert',
                  product.lowStockAlert.toString(),
                ),
                _buildInfoRow('Availability', product.availability),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            if (product.description.isNotEmpty)
              _buildInfoCard(
                title: 'Description',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      product.description,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),

            if (product.description.isNotEmpty) const SizedBox(height: 16),

            // Variants
            if (product.variants.isNotEmpty)
              _buildInfoCard(
                title: 'Variants (${product.variants.length})',
                children: [
                  ...product.variants.map(
                    (variant) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${variant.type}: ${variant.value}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (variant.priceAdjustment != 0)
                            Text(
                              variant.priceAdjustment > 0
                                  ? '+\$${variant.priceAdjustment.toStringAsFixed(2)}'
                                  : '\$${variant.priceAdjustment.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: variant.priceAdjustment > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            if (product.variants.isNotEmpty) const SizedBox(height: 16),

            // Tags
            if (product.tags.isNotEmpty)
              _buildInfoCard(
                title: 'Tags',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.brown[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.brown[200]!),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown[800],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

            if (product.tags.isNotEmpty) const SizedBox(height: 16),

            // Ratings
            _buildInfoCard(
              title: 'Ratings & Statistics',
              children: [
                _buildInfoRow(
                  'Average Rating',
                  product.ratings.average > 0
                      ? '${product.ratings.average.toStringAsFixed(1)} ⭐'
                      : 'No ratings yet',
                ),
                _buildInfoRow(
                  'Total Reviews',
                  product.ratings.count.toString(),
                ),
                _buildInfoRow(
                  'Completed Projects',
                  product.completedProjects.toString(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dates
            _buildInfoCard(
              title: 'Timeline',
              children: [
                _buildInfoRow('Created At', _formatDate(product.createdAt)),
                _buildInfoRow('Last Updated', _formatDate(product.updatedAt)),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final allImages = [
      if (product.featuredImage.isNotEmpty) product.featuredImage,
      ...product.images.where((img) => img != product.featuredImage),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.image, color: Colors.brown),
                const SizedBox(width: 8),
                Text(
                  'Images (${allImages.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (allImages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            )
          else
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            allImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Delete button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Consumer<UploadedProductProvider>(
                          builder: (context, provider, child) {
                            return IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              onPressed: provider.isLoading
                                  ? null
                                  : () => _showDeleteImageDialog(
                                      context,
                                      provider,
                                      allImages[index],
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteImageDialog(
    BuildContext context,
    UploadedProductProvider provider,
    String imageUrl,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text(
          'Are you sure you want to delete this image? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final success = await provider.deleteProductImage(
                product.id,
                imageUrl,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Image deleted successfully'
                          : provider.errorMessage ?? 'Failed to delete image',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) {
                  // Refresh the product list to update images
                  provider.refresh();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.isActive
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: product.isActive
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   child: OutlinedButton.icon(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => EditProductScreen(
        //             productId: product.id,
        //             productModel: product,
        //           ),
        //         ),
        //       ).then((shouldRefresh) {
        //         if (shouldRefresh == true && context.mounted) {
        //           // Refresh the product list
        //           final provider = context.read<UploadedProductProvider>();
        //           provider.refresh();
        //         }
        //       });
        //     },
        //     icon: const Icon(Icons.edit),
        //     label: const Text('Edit Product'),
        //     style: OutlinedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 12),
        Expanded(
          child: Consumer<UploadedProductProvider>(
            builder: (context, provider, child) {
              final isDeleting = provider.isLoading;

              return ElevatedButton.icon(
                onPressed: isDeleting
                    ? null
                    : () => _showDeleteConfirmation(context, provider),
                icon: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.delete),
                label: Text(isDeleting ? 'Deleting...' : 'Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.red.withOpacity(0.6),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(
    BuildContext context,
    UploadedProductProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              final success = await provider.deleteProduct(product.id);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${product.title}" deleted successfully'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  // Navigate back to list
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.errorMessage ?? 'Failed to delete product',
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
