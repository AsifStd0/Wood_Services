import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_detail_screen.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_provider.dart';

Widget buildProductUploadCard(
  UploadedProductModel product,
  UploadedProductProvider provider,
  BuildContext context,
) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (detailContext) => ChangeNotifierProvider.value(
            value: provider,
            child: UploadedProductDetailScreen(product: product),
          ),
        ),
      ).then((_) {
        // Refresh list when returning from detail screen
        provider.refresh();
      });
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: product.displayImage.isNotEmpty
                      ? Image.network(
                          product.displayImage,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),

                // Status badge
              ],
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Category
                  Text(
                    product.category,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Price and Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.stockQuantity > 0
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${double.tryParse(product.stockQuantity.toString())?.toStringAsFixed(0) ?? product.stockQuantity.toString()} in stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: product.stockQuantity > 0
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Variants count
                  if (product.variants.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${product.variants.length} variants',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildEmptyState(UploadedProductProvider provider) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'No products found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          provider.statusFilter != null
              ? 'Try changing the filter'
              : 'Start by uploading your first product',
          style: TextStyle(color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
