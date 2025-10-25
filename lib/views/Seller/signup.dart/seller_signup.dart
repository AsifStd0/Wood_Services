import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_widge.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class SellerSignup extends StatefulWidget {
  @override
  State<SellerSignup> createState() => _SellerSignupState();
}

class _SellerSignupState extends State<SellerSignup> {
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
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+1'; // Default country code
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: CustomText('SignUp', type: CustomTextType.appbar),
        // const Text('SignUp'),
      ),
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
                      padding: const EdgeInsets.only(top: 20, bottom: 5),
                      child: CustomText(
                        'Start Selling Your Furniture with Giga Home',
                        type: CustomTextType.headingLittleLarge,
                      ),
                    ),

                    // Full Name Field
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 10),
                      child: CustomText(
                        'Full Name',
                        type: CustomTextType.subtitleMedium,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    CustomTextFormField(
                      prefixIcon: Icon(Icons.person, color: AppColors.grey),
                      controller: _fullNameController,
                      hintText: 'Enter your full name',
                      onChanged: (value) {
                        print('Full Name: $value');
                      },
                      focusNode: _fullNameFocusNode,
                    ),

                    // Business Name Field
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 10),
                      child: CustomText(
                        'Business Email',
                        type: CustomTextType.subtitleMedium,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    CustomTextFormField(
                      prefixIcon: Icon(Icons.email, color: AppColors.grey),
                      controller: _businessNameController,
                      hintText: 'Enter your business email',
                      onChanged: (value) {
                        print('Business Name: $value');
                      },
                      focusNode: _businessNameFocusNode,
                    ),

                    // Contact Number Field with Country Code
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 10),
                      child: CustomText(
                        'Contact Number',
                        type: CustomTextType.subtitleMedium,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: CustomTextFormField(
                        prefixIcon: CountryCodePicker(
                          onChanged: (CountryCode countryCode) {
                            setState(() {
                              _countryCode = countryCode.dialCode ?? '+1';
                            });
                          },
                          initialSelection: 'US',
                          favorite: ['+1', 'US'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          showFlag: true,
                          showFlagDialog: true,
                          padding: EdgeInsets.zero,
                          textStyle: TextStyle(fontSize: 14),
                        ),
                        controller: _phoneController,
                        hintText: 'Enter your phone number',
                        // keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          final fullNumber = '$_countryCode$value';
                          print('Phone Number: $fullNumber');
                        },
                        focusNode: _phoneFocusNode,
                      ),
                    ),

                    // Address Field
                    Row(
                      children: [
                        Icon(
                          Icons.security_outlined,
                          size: 18,
                          color: AppColors.darkGrey,
                        ),
                        const SizedBox(width: 8),
                        CustomText(
                          'Secure Banking Details',
                          type: CustomTextType.subtitleMedium,
                          color: AppColors.darkGrey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      'Your information is encrypted and secure. We need this for seller payouts',
                      type: CustomTextType.hint,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: CustomTextFormField(
                        prefixIcon: Icon(Icons.lock, color: AppColors.grey),
                        controller: _addressController,
                        hintText: 'Enter your banking details',
                        onChanged: (value) {
                          print('Address: $value');
                        },
                        focusNode: _addressFocusNode,
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        UploadBox(
                          title: "Company Documents",
                          subtitle: "Click to upload",
                          check: false,

                          // fileTypeNote: "PNG, JPG or GIF (MAX. 800x400px)",
                        ),
                        UploadBox(
                          title: "Store Logo",
                          subtitle: "Click to upload",
                          // fileTypeNote: "PDF, PNG or JPG (MAX. 5MB)",
                          check: false,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    CustomButtonUtils.login(
                      title: 'Register as Seller',
                      padding: EdgeInsets.all(0),

                      backgroundColor: AppColors.brightOrange,
                      onPressed: _submitApplication,
                    ),

                    /// Always at bottom
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: AuthBottomText(
                        questionText: "Already have an account? ",
                        actionText: "Sign In",
                        onPressed: () {
                          // Navigator.pushNamed(context, '/seller_login');
                          context.push('/seller_login');
                        },
                      ),
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
    // Get the complete phone number
    final completePhoneNumber = '$_countryCode${_phoneController.text}';

    // // Collect all data from controllers
    // final sellerData = {
    //   'fullName': _fullNameController.text,
    //   'businessName': _businessNameController.text,
    //   'contactNumber': completePhoneNumber,
    //   'countryCode': _countryCode,
    //   'phoneNumber': _phoneController.text,
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
    context.push('/main_seller_screen');
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
    _phoneController.dispose();

    // Dispose all focus nodes
    _fullNameFocusNode.dispose();
    _businessNameFocusNode.dispose();
    _contactNameFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();

    super.dispose();
  }
}
