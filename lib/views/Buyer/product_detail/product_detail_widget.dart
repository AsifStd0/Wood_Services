import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/views/Buyer/product_detail/car_bottom_sheet.dart';
import 'package:wood_service/views/Buyer/product_detail/product_detail.dart';
import 'package:wood_service/widgets/custom_button.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({super.key});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Sample images - replace with your actual image URLs
  final List<String> productImages = [
    'assets/images/sofa.jpg',
    'assets/images/sofa1.jpg',
    'assets/images/table.jpg',
    'assets/images/table2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageListener);
  }

  void _pageListener() {
    setState(() {
      _currentPage = _pageController.page?.round() ?? 0;
    });
  }

  void _onThumbnailTap(int index) {
    setState(() {
      _currentPage = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Main Slider
        _buildMainSlider(),

        const SizedBox(height: 16),

        // Bottom Thumbnail Strip
        _buildThumbnailStrip(),
      ],
    );
  }

  Widget _buildMainSlider() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Main PageView Slider
          PageView.builder(
            controller: _pageController,
            itemCount: productImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    productImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.chair,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Page Indicator
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentPage + 1}/${productImages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Favorite Button
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: () {
                  // Add to favorites
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onThumbnailTap(index),
            child: Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.only(
                right: 12,
                left: index == 0 ? 16 : 0, // First item left margin
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentPage == index
                      ? AppColors.brightOrange
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    // Thumbnail Image
                    Image.asset(
                      productImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.chair,
                            size: 30,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),

                    // Selection Overlay
                    if (_currentPage == index)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
// class ProductImageGallery extends StatelessWidget {
//   const ProductImageGallery({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 300,
//       child: Stack(
//         children: [
//           // Main Image
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.grey[100],
//             ),
//             child: Image.asset('assets/images/sofa.jpg', fit: BoxFit.cover),
//           ),

//           // Image Indicator
//           Positioned(
//             bottom: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Text(
//                 '1/4',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ProductBasicInfo extends StatelessWidget {
  const ProductBasicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Modern Velvet Sofa',
          type: CustomTextType.headingMedium,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),

        const SizedBox(height: 3),

        // Price
        Row(
          children: [
            CustomText(
              '\$899.00',
              type: CustomTextType.headingMedium,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
            const SizedBox(width: 10),
            CustomText(
              '\$899.00',
              type: CustomTextType.headingMedium,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
              decoration: TextDecoration.lineThrough,
              fontSize: 18,
            ),
          ],
        ),

        // Rating
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),

              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.brightOrange,
                    size: 14,
                  ),
                  const SizedBox(width: 3),

                  CustomText(
                    '4.8',
                    type: CustomTextType.buttonMedium,
                    color: AppColors.brightOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            CustomText(
              '(120)',
              type: CustomTextType.buttonMedium,
              color: AppColors.grey,
            ),
          ],
        ),
      ],
    );
  }
}

class SellerInfoCard extends StatelessWidget {
  const SellerInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 12, bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Seller Avatar
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue[50],
            backgroundImage: AssetImage('assets/images/sofa.jpg'),
          ),

          const SizedBox(width: 6),

          // Seller Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'Crafted Interiors',
                  type: CustomTextType.buttonMedium,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                // Text(
                //   'Crafted Interiors',
                //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Top Rated Seller',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View Shop Button
          OutlinedButton(
            onPressed: () {
              // Navigate to shop page
            },
            child: const Text('View Shop'),
          ),
        ],
      ),
    );
  }
}

// ! ***
class MinimalColorSelectionWidget extends StatefulWidget {
  const MinimalColorSelectionWidget({super.key});

  @override
  State<MinimalColorSelectionWidget> createState() =>
      _MinimalColorSelectionWidgetState();
}

class _MinimalColorSelectionWidgetState
    extends State<MinimalColorSelectionWidget> {
  int _selectedColorIndex = 0;

  final List<Color> _colors = [
    Colors.blueGrey,
    Colors.brown,
    Colors.grey,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Color',
          type: CustomTextType.buttonMedium,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),

        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_colors.length, (index) {
            return _buildMinimalColorOption(_colors[index], index);
          }),
        ),
      ],
    );
  }

  Widget _buildMinimalColorOption(Color color, int index) {
    bool isSelected = _selectedColorIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: isSelected ? 40 : 40,
        height: isSelected ? 40 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 12, color: Colors.black),
                ),
              )
            : null,
      ),
    );
  }
}

// ! ****
class SizeSelectionWidget extends StatefulWidget {
  SizeSelectionWidget({super.key});

  @override
  State<SizeSelectionWidget> createState() => _SizeSelectionWidgetState();
}

class _SizeSelectionWidgetState extends State<SizeSelectionWidget> {
  int _selectedSizeIndex = 1; // Default to Medium (index 1)

