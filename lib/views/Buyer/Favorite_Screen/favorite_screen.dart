// lib/views/Buyer/Favorite_Screen/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/favorite_button.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/buyer_favorite_product_model.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/custom_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Pagination state
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Local favorites list
  final List<FavoriteProduct> _favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();

    // Listen to provider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<FavoriteProvider>(context, listen: false);
        provider.addListener(_onProviderChanged);
      }
    });
  }

  @override
  void dispose() {
    final provider = Provider.of<FavoriteProvider>(context, listen: false);
    provider.removeListener(_onProviderChanged);
    super.dispose();
  }

  // Handle provider changes
  void _onProviderChanged() {
    if (!mounted) return;

    final provider = Provider.of<FavoriteProvider>(context, listen: false);

    // Remove items that are no longer favorited
    _favoriteProducts.removeWhere((product) {
      return !provider.isProductFavorited(product.productId);
    });

    // Reset pagination if list becomes empty
    if (_favoriteProducts.isEmpty && mounted) {
      setState(() {
        _currentPage = 1;
        _hasMore = false;
      });
    }
  }

  // Load favorites
  Future<void> _loadFavorites({bool refresh = false}) async {
    if (_isLoadingMore && !refresh) return;

    setState(() {
      if (refresh) {
        _currentPage = 1;
        _favoriteProducts.clear();
        _hasMore = true;
      }
      _isLoadingMore = true;
    });

    try {
      final provider = Provider.of<FavoriteProvider>(context, listen: false);
      final products = await provider.getFavoriteProducts(
        page: _currentPage,
        limit: 20,
        refreshCache: refresh,
      );

      setState(() {
        if (refresh) {
          _favoriteProducts.clear();
        }
        _favoriteProducts.addAll(products);
        _hasMore = products.length == 20;
        if (products.isNotEmpty) {
          _currentPage++;
        }
      });
    } catch (error) {
      log('❌ Load favorites error: $error');
      _showErrorSnackbar('Failed to load favorites: $error');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Clear all favorites dialog
  void _showClearAllDialog() {
    if (_favoriteProducts.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: Text(
          'Remove all ${_favoriteProducts.length} items from favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _clearAllFavorites(),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Clear all favorites
  Future<void> _clearAllFavorites() async {
    Navigator.pop(context);

    final tempList = List<FavoriteProduct>.from(_favoriteProducts);

    // Optimistic update
    setState(() {
      _favoriteProducts.clear();
    });

    try {
      final provider = Provider.of<FavoriteProvider>(context, listen: false);
      await provider.clearAllFavorites();

      _showSuccessSnackbar('All favorites cleared');
    } catch (error) {
      // Restore on error
      setState(() {
        _favoriteProducts.clear();
        _favoriteProducts.addAll(tempList);
      });
      _showErrorSnackbar('Error: $error');
    }
  }

  // Helper methods
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, provider, child) {
        final totalFavorites = provider.favoriteCount;
        final isLoading = provider.isLoading;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: CustomAppBar(title: 'My Favorites', showBackButton: false),
          body: isLoading && _favoriteProducts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _favoriteProducts.isEmpty
              ? _buildEmptyView()
              : _buildFavoritesList(totalFavorites),
        );
      },
    );
  }

  // Empty state
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Favorites Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Favorites list with grid
  Widget _buildFavoritesList(int totalFavorites) {
    return RefreshIndicator(
      onRefresh: () => _loadFavorites(refresh: true),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$totalFavorites ${totalFavorites == 1 ? 'Item' : 'Items'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.brown,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showClearAllDialog,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ),
          ),

          // Grid of favorites
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.70,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildFavoriteCard(_favoriteProducts[index]),
                childCount: _favoriteProducts.length,
              ),
            ),
          ),

          // Load more indicator
          if (_hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: _isLoadingMore
                      ? const CircularProgressIndicator()
                      : TextButton(
                          onPressed: () => _loadFavorites(),
                          child: const Text('Load More'),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Single favorite card
  Widget _buildFavoriteCard(FavoriteProduct product) {
    final hasDiscount = product.discountPercentage > 0;
    final buyerProduct = _convertToBuyerProduct(product);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image section
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                // Product Image
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: _buildProductImage(product),
                ),

                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    productId: product.productId,
                    initialIsFavorited: true,
                  ),
                ),

                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 10,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.discountPercentage.toInt()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Details section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 5,
                bottom: 2,
              ),
              child: _buildProductDetails(product, buyerProduct),
            ),
          ),
        ],
      ),
    );
  }

  // Product image widget
  Widget _buildProductImage(FavoriteProduct product) {
    if (product.featuredImage == null) {
      return const Center(
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
          child: Icon(Icons.image, color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Image.network(
        product.featuredImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.image, size: 40, color: Colors.grey),
          );
        },
      ),
    );
  }

  // Product details widget
  Widget _buildProductDetails(
    FavoriteProduct product,
    BuyerProductModel buyerProduct,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title and Description
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product.shortDescription,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Price and Rating
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${product.finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    if (product.basePrice > product.finalPrice)
                      Text(
                        '\$${product.basePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),

                // Rating
                if (product.rating > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Order Now Button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            backgroundColor: AppColors.yellowButton,
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: buyerProduct),
                ),
              );
            },
            child: const Text(
              'Order Now',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Convert FavoriteProduct to BuyerProductModel
  BuyerProductModel _convertToBuyerProduct(FavoriteProduct favorite) {
    return BuyerProductModel(
      id: favorite.productId,
      sellerId: null,
      sellerInfo: null,
      title: favorite.title,
      shortDescription: favorite.shortDescription,
      longDescription: favorite.longDescription ?? '',
      category: favorite.category,
      productType: null,
      tags: [],
      basePrice: favorite.basePrice,
      salePrice: favorite.salePrice,
      costPrice: null,
      taxRate: null,
      currency: 'USD',
      hasDiscount: favorite.discountPercentage > 0,
      sku: null,
      stockQuantity: favorite.stockQuantity,
      lowStockAlert: null,
      weight: null,
      dimensions: null,
      dimensionSpec: null,
      variants: [],
      variantTypes: [],
      featuredImage: favorite.featuredImage,
      imageGallery: favorite.imageGallery,
      video: null,
      status: 'active',
      isActive: true,
      views: favorite.views,
      salesCount: favorite.salesCount,
      inStock: favorite.inStock,
      finalPrice: favorite.finalPrice,
      discountPercentage: favorite.discountPercentage,
      rating: favorite.rating > 0 ? favorite.rating : null,
      reviewCount: null,
      isFavorited: true,
      favoriteId: favorite.id,
      createdAt: favorite.addedDate,
      updatedAt: favorite.addedDate,
      createdBy: null,
    );
  }
}
