// views/seller_signup_view.dart
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';
import 'package:wood_service/widgets/seller_signup_widget.dart';

class SellerSignup extends StatelessWidget {
  const SellerSignup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SellerSignupViewModel(),
      child: const _SellerSignupContent(),
    );
  }
}

class _SellerSignupContent extends StatelessWidget {
  const _SellerSignupContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: CustomText('Seller Registration', type: CustomTextType.appbar),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildPersonalInfoSection(context),
                    const SizedBox(height: 20),
                    _buildBusinessInfoSection(context),
                    const SizedBox(height: 20),
                    _buildShopBrandingSection(context),
                    const SizedBox(height: 20),
                    _buildCategoriesSection(context),
                    const SizedBox(height: 20),
                    _buildBankDetailsSection(context),
                    const SizedBox(height: 20),
                    _buildDocumentsSection(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(context),
                    _buildSignInLink(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: CustomText(
        'Start Your Furniture Business with Giga Home',
        type: CustomTextType.headingLittleLarge,
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    final viewModel = context.read<SellerSignupViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Personal Information',
          type: CustomTextType.subtitleLarge,
          color: AppColors.brightOrange,
        ),
        const SizedBox(height: 15),
        _buildFormField(
          label: 'Full Name *',
          controller: viewModel.fullNameController,
          icon: Icons.person,
          hintText: 'Enter your full name',
        ),
        _buildFormField(
          label: 'Email Address *',
          controller: viewModel.emailController,
          icon: Icons.email,
          hintText: 'Enter your email address',
          textInputType: TextInputType.emailAddress,
        ),
        _buildPhoneField(context),
        _buildPasswordField(
          context,
          label: 'Password *',
          controller: viewModel.passwordController,
          isObscure: viewModel.obscurePassword,
          onToggle: () =>
              viewModel.setObscurePassword(!viewModel.obscurePassword),
        ),
        _buildPasswordField(
          context,
          label: 'Confirm Password *',
          controller: viewModel.confirmPasswordController,
          isObscure: viewModel.obscureConfirmPassword,
          onToggle: () => viewModel.setObscureConfirmPassword(
            !viewModel.obscureConfirmPassword,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    final viewModel = context.read<SellerSignupViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText('Contact Number *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            prefixIcon: CountryCodePicker(
              onChanged: (CountryCode countryCode) {
                viewModel.countryCode = countryCode.dialCode ?? '+1';
              },
              initialSelection: 'US',
              favorite: const ['+1', 'US'],
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              showFlag: true,
              showFlagDialog: true,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(fontSize: 14),
            ),
            controller: viewModel.phoneController,
            hintText: 'Enter your phone number',
            textInputType: TextInputType.phone,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
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

  Widget _buildBusinessInfoSection(BuildContext context) {
    final viewModel = context.read<SellerSignupViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Business Information',
          type: CustomTextType.subtitleLarge,
          color: AppColors.brightOrange,
        ),
        const SizedBox(height: 15),
        _buildFormField(
          label: 'Business Name *',
          controller: viewModel.businessNameController,
          icon: Icons.business,
          hintText: 'Enter your business legal name',
        ),
        _buildFormField(
          label: 'Shop Name *',
          controller: viewModel.shopNameController,
          icon: Icons.store,
          hintText: 'Enter your shop display name',
        ),
        _buildDescriptionField(context),
        _buildFormField(
          label: 'Business Address *',
          controller: viewModel.addressController,
          icon: Icons.location_on,
          hintText: 'Enter your business address',
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    final viewModel = context.read<SellerSignupViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Business Description *',
          type: CustomTextType.subtitleMedium,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            prefixIcon: Icon(Icons.description, color: AppColors.grey),
            controller: viewModel.descriptionController,
            hintText: 'Describe your business and products',
            maxLines: 4,
            minline: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildShopBrandingSection(BuildContext context) {
    final viewModel = context.watch<SellerSignupViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Shop Branding',
          type: CustomTextType.subtitleLarge,
          color: AppColors.brightOrange,
        ),
        const SizedBox(height: 15),
        _buildImageUploader(
          label: 'Shop Logo',
          image: viewModel.shopLogo,
          onTap: viewModel.pickShopLogo,
          size: const Size(120, 120),
          hintText: 'Upload Logo',
        ),
        const SizedBox(height: 15),
        _buildImageUploader(
          label: 'Shop Banner',
          image: viewModel.shopBanner,
          onTap: viewModel.pickShopBanner,
          size: const Size(double.infinity, 120),
          hintText: 'Upload Banner (1200x400 recommended)',
        ),
      ],
    );
  }

  Widget _buildImageUploader({
    required String label,
    required File? image,
    required VoidCallback onTap,
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
                      Text(hintText, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final viewModel = context.watch<SellerSignupViewModel>();

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
        _buildCategoriesList(viewModel),
        const SizedBox(height: 12),
        _buildAddCategoryButton(context, viewModel),
      ],
    );
  }

  Widget _buildCategoriesList(SellerSignupViewModel viewModel) {
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
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.brightOrange,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddCategoryButton(
    BuildContext context,
    SellerSignupViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(context, viewModel),
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

  Widget _buildBankDetailsSection(BuildContext context) {
    final viewModel = context.read<SellerSignupViewModel>();

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
        _buildFormField(
          label: 'Bank Name *',
          controller: viewModel.bankNameController,
          icon: Icons.account_balance,
          hintText: 'Enter your bank name',
        ),
        _buildFormField(
          label: 'Account Number *',
          controller: viewModel.accountNumberController,
          icon: Icons.credit_card,
          hintText: 'Enter your account number',
          textInputType: TextInputType.number,
        ),
        _buildFormField(
          label: 'IBAN',
          controller: viewModel.ibanController,
          icon: Icons.receipt,
          hintText: 'Enter IBAN (if applicable)',
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Business Documents',
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
            UploadBox(
              title: "Business License",
              subtitle: "Click to upload",
              check: false,
            ),
            const SizedBox(height: 12),
            UploadBox(
              title: "Tax Certificate",
              subtitle: "Click to upload",
              check: false,
            ),
            const SizedBox(height: 12),
            UploadBox(
              title: "Identity Proof",
              subtitle: "Click to upload",
              check: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final viewModel = context.watch<SellerSignupViewModel>();

    return CustomButtonUtils.login(
      title: 'Complete Seller Registration',
      padding: EdgeInsets.all(0),
      backgroundColor: AppColors.brightOrange,
      onPressed: viewModel.isLoading ? null : () => _handleSubmission(context),
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AuthBottomText(
        questionText: "Already have an account? ",
        actionText: "Sign In",
        onPressed: () {
          context.push('/seller_login');
        },
      ),
    );
  }

  Widget _buildFormField({
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

  void _showAddCategoryDialog(
    BuildContext context,
    SellerSignupViewModel viewModel,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Business Category'),

        content: CustomTextFormField.dialog(
          // USE THE NEW DIALOG METHOD
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

  Future<void> _handleSubmission(BuildContext context) async {
    final viewModel = context.read<SellerSignupViewModel>();
    // final success = await viewModel.submitApplication();

    // if (success) {
    context.push('/main_seller_screen');
    // } else {
    //   _showErrorDialog(context, viewModel.errorMessage ?? 'An error occurred');
    // }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