  final List<String> _sizes = ['Small', 'Medium', 'Large'];
  final List<String> _sizeDimensions = ['80x80cm', '120x120cm', '150x150cm'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              'Size',
              type: CustomTextType.buttonMedium,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            Text(
              _sizeDimensions[_selectedSizeIndex],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < _sizes.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _buildSizeOption(_sizes[i], i == _selectedSizeIndex, i),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size, bool isSelected, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSizeIndex = index;
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                size,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              // if (isSelected)
              // const Icon(Icons.check, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ! *****
class MinimalQuantityStockWidget extends StatefulWidget {
  const MinimalQuantityStockWidget({super.key});

  @override
  State<MinimalQuantityStockWidget> createState() =>
      _MinimalQuantityStockWidgetState();
}

class _MinimalQuantityStockWidgetState
    extends State<MinimalQuantityStockWidget> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Quantity',
              type: CustomTextType.buttonMedium,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),

        // Minimal Quantity Selector
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffF6DCC9),

            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              // Decrement Button
              _buildButton(
                icon: Icons.remove,
                isEnabled: _quantity > 1,
                onTap: () {
                  setState(() {
                    _quantity--;
                  });
                },
                isLeft: true,
              ),

              // Quantity Display
              Container(
                width: 40,
                height: 36,
                child: Center(
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Increment Button
              _buildButton(
                icon: Icons.add,
                isEnabled: true,
                onTap: () {
                  setState(() {
                    _quantity++;
                  });
                },
                isLeft: false,
              ),
            ],
          ),
        ),

        // Stock Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 14),
              const SizedBox(width: 4),
              Text(
                'In Stock',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled ? null : Colors.transparent,
          borderRadius: isLeft
              ? const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.black : Colors.grey[400],
          size: 18,
        ),
      ),
    );
  }
}

class ProductTabsSection extends StatefulWidget {
  const ProductTabsSection({super.key});

  @override
  State<ProductTabsSection> createState() => _ProductTabsSectionState();
}

class _ProductTabsSectionState extends State<ProductTabsSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Headers
        Row(
          children: [
            _buildTab('Description', 0),
            _buildTab('Specifications', 1),
            _buildTab('Shipping & Returns', 2),
          ],
        ),

        const SizedBox(height: 16),

        // Tab Content
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: _selectedTab == index
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _selectedTab == index ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return const Text(
          'Experience ultimate comfort with our Modern Velvet Sofa. Crafted with premium materials and elegant design, this sofa adds sophistication to any living space. Perfect for modern homes seeking both style and comfort.',
          style: TextStyle(height: 1.5),
        );
      case 1:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Material: Premium Velvet'),
            Text('• Dimensions: 84" W x 36" D x 32" H'),
            Text('• Weight: 120 lbs'),
            Text('• Assembly: Required'),
          ],
        );
      case 2:
        return const Text(
          'Free shipping on orders over \$50. Returns accepted within 30 days. Contact customer service for return instructions.',
          style: TextStyle(height: 1.5),
        );
      default:
        return const SizedBox();
    }
  }
}

class ReviewsPreviewSection extends StatelessWidget {
  const ReviewsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews (120)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all reviews
              },
              child: const Text('View All Reviews'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Review 1
        const ReviewItem(
          name: 'Sophia Bennett',
          rating: 5,
          comment:
              'Absolutely love this sofa! It\'s incredibly comfortable and looks fantastic in my living room. The quality is top-notch.',
        ),

        const SizedBox(height: 16),

        // Review 2
        const ReviewItem(
          name: 'Ethan Carter',
          rating: 5,
          comment:
              'Great sofa for the price. It\'s stylish and comfortable, although the cushions could be a bit firmer. Overall, very satisfied.',
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;

  const ReviewItem({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 8),

          // Stars
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                color: index < rating ? Colors.amber : Colors.grey[300],
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(comment, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}

class RelatedProductsSection extends StatelessWidget {
  const RelatedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Products',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              RelatedProductCard(
                name: 'Modern Armchair',
                price: '\$299',
                imageUrl: 'assets/images/sofa.jpg',
              ),
              SizedBox(width: 12),
              RelatedProductCard(
                name: 'Coffee Table',
                price: '\$149',
                imageUrl: 'assets/images/table.jpg',
              ),
              SizedBox(width: 12),
              RelatedProductCard(
                name: 'Side Table',
                price: '\$199',
                imageUrl: 'assets/images/table2.jpg',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RelatedProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;

  const RelatedProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Icon(Icons.chair, size: 60, color: Colors.grey[400]),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductActionButtons extends StatelessWidget {
  const ProductActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.15),
        //     blurRadius: 20,
        //     spreadRadius: 2,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          // Add to Cart Button
          Expanded(
            child: CustomButtonUtils.login(
              height: 45,
              padding: EdgeInsets.all(0),
              title: 'Add to Cart',
              backgroundColor: AppColors.orangeLight,
              color: AppColors.brightOrange,
              borderRadius: 6,

              onPressed: () {
                context.push('/new_password');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButtonUtils.login(
              height: 45,
              padding: EdgeInsets.all(0),
              title: 'Buy Now',
              backgroundColor: AppColors.brightOrange,
              borderRadius: 6,
              onPressed: () {
                showCartBottomSheet(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showCartBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    builder: (context) => const CartBottomSheet(),
  );
}
