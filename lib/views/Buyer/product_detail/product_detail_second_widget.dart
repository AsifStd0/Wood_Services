import 'package:flutter/material.dart';
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
        _buildMainSlider(context),
        const SizedBox(height: 16),
        _buildThumbnailStrip(context),
      ],
    );
  }

  Widget _buildMainSlider(BuildContext context) {
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
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;
              final surfaceContainer = colorScheme.surfaceContainerHighest;
              final onSurfaceVariant = colorScheme.onSurfaceVariant;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: surfaceContainer.withOpacity(0.5),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: productImages[index] == 'placeholder'
                      ? Container(
                          color: surfaceContainer,
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: onSurfaceVariant,
                          ),
                        )
                      : Image.network(
                          productImages[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: surfaceContainer,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: colorScheme.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: surfaceContainer,
                              child: Icon(
                                Icons.broken_image,
                                size: 80,
                                color: onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                ),
              );
            },
          ),

          if (productImages.length > 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.inverseSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${productImages.length}',
                      style: TextStyle(
                        color: colorScheme.onInverseSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailStrip(BuildContext context) {
    if (productImages.length <= 1) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaceContainer = colorScheme.surfaceContainerHighest;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
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
                left: index == 0 ? 16 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentPage == index
                      ? colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    productImages[index] == 'placeholder'
                        ? Container(
                            color: surfaceContainer,
                            child: Icon(
                              Icons.image,
                              size: 30,
                              color: onSurfaceVariant,
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
                                color: surfaceContainer,
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
                                color: surfaceContainer,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 30,
                                  color: onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                    if (_currentPage == index)
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.scrim.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: colorScheme.surface,
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
