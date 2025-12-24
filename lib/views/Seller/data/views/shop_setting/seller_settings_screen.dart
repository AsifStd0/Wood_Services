import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/shop_widgets.dart';
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
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logging out...'),
                  duration: Duration(seconds: 2),
                ),
              );

              final success = await viewModel.logout();

              if (success && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => OnboardingScreen()),
                  (route) => false,
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${viewModel.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Header
              buildShopHeader(viewModel),

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
            'Full Name',
            viewModel.fullName,
            Icons.person_rounded,
            viewModel.isEditing,
            (value) => viewModel.setFullName(value),
          ),
          const SizedBox(height: 16),
          buildInfoField(
            'Email Address',
            viewModel.email,
            Icons.email_rounded,
            viewModel.isEditing,
            (value) => viewModel.setEmail(value),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          buildInfoField(
            'Phone Number',
            viewModel.phone,
            Icons.phone_rounded,
            viewModel.isEditing,
            (value) => viewModel.setPhone(value),
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
            'Business Name',
            viewModel.businessName,
            Icons.business_rounded,
            viewModel.isEditing,
            (value) => viewModel.setBusinessName(value),
          ),
          const SizedBox(height: 16),
          buildInfoField(
            'Shop Name',
            viewModel.shopName,
            Icons.store_rounded,
            viewModel.isEditing,
            (value) => viewModel.setShopName(value),
          ),
          const SizedBox(height: 16),
          buildInfoTextArea(
            'Business Description',
            viewModel.description,
            Icons.description_rounded,
            viewModel.isEditing,
            (value) => viewModel.setDescription(value),
          ),
          const SizedBox(height: 16),
          buildInfoField(
            'Business Address',
            viewModel.address,
            Icons.location_on_rounded,
            viewModel.isEditing,
            (value) => viewModel.setAddress(value),
          ),
        ],
      ),
    );
  }
}
