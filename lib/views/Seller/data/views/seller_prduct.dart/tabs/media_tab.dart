import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';

class MediaTab extends StatelessWidget {
  const MediaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddProductViewModel>();
    final product = viewModel.product;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Media Gallery',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload product images, videos, and documents',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Featured Image
          _buildSectionHeader(
            'Featured Image',
            'Main product image displayed in listings',
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                // style: BorderStyle.dashed,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 40,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
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
                  'Recommended: 800x800px',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Image Gallery
          _buildSectionHeader(
            'Image Gallery',
            'Additional product images (up to 10 images)',
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 7, // 6 empty slots + 1 add button
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddImageButton();
              }
              return _buildEmptyImageSlot();
            },
          ),
          const SizedBox(height: 24),

          // // Video
          // _buildSectionHeader(
          //   'Product Video',
          //   'Add a video showcasing your product (Optional)',
          // ),
          // const SizedBox(height: 12),
          // Container(
          //   height: 120,
          //   decoration: BoxDecoration(
          //     color: Colors.grey[50],
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: Colors.grey.withOpacity(0.3),
          //       // style: BorderStyle.dashed,
          //     ),
          //   ),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Icon(
          //         Icons.video_library_rounded,
          //         size: 32,
          //         color: Colors.grey[400],
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         'Add Product Video',
          //         style: TextStyle(
          //           fontSize: 14,
          //           fontWeight: FontWeight.w600,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //       const SizedBox(height: 4),
          //       Text(
          //         'MP4, MOV up to 50MB',
          //         style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 24),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          // style: BorderStyle.dashed,
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
        ],
      ),
    );
  }

  Widget _buildEmptyImageSlot() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
