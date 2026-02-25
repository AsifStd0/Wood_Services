// views/seller_signup_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/views/Seller/seller_login.dart/seller_login.dart';
// import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';
import 'package:wood_service/views/Seller/signup.dart/signup_widget.dart';
import 'package:wood_service/widgets/custom_button.dart';

class SellerSignupScreen extends StatelessWidget {
  String role = 'seller';
  SellerSignupScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Seller Signup'),
        centerTitle: true,
        backgroundColor: AppColors.brightOrange,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 20),
                    buildPersonalInfoSection(context),
                    const SizedBox(height: 20),
                    buildBusinessInfoSection(context),
                    const SizedBox(height: 20),
                    buildShopBrandingSection(context),
                    const SizedBox(height: 20),
                    buildCategoriesSection(context),
                    const SizedBox(height: 20),
                    buildBankDetailsSection(context),
                    const SizedBox(height: 20),
                    buildDocumentsSection(context),
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

  Widget _buildSubmitButton(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();

    return CustomButtonUtils.login(
      title: 'Register Seller',
      // padding: EdgeInsets.all(0),
      backgroundColor: AppColors.brightOrange,
      onPressed: viewModel.isLoading
          ? null
          : () => viewModel.handleSubmission(context, role),
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AuthBottomText(
        questionText: "Already have an account? ",
        actionText: "Sign In",
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return SellerLogin(role: 'seller');
              },
            ),
          );
        },
      ),
    );
  }

  // In your UI - Update _handleSubmission method
}
