import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/buyer_favorite_product_model.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

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

  Future<void> _removeFavorite(int index) async {
    final product = _favoriteProducts[index];
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    // Optimistic update - remove from UI immediately
    setState(() {
      _favoriteProducts.removeAt(index);
    });

    try {
      await favoriteProvider.removeFromFavorites(product.productId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      // If error, add back to list
      setState(() {
        _favoriteProducts.insert(index, product);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final totalFavorites = favoriteProvider.favoriteCount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'My Favorites',
        showBackButton: false,
        actions: [
          Row(
            children: [
              if (_favoriteProducts.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _showClearAllDialog,
                  tooltip: 'Clear All',
                ),
            ],
          ),
        ],
      ),
      body: _isLoading && _favoriteProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _favoriteProducts.isEmpty
          ? _buildEmptyView()
          : _buildFavoritesGrid(context, totalFavorites),
    );
  }

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
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the heart icon on any product to add it to your favorites',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(BuildContext context, int totalFavorites) {
    return RefreshIndicator(
      onRefresh: () => _loadFavorites(refresh: true),
      child: CustomScrollView(
        slivers: [
          // Header with count
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
                return _buildFavoriteCard(_favoriteProducts[index], index);
              }, childCount: _favoriteProducts.length),
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

    return GestureDetector(
      onLongPress: () => _showRemoveDialog(product, index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badges
            Stack(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 90,
                    color: Colors.grey[200],
                    child: Center(
                      child: product.featuredImage != null
                          ? Image.network(
                              product.featuredImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : CircleAvatar(radius: 60),
                    ),
                  ),
                ),

                // Favorite Button (Already favorited - shows red heart)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _showRemoveDialog(product, index),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Discount Badge
                if (hasDiscount && discount > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${discount.toInt()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
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
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      product.shortDescription,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Price and Stock
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
                                fontSize: 16,
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

                        // Stock Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.inStock ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.inStock ? 'In Stock' : 'Out of Stock',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Rating (if available)
                    if (product.rating > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.views})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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

  void _showRemoveDialog(FavoriteProduct product, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Favorites'),
        content: Text('Remove "${product.title}" from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFavorite(index);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All favorites cleared'),
                    backgroundColor: Colors.green,
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
}
