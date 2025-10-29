// views/shop_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/shop_model.dart';
import 'package:wood_service/widgets/advance_appbar.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

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
      context.read<ShopSettingsViewModel>().loadShopData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShopSettingsViewModel(),
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Shop Settings',
          showBackButton: false,
          backgroundColor: Colors.white,
          actions: [
            Consumer<ShopSettingsViewModel>(
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
    return Consumer<ShopSettingsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.shop.sellerId.isEmpty) {
          return _buildLoadingState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Header with Stats
              _buildShopHeader(viewModel),

              const SizedBox(height: 24),

              // Shop Banner
              _buildShopBanner(viewModel),

              const SizedBox(height: 24),

              // Shop Information
              _buildShopInformation(viewModel, context),

              const SizedBox(height: 24),

              // Business Details
              _buildBusinessDetails(viewModel),

              const SizedBox(height: 24),

              // Shop Policies
              _buildShopPolicies(viewModel, context),

              const SizedBox(height: 24),

              // Documents Section
              _buildDocumentsSection(viewModel),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(viewModel, context),

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
            'Loading Shop Settings',
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

  Widget _buildShopHeader(ShopSettingsViewModel viewModel) {
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
          // Shop Logo/Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFF667EEA),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.store_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.shop.shopName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.shop.description.split('.').first,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${viewModel.shop.rating} (${viewModel.shop.reviewCount} reviews)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: viewModel.shop.isVerified
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            viewModel.shop.isVerified
                                ? Icons.verified_rounded
                                : Icons.pending_rounded,
                            size: 12,
                            color: viewModel.shop.isVerified
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            viewModel.shop.isVerified ? 'Verified' : 'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              color: viewModel.shop.isVerified
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

  Widget _buildShopBanner(ShopSettingsViewModel viewModel) {
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
                    color: Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Edit Mode',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF667EEA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Showcase your shop\'s personality with a beautiful banner',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: viewModel.isEditing
                ? () => _handleBannerUpload(viewModel)
                : null,
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: viewModel.shop.bannerImage == null
                    ? Colors.grey[50]
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  style: viewModel.shop.bannerImage == null
                      ? BorderStyle.solid
                      : BorderStyle.solid,
                ),
                image: viewModel.shop.bannerImage != null
                    ? DecorationImage(
                        image: NetworkImage(viewModel.shop.bannerImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: viewModel.shop.bannerImage == null
                  ? Column(
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recommended: 1200x400px',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInformation(ShopSettingsViewModel viewModel, context) {
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
            'Shop Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            'Shop Name',
            viewModel.shop.shopName,
            Icons.store_rounded,
            viewModel.isEditing,
            (value) => viewModel.setShopName(value),
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            'Owner Name',
            viewModel.shop.ownerName,
            Icons.person_rounded,
            viewModel.isEditing,
            (value) => viewModel.setOwnerName(value),
          ),
          const SizedBox(height: 16),
          _buildEditableTextArea(
            'Shop Description',
            viewModel.shop.description,
            Icons.description_rounded,
            viewModel.isEditing,
            (value) => viewModel.setDescription(value),
          ),
          const SizedBox(height: 16),
          _buildCategoriesSection(viewModel, context),
        ],
      ),
    );
  }

  Widget _buildBusinessDetails(ShopSettingsViewModel viewModel) {
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
            'Business Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            'Phone Number',
            viewModel.shop.phoneNumber,
            Icons.phone_rounded,
            viewModel.isEditing,
            (value) => viewModel.setPhoneNumber(value),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            'Email Address',
            viewModel.shop.email,
            Icons.email_rounded,
            viewModel.isEditing,
            (value) => viewModel.setEmail(value),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildEditableTextArea(
            'Business Address',
            viewModel.shop.address,
            Icons.location_on_rounded,
            viewModel.isEditing,
            (value) => viewModel.setAddress(value),
          ),
        ],
      ),
    );
  }

  Widget _buildShopPolicies(
    ShopSettingsViewModel viewModel,
    BuildContext context,
  ) {
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
            'Shop Policies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildPolicyItem(
            'Delivery Lead Time',
            '${viewModel.shop.deliveryLeadTime} days',
            Icons.schedule_rounded,
            viewModel.isEditing,
            () => _showDeliveryTimeDialog(viewModel, context),
          ),
          const SizedBox(height: 16),
          _buildPolicyItem(
            'Return Policy',
            viewModel.shop.returnPolicy,
            Icons.assignment_return_rounded,
            viewModel.isEditing,
            () => _showReturnPolicyDialog(viewModel, context),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(ShopSettingsViewModel viewModel) {
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
                'Business Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              if (viewModel.shop.documents.isNotEmpty)
                Text(
                  '${viewModel.shop.documents.length} uploaded',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload required documents for verification',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          if (viewModel.shop.documents.isEmpty)
            _buildEmptyDocumentsState()
          else
            Column(
              children: viewModel.shop.documents
                  .map((doc) => _buildDocumentItem(doc, viewModel))
                  .toList(),
            ),

          const SizedBox(height: 16),
          _buildUploadDocumentsButton(viewModel),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ShopSettingsViewModel viewModel, context) {
    return Column(
      children: [
        if (viewModel.isEditing) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _saveChanges(viewModel, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: Color(0xFF667EEA).withOpacity(0.3),
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _previewShop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Text(
              'Preview Shop',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for building UI components
  Widget _buildEditableField(
    String label,
    String value,
    IconData icon,
    bool isEditing,
    Function(String) onChanged, {
    TextInputType keyboardType = TextInputType.text,
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
          onChanged: onChanged,
          controller: TextEditingController(text: value),
        ),
      ],
    );
  }

  Widget _buildEditableTextArea(
    String label,
    String value,
    IconData icon,
    bool isEditing,
    Function(String) onChanged,
  ) {
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
          maxLines: 3,
          minline: 3,

          onChanged: onChanged,
          controller: TextEditingController(text: value),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(ShopSettingsViewModel viewModel, context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.shop.categories.map((category) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: Color(0xFF667EEA),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (viewModel.isEditing) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        final newCategories = List<String>.from(
                          viewModel.shop.categories,
                        )..remove(category);
                        viewModel.setCategories(newCategories);
                      },
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
        if (viewModel.isEditing) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showAddCategoryDialog(viewModel, context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  // style: BorderStyle.dashed,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Add Category',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPolicyItem(
    String title,
    String value,
    IconData icon,
    bool isEditing,
    VoidCallback onEdit,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF667EEA), size: 20),
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
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (isEditing)
            IconButton(
              icon: Icon(Icons.edit_rounded, size: 18, color: Colors.grey[500]),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyDocumentsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          // style: BorderStyle.dashed,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Documents Uploaded',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your business documents for verification',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(ShopDocument doc, ShopSettingsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getDocumentIcon(doc.type),
            color: doc.isVerified ? Colors.green : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Uploaded ${_formatDate(doc.uploadDate)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: doc.isVerified
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        doc.isVerified ? 'Verified' : 'Pending',
                        style: TextStyle(
                          fontSize: 10,
                          color: doc.isVerified ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (viewModel.isEditing)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Colors.grey[500],
              ),
              onPressed: () => viewModel.removeDocument(doc.id),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadDocumentsButton(ShopSettingsViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: viewModel.isEditing
            ? () => _handleDocumentUpload(viewModel)
            : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        icon: Icon(Icons.upload_rounded, size: 18, color: Colors.grey[600]),
        label: Text(
          'Upload Documents',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Helper methods for icons and formatting
  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'license':
        return Icons.business_center_rounded;
      case 'tax_certificate':
        return Icons.receipt_long_rounded;
      case 'identity':
        return Icons.badge_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'today';
    if (difference.inDays == 1) return 'yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }

  // Dialog methods
  void _showDeliveryTimeDialog(
    ShopSettingsViewModel viewModel,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delivery Lead Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set the estimated delivery time for orders'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: viewModel.shop.deliveryLeadTime,
              items: [1, 2, 3, 5, 7, 10, 14, 21, 30].map((days) {
                return DropdownMenuItem(value: days, child: Text('$days days'));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.setDeliveryLeadTime(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnPolicyDialog(ShopSettingsViewModel viewModel, context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Return Policy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set your shop\'s return policy'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              isDense: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white, // 👈 makes sure it's white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              focusColor: AppColors.white,

              value: viewModel.shop.returnPolicy,
              items: ['No returns', '7 days', '14 days', '30 days', '60 days']
                  .map((policy) {
                    return DropdownMenuItem(value: policy, child: Text(policy));
                  })
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.setReturnPolicy(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(ShopSettingsViewModel viewModel, context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newCategories = List<String>.from(
                  viewModel.shop.categories,
                )..add(controller.text);
                viewModel.setCategories(newCategories);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _handleBannerUpload(ShopSettingsViewModel viewModel) {
    // Implement image picker logic here
    // For now, we'll simulate an upload
    viewModel.setBannerImage('https://example.com/banner.jpg');
  }

  void _handleDocumentUpload(ShopSettingsViewModel viewModel) {
    // Implement document picker logic here
    // For now, we'll simulate an upload
    final newDoc = ShopDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New Document',
      url: '',
      type: 'license',
      uploadDate: DateTime.now(),
    );
    viewModel.addDocument(newDoc);
  }

  void _saveChanges(
    ShopSettingsViewModel viewModel,
    BuildContext context,
  ) async {
    final success = await viewModel.saveChanges();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shop settings updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _previewShop(BuildContext context) {
    // Navigate to shop preview screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening shop preview...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
