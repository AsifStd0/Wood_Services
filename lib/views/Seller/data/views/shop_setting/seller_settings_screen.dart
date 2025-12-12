import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/shop_widgets.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class SellerSettingsScreen extends StatefulWidget {
  const SellerSettingsScreen({super.key});

  @override
  State<SellerSettingsScreen> createState() => _SellerSettingsScreenState();
}

class _SellerSettingsScreenState extends State<SellerSettingsScreen> {
  final ProfileViewModel _viewModel = locator<ProfileViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadSellerDataFromSignup();
    });
  }

  void _showLogoutDialog(ProfileViewModel viewModel, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await viewModel.logout();

                // Use go_router's go() or push() method
                // context.go('/seller_login');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return SellerLogin();
                    },
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Shop Settings',
          showBackButton: false,
          backgroundColor: Colors.white,
          actions: [
            // Edit/Close button
            Consumer<ProfileViewModel>(
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
            // Logout button in AppBar
            Consumer<ProfileViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: Icon(Icons.logout_rounded, color: Colors.red),
                  onPressed: () => _showLogoutDialog(viewModel, context),
                );
              },
            ),
          ],
        ),
        body: const _ShopSettingsContent(),
      ),
    );
  }
}

class _ShopSettingsContent extends StatelessWidget {
  const _ShopSettingsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && !viewModel.hasData) {
          return _buildLoadingState();
        }

        if (!viewModel.hasData) {
          return CircularProgressIndicator();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Header
              buildShopHeader(viewModel),

              const SizedBox(height: 24),

              // Shop Banner
              buildShopBanner(viewModel),

              const SizedBox(height: 24),

              // Personal Information
              _buildPersonalInfoSection(viewModel),

              const SizedBox(height: 24),

              // Business Information
              _buildBusinessInfoSection(viewModel),

              const SizedBox(height: 24),

              // Shop Branding
              buildShopBrandingSection(viewModel),

              const SizedBox(height: 24),

              // Categories
              buildCategoriesSection(viewModel, context),

              const SizedBox(height: 24),

              // Bank Details
              buildBankDetailsSection(viewModel),

              const SizedBox(height: 32),

              // Action Buttons
              buildActionButtons(viewModel, context),

              const SizedBox(height: 40),
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

  Widget _buildPersonalInfoSection(ProfileViewModel viewModel) {
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

  Widget _buildBusinessInfoSection(ProfileViewModel viewModel) {
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
