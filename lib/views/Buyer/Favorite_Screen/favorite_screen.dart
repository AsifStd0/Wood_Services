import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favirute_widet.dart';
import 'package:wood_service/views/Buyer/home/asif/model/favirute_model.dart';
import 'package:wood_service/widgets/advance_appbar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // bool _gridView = true;
  String _sortBy = 'Recently Added';
  final List<String> _sortOptions = [
    'Recently Added',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated',
    'Name: A to Z',
  ];

  List<FavoriteProduct> get _sortedItems {
    List<FavoriteProduct> items = List.from(favoriteItems);

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
      appBar: CustomAppBar(
        title: 'My Favorites',
        automaticallyImplyLeading: false,
        showBackButton: false,
      ),
      body: favoriteItems.isEmpty
          ? buildEmptyFavorites(context)
          : _buildFavoritesContent(),
    );
  }

  Widget _buildFavoritesContent() {
    return Column(
      children: [
        // Sort Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${favoriteItems.length} ${favoriteItems.length == 1 ? 'Item' : 'Items'}',
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
        Expanded(child: _buildGridView()),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 10, right: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        childAspectRatio: 0.50,
      ),
      itemCount: _sortedItems.length,
      itemBuilder: (context, index) {
        return _buildGridItem(_sortedItems[index]);
      },
    );
  }

  Widget _buildGridItem(FavoriteProduct product) {
    bool hasDiscount =
        product.originalPrice != null && product.originalPrice! > product.price;
    final double? discount = hasDiscount
        ? ((product.originalPrice! - product.price) /
                  product.originalPrice! *
                  100)
              .roundToDouble()
        : null;
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: Center(
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),

              // Discount Badge - Only show if product has discount
              if (hasDiscount && discount != null && discount > 0)
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
                // Seller
                Text(
                  product.seller,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Product Name
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

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

                // Price Section
                Row(
                  children: [
                    // Current Price
                    Text(
                      '\$${product.price.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 2),

                    // Original Price (Crossed) - Only show if has discount
                    if (hasDiscount)
                      Text(
                        '\$${product.originalPrice!.toInt()}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),

                    const Spacer(),

                    // Delivery Info - Only show if free delivery
                    // if (product.freeDelivery)
                    Row(
                      children: [
                        Text(
                          'Free Delivery',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                  favoriteItems.removeWhere((item) => item.id == productId);
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
