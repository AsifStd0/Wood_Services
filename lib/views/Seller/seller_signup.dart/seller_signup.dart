import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/views/Seller/seller_signup.dart/seller_widge.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class SellerSignup extends StatefulWidget {
  @override
  State<SellerSignup> createState() => _SellerSignupState();
}

class _SellerSignupState extends State<SellerSignup> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 70, bottom: 5),
                      child: Text(
                        'Seller Information',
                        style: AppCustomTextStyle.headlineMedium(context),
                      ),
                    ),
                    CustomText(
                      'Tell us a bit about you and your busnines',
                      fontSize: 14,
                      color: AppColors.grayMedium,
                    ),
                    SizedBox(height: 15),
                    CustomText('Name', type: CustomTextType.subtitleMedium),
                    // Full Name Field
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _fullNameController,
                        hintText: 'e.g.. John Doe',
                        onChanged: (value) {
                          print('Full Name: $value');
                        },
                        focusNode: _fullNameFocusNode,
                      ),
                    ),

                    // Email Field
                    CustomText(
                      'Business Name',
                      type: CustomTextType.subtitleMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _emailController,
                        hintText: 'e.g.. Modern Design Co.',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _emailFocusNode,
                      ),
                    ),
                    // Email Field
                    CustomText(
                      'Contact Name',
                      type: CustomTextType.subtitleMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _emailController,
                        hintText: 'e.g.. Jame Smith',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _emailFocusNode,
                      ),
                    ),
                    // Email Field
                    CustomText('Address', type: CustomTextType.subtitleMedium),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _emailController,
                        hintText: 'Enter your full address',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _emailFocusNode,
                      ),
                    ),

                    CustomText('Short Description(Optional)'),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        minline: 4,
                        maxLines: 4,

                        controller: _emailController,
                        hintText: 'A little about your shop..',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _emailFocusNode,
                      ),
                    ),

                    Divider(color: AppColors.greyDim),

                    CustomText(
                      'Bank Detail',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: CustomText(
                        'where we should send your enarning',
                        fontSize: 14,
                        color: AppColors.grayMedium,
                      ),
                    ),

                    CustomText(
                      'Bank Name',
                      type: CustomTextType.subtitleMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _emailController,
                        hintText: 'e.g.. Premier National Bank',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _emailFocusNode,
                      ),
                    ),

                    CustomText('IBAN', type: CustomTextType.subtitleMedium),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _emailController,
                        hintText: 'SA00 0000 0000 0000 0000 0000',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _emailFocusNode,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CustomText(
                        'Documents',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        UploadBox(
                          title: "Company Logo",
                          subtitle: "Click to upload",
                          fileTypeNote: "PNG, JPG or GIF (MAX. 800x400px)",
                        ),
                        UploadBox(
                          title: "Commercial Registration (CR)",
                          subtitle: "Click to upload",
                          fileTypeNote: "PDF, PNG or JPG (MAX. 5MB)",
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Sign Up Button
                    CustomButtonUtils.login(
                      title: 'Submit Application',
                      backgroundColor: AppColors.brightOrange,
                      onPressed: () {
                        context.push('/forgot');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }
}
