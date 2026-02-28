import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/Responsive/responsive_context_extensions.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

Widget buildFormField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required String hintText,
  TextInputType textInputType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(label, type: CustomTextType.subtitleMedium),
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        child: CustomTextFormField(
          prefixIcon: Icon(icon, color: AppColors.grey),
          controller: controller,
          hintText: hintText,
          textInputType: textInputType,
        ),
      ),
    ],
  );
}

void showAddCategoryDialog(BuildContext context, RegisterViewModel viewModel) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Business Category'),

      content: CustomTextFormField.dialog(
        controller: controller,
        hintText: 'e.g. Furniture, Home Decor, Office Furniture',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              viewModel.addCategory(controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}

Widget buildDescriptionField(BuildContext context) {
  final viewModel = context.read<RegisterViewModel>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText('Business Description *', type: CustomTextType.subtitleMedium),
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        child: CustomTextFormField(
          prefixIcon: Icon(Icons.description, color: AppColors.grey),
          controller: viewModel.businessDescriptionController,
          hintText: 'Describe your business and products',
          maxLines: 4,
          minline: 3,
        ),
      ),
    ],
  );
}

Widget buildShopBrandingSection(BuildContext context) {
  final viewModel = context.watch<RegisterViewModel>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        'Shop Branding',
        type: CustomTextType.subtitleLarge,
        color: AppColors.brightOrange,
      ),
      const SizedBox(height: 15),
      buildImageUploader(
        label: 'Shop Logo',
        image: viewModel.shopLogo,
        onTap: viewModel.pickShopLogo,
        onRemove: viewModel.clearShopLogo,
        size: const Size(120, 120),
        hintText: 'Upload Logo',
      ),
      const SizedBox(height: 15),
      buildImageUploader(
        label: 'Shop Banner',
        image: viewModel.shopBanner,
        onTap: viewModel.pickShopBanner,
        onRemove: viewModel.clearShopBanner,
        size: Size(double.infinity, context.h(160)),
        hintText: 'Upload Banner (1200x400 recommended)',
      ),
    ],
  );
}

Widget buildImageUploader({
  required String label,
  required File? image,
  required VoidCallback onTap,
  required VoidCallback? onRemove,
  required Size size,
  required String hintText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(label, type: CustomTextType.subtitleMedium),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: size.width == double.infinity ? double.infinity : size.width,
          height: size.height,
          constraints: size.width == double.infinity
              ? BoxConstraints.expand(height: size.height)
              : null,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (onRemove != null) {
                            onRemove();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      label.contains('Logo')
                          ? Icons.add_photo_alternate
                          : Icons.add_to_photos,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        hintText,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ],
  );
}

Widget buildCategoriesList(RegisterViewModel viewModel) {
  return Wrap(
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
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => viewModel.removeCategory(category),
              child: Icon(Icons.close, size: 14, color: AppColors.brightOrange),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

Widget buildAddCategoryButton(
  BuildContext context,
  RegisterViewModel viewModel,
) {
  return GestureDetector(
    onTap: () => showAddCategoryDialog(context, viewModel),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            'Add Category',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}

Widget buildBankDetailsSection(BuildContext context) {
  final viewModel = context.read<RegisterViewModel>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        'Bank Details for Payouts',
        type: CustomTextType.subtitleLarge,
        color: AppColors.brightOrange,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(Icons.security, size: 16, color: AppColors.darkGrey),
          const SizedBox(width: 8),
          CustomText(
            'Your information is encrypted and secure',
            type: CustomTextType.hint,
          ),
        ],
      ),
      const SizedBox(height: 15),
      buildFormField(
        label: 'Bank Name *',
        controller: viewModel.bankNameController,
        icon: Icons.account_balance,
        hintText: 'Enter your bank name',
      ),
      buildFormField(
        label: 'Account Number *',
        controller: viewModel.accountNumberController,
        icon: Icons.credit_card,
        hintText: 'Enter your account number',
        textInputType: TextInputType.number,
      ),
      buildFormField(
        label: 'IBAN',
        controller: viewModel.ibanController,
        icon: Icons.receipt,
        hintText: 'Enter IBAN (if applicable)',
      ),
    ],
  );
}

Widget buildPhoneField(BuildContext context) {
  final viewModel = context.read<RegisterViewModel>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText('Contact Number *', type: CustomTextType.subtitleMedium),
      Padding(
        padding: EdgeInsets.only(top: context.h(4), bottom: context.h(12)),
        child: CustomTextFormField(
          prefixIcon: CountryCodePicker(
            onChanged: (CountryCode countryCode) {
              viewModel.countryCode = countryCode.dialCode ?? '+966';
            },
            initialSelection: 'SA', // Saudi Arabia
            favorite: const ['+966', 'SA', '+1', 'US'], // Saudi Arabia, USA
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
            showFlag: true,
            showFlagDialog: true,
            padding: EdgeInsets.zero,
            textStyle: TextStyle(fontSize: context.sp(14)),
          ),
          controller: viewModel.phoneController,
          hintText: 'Enter your phone number',
          textInputType: TextInputType.phone,
        ),
      ),
    ],
  );
}

