import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/views/Buyer/buyer_main.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_provider.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class BuyerSignupScreen extends StatefulWidget {
  const BuyerSignupScreen({Key? key}) : super(key: key);

  @override
  State<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends State<BuyerSignupScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BuyerSignupProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<BuyerSignupProvider>(
            builder: (context, provider, child) {
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
                              _buildProfileImageSection(provider),
                              const SizedBox(height: 20),

                              // Personal Information Section
                              _buildPersonalInfoSection(provider),
                              const SizedBox(height: 20),

                              // Business Information Section
                              _buildBusinessInfoSection(provider),
                              const SizedBox(height: 20),

                              // Bank Details Section
                              _buildBankDetailsSection(provider),
                              const SizedBox(height: 30),

                              // Submit Button
                              _buildSubmitButton(provider),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Loading overlay
                  if (provider.isLoading)
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
            style: AppCustomTextStyle.headlineMedium(context)?.copyWith(
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

  Widget _buildProfileImageSection(BuyerSignupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText('Profile Picture', type: CustomTextType.subtitleMedium),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () => provider.pickProfileImage(),
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
              child: provider.profileImage != null
                  ? ClipOval(
                      child: Image.file(
                        provider.profileImage!,
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

  Widget _buildPersonalInfoSection(BuyerSignupProvider provider) {
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

        // Full Name Field
        CustomText('Full Name *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.name,
            onChanged: provider.setFullName,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
            hintText: 'e.g. John Doe',
          ),
        ),

        // Email Field
        CustomText('Email Address *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.email,
            onChanged: provider.setEmail,
            validator: (value) {
              if (value?.isEmpty == true) return 'Required';
              if (!value!.contains('@')) return 'Invalid email';
              return null;
            },
            hintText: 'e.g. john@example.com',
            textInputType: TextInputType.emailAddress,
          ),
        ),

        // Password Field
        CustomText('Password *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.password,
            onChanged: provider.setPassword,
            validator: (value) {
              if (value?.isEmpty == true) return 'Required';
              if (value!.length < 6) return 'At least 6 characters';
              return null;
            },
            hintText: 'Enter your password',
            obscureText: provider.obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                provider.obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.grayMedium,
              ),
              onPressed: provider.togglePasswordVisibility,
            ),
          ),
        ),

        // Confirm Password Field
        CustomText('Confirm Password *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.confrimpassword,
            onChanged: provider.setConfirmPassword,
            validator: (value) {
              if (value?.isEmpty == true) return 'Required';
              if (value != provider.password) return 'Passwords do not match';
              return null;
            },
            hintText: 'Confirm your password',
            obscureText: provider.obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                provider.obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.grayMedium,
              ),
              onPressed: provider.toggleConfirmPasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection(BuyerSignupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Business Information',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.brightOrange,
        ),
        const SizedBox(height: 15),

        // Business Name Field
        CustomText('Business Name', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.businessName,
            onChanged: provider.setBusinessName,
            hintText: 'e.g. Modern Design Co.',
          ),
        ),

        // Contact Name Field
        CustomText('Contact Name', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.contactName,
            onChanged: provider.setContactName,
            hintText: 'e.g. James Smith',
          ),
        ),

        // Address Field
        CustomText('Address', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.address,
            onChanged: provider.setAddress,
            hintText: 'Enter your full address',
          ),
        ),

        // Description Field
        CustomText('Short Description (Optional)'),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            minline: 4,
            maxLines: 4,
            onChanged: provider.setDescription,
            hintText: 'A little about your business...',
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetailsSection(BuyerSignupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Bank Details',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.brightOrange,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomText(
            'Where we should send your payments',
            fontSize: 14,
            color: AppColors.grayMedium,
          ),
        ),

        // Bank Name Field
        CustomText('Bank Name', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            onChanged: provider.setBankName,
            hintText: 'e.g. Premier National Bank',
          ),
        ),

        // IBAN Field
        CustomText('IBAN', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            onChanged: provider.setIban,
            hintText: 'SA00 0000 0000 0000 0000 0000',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuyerSignupProvider provider) {
    // Show error message if exists
    Widget? errorWidget;
    if (provider.errorMessage != null) {
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
                  provider.errorMessage!,
                  style: TextStyle(color: Colors.red[800]),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: Colors.red[800]),
                onPressed: provider.clearError,
              ),
            ],
          ),
        ),
      );
    }

    // Show success message if exists
    Widget? successWidget;
    if (provider.successMessage != null) {
      successWidget = Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.successMessage!,
                  style: TextStyle(color: Colors.green[800]),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: Colors.green[800]),
                onPressed: provider.clearSuccess,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (errorWidget != null) errorWidget,
        if (successWidget != null) successWidget,
        CustomButtonUtils.login(
          padding: EdgeInsets.all(0),
          title: 'Complete Registration',
          backgroundColor: AppColors.brightOrange,
          onPressed: () async {
            // Hide keyboard
            FocusScope.of(context).unfocus();

            // Print form data for debugging
            // provider.printFormData();

            // Submit registration
            final result = await provider.registerBuyer();

            if (result['success'] == true) {
              // Navigate to main screen after successful registration
              await Future.delayed(const Duration(seconds: 1));
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => BuyerMainScreen()),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
