// views/seller_signup_view.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup_provider.dart';
import 'package:wood_service/views/Seller/signup.dart/signup_widget.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';

class SellerSignupScreen extends StatelessWidget {
  const SellerSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
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
    final viewModel = context.watch<SellerSignupViewModel>();

    return CustomButtonUtils.login(
      title: 'Register Seller',
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return SellerLogin();
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSubmission(BuildContext context) async {
    final viewModel = context.read<SellerSignupViewModel>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final result = await viewModel.submitApplication();

      if (context.mounted) Navigator.of(context).pop();

      result.fold(
        (failure) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Registration Failed'),
                content: Text(failure.message ?? 'An error occurred'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        (authResponse) async {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Registration Successful!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            await Future.delayed(Duration(milliseconds: 1500));

            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) {
                    return MainSellerScreen();
                  },
                ),
              );
            }
          }
        },
      );
    } catch (error) {
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Network error: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
