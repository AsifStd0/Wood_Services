import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

// Common widgets used in the seller settings screen

Widget buildShopHeader(SellerSettingsProvider provider) {
  return Container(
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
    child: Row(
      children: [
        // Shop Logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: (provider.shopLogo == null && provider.shopLogoUrl == null)
                ? const Color(0xFF667EEA)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: provider.shopLogo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.file(provider.shopLogo!, fit: BoxFit.cover),
                )
              : provider.shopLogoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    provider.shopLogoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.store_rounded,
                        color: Colors.white,
                        size: 30,
                      );
                    },
                  ),
                )
              : const Icon(Icons.store_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.currentUser?.shopName?.isNotEmpty == true
                    ? provider.currentUser!.shopName!
                    : 'Your Shop Name',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                provider.currentUser?.businessName?.isNotEmpty == true
                    ? provider.currentUser!.businessName!
                    : 'Business Name',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      provider.currentUser?.email ?? 'email@example.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: provider.currentUser?.isVerified == true
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          provider.currentUser?.isVerified == true
                              ? Icons.verified_rounded
                              : Icons.pending_rounded,
                          size: 12,
                          color: provider.currentUser?.isVerified == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.currentUser?.isVerified == true
                              ? 'Verified'
                              : 'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            color: provider.currentUser?.isVerified == true
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

Widget buildInfoField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required bool isEditing,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      CustomTextFormField(
        enabled: isEditing,
        prefixIcon: Icon(icon, color: AppColors.grey),
        controller: controller,
      ),
    ],
  );
}

Widget buildInfoTextArea({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required bool isEditing,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      CustomTextFormField(
        enabled: isEditing,
        prefixIcon: Icon(icon, color: AppColors.grey),
        controller: controller,
        maxLines: 4,
      ),
    ],
  );
}

Widget saveChangesButton(
  SellerSettingsProvider provider,
  BuildContext context,
) {
  return Column(
    children: [
      if (provider.isEditing) ...[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () async {
                    final success = await provider.saveChanges();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                        ),
                      );
                    } else if (provider.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.errorMessage!)),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brightOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: provider.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    ],
  );
}

Widget buildShopBrandingSection(SellerSettingsProvider provider) {
  return Container(
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
          'Shop Branding',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildImageUploader(
                label: 'Shop Logo',
                image: provider.shopLogo,
                imageUrl: provider.shopLogoUrl,
                onTap: provider.isEditing
                    ? () => provider.pickShopLogo()
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageUploader(
                label: 'Shop Banner',
                image: provider.shopBanner,
                imageUrl: provider.shopBannerUrl,
                onTap: provider.isEditing
                    ? () => provider.pickShopBanner()
                    : null,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildImageUploader({
  required String label,
  required File? image,
  required String? imageUrl,
  required VoidCallback? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(image, fit: BoxFit.cover),
                )
              : imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(label);
                    },
                  ),
                )
              : _buildPlaceholder(label),
        ),
      ),
    ],
  );
}

Widget _buildPlaceholder(String label) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        label.contains('Logo')
            ? Icons.add_photo_alternate
            : Icons.add_to_photos,
        color: Colors.grey[400],
        size: 32,
      ),
      const SizedBox(height: 8),
      Text(
        label.contains('Logo') ? 'Upload Logo' : 'Upload Banner',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ],
  );
}

Widget buildBankDetailsSection(SellerSettingsProvider provider) {
  return Container(
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
          'Bank Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.security_rounded,
              size: 16,
              color: AppColors.darkGrey,
            ),
            const SizedBox(width: 8),
            Text(
              'Your information is encrypted and secure',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'IBAN',
          controller: provider.ibanController,
          icon: Icons.receipt_rounded,
          isEditing: provider.isEditing,
        ),
      ],
    ),
  );
}

Widget buildShopBanner(SellerSettingsProvider viewModel) {
  return Container(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Shop Banner',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            if (viewModel.isEditing)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brightOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Edit Mode',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.brightOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: viewModel.isEditing ? () => viewModel.pickShopBanner() : null,
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color:
                  (viewModel.shopBanner == null &&
                      viewModel.shopBannerUrl == null)
                  ? Colors.grey[50]
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: viewModel.shopBanner != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(viewModel.shopBanner!, fit: BoxFit.cover),
                  )
                : viewModel.shopBannerUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      viewModel.shopBannerUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderBanner();
                      },
                    ),
                  )
                : _buildPlaceholderBanner(),
          ),
        ),
      ],
    ),
  );
}

Widget _buildPlaceholderBanner() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.add_photo_alternate_rounded,
        size: 32,
        color: Colors.grey[400],
      ),
      const SizedBox(height: 8),
      Text(
        'Upload Banner Image',
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
    ],
  );
}
