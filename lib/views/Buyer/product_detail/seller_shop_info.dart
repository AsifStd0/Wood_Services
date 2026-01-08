import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';

class ShopPreviewCard extends StatelessWidget {
  final BuyerProductModel product;

  const ShopPreviewCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final sellerInfo = product.sellerInfo;

    // Use the correct field names
    final shopName = sellerInfo?['businessName'] ?? 'Unknown Shop';
    final sellerName = sellerInfo?['name'] ?? 'Unknown Seller';
    final shopLogo = sellerInfo?['shopLogo'];
    final totalProducts = sellerInfo?['totalProducts'] ?? 0;
    final verificationStatus = sellerInfo?['verificationStatus'] ?? 'pending';

    return GestureDetector(
      onTap: () {
        _showShopDetailsDialog(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Shop Logo with verification badge
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    image: shopLogo != null
                        ? DecorationImage(
                            image: NetworkImage(_getFullImageUrl(shopLogo)),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage(
                              'assets/images/shop_placeholder.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                if (verificationStatus == 'verified')
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green),
                      ),
                      child: Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Shop Name and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shopName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Seller Name
                  Text(
                    sellerName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      // Products count
                      Icon(
                        Icons.inventory,
                        size: 12,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$totalProducts products',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Verification status badge
                      if (verificationStatus != 'verified')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            verificationStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      if (verificationStatus == 'verified')
                        Row(
                          children: [
                            Icon(Icons.verified, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(Icons.chevron_right, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://192.168.137.78:5001$imagePath';
  }

  void _showShopDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleShopDialog(product: product),
    );
  }
}

class SimpleShopDialog extends StatelessWidget {
  final BuyerProductModel product;

  const SimpleShopDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final sellerInfo = product.sellerInfo ?? {};

    final shopName = sellerInfo['businessName'] ?? 'Unknown Shop';
    final sellerName = sellerInfo['name'] ?? 'Unknown Seller';
    final email = sellerInfo['email'];
    final phone = sellerInfo['phone'];
    final shopLogo = sellerInfo['shopLogo'];
    final totalProducts = sellerInfo['totalProducts'] ?? 0;
    final verificationStatus = sellerInfo['verificationStatus'] ?? 'pending';
    final shopLocation = sellerInfo['address'] is Map
        ? _formatAddress(sellerInfo['address'])
        : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shop Logo with verification badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  // image: shopLogo != null
                  // ? DecorationImage(
                  //     image: NetworkImage(_getFullImageUrl(shopLogo)),
                  //     fit: BoxFit.cover,
                  //   )
                  // :
                  // const DecorationImage(
                  //     image: AssetImage(
                  //       'assets/images/shop_placeholder.png',
                  //     ),
                  //     fit: BoxFit.cover,
                  //   ),
                ),
                child: Icon(Icons.image),
              ),
              if (verificationStatus == 'verified')
                Container(
                  padding: const EdgeInsets.all(4),
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
                  child: Icon(Icons.verified, color: Colors.green, size: 18),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Shop Name
          Text(
            shopName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Seller Name
          Text(
            sellerName,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Contact Information Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                // Email
                if (email != null && email.isNotEmpty)
                  _buildContactItem(
                    icon: Icons.email,
                    title: 'Email',
                    value: email,
                  ),

                if (email != null && email.isNotEmpty)
                  const SizedBox(height: 10),

                // Phone
                if (phone != null && phone.isNotEmpty)
                  _buildContactItem(
                    icon: Icons.phone,
                    title: 'Phone',
                    value: phone,
                  ),

                if (shopLocation != null && shopLocation.isNotEmpty)
                  const SizedBox(height: 10),

                // Location
                if (shopLocation != null && shopLocation.isNotEmpty)
                  _buildContactItem(
                    icon: Icons.location_on,
                    title: 'Location',
                    value: shopLocation,
                  ),
              ],
            ),
          ),

          // Additional Info
          if (verificationStatus != 'verified')
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This seller is currently under verification process.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to shop page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening $shopName...'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Visit Shop'),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return '';

    final parts = <String>[];
    if (address['street'] != null) parts.add(address['street']);
    if (address['city'] != null) parts.add(address['city']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['country'] != null) parts.add(address['country']);

    return parts.join(', ');
  }
}


// ! ******

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ShopVisitScreen extends StatefulWidget {
//   final String sellerId;
//   final String shopName;

//   const ShopVisitScreen({
//     super.key,
//     required this.sellerId,
//     required this.shopName,
//   });

//   @override
//   State<ShopVisitScreen> createState() => _ShopVisitScreenState();
// }

// class _ShopVisitScreenState extends State<ShopVisitScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ShopApiService _apiService = ShopApiService();
//   ShopDetails? _shopDetails;
//   bool _isLoading = true;
//   bool _isFollowing = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _loadShopDetails();
//     _checkFollowingStatus();
//   }

//   Future<void> _loadShopDetails() async {
//     try {
//       final details = await _apiService.visitShop(widget.sellerId);
//       setState(() {
//         _shopDetails = details;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to load shop details: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _checkFollowingStatus() async {
//     try {
//       final isFollowing = await _apiService.checkFollowing(widget.sellerId);
//       setState(() {
//         _isFollowing = isFollowing;
//       });
//     } catch (e) {
//       print('Error checking following status: $e');
//     }
//   }

//   Future<void> _toggleFollow() async {
//     try {
//       final result = await _apiService.toggleFollowShop(widget.sellerId);
//       setState(() {
//         _isFollowing = result;
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(result ? 'Shop followed successfully!' : 'Shop unfollowed'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? Center(child: Text(_error!))
//               : _shopDetails == null
//                   ? const Center(child: Text('No shop data available'))
//                   : _buildShopScreen(),
//     );
//   }

//   Widget _buildShopScreen() {
//     final shop = _shopDetails!.shop;
//     final stats = _shopDetails!.statistics;

//     return NestedScrollView(
//       headerSliverBuilder: (context, innerBoxIsScrolled) {
//         return [
//           SliverAppBar(
//             expandedHeight: 250,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // Cover Image
//                   if (shop.coverImage != null)
//                     Image.network(
//                       _getFullImageUrl(shop.coverImage!),
//                       fit: BoxFit.cover,
//                     )
//                   else
//                     Container(
//                       color: Colors.blue.shade100,
//                       child: Icon(
//                         Icons.store,
//                         size: 100,
//                         color: Colors.blue.shade300,
//                       ),
//                     ),
                  
//                   // Gradient overlay
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                         colors: [
//                           Colors.black.withOpacity(0.7),
//                           Colors.transparent,
//                         ],
//                       ),
//                     ),
//                   ),
                  
//                   // Shop info overlay
//                   Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         children: [
//                           // Shop Logo
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 3),
//                               image: shop.shopLogo != null
//                                   ? DecorationImage(
//                                       image: NetworkImage(_getFullImageUrl(shop.shopLogo!)),
//                                       fit: BoxFit.cover,
//                                     )
//                                   : const DecorationImage(
//                                       image: AssetImage('assets/images/shop_placeholder.png'),
//                                       fit: BoxFit.cover,
//                                     ),
//                             ),
//                           ),
                          
//                           const SizedBox(width: 16),
                          
//                           // Shop Name and Info
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   shop.shopName,
//                                   style: const TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
                                
//                                 const SizedBox(height: 4),
                                
//                                 Text(
//                                   shop.businessName,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.white.withOpacity(0.9),
//                                   ),
//                                 ),
                                
//                                 const SizedBox(height: 8),
                                
//                                 Row(
//                                   children: [
//                                     if (shop.verificationStatus == 'verified')
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: Colors.green,
//                                           borderRadius: BorderRadius.circular(12),
//                                         ),
//                                         child: const Row(
//                                           children: [
//                                             Icon(Icons.verified, size: 12, color: Colors.white),
//                                             SizedBox(width: 4),
//                                             Text(
//                                               'Verified',
//                                               style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
                                    
//                                     const SizedBox(width: 8),
                                    
//                                     Icon(Icons.star, size: 14, color: Colors.amber),
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       stats.averageRating.toString(),
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
                                    
//                                     const SizedBox(width: 8),
                                    
//                                     Icon(Icons.inventory, size: 14, color: Colors.white),
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${stats.totalProducts} products',
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           SliverPersistentHeader(
//             pinned: true,
//             delegate: _SliverAppBarDelegate(
//               TabBar(
//                 controller: _tabController,
//                 labelColor: Colors.blue,
//                 unselectedLabelColor: Colors.grey,
//                 indicatorColor: Colors.blue,
//                 tabs: const [
//                   Tab(text: 'Overview'),
//                   Tab(text: 'Products'),
//                   Tab(text: 'Reviews'),
//                   Tab(text: 'About'),
//                 ],
//               ),
//             ),
//           ),
//         ];
//       },
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildOverviewTab(),
//           _buildProductsTab(),
//           _buildReviewsTab(),
//           _buildAboutTab(),
//         ],
//       ),
//     );
//   }

//   Widget _buildOverviewTab() {
//     final shop = _shopDetails!.shop;
//     final stats = _shopDetails!.statistics;
//     final featured = _shopDetails!.featuredProducts;
//     final bestSelling = _shopDetails!.bestSelling;
//     final categories = _shopDetails!.categories;

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // Stats Cards
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: GridView.count(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: 2,
//               childAspectRatio: 1.5,
//               mainAxisSpacing: 10,
//               crossAxisSpacing: 10,
//               children: [
//                 _buildStatCard(
//                   icon: Icons.inventory,
//                   value: '${stats.totalProducts}',
//                   label: 'Products',
//                   color: Colors.blue,
//                 ),
//                 _buildStatCard(
//                   icon: Icons.shopping_cart,
//                   value: '${stats.totalSales}',
//                   label: 'Total Sales',
//                   color: Colors.green,
//                 ),
//                 _buildStatCard(
//                   icon: Icons.star,
//                   value: stats.averageRating.toString(),
//                   label: 'Avg Rating',
//                   color: Colors.amber,
//                 ),
//                 _buildStatCard(
//                   icon: Icons.people,
//                   value: '${shop.followersCount}',
//                   label: 'Followers',
//                   color: Colors.purple,
//                 ),
//               ],
//             ),
//           ),

//           // Follow Button
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _toggleFollow,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 icon: Icon(
//                   _isFollowing ? Icons.check : Icons.add,
//                   size: 20,
//                 ),
//                 label: Text(
//                   _isFollowing ? 'Following' : 'Follow Shop',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Featured Products
//           if (featured.isNotEmpty)
//             _buildProductSection(
//               title: 'Featured Products',
//               products: featured,
//             ),

//           // Categories
//           if (categories.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Shop Categories',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: categories.map((category) {
//                       return Chip(
//                         label: Text('${category.name} (${category.count})'),
//                         backgroundColor: Colors.blue.shade100,
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),

//           // Best Selling
//           if (bestSelling.isNotEmpty)
//             _buildProductSection(
//               title: 'Best Selling',
//               products: bestSelling,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductsTab() {
//     return FutureBuilder<ShopProductsResponse>(
//       future: _apiService.getShopProducts(widget.sellerId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData) {
//           return const Center(child: Text('No products available'));
//         } else {
//           final response = snapshot.data!;
//           return GridView.builder(
//             padding: const EdgeInsets.all(8),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.7,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: response.products.length,
//             itemBuilder: (context, index) {
//               final product = response.products[index];
//               return ProductCard(product: product);
//             },
//           );
//         }
//       },
//     );
//   }

//   Widget _buildReviewsTab() {
//     return FutureBuilder<ShopReviewsResponse>(
//       future: _apiService.getShopReviews(widget.sellerId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData) {
//           return const Center(child: Text('No reviews yet'));
//         } else {
//           final response = snapshot.data!;
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: response.reviews.length,
//             itemBuilder: (context, index) {
//               final review = response.reviews[index];
//               return ReviewCard(review: review);
//             },
//           );
//         }
//       },
//     );
//   }

//   Widget _buildAboutTab() {
//     final shop = _shopDetails!.shop;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Shop Description
//           if (shop.description != null && shop.description!.isNotEmpty)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'About This Shop',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   shop.description!,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),

//           // Contact Information
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Contact Information',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
                  
//                   if (shop.email != null && shop.email!.isNotEmpty)
//                     _buildContactItem(
//                       icon: Icons.email,
//                       label: 'Email',
//                       value: shop.email!,
//                     ),
                  
//                   if (shop.phone != null && shop.phone!.isNotEmpty)
//                     _buildContactItem(
//                       icon: Icons.phone,
//                       label: 'Phone',
//                       value: shop.phone!,
//                     ),
                  
//                   if (shop.address != null && shop.address!.isNotEmpty)
//                     _buildContactItem(
//                       icon: Icons.location_on,
//                       label: 'Address',
//                       value: shop.address!,
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Shop Stats
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Shop Statistics',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
                  
//                   _buildStatItem(
//                     label: 'Joined Date',
//                     value: shop.joinedDate != null 
//                         ? '${shop.joinedDate!.day}/${shop.joinedDate!.month}/${shop.joinedDate!.year}'
//                         : 'N/A',
//                   ),
                  
//                   _buildStatItem(
//                     label: 'Verification Status',
//                     value: shop.verificationStatus.toUpperCase(),
//                     color: shop.verificationStatus == 'verified' 
//                         ? Colors.green 
//                         : Colors.orange,
//                   ),
                  
//                   _buildStatItem(
//                     label: 'Total Products',
//                     value: '${_shopDetails!.statistics.totalProducts}',
//                   ),
                  
//                   _buildStatItem(
//                     label: 'Total Sales',
//                     value: '${_shopDetails!.statistics.totalSales}',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper widgets
//   Widget _buildStatCard({
//     required IconData icon,
//     required String value,
//     required String label,
//     required Color color,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 30, color: color),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductSection({
//     required String title,
//     required List<Product> products,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 200,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: products.length,
//               itemBuilder: (context, index) {
//                 final product = products[index];
//                 return Container(
//                   width: 150,
//                   margin: const EdgeInsets.only(right: 12),
//                   child: ProductCard(product: product),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContactItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: Colors.blue),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 SelectableText(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required String label,
//     required String value,
//     Color? color,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getFullImageUrl(String imagePath) {
//     if (imagePath.startsWith('http')) return imagePath;
//     return 'http://192.168.137.78:5001$imagePath';
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;

//   _SliverAppBarDelegate(this._tabBar);

//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: Colors.white,
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }