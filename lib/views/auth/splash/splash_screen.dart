import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Text('FurniFind', style: AppCustomTextStyle.appTitle(context)),
                const SizedBox(height: 10),
                Text(
                  'Find Perfect Furniture',
                  style: AppCustomTextStyle.appSubtitle(context),
                ),
                const SizedBox(height: 40),
                CustomButtonUtils.categorySelection(
                  color: AppColors.bluePrimary,
                  onPressed: () {
                    context.push('/login');
                  },
                  child: Text(
                    "I'm Buying",
                    style: AppCustomTextStyle.buttonText(context),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButtonUtils.categorySelection(
                  onPressed: () {
                    context.push('/seller_signup');
                  },
                  child: Text(
                    "I'm Selling",
                    style: AppCustomTextStyle.buttonText(
                      context,
                    ).copyWith(color: AppColors.bluePrimary),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
