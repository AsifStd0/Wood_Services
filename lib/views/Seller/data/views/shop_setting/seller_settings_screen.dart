import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/core/constants/app_strings.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/setting_data/seller_settings_repository.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/status/seller_stats_screen.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Seller_Ads_Own_Products/seller_own_ads_screen.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_products_screen.dart';
import 'package:wood_service/views/splash/splash_screen.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/shop_widgets.dart';

class SellerSettingsScreen extends StatelessWidget {
  const SellerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SellerSettingsProvider(locator<SellerSettingsRepository>()),
      child: const _SellerSettingsScreenContent(),
    );
  }
}

class _SellerSettingsScreenContent extends StatelessWidget {
  const _SellerSettingsScreenContent();

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<SellerSettingsProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                const Text('Confirm Logout'),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout? You will need to login again to access your account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.cancel,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        Navigator.pop(context);
                        final success = await provider.logout();
                        if (success && context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OnboardingScreen(),
                            ),
                            (route) => false,
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Logout failed'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(AppStrings.logout),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.settings,
        showBackButton: false,
        backgroundColor: AppColors.white,
        actions: [
          Consumer<SellerSettingsProvider>(
            builder: (context, provider, _) => IconButton(
              icon: Icon(
                provider.isEditing ? Icons.close_rounded : Icons.edit_rounded,
                color: AppColors.textPrimary,
              ),
              tooltip: provider.isEditing ? 'Cancel Editing' : 'Edit Profile',
              onPressed: () {
                if (provider.isEditing) {
                  // Reset to original values
                  provider.setEditing(false);
                } else {
                  provider.setEditing(true);
                }
              },
            ),
          ),
        ],
      ),
      body: Consumer<SellerSettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasData) {
            return _buildLoadingState();
          }

          if (!provider.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.loading,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Header Card
                _buildShopHeaderCard(provider),
                const SizedBox(height: 20),

                // Quick Actions Section
                _buildQuickActionsSection(context, provider),
                const SizedBox(height: 20),

                // My Ads Section
                _buildMyAdsSection(context),
                const SizedBox(height: 20),

                // Shop Information Container
                _buildMainInfoContainer(context, provider),
                const SizedBox(height: 20),

                // Shop Branding Section
                _buildSectionCard(
                  title: 'Shop Branding',
                  icon: Icons.palette_rounded,
                  child: _buildShopBrandingSection(provider),
                ),
                const SizedBox(height: 20),

                // Bank Details Section
                _buildSectionCard(
                  title: 'Bank Details',
                  icon: Icons.account_balance_rounded,
                  child: _buildBankDetailsSection(provider),
                ),
                const SizedBox(height: 20),

                // Documents Section
                _buildSectionCard(
                  title: 'Business Documents',
                  icon: Icons.description_rounded,
                  child: _buildDocumentsSection(context, provider),
                ),
                const SizedBox(height: 20),

                // Save Button
                if (provider.isEditing) ...[
                  _buildSaveButton(context, provider),
                  const SizedBox(height: 20),
                ],

                // Logout Section at Bottom
                _buildLogoutSection(context, provider),

                // Bottom spacing
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Your Shop Data',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    SellerSettingsProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context: context,
            title: 'Statistics',
            subtitle: 'View analytics',
            icon: Icons.analytics_rounded,
            color: AppColors.info,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerStatsScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context: context,
            title: 'Products',
            subtitle: 'Manage items',
            icon: Icons.inventory_2_rounded,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadedProductsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeaderCard(SellerSettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Shop Logo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient:
                  (provider.shopLogo == null && provider.shopLogoUrl == null)
                  ? AppColors.primaryGradient
                  : null,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: provider.shopLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.file(provider.shopLogo!, fit: BoxFit.cover),
                  )
                : provider.shopLogoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.network(
                      provider.shopLogoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.store_rounded,
                          color: AppColors.white,
                          size: 35,
                        );
                      },
                    ),
                  )
                : Icon(Icons.store_rounded, color: AppColors.white, size: 35),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentUser?.shopName?.isNotEmpty == true
                      ? provider.currentUser!.shopName!
                      : 'Your Shop Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.currentUser?.businessName?.isNotEmpty == true
                      ? provider.currentUser!.businessName!
                      : 'Business Name',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        provider.currentUser?.email ?? 'email@example.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: provider.currentUser?.isVerified == true
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: provider.currentUser?.isVerified == true
                              ? AppColors.success
                              : AppColors.warning,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            provider.currentUser?.isVerified == true
                                ? Icons.verified_rounded
                                : Icons.pending_rounded,
                            size: 14,
                            color: provider.currentUser?.isVerified == true
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.currentUser?.isActive == true
                                ? 'Active'
                                : 'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              color: provider.currentUser?.isVerified == true
                                  ? AppColors.success
                                  : AppColors.warning,
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

  Widget _buildShopBannerSection(SellerSettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.image_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Shop Banner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (provider.isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Edit Mode',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: provider.isEditing ? () => provider.pickShopBanner() : null,
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color:
                    (provider.shopBanner == null &&
                        provider.shopBannerUrl == null)
                    ? AppColors.extraLightGrey
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: provider.shopBanner != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        provider.shopBanner!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : provider.shopBannerUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        provider.shopBannerUrl!,
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
          size: 40,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 8),
        Text(
          'Upload Banner Image',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(
    BuildContext context,
    SellerSettingsProvider provider,
  ) {
    return Column(
      children: [
        buildInfoField(
          label: AppStrings.name,
          controller: provider.nameController,
          icon: Icons.person_rounded,
          isEditing: provider.isEditing,
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: AppStrings.email,
          controller: provider.emailController,
          icon: Icons.email_rounded,
          isEditing: provider.isEditing,
        ),
        const SizedBox(height: 16),
        buildPhoneFieldWithCountryCode(
          context: context,
          label: AppStrings.phone,
          controller: provider.phoneController,
          isEditing: provider.isEditing,
          countryCode: provider.countryCode,
          onCountryCodeChanged: (code) => provider.countryCode = code,
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection(SellerSettingsProvider provider) {
    return Column(
      children: [
        buildInfoField(
          label: 'Business Name',
          controller: provider.businessNameController,
          icon: Icons.business_rounded,
          isEditing: provider.isEditing,
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'Shop Name',
          controller: provider.shopNameController,
          icon: Icons.store_rounded,
          isEditing: provider.isEditing,
        ),
        const SizedBox(height: 16),
        buildInfoTextArea(
          label: 'Business Description',
          controller: provider.descriptionController,
          icon: Icons.description_rounded,
          isEditing: provider.isEditing,
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'Business Address',
          controller: provider.addressController,
          icon: Icons.location_on_rounded,
          isEditing: provider.isEditing,
        ),
      ],
    );
  }

  Widget _buildShopBrandingSection(SellerSettingsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildImageUploader(
            label: 'Shop Logo',
            image: provider.shopLogo,
            imageUrl: provider.shopLogoUrl,
            onTap: provider.isEditing ? () => provider.pickShopLogo() : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildImageUploader(
            label: 'Shop Banner',
            image: provider.shopBanner,
            imageUrl: provider.shopBannerUrl,
            onTap: provider.isEditing ? () => provider.pickShopBanner() : null,
          ),
        ),
      ],
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.extraLightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
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
          color: AppColors.textSecondary,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          label.contains('Logo') ? 'Upload Logo' : 'Upload Banner',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBankDetailsSection(SellerSettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.security_rounded, size: 16, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your information is encrypted and secure',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'IBAN',
          controller: provider.ibanController,
          icon: Icons.receipt_rounded,
          isEditing: provider.isEditing,
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(
    BuildContext context,
    SellerSettingsProvider provider,
  ) {
    final user = provider.currentUser;
    return Column(
      children: [
        _buildDocumentItem(
          context: context,
          title: 'Business License',
          url: user?.businessLicense,
          icon: Icons.business_center_rounded,
        ),
        const SizedBox(height: 12),
        _buildDocumentItem(
          context: context,
          title: 'Tax Certificate',
          url: user?.taxCertificate,
          icon: Icons.receipt_long_rounded,
        ),
        const SizedBox(height: 12),
        _buildDocumentItem(
          context: context,
          title: 'Identity Proof',
          url: user?.identityProof,
          icon: Icons.badge_rounded,
        ),
      ],
    );
  }

  void _showDocumentViewer(BuildContext context, String title, String url) {
    final isImage =
        url.toLowerCase().contains('.jpg') ||
        url.toLowerCase().contains('.jpeg') ||
        url.toLowerCase().contains('.png') ||
        url.toLowerCase().contains('.gif') ||
        url.toLowerCase().contains('.webp');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.7,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isImage
                      ? InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4,
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                ? child
                                : const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                            errorBuilder: (_, __, ___) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.description_rounded,
                                color: Colors.white70,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Document available at link',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                url,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem({
    required BuildContext context,
    required String title,
    required String? url,
    required IconData icon,
  }) {
    final hasDocument = url != null && url.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasDocument
            ? () => _showDocumentViewer(context, title, url)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasDocument
                ? AppColors.success.withOpacity(0.05)
                : AppColors.extraLightGrey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasDocument
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasDocument
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: hasDocument
                      ? AppColors.success
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDocument ? 'Tap to view' : 'No document',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasDocument)
                Icon(
                  Icons.visibility_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyAdsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Ads',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Create and manage your advertising campaigns to reach more customers',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellerOwnAdsScreen(),
                    // SellerAdsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.campaign_rounded, size: 20),
              label: const Text('Manage Ads'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoContainer(
    BuildContext context,
    SellerSettingsProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Shop Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Shop Banner Section
          if (provider.isEditing || provider.shopBannerUrl != null)
            _buildShopBannerSection(provider),
          if (provider.isEditing || provider.shopBannerUrl != null)
            const SizedBox(height: 20),
          // Personal Information Section
          _buildPersonalInfoSection(context, provider),
          const SizedBox(height: 20),
          // Business Information Section
          _buildBusinessInfoSection(provider),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(
    BuildContext context,
    SellerSettingsProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.extraLightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              subtitle: Text(
                'Logout from your account',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    SellerSettingsProvider provider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading
            ? null
            : () async {
                final success = await provider.saveChanges();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile updated successfully!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (context.mounted && provider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage!),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
