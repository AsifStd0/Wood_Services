import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';

import '../../../app/index.dart';

class ProductImageGallery extends StatefulWidget {
  final BuyerProductModel product;

  const ProductImageGallery({super.key, required this.product});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Get actual product images from the product model
  List<String> get productImages {
    final images = <String>[];

    // Add featured image first if available
    if (widget.product.featuredImage != null &&
        widget.product.featuredImage!.isNotEmpty) {
      images.add(_getFullImageUrl(widget.product.featuredImage!));
    }

    // Add gallery images
    for (final imageUrl in widget.product.imageGallery) {
      if (imageUrl.isNotEmpty) {
        final fullUrl = _getFullImageUrl(imageUrl);
        // Avoid duplicates if featured image is also in gallery
        if (!images.contains(fullUrl)) {
          images.add(fullUrl);
        }
      }
    }

    // If no images, return placeholder
    if (images.isEmpty) {
      return ['placeholder']; // Will show placeholder icon
    }

    return images;
  }

  // Build full image URL
  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    // If it starts with /uploads/ or /, prepend base URL
    if (imagePath.startsWith('/')) {
      return '${Config.baseUrl}$imagePath';
    }
    // Otherwise, assume it's in uploads folder
    return '${Config.baseUrl}/uploads/$imagePath';
  }

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
                  child: productImages[index] == 'placeholder'
                      ? Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        )
                      : Image.network(
                          productImages[index],
                          fit: BoxFit.cover,
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
                                  color: AppColors.brightOrange,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
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

          // Page Indicator (only show if more than 1 image)
          if (productImages.length > 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
        ],
      ),
    );
  }

  Widget _buildThumbnailStrip() {
    // Hide thumbnail strip if only 1 image or no images
    if (productImages.length <= 1) {
      return const SizedBox.shrink();
    }

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
                    productImages[index] == 'placeholder'
                        ? Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image,
                              size: 30,
                              color: Colors.grey[400],
                            ),
                          )
                        : Image.network(
                            productImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
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
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
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
