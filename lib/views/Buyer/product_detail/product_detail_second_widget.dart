import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/product_detail/car_bottom_sheet.dart';

import '../../../app/index.dart';

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
      height: 200,
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
