// screens/uploaded_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_detail_screen.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class UploadedProductsScreen extends StatefulWidget {
  const UploadedProductsScreen({super.key});

  @override
  State<UploadedProductsScreen> createState() => _UploadedProductsScreenState();
}

class _UploadedProductsScreenState extends State<UploadedProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _initialLoadTriggered = false;

  @override
  void initState() {
    super.initState();

    // Load more on scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (mounted) {
        final provider = context.read<UploadedProductProvider>();
        if (provider.hasMore && !provider.isLoading) {
          provider.loadMore();
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => locator<UploadedProductProvider>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: 'My Uploaded Products',
          showBackButton: true,
          backgroundColor: Colors.white,
        ),
        body: Consumer<UploadedProductProvider>(
          builder: (context, provider, child) {
            // Load products automatically when screen is first shown
            if (!_initialLoadTriggered &&
                provider.products.isEmpty &&
                !provider.isLoading) {
              _initialLoadTriggered = true;
              // Use Future.microtask to avoid calling setState during build
              Future.microtask(() {
                if (mounted) {
                  provider.loadProducts(status: null);
                }
              });
            }

            return RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: Column(
                children: [
                  // Products list
                  Expanded(child: _buildContent(provider)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(UploadedProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.isEmpty) {
      return _buildEmptyState(provider);
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(provider.products[index], provider);
      },
    );
  }

  Widget _buildEmptyState(UploadedProductProvider provider) {
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

  Widget _buildProductCard(
    UploadedProductModel product,
    UploadedProductProvider provider,
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
              flex: 3,
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
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
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
                padding: const EdgeInsets.all(8),
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
                    const SizedBox(height: 4),

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
                            fontSize: 14,
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
                            '${product.stockQuantity} in stock',
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
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
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
}
