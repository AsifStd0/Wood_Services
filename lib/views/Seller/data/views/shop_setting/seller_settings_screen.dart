import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/shop_widgets.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_products_screen.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerSettingsScreen extends StatefulWidget {
  const SellerSettingsScreen({super.key});

  @override
  State<SellerSettingsScreen> createState() => _SellerSettingsScreenState();
}

class _SellerSettingsScreenState extends State<SellerSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access provider from context
      final viewModel = context.read<SelllerSettingProvider>();
      viewModel.loadSellerData();
    });
  }

  void _showLogoutDialog(BuildContext context) {
    final viewModel = context.read<SelllerSettingProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Use outer context for navigation
              _performLogout(context, viewModel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(
    BuildContext context,
    SelllerSettingProvider provider,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      log('🔄 Starting logout process...');

      // Perform logout
      final success = await provider.logout();

      log('🔄 Logout result: $success');

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        log('✅ Logout successful, navigating to OnboardingScreen...');

        // Navigate to onboarding screen
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            (route) => false,
          );
        }
      } else {
        log('❌ Logout failed: ${provider.errorMessage}');

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Logout failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      log('❌ Error during logout: $e', error: e, stackTrace: stackTrace);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Shop Settings',
        showBackButton: false,
        backgroundColor: Colors.white,
        actions: [
          // Edit/Close button
          Consumer<SelllerSettingProvider>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: Icon(
                  viewModel.isEditing
                      ? Icons.close_rounded
                      : Icons.edit_rounded,
                  color: Colors.grey[700],
                ),
                onPressed: () {
                  viewModel.setEditing(!viewModel.isEditing);
                },
              );
            },
          ),
          // Logout button
          Consumer<SelllerSettingProvider>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: Icon(Icons.logout_rounded, color: Colors.red),
                onPressed: () => _showLogoutDialog(context),
              );
            },
          ),
        ],
      ),
      body: const _ShopSettingsContent(),
    );
  }
}

class _ShopSettingsContent extends StatelessWidget {
  const _ShopSettingsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<SelllerSettingProvider>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && !viewModel.hasData) {
          return _buildLoadingState();
        }

        if (!viewModel.hasData) {
          return CircularProgressIndicator();
        }
        log(
          '🔄 Building Shop Settings Content...${viewModel.currentUser?.toJson()}',
        );
        log(
          '🔄 Building Shop Settings Content...${viewModel.currentUser?.toJson()}',
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Header
              buildShopHeader(viewModel),

              const SizedBox(height: 14),

              // Uploaded Products Button
              _buildUploadedProductsButton(context),
              const SizedBox(height: 14),

              // Shop Banner
              buildShopBanner(viewModel),

              const SizedBox(height: 14),

              // Personal Information
              _buildPersonalInfoSection(viewModel),

              const SizedBox(height: 14),

              // Business Information
              _buildBusinessInfoSection(viewModel),

              const SizedBox(height: 14),

              // Shop Branding
              buildShopBrandingSection(viewModel),

              const SizedBox(height: 14),

              // Categories
              buildCategoriesSection(viewModel, context),

              const SizedBox(height: 14),

              // Bank Details
              buildBankDetailsSection(viewModel),

              const SizedBox(height: 14),

              // Action Buttons
              saveChangesButton(viewModel, context),
            ],
          ),
        );
      },
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
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Your Shop Data',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(SelllerSettingProvider viewModel) {
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
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Full Name',
            controller: viewModel.nameController,
            icon: Icons.person_rounded,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.setFullName(value),
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Email Address',
            controller: viewModel.emailController,
            icon: Icons.email_rounded,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.setEmail(value),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Phone Number',
            controller: viewModel.phoneController,
            icon: Icons.phone_rounded,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.setPhone(value),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoSection(SelllerSettingProvider viewModel) {
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
            'Business Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          buildInfoField(
            label: 'Business Name',
            controller: viewModel.businessNameController,
            icon: Icons.business_rounded,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.setBusinessName(value),
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Shop Name',
            controller: viewModel.shopNameController,
            icon: Icons.store_rounded,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.setShopName(value),
          ),
          const SizedBox(height: 16),
          buildInfoTextArea(
            label: 'Business Description',
            controller: viewModel.descriptionController,
            icon: Icons.description_rounded,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.setDescription(value),
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Business Address',
            controller: viewModel.addressController,
            icon: Icons.location_on_rounded,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.setAddress(value),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedProductsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadedProductsScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.brown,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Uploaded Products',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View and manage all your products',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
