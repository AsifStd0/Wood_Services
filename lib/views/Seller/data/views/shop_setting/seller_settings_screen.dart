// views/shop_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/widgets/advance_appbar.dart';

class SellerSettingsScreen extends StatelessWidget {
  const SellerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Shop Settings', showBackButton: false),

      body: const _ShopSettingsContent(),
    );
  }
}

class _ShopSettingsContent extends StatelessWidget {
  const _ShopSettingsContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Header
          _buildShopHeader(),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),

          // Shop Banner
          _buildShopBanner(),

          const SizedBox(height: 24),

          // Shop Description
          _buildShopDescription(),

          const SizedBox(height: 24),

          // Categories & Details
          _buildShopDetails(),

          const SizedBox(height: 32),

          // Save Changes Button
          _buildSaveButton(),

          const SizedBox(height: 24),

          // Upload Documents
          _buildUploadDocuments(),

          const SizedBox(height: 24),

          // Preview Shop
          _buildPreviewShop(),
        ],
      ),
    );
  }

  Widget _buildShopHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Asif Khan",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Handmade goods",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              "✰ ${4} (${10} reviews)",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShopBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Shop Banner",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Showcase your shop's personality.",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              //  viewModel.shop.bannerImage == null
              // ?
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload, size: 32, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text("Upload", style: TextStyle(color: Colors.grey)),
                ],
              ),
          // : Image.asset(viewModel.shop.bannerImage!, fit: BoxFit.cover),
        ),
      ],
    );
  }

  Widget _buildShopDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Shop Description",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Description is here about ..... shop",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildShopDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories Sold",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildDetailItem("Handmade Jewelry", Icons.shopping_bag),
        _buildDetailItem("Delivery Lead Time", Icons.schedule),
        _buildDetailItem('7 days', Icons.access_time),
        _buildDetailItem("Return Policy", Icons.assignment_return),
        _buildDetailItem('30 days', Icons.policy),
        _buildDetailItem("Verification Status", Icons.verified),
        _buildDetailItem("Verified", Icons.verified),
      ],
    );
  }

  Widget _buildDetailItem(
    String text,
    IconData icon, {
    bool isVerified = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isVerified ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isVerified ? Colors.green : Colors.black87,
              fontWeight: isVerified ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},

        // viewModel.isLoading ? null : viewModel.saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brightOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildUploadDocuments() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Handle upload documents
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: const Text(
          "Upload Documents",
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildPreviewShop() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Handle preview shop
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: const Text(
          "Preview Shop",
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
