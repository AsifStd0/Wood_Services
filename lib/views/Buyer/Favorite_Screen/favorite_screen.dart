import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<FavoriteProduct> _favoriteItems = [
    FavoriteProduct(
      id: '1',
      name: 'Premium Teak Wood Planks',
      description: 'Grade A Teak, 2" x 4" x 8ft, Water Resistant',
      price: 299.99,
      originalPrice: 349.99,
      imageUrl:
          'https://images.unsplash.com/photo-1596541223130-5ccd06ed6e78?w=200&h=200&fit=crop',
      seller: 'Premium Timber Co.',
      rating: 4.8,
      reviewCount: 124,
      inStock: true,
      isOnSale: true,
      discountPercent: 15,
      isSustainable: true,
      addedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FavoriteProduct(
      id: '2',
      name: 'Solid Mahogany Dining Table',
      description: 'Handcrafted Mahogany, 72" x 36" x 30"',
      price: 1299.99,
      originalPrice: 1499.99,
      imageUrl:
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&h=200&fit=crop',
      seller: 'Luxury Furniture',
      rating: 4.9,
      reviewCount: 89,
      inStock: true,
      isOnSale: true,
      discountPercent: 13,
      isSustainable: false,
      addedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    FavoriteProduct(
      id: '3',
      name: 'Oak Wood Bookshelf',
      description: 'Solid Oak, 5 Shelves, 60" Height',
      price: 459.99,
      originalPrice: 459.99,
      imageUrl:
          'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=200&h=200&fit=crop',
      seller: 'Wood Crafts',
      rating: 4.6,
      reviewCount: 67,
      inStock: false,
      isOnSale: false,
      discountPercent: 0,
      isSustainable: true,
      addedDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
    FavoriteProduct(
      id: '4',
      name: 'Walnut Coffee Table',
      description: 'Modern Design, 48" Round, Glass Top',
      price: 599.99,
      originalPrice: 699.99,
      imageUrl:
          'https://images.unsplash.com/photo-1533090368676-1fd25485db88?w=200&h=200&fit=crop',
      seller: 'Modern Furniture',
      rating: 4.7,
      reviewCount: 203,
      inStock: true,
      isOnSale: true,
      discountPercent: 14,
      isSustainable: true,
      addedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FavoriteProduct(
      id: '5',
      name: 'Maple Wood Chairs (Set of 4)',
      description: 'Solid Maple, Upholstered Seats, Modern Design',
      price: 399.99,
      originalPrice: 499.99,
      imageUrl:
          'https://images.unsplash.com/photo-1503602642458-232111445657?w=200&h=200&fit=crop',
      seller: 'Home Comfort',
      rating: 4.5,
      reviewCount: 156,
      inStock: true,
      isOnSale: true,
      discountPercent: 20,
      isSustainable: true,
      addedDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  bool _gridView = true;
  String _sortBy = 'Recently Added';
  final List<String> _sortOptions = [
    'Recently Added',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated',
    'Name: A to Z',
  ];

  List<FavoriteProduct> get _sortedItems {
    List<FavoriteProduct> items = List.from(_favoriteItems);

    switch (_sortBy) {
      case 'Recently Added':
        items.sort((a, b) => b.addedDate.compareTo(a.addedDate));
        break;
      case 'Price: Low to High':
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Highest Rated':
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Name: A to Z':
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // View Toggle
          IconButton(
            icon: Icon(
              _gridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: Colors.brown,
            ),
            onPressed: () {
              setState(() {
                _gridView = !_gridView;
              });
            },
          ),
        ],
      ),
      body: _favoriteItems.isEmpty
          ? _buildEmptyFavorites()
          : _buildFavoritesContent(),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_outline_rounded,
              size: 50,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start saving your favorite wood products to easily find them later',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.explore_outlined),
            label: const Text(
              'Explore Products',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return Column(
      children: [
        // Sort Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_favoriteItems.length} ${_favoriteItems.length == 1 ? 'Item' : 'Items'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              Row(
                children: [
                  // Sort
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _sortBy = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return _sortOptions.map((String option) {
                        return PopupMenuItem<String>(
                          value: option,
                          child: Row(
                            children: [
                              Icon(
                                _sortBy == option ? Icons.check : null,
                                size: 16,
                                color: Colors.brown,
                              ),
                              const SizedBox(width: 8),
                              Text(option),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    icon: const Icon(Icons.sort_rounded, color: Colors.brown),
                  ),
                  Text('Order'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Products Grid/List
        Expanded(child: _gridView ? _buildGridView() : _buildListView()),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.51,
      ),
      itemCount: _sortedItems.length,
      itemBuilder: (context, index) {
        return _buildGridItem(_sortedItems[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sortedItems.length,
      itemBuilder: (context, index) {
        return _buildListItem(_sortedItems[index]);
      },
    );
  }

  Widget _buildGridItem(FavoriteProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Product Image with Badges
          Stack(
            children: [
              // Product Image
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Favorite Button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                    onPressed: () => _removeFromFavorites(product.id),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Seller
                Text(
                  product.seller,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Rating
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviewCount})',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Price
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _addToCart(product),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(FavoriteProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              image: DecorationImage(
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Seller
                  Text(
                    product.seller,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 8),

                  // Rating and Stock
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Stock Status
                      if (!product.inStock)
                        Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price and Actions
                  Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Action Buttons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            onPressed: () => _removeFromFavorites(product.id),
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () => _addToCart(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Favorite Actions
  void _removeFromFavorites(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Remove from Favorites'),
          content: const Text(
            'Are you sure you want to remove this item from your favorites?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _favoriteItems.removeWhere((item) => item.id == productId);
                });
                Navigator.pop(context);
                _showSnackBar('Removed from favorites');
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(FavoriteProduct product) {
    // Add to cart logic here
    _showSnackBar('Added ${product.name} to cart');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.brown,
      ),
    );
  }
}

// Favorite Product Model
class FavoriteProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final String seller;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final bool isOnSale;
  final int discountPercent;
  final bool isSustainable;
  final DateTime addedDate;

  FavoriteProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.seller,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.isOnSale,
    required this.discountPercent,
    required this.isSustainable,
    required this.addedDate,
  });
}
