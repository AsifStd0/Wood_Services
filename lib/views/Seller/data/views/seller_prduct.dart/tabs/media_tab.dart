import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';

class MediaTab extends StatefulWidget {
  const MediaTab({super.key});

  @override
  State<MediaTab> createState() => _MediaTabState();
}

class _MediaTabState extends State<MediaTab> {
  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<SellerProductProvider>();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Media Gallery',
                'Upload product images, videos, and documents',
              ),
              const SizedBox(height: 24),

              // Featured Image
              _buildMediaSection(
                'Featured Image',
                'Main product image displayed in listings (Required)',
                _buildFeaturedImageSection(productProvider),
              ),
              const SizedBox(height: 32),

              // Image Gallery
              _buildMediaSection(
                'Image Gallery',
                'Additional product images (Optional, up to 10 images)',
                _buildImageGallery(productProvider),
              ),
              const SizedBox(height: 32),

              // Uploaded Images Preview
              if (productProvider.selectedImages.isNotEmpty) ...[
                _buildUploadedImagesPreview(productProvider),
                const SizedBox(height: 32),
              ],

              // Validation message
              if (productProvider.currentTabIndex == 4 &&
                  productProvider.selectedImages.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[800]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please upload at least one product image before publishing',
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Loading overlay
        if (productProvider.isUploadingImages || productProvider.isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    productProvider.isUploadingImages
                        ? 'Uploading images...'
                        : 'Publishing product...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedImageSection(SellerProductProvider provider) {
    return GestureDetector(
      onTap: () => provider.pickFeaturedImage(),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: provider.featuredImage == null
                ? Colors.red.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: provider.featuredImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  provider.featuredImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add Featured Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommended: 800x800px, Max 5MB',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  if (provider.featuredImage == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '* Required',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildImageGallery(SellerProductProvider provider) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: provider.selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildAddImageButton(provider);
            }
            final imageIndex = index - 1;
            if (imageIndex < provider.selectedImages.length) {
              return _buildImageThumbnail(provider, imageIndex);
            }
            return Container();
          },
        ),
        const SizedBox(height: 16),
        if (provider.selectedImages.length < 10)
          ElevatedButton.icon(
            onPressed: () => provider.pickMultipleImages(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add More Images'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
      ],
    );
  }

  Widget _buildAddImageButton(SellerProductProvider provider) {
    return GestureDetector(
      onTap: () => provider.pickMultipleImages(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 24, color: Colors.grey[500]),
            const SizedBox(height: 4),
            Text(
              'Add Image',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              '${provider.selectedImages.length}/10',
              style: TextStyle(fontSize: 8, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(SellerProductProvider provider, int index) {
    final isFeatured =
        provider.featuredImage != null &&
        provider.selectedImages[index].path == provider.featuredImage!.path;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            provider.selectedImages[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => provider.removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (isFeatured)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Featured',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadedImagesPreview(SellerProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Images (${provider.selectedImages.length})',
          style: _buildLabelStyle(),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: provider.selectedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              final isFeatured =
                  provider.featuredImage != null &&
                  image.path == provider.featuredImage!.path;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => provider.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (isFeatured)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'F',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection(String title, String subtitle, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _buildLabelStyle()),
        const SizedBox(height: 4),
        Text(subtitle, style: _buildSubtitleStyle()),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _buildLabelStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle, style: _buildSubtitleStyle()),
        ],
      ),
    );
  }

  TextStyle _buildLabelStyle({double fontSize = 16}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
    );
  }

  TextStyle _buildSubtitleStyle() {
    return TextStyle(fontSize: 14, color: Colors.grey[600]);
  }
}
