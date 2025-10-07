import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/constant/image_paths.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text.dart';

class Slides extends StatelessWidget {
  const Slides({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Full screen background image
          SizedBox.expand(
            child: Image.asset(AssetImages.splash, fit: BoxFit.cover),
          ),

          // ✅ Foreground content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- Logo & Title ---
                SizedBox(height: 4),
                Column(
                  children: [
                    Image.asset(AssetImages.simpleSofa, width: 50, height: 50),
                    const SizedBox(height: 12),
                    CustomText(
                      'FURNI EXPO',
                      type: CustomTextType.mainheadingLarge,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ],
                ),
                SizedBox(height: 50),
                // --- Bottom Section ---
                Column(
                  children: [
                    CustomText(
                      'Tons of furniture collections',
                      fontSize: 21,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod.",
                      fontSize: 14,
                      color: Colors.white70,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_dot(true), _dot(false), _dot(false)],
                    ),
                    const SizedBox(height: 8),
                    CustomButtonUtils.signUp(
                      onPressed: () {
                        context.push('/login');
                      },
                      width: double.infinity,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 10,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.orange : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
