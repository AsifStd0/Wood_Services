import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/setting_data/seller_settings_repository.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_products_screen.dart';
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
    // Use Consumer to get the provider
    showDialog(
      context: context,
      builder: (context) => Consumer<SellerSettingsProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
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
                            const SnackBar(
                              content: Text('Logout failed'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Logout'),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Shop Settings',
        showBackButton: false,
        backgroundColor: Colors.white,
        actions: [
          Consumer<SellerSettingsProvider>(
            builder: (context, provider, _) => IconButton(
              icon: Icon(
                provider.isEditing ? Icons.close_rounded : Icons.edit_rounded,
                color: Colors.grey[700],
              ),
              onPressed: () => provider.setEditing(!provider.isEditing),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<SellerSettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasData) {
            return _buildLoadingState();
          }

          if (!provider.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Header
                buildShopHeader(provider),
                const SizedBox(height: 14),

                // Uploaded Products Button
                _buildUploadedProductsButton(context),
                const SizedBox(height: 14),

                // Shop Banner
                buildShopBanner(provider),
                const SizedBox(height: 14),

                // Personal Information
                _buildPersonalInfoSection(provider),
                const SizedBox(height: 14),

                // Business Information
                _buildBusinessInfoSection(provider),
                const SizedBox(height: 14),

                // Shop Branding
                buildShopBrandingSection(provider),
                const SizedBox(height: 14),

                // Bank Details
                buildBankDetailsSection(provider),
                const SizedBox(height: 14),

                // Action Buttons
                saveChangesButton(provider, context),
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
            decoration: const BoxDecoration(
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

  Widget _buildPersonalInfoSection(SellerSettingsProvider provider) {
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
            controller: provider.nameController,
            icon: Icons.person_rounded,
            isEditing: provider.isEditing,
            // onChanged: (value) => provider.nameController.text = value,
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Email Address',
            controller: provider.emailController,
            icon: Icons.email_rounded,
            isEditing: provider.isEditing,
            // onChanged: (value) => provider.emailController.text = value,
            // keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Phone Number',
            controller: provider.phoneController,
            icon: Icons.phone_rounded,
            isEditing: provider.isEditing,
            // onChanged: (value) => provider.phoneController.text = value,
            // keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoSection(SellerSettingsProvider provider) {
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
            controller: provider.businessNameController,
            icon: Icons.business_rounded,
            isEditing: provider.isEditing,
            // onChanged: (value) => provider.businessNameController.text = value,
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Shop Name',
            controller: provider.shopNameController,
            icon: Icons.store_rounded,
            isEditing: provider.isEditing,
            // onChanged: (value) => provider.shopNameController.text = value,
          ),
          const SizedBox(height: 16),
          buildInfoTextArea(
            label: 'Business Description',
            controller: provider.descriptionController,
            icon: Icons.description_rounded,
            isEditing: provider.isEditing,
            // onChanged: (value) => provider.descriptionController.text = value,
          ),
          const SizedBox(height: 16),
          buildInfoField(
            label: 'Business Address',
            controller: provider.addressController,
            icon: Icons.location_on_rounded,
            isEditing: provider.isEditing,
            // onChanged: (value) => provider.addressController.text = value,
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
            // Navigate to uploaded products
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return UploadedProductsScreen();
                },
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
