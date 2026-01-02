import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/selller_setting_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

Widget buildImageUploader({
  required String label,
  required File? image,
  required VoidCallback? onTap,
  required Size size,
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
          width: size.width,
          height: size.height,
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
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      label.contains('Logo')
                          ? Icons.add_photo_alternate
                          : Icons.add_to_photos,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label.contains('Logo') ? 'Upload Logo' : 'Upload Banner',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
        ),
      ),
    ],
  );
}

// Dialog methods
void showAddCategoryDialog(
  SelllerSettingProvider viewModel,
  BuildContext context,
) {
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
              viewModel.addCategory(controller.text);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    ),
  );
}

Widget buildBankDetailsSection(SelllerSettingProvider viewModel) {
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
            Icon(Icons.security_rounded, size: 16, color: AppColors.darkGrey),
            const SizedBox(width: 8),
            Text(
              'Your information is encrypted and secure',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'Bank Name',
          controller: viewModel.bankNameController,
          icon: Icons.account_balance_rounded,
          isEditing: viewModel.isEditing,
          onChanged: (value) => viewModel.setBankName(value),
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'Account Number',
          controller: viewModel.accountNumberController,
          icon: Icons.credit_card_rounded,
          isEditing: viewModel.isEditing,
          onChanged: (value) => viewModel.setAccountNumber(value),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'IBAN',
          controller: viewModel.ibanController,
          icon: Icons.receipt_rounded,
          isEditing: viewModel.isEditing,
          onChanged: (value) => viewModel.setIban(value),
        ),
      ],
    ),
  );
}

Widget saveChangesButton(
  SelllerSettingProvider viewModel,
  BuildContext context,
) {
  return Column(
    children: [
      if (viewModel.isEditing) ...[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    final success = await viewModel.saveChanges();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile updated successfully!'),
                        ),
                      );
                    } else if (viewModel.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(viewModel.errorMessage!)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    ],
  );
}

// Helper Widgets with controller parameter
Widget buildInfoField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required bool isEditing,
  required Function(String) onChanged,
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
        controller: controller, // Use the provided controller
        textInputType: keyboardType,
      ),
    ],
  );
}

Widget buildInfoTextArea({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required bool isEditing,
  required Function(String) onChanged,
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
        controller: controller,
        textInputType: TextInputType.multiline,
        maxLines: 4,
      ),
    ],
  );
}

Widget buildShopBrandingSection(SelllerSettingProvider viewModel) {
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
              child: buildImageUploader(
                label: 'Shop Logo',
                image: viewModel.shopLogo,
                onTap: viewModel.isEditing
                    ? () => viewModel.pickShopLogo()
                    : null,
                size: const Size(120, 120),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildImageUploader(
                label: 'Shop Banner',
                image: viewModel.shopBanner,
                onTap: viewModel.isEditing
                    ? () => viewModel.pickShopBanner()
                    : null,
                size: const Size(double.infinity, 120),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildCategoriesSection(
  SelllerSettingProvider viewModel,
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
          'Business Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.categories.map((category) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.brightOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: AppColors.brightOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (viewModel.isEditing) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => viewModel.removeCategory(category),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.brightOrange,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
        if (viewModel.isEditing) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => showAddCategoryDialog(viewModel, context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
    ),
  );
}

Widget buildShopHeader(SelllerSettingProvider viewModel) {
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
            color: viewModel.shopLogo != null
                ? Colors.transparent
                : Color(0xFF667EEA),
            shape: BoxShape.circle,
          ),
          child: viewModel.shopLogo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.file(viewModel.shopLogo!, fit: BoxFit.cover),
                )
              : Icon(Icons.store_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.shopName.isNotEmpty
                    ? viewModel.shopName
                    : 'Your Shop Name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                viewModel.businessName.isNotEmpty
                    ? viewModel.businessName
                    : 'Business Name',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email_rounded, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      viewModel.email.isNotEmpty
                          ? viewModel.email
                          : 'email@example.com',
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
                      color: viewModel.isVerified
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          viewModel.isVerified
                              ? Icons.verified_rounded
                              : Icons.pending_rounded,
                          size: 12,
                          color: viewModel.isVerified
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          viewModel.isVerified ? 'Verified' : 'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            color: viewModel.isVerified
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

Widget buildShopBanner(SelllerSettingProvider viewModel) {
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
              color: viewModel.shopBanner == null ? Colors.grey[50] : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: viewModel.shopBanner != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(viewModel.shopBanner!, fit: BoxFit.cover),
                  )
                : Column(
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
                    ],
                  ),
          ),
        ),
      ],
    ),
  );
}
