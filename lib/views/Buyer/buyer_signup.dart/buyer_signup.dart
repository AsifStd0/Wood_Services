import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/Responsive/responsive_context_extensions.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

// ignore: must_be_immutable
class BuyerSignupScreen extends StatefulWidget {
  String role;
  BuyerSignupScreen({super.key, required this.role});

  @override
  State<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends State<BuyerSignupScreen> {
  // Add this to both SellerSignupScreen and BuyerSignupScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Buyer Signup',
        fontSize: context.sp(22),
        backgroundColor: AppColors.brightOrange,
        showBackButton: true,
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
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
                        padding: context.paddingAll(
                          context.responsiveValue(
                            mobile: 24,
                            tablet: 40,
                            desktop: 60,
                          ),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: context.responsiveValue(
                              mobile: double.infinity,
                              tablet: 700,
                              desktop: 900,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              _buildHeaderSection(context),
                              SizedBox(height: context.h(20)),

                              // Profile Image Section
                              _buildProfileImageSection(context, viewModel),
                              SizedBox(height: context.h(20)),

                              // Personal Information Section
                              _buildPersonalInfoSection(context, viewModel),
                              SizedBox(height: context.h(20)),

                              // Business Information Section
                              _buildBusinessInfoSection(context, viewModel),
                              SizedBox(height: context.h(20)),

                              // Submit Button
                              _buildSubmitButton(
                                context,
                                viewModel,
                                widget.role,
                              ),
                            ],
                          ),
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
                          SizedBox(height: context.h(16)),
                          Text(
                            'Registering...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(14),
                            ),
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

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.paddingOnly(
            top: context.h(20),
            bottom: context.h(5),
          ),
          child: Text(
            'Buyer Registration',
            style: AppCustomTextStyle.headlineMedium(context).copyWith(
              color: AppColors.brightOrange,
              fontWeight: FontWeight.bold,
              fontSize: context.sp(24),
            ),
          ),
        ),
        CustomText(
          'Complete your profile to start buying',
          fontSize: context.sp(14),
          color: AppColors.grayMedium,
        ),
      ],
    );
  }

  Widget _buildProfileImageSection(
    BuildContext context,
    RegisterViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText('Profile Picture', type: CustomTextType.subtitleMedium),
        SizedBox(height: context.h(8)),
        Center(
          child: GestureDetector(
            onTap: () => viewModel.pickImage('profile'),
            child: Container(
              width: context.w(120),
              height: context.h(120),
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
                        width: context.w(120),
                        height: context.h(120),
                      ),
                    )
                  : Icon(
                      Icons.camera_alt_outlined,
                      size: context.sp(40),
                      color: AppColors.grayMedium,
                    ),
            ),
          ),
        ),
        SizedBox(height: context.h(8)),
        Center(
          child: CustomText(
            'Tap to upload profile picture',
            fontSize: context.sp(12),
            color: AppColors.grayMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(
    BuildContext context,
    RegisterViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Personal Information',
          fontSize: context.sp(18),
          fontWeight: FontWeight.bold,
          color: AppColors.brightOrange,
        ),
        SizedBox(height: context.h(15)),

        // Full Name Field - Using RegisterViewModel
        CustomText('Full Name *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: context.paddingOnly(
            top: context.h(4),
            bottom: context.h(12),
          ),
          child: CustomTextFormField(
            controller: viewModel.nameController,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
            hintText: 'e.g. John Doe',
          ),
        ),

        // Email Field - Using RegisterViewModel
        CustomText('Email Address *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: context.paddingOnly(
            top: context.h(4),
            bottom: context.h(12),
          ),
          child: CustomTextFormField(
            controller: viewModel.emailController,
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
          padding: context.paddingOnly(
            top: context.h(4),
            bottom: context.h(12),
          ),
          child: CustomTextFormField(
            controller: viewModel.passwordController,
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
              onPressed: viewModel.togglePasswordVisibility,
            ),
          ),
        ),

        // Confirm Password Field - Using RegisterViewModel
        CustomText('Confirm Password *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: context.paddingOnly(
            top: context.h(4),
            bottom: context.h(12),
          ),
          child: CustomTextFormField(
            controller: viewModel.confirmPasswordController,
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
              onPressed: viewModel.toggleConfirmPasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection(
    BuildContext context,
    RegisterViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Contact Number *', type: CustomTextType.subtitleMedium),
            Padding(
              padding: context.paddingOnly(
                top: context.h(4),
                bottom: context.h(12),
              ),
              child: CustomTextFormField(
                prefixIcon: CountryCodePicker(
                  onChanged: (CountryCode countryCode) {
                    viewModel.countryCode = countryCode.dialCode ?? '+966';
                  },
                  initialSelection: 'SA', // Saudi Arabia
                  favorite: const [
                    '+966',
                    'SA',
                    '+1',
                    'US',
                  ], // Saudi Arabia, USA
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
        ),
        CustomText(
          'Business Information (Optional)',
          fontSize: context.sp(18),
          fontWeight: FontWeight.bold,
          color: AppColors.brightOrange,
        ),
        SizedBox(height: context.h(15)),

        // Business Name Field - Optional for buyer
        CustomText(
          'Business Name (Optional)',
          type: CustomTextType.subtitleMedium,
        ),
        Padding(
          padding: context.paddingOnly(
            top: context.h(4),
            bottom: context.h(12),
          ),
          child: CustomTextFormField(
            controller: viewModel.businessNameController,
            hintText: 'e.g. Modern Design Co.',
          ),
        ),

        // Address Field - Optional for buyer
        CustomText('Address *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: context.paddingOnly(
            top: context.h(4),
            bottom: context.h(12),
          ),
          child: CustomTextFormField(
            controller: viewModel.businessAddressController,
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
          padding: context.paddingOnly(
            top: context.h(4),
            bottom: context.h(12),
          ),
          child: CustomTextFormField(
            controller: viewModel.businessDescriptionController,
            minline: 4,
            maxLines: 4,
            hintText: 'A little about your business...',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    RegisterViewModel viewModel,
    String role,
  ) {
    // Show error message if exists
    Widget? errorWidget;
    if (viewModel.errorMessage != null) {
      errorWidget = Padding(
        padding: EdgeInsets.only(bottom: context.h(16)),
        child: Container(
          padding: context.paddingAll(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: context.borderRadius(8),
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[800]),
              SizedBox(width: context.w(8)),
              Expanded(
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: context.sp(14),
                  ),
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
        // Hide button's loading state completely - only show overlay
        Opacity(
          opacity: viewModel.isLoading ? 0.6 : 1.0,
          child: IgnorePointer(
            ignoring: viewModel.isLoading,
            child: CustomButtonUtils.login(
              title: 'Complete Registration',
              backgroundColor: AppColors.brightOrange,
              isLoading: false, // Never show button's loading indicator
              disabled: false, // Let opacity handle visual state
              onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.handleSubmission(context, role),
            ),
          ),
        ),
      ],
    );
  }
}