Widget buildPasswordField(
  BuildContext context, {
  required String label,
  required TextEditingController controller,
  required bool isObscure,
  required VoidCallback onToggle,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(label, type: CustomTextType.subtitleMedium),
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        child: CustomTextFormField(
          prefixIcon: Icon(Icons.lock, color: AppColors.grey),
          controller: controller,
          hintText: label.contains('Confirm')
              ? 'Confirm your password'
              : 'Create a password',
          obscureText: isObscure,
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: AppColors.grey,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    ],
  );
}

Widget buildBusinessInfoSection(BuildContext context) {
  final viewModel = context.read<RegisterViewModel>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        'Business Information',
        type: CustomTextType.subtitleLarge,
        color: AppColors.brightOrange,
      ),
      const SizedBox(height: 15),
      buildFormField(
        label: 'Business Name *',
        controller: viewModel.businessNameController,
        icon: Icons.business,
        hintText: 'Enter your business legal name',
      ),
      buildFormField(
        label: 'Shop Name *',
        controller: viewModel.shopNameController,
        icon: Icons.store,
        hintText: 'Enter your shop display name',
      ),
      buildDescriptionField(context),
      buildFormField(
        label: 'Business Address *',
        controller: viewModel.addressController,
        icon: Icons.location_on,
        hintText: 'Enter your business address',
      ),
    ],
  );
}

Widget buildCategoriesSection(BuildContext context) {
  final viewModel = context.watch<RegisterViewModel>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        'Business Categories',
        type: CustomTextType.subtitleLarge,
        color: AppColors.brightOrange,
      ),
      const SizedBox(height: 8),
      CustomText(
        'Select the categories that best describe your products',
        type: CustomTextType.hint,
      ),
      const SizedBox(height: 12),
      buildCategoriesList(viewModel),
      const SizedBox(height: 12),
      buildAddCategoryButton(context, viewModel),
    ],
  );
}

Widget buildDocumentUploader(
  BuildContext context,
  String title,
  String documentType,
) {
  final viewModel = context.watch<RegisterViewModel>();
  final file = viewModel.documents[documentType];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText('$title *', type: CustomTextType.subtitleMedium),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => viewModel.pickDocument(documentType),
        child: Container(
          width: double.infinity,
          height: 120,
          constraints: const BoxConstraints.expand(height: 120),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: file != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => viewModel.clearDocument(documentType),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, color: Colors.grey[400], size: 40),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            'Upload $title',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Image or PDF',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ],
  );
}

Widget buildDocumentsSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        'Business Documents *',
        type: CustomTextType.subtitleLarge,
        color: AppColors.brightOrange,
      ),
      const SizedBox(height: 8),
      CustomText(
        'Upload required documents for verification',
        type: CustomTextType.hint,
      ),
      const SizedBox(height: 15),
      Column(
        children: [
          buildDocumentUploader(context, 'Business License', 'businessLicense'),
          const SizedBox(height: 12),
          buildDocumentUploader(context, 'Tax Certificate', 'taxCertificate'),
          const SizedBox(height: 12),
          buildDocumentUploader(context, 'Identity Proof', 'identityProof'),
        ],
      ),
    ],
  );
}

Widget buildHeader(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(top: context.h(20), bottom: context.h(5)),
    child: CustomText(
      'Start Your Furniture Business with GIGA Home',
      type: CustomTextType.headingLittleLarge,
    ),
  );
}

Widget buildPersonalInfoSection(BuildContext context) {
  final viewModel = context.read<RegisterViewModel>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        'Personal Information',
        type: CustomTextType.subtitleLarge,
        color: AppColors.brightOrange,
      ),
      const SizedBox(height: 15),
      buildFormField(
        label: 'Full Name *',
        controller: viewModel.nameController,
        icon: Icons.person,
        hintText: 'Enter your full name',
      ),
      buildFormField(
        label: 'Email Address *',
        controller: viewModel.emailController,
        icon: Icons.email,
        hintText: 'Enter your email address',
        textInputType: TextInputType.emailAddress,
      ),
      buildPhoneField(context),
      buildPasswordField(
        context,
        label: 'Password *',
        controller: viewModel.passwordController,
        isObscure: viewModel.obscurePassword,
        onToggle: () => viewModel.togglePasswordVisibility(),
        // viewModel.setObscurePassword(!viewModel.obscurePassword),
      ),
      buildPasswordField(
        context,
        label: 'Confirm Password *',
        controller: viewModel.confirmPasswordController,
        isObscure: viewModel.obscureConfirmPassword,
        onToggle: () => viewModel.toggleConfirmPasswordVisibility(),
      ),
    ],
  );
}
