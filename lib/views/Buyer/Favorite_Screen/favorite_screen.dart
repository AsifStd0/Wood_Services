import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/favorite_button.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/buyer_favorite_product_model.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';
import 'package:wood_service/views/Buyer/product_detail/product_detail.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/custom_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  List<FavoriteProduct> _favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();

    // Listen to provider changes to sync local list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final favoriteProvider = Provider.of<FavoriteProvider>(
          context,
          listen: false,
        );
        favoriteProvider.addListener(_onFavoritesChanged);
      }
    });
  }

  void _onFavoritesChanged() {
    if (!mounted) return;

    // Filter out items that are no longer favorited
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    final filtered = _favoriteProducts.where((product) {
      return favoriteProvider.isProductFavorited(product.productId);
    }).toList();

    if (filtered.length != _favoriteProducts.length) {
      setState(() {
        _favoriteProducts = filtered;
        if (_favoriteProducts.isEmpty) {
          _currentPage = 1;
          _hasMore = false;
        }
      });
    }
  }

  @override
  void dispose() {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    favoriteProvider.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  Future<void> _loadFavorites({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      if (refresh) {
        _currentPage = 1;
        _favoriteProducts.clear();
        _hasMore = true;
      }
      _isLoading = true;
    });

    try {
      final favoriteProvider = Provider.of<FavoriteProvider>(
        context,
        listen: false,
      );

      final products = await favoriteProvider.getFavoriteProducts(
        page: _currentPage,
        limit: 20,
        refreshCache: refresh,
      );

      setState(() {
        if (refresh) {
          _favoriteProducts = products;
        } else {
          _favoriteProducts.addAll(products);
        }

        _hasMore =
            products.length == 20; // If we got 20 items, there might be more

        if (products.isNotEmpty) {
          _currentPage++;
        }
      });
    } catch (error) {
      log('❌ Load favorites error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load favorites: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final totalFavorites = favoriteProvider.favoriteCount;

        // Filter out items that are no longer favorited (when user clicks unfavorite)
        final filteredProducts = _favoriteProducts.where((product) {
          return favoriteProvider.isProductFavorited(product.productId);
        }).toList();

        // Update local list if filtered list is different (only once per frame)
        if (filteredProducts.length != _favoriteProducts.length && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _favoriteProducts = filteredProducts;
                // Reset pagination if list becomes empty
                if (_favoriteProducts.isEmpty) {
                  _currentPage = 1;
                  _hasMore = false;
                }
              });
            }
          });
        }

        final displayProducts =
            filteredProducts.length != _favoriteProducts.length
            ? filteredProducts
            : _favoriteProducts;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: CustomAppBar(title: 'My Favorites', showBackButton: false),
          body: _isLoading && _favoriteProducts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : displayProducts.isEmpty
              ? buildEmptyView()
              : _buildFavoritesGrid(context, totalFavorites, displayProducts),
        );
      },
    );
  }

  Widget _buildFavoritesGrid(
    BuildContext context,
    int totalFavorites,
    List<FavoriteProduct> products,
  ) {
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
                childAspectRatio: 0.70, // Same as home screen
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildFavoriteCard(products[index], index);
              }, childCount: products.length),
            ),
          ),

          // Load more button
          if (_hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: _isLoading
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

  Widget _buildFavoriteCard(FavoriteProduct product, int index) {
    final bool hasDiscount = product.discountPercentage > 0;
    final double discount = hasDiscount ? product.discountPercentage : 0;

    // Convert FavoriteProduct to BuyerProductModel for navigation
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
                  child: product.featuredImage != null
                      ? ClipRRect(
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
                                child: Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.image, color: Colors.white),
                          ),
                        ),
                ),

                // Favorite Button (Already favorited - shows red heart)
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    productId: product.productId,
                    initialIsFavorited: true,
                  ),
                ),

                // Discount Badge
                if (hasDiscount && discount > 0)
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
                        '${discount.toInt()}% OFF',
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

          // Product Details
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 5,
                bottom: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
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

                      // Short Description
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
                          // Price Column
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
                              if (hasDiscount &&
                                  product.basePrice > product.finalPrice)
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
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber,
                                  ),
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
                            builder: (_) =>
                                ProductDetailScreen(product: buyerProduct),
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
              ),
            ),
          ),
        ],
      ),
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
            onPressed: () async {
              Navigator.pop(context);

              final favoriteProvider = Provider.of<FavoriteProvider>(
                context,
                listen: false,
              );

              // Optimistic update
              final tempList = List<FavoriteProduct>.from(_favoriteProducts);
              setState(() {
                _favoriteProducts.clear();
              });

              try {
                await favoriteProvider.clearAllFavorites();

                // Reset state and reload
                setState(() {
                  _favoriteProducts.clear();
                  _currentPage = 1;
                  _hasMore = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All favorites cleared'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (error) {
                // If error, restore list
                setState(() {
                  _favoriteProducts = tempList;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyView() {
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
}
