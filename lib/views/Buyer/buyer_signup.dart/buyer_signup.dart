import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/views/Buyer/buyer_main.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BuyerSignup extends StatefulWidget {
  @override
  State<BuyerSignup> createState() => _BuyerSignupState();
}

class _BuyerSignupState extends State<BuyerSignup> {
  // Existing controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();

  // New controllers for additional fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Focus nodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _businessNameFocusNode = FocusNode();
  final FocusNode _contactNameFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _bankNameFocusNode = FocusNode();
  final FocusNode _ibanFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _submitApplication() {
    // // Validate passwords match
    // if (_passwordController.text != _confirmPasswordController.text) {
    //   _showErrorDialog('Passwords do not match');
    //   return;
    // }

    // // Validate required fields
    // if (_emailController.text.isEmpty ||
    //     _passwordController.text.isEmpty ||
    //     _fullNameController.text.isEmpty) {
    //   _showErrorDialog('Please fill all required fields');
    //   return;
    // }

    // // Collect all data
    // final buyerData = {
    //   'fullName': _fullNameController.text,
    //   'businessName': _businessNameController.text,
    //   'contactName': _contactNameController.text,
    //   'address': _addressController.text,
    //   'description': _descriptionController.text,
    //   'bankName': _bankNameController.text,
    //   'iban': _ibanController.text,
    //   'email': _emailController.text,
    //   'password': _passwordController.text,
    //   'profileImage': _selectedImage?.path,
    // };

    // // Print all data for verification
    // buyerData.forEach((key, value) {
    //   print('$key: $value');
    // });

    // Navigate to next screen
    // context.push('/main_buyer');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return MainScreen();
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

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
                    // Header Section
                    _buildHeaderSection(),
                    SizedBox(height: 20),

                    // Profile Image Section
                    _buildProfileImageSection(),
                    SizedBox(height: 20),

                    // Personal Information Section
                    _buildPersonalInfoSection(),
                    SizedBox(height: 20),

                    // Business Information Section
                    _buildBusinessInfoSection(),
                    SizedBox(height: 20),

                    // Bank Details Section
                    _buildBankDetailsSection(),
                    SizedBox(height: 30),

                    // Submit Button
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildProfileImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText('Profile Picture', type: CustomTextType.subtitleMedium),
        SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
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
              child: _selectedImage != null
                  ? ClipOval(
                      child: Image.file(
                        _selectedImage!,
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
        SizedBox(height: 8),
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

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Personal Information',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.brightOrange,
        ),
        SizedBox(height: 15),

        // Full Name Field
        CustomText('Full Name *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.name,
            validator: (value) {},
            controller: _fullNameController,
            hintText: 'e.g. John Doe',
            onChanged: (value) {
              print('Full Name: $value');
            },
            focusNode: _fullNameFocusNode,
          ),
        ),

        // Email Field
        CustomText('Email Address *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.email,
            controller: _emailController,
            hintText: 'e.g. john@example.com',
            textInputType: TextInputType.emailAddress,
            onChanged: (value) {
              print('Email: $value');
            },
            focusNode: _emailFocusNode,
          ),
        ),

        // Password Field
        CustomText('Password *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.password,
            controller: _passwordController,
            hintText: 'Enter your password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.grayMedium,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            onChanged: (value) {
              print('Password: $value');
            },
            focusNode: _passwordFocusNode,
          ),
        ),

        // Confirm Password Field
        CustomText('Confirm Password *', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.confrimpassword,
            controller: _confirmPasswordController,
            hintText: 'Confirm your password',
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.grayMedium,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            onChanged: (value) {
              print('Confirm Password: $value');
            },
            focusNode: _confirmPasswordFocusNode,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Business Information',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.brightOrange,
        ),
        SizedBox(height: 15),

        // Business Name Field
        CustomText('Business Name', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.businessName,

            controller: _businessNameController,
            hintText: 'e.g. Modern Design Co.',
            onChanged: (value) {
              print('Business Name: $value');
            },
            focusNode: _businessNameFocusNode,
          ),
        ),

        // Contact Name Field
        CustomText('Contact Name', type: CustomTextType.subtitleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.contactName,

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
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            textFieldType: TextFieldType.address,

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
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            minline: 4,
            maxLines: 4,
            controller: _descriptionController,
            hintText: 'A little about your business...',
            onChanged: (value) {
              print('Description: $value');
            },
            focusNode: _descriptionFocusNode,
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetailsSection() {
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
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: CustomTextFormField(
            controller: _ibanController,
            hintText: 'SA00 0000 0000 0000 0000 0000',
            onChanged: (value) {
              print('IBAN: $value');
            },
            focusNode: _ibanFocusNode,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CustomButtonUtils.login(
      padding: EdgeInsets.all(0),
      title: 'Complete Registration',
      backgroundColor: AppColors.brightOrange,
      // textColor: Colors.white,
      onPressed: _submitApplication,
    );
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Dispose all focus nodes
    _fullNameFocusNode.dispose();
    _businessNameFocusNode.dispose();
    _contactNameFocusNode.dispose();
    _addressFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _bankNameFocusNode.dispose();
    _ibanFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }
}
