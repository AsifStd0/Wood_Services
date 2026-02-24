import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class BuyerSignupScreen extends StatefulWidget {
  String role;
  BuyerSignupScreen({super.key, required this.role});

  @override
  State<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends State<BuyerSignupScreen> {
  // Add this to both SellerSignupScreen and BuyerSignupScreen

  @override
  void dispose() {
    // Clear form when screen is disposed (when user navigates away)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RegisterViewModel>();
      viewModel.clearForm();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<RegisterViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    /// Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            _buildHeaderSection(),
                            const SizedBox(height: 20),

                            // Profile Image Section
                            _buildProfileImageSection(viewModel),
                            const SizedBox(height: 20),

                            // Personal Information Section
                            _buildPersonalInfoSection(viewModel),
                            const SizedBox(height: 20),

                            // Business Information Section
                            _buildBusinessInfoSection(viewModel),
                            const SizedBox(height: 20),

                            // Submit Button
                            _buildSubmitButton(viewModel, widget.role),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Loading overlay
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.brightOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Registering...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 5),
          child: Text(
            'Buyer Registration',
            style: AppCustomTextStyle.headlineMedium(context).copyWith(
              color: AppColors.brightOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CustomText(
          'Complete your profile to start buying',
          fontSize: 14,
          color: AppColors.grayMedium,
        ),
      ],
    );
  }

  Widget _buildProfileImageSection(RegisterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText('Profile Picture', type: CustomTextType.subtitleMedium),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () => viewModel.pickImage(
              'profile',
            ), // Use RegisterViewModel's method
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.greyLight,
                border: Border.all(
                  color: AppColors.brightOrange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: viewModel.profileImage != null
                  ? ClipOval(
                      child: Image.file(
                        viewModel.profileImage!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: AppColors.grayMedium,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: CustomText(
            'Tap to upload profile picture',
            fontSize: 12,
            color: AppColors.grayMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(RegisterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Personal Information',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.brightOrange,
        ),
        const SizedBox(height: 15),

        // Full Name Field - Using RegisterViewModel
        CustomText('Full Name *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            controller: viewModel.nameController, // Use viewModel's controller
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
            hintText: 'e.g. John Doe',
          ),
        ),

        // Email Field - Using RegisterViewModel
        CustomText('Email Address *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            controller: viewModel.emailController, // Use viewModel's controller
            validator: (value) {
              if (value?.isEmpty == true) return 'Required';
              if (!value!.contains('@')) return 'Invalid email';
              return null;
            },
            hintText: 'e.g. john@example.com',
            textInputType: TextInputType.emailAddress,
          ),
        ),

        // Password Field - Using RegisterViewModel
        CustomText('Password *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            controller:
                viewModel.passwordController, // Use viewModel's controller
            validator: (value) {
              if (value?.isEmpty == true) return 'Required';
              if (value!.length < 6) return 'At least 6 characters';
              return null;
            },
            hintText: 'Enter your password',
            obscureText: viewModel.obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.grayMedium,
              ),
              onPressed:
                  viewModel.togglePasswordVisibility, // Use viewModel's method
            ),
          ),
        ),

        // Confirm Password Field - Using RegisterViewModel
        CustomText('Confirm Password *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            controller: viewModel
                .confirmPasswordController, // Use viewModel's controller
            validator: (value) {
              if (value?.isEmpty == true) return 'Required';
              if (value != viewModel.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            hintText: 'Confirm your password',
            obscureText: viewModel.obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.grayMedium,
              ),
              onPressed: viewModel
                  .toggleConfirmPasswordVisibility, // Use viewModel's method
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection(RegisterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
        ),
        CustomText(
          'Business Information (Optional)',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.brightOrange,
        ),
        const SizedBox(height: 15),

        // Business Name Field - Optional for buyer
        CustomText(
          'Business Name (Optional)',
          type: CustomTextType.subtitleMedium,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            controller: viewModel.businessNameController, // Optional for buyer
            hintText: 'e.g. Modern Design Co.',
          ),
        ),

        // Address Field - Optional for buyer
        CustomText('Address *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            controller: viewModel.addressController, // Optional for buyer
            hintText: 'Enter your full address',

            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
        ),

        // Description Field - Optional for buyer
        CustomText(
          'Short Description (Optional)',
          type: CustomTextType.subtitleMedium,
        ),

        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            controller:
                viewModel.businessDescriptionController, // Optional for buyer
            minline: 4,
            maxLines: 4,
            hintText: 'A little about your business...',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(RegisterViewModel viewModel, String role) {
    // Show error message if exists
    Widget? errorWidget;
    if (viewModel.errorMessage != null) {
      errorWidget = Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red[800]),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        if (errorWidget != null) errorWidget,
        CustomButtonUtils.login(
          title: 'Complete Registration',
          backgroundColor: AppColors.brightOrange,
          onPressed: viewModel.isLoading
              ? null
              : () => viewModel.handleSubmission(context, role),
        ),
      ],
    );
  }
}
