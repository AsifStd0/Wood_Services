import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_widge.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class BuyerSignup extends StatefulWidget {
  @override
  State<BuyerSignup> createState() => _BuyerSignupState();
}

class _BuyerSignupState extends State<BuyerSignup> {
  // Create separate controllers for each field
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();

  // Focus nodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _businessNameFocusNode = FocusNode();
  final FocusNode _contactNameFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _bankNameFocusNode = FocusNode();
  final FocusNode _ibanFocusNode = FocusNode();

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
                        'Buyer Information',
                        style: AppCustomTextStyle.headlineMedium(context),
                      ),
                    ),
                    CustomText(
                      'Tell us a bit about you and your business',
                      fontSize: 14,
                      color: AppColors.grayMedium,
                    ),
                    SizedBox(height: 15),

                    // Full Name Field
                    CustomText('Name', type: CustomTextType.subtitleMedium),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _fullNameController,
                        hintText: 'e.g. John Doe',
                        onChanged: (value) {
                          print('Full Name: $value');
                        },
                        focusNode: _fullNameFocusNode,
                      ),
                    ),

                    // Business Name Field
                    CustomText(
                      'Business Name',
                      type: CustomTextType.subtitleMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _businessNameController,
                        hintText: 'e.g. Modern Design Co.',
                        onChanged: (value) {
                          print('Business Name: $value');
                        },
                        focusNode: _businessNameFocusNode,
                      ),
                    ),

                    // Contact Name Field
                    CustomText(
                      'Contact Name',
                      type: CustomTextType.subtitleMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _contactNameController,
                        hintText: 'e.g. James Smith',
                        onChanged: (value) {
                          print('Contact Name: $value');
                        },
                        focusNode: _contactNameFocusNode,
                      ),
                    ),

                    // Address Field
                    CustomText('Address', type: CustomTextType.subtitleMedium),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _addressController,
                        hintText: 'Enter your full address',
                        onChanged: (value) {
                          print('Address: $value');
                        },
                        focusNode: _addressFocusNode,
                      ),
                    ),

                    // Description Field
                    CustomText('Short Description (Optional)'),

                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        minline: 4,
                        maxLines: 4,

                        controller: _descriptionController,
                        hintText: 'A little about your shop..',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _descriptionFocusNode,
                      ),
                    ),

                    Divider(color: AppColors.greyDim),

                    // Bank Details Section
                    CustomText(
                      'Bank Details',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: CustomText(
                        'Where we should send your earnings',
                        fontSize: 14,
                        color: AppColors.grayMedium,
                      ),
                    ),

                    // Bank Name Field
                    CustomText(
                      'Bank Name',
                      type: CustomTextType.subtitleMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _bankNameController,
                        hintText: 'e.g. Premier National Bank',
                        onChanged: (value) {
                          print('Bank Name: $value');
                        },
                        focusNode: _bankNameFocusNode,
                      ),
                    ),

                    // IBAN Field
                    CustomText('IBAN', type: CustomTextType.subtitleMedium),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _ibanController,
                        hintText: 'SA00 0000 0000 0000 0000 0000',
                        onChanged: (value) {
                          print('IBAN: $value');
                        },
                        focusNode: _ibanFocusNode,
                      ),
                    ),

                    // Documents Section
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

                    // Submit Button
                    CustomButtonUtils.login(
                      padding: EdgeInsets.all(0),

                      title: 'Submit Application',
                      backgroundColor: AppColors.brightOrange,
                      onPressed: _submitApplication,
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

  // Submit application method
  void _submitApplication() {
    context.push('/forgot');
    // // Collect all data from controllers
    // final sellerData = {
    //   'fullName': _fullNameController.text,
    //   'businessName': _businessNameController.text,
    //   'contactName': _contactNameController.text,
    //   'address': _addressController.text,
    //   'description': _descriptionController.text,
    //   'bankName': _bankNameController.text,
    //   'iban': _ibanController.text,
    // };

    // // Print all data for verification
    // sellerData.forEach((key, value) {
    //   print('$key: $value');
    // });

    // TODO: Add your API call or form validation here
    // context.push('/forgot');
  }

  @override
  void dispose() {
    // Dispose all controllers
    _fullNameController.dispose();
    _businessNameController.dispose();
    _contactNameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _bankNameController.dispose();
    _ibanController.dispose();

    // Dispose all focus nodes
    _fullNameFocusNode.dispose();
    _businessNameFocusNode.dispose();
    _contactNameFocusNode.dispose();
    _addressFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _bankNameFocusNode.dispose();
    _ibanFocusNode.dispose();

    super.dispose();
  }
}
