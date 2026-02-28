// views/seller_signup_view.dart
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/Responsive/responsive_context_extensions.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/views/Seller/seller_login.dart/seller_login.dart';
// import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';
import 'package:wood_service/views/Seller/signup.dart/signup_widget.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/custom_button.dart';

class SellerSignupScreen extends StatelessWidget {
  final String role;
  SellerSignupScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Seller Signup',
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
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: context.paddingOnly(
                      left: context.responsiveValue(
                        mobile: 20,
                        tablet: 40,
                        desktop: 60,
                      ),
                      right: context.responsiveValue(
                        mobile: 20,
                        tablet: 40,
                        desktop: 60,
                      ),
                      bottom: context.h(20),
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
                          buildHeader(context),
                          SizedBox(height: context.h(20)),
                          buildPersonalInfoSection(context),
                          SizedBox(height: context.h(20)),
                          buildBusinessInfoSection(context),
                          SizedBox(height: context.h(20)),
                          buildShopBrandingSection(context),
                          SizedBox(height: context.h(20)),
                          buildCategoriesSection(context),
                          SizedBox(height: context.h(20)),
                          buildBankDetailsSection(context),
                          SizedBox(height: context.h(20)),
                          buildDocumentsSection(context),
                          SizedBox(height: context.h(20)),
                          _buildSubmitButton(context, viewModel),
                          _buildSignInLink(context),
                        ],
                      ),
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

  Widget _buildSubmitButton(BuildContext context, RegisterViewModel viewModel) {
    // final viewModel = context.watch<RegisterViewModel>();

    return CustomButtonUtils.login(
      title: 'Register Seller',
      backgroundColor: AppColors.brightOrange,
      onPressed: viewModel.isLoading
          ? null
          : () {
              // Debug registration logic only (runs on tap, not during UI build)
              if (kDebugMode) {
                dev.log(
                  '[RegisterSeller] Step 0: Submit button pressed, role=$role',
                  name: 'RegisterSeller',
                );
              }
              viewModel.handleSubmission(context, role);
            },
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.h(20)),
      child: AuthBottomTextData(
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
}
