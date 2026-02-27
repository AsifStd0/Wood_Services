import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Buyer/login.dart/buyer_login_screen.dart';
import 'package:wood_service/views/Seller/seller_login.dart/seller_login.dart';
import 'package:wood_service/widgets/custom_text_style.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen>
    with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // simple entrance animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // small delay for staggered feel
    Timer(const Duration(milliseconds: 150), () {
      setState(() => _showContent = true);
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ButtonStyle _filledButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.bluePrimary,
      foregroundColor: Colors.white,
      elevation: 6,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: AppCustomTextStyle.buttonText(context),
    );
  }

  ButtonStyle _outlinedButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.bluePrimary,
      side: BorderSide(color: AppColors.bluePrimary, width: 1.8),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: AppCustomTextStyle.buttonText(
        context,
      ).copyWith(color: AppColors.bluePrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bluePrimary.withOpacity(0.14), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 450),
                opacity: _showContent ? 1 : 0,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: radius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 28,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo / App Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 64,
                                width: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.bluePrimary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.bluePrimary.withOpacity(
                                        0.28,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.chair_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    'FurniFind',
                                    type: CustomTextType.headingLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Find Perfect Furniture',
                                    style: AppCustomTextStyle.appSubtitle(
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // friendly instruction
                          Text(
                            'Choose how you want to use FurniFind:',
                            style: AppCustomTextStyle.appSubtitle(
                              context,
                            ).copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 22),

                          // Actions - buying / selling
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Buying - filled primary
                              ElevatedButton(
                                style: _filledButtonStyle(context),
                                onPressed: () {
                                  // context.push('/buyer_login');
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return BuyerLoginScreen(role: 'buyer');
                                      },
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "I'm Buying",
                                          style: AppCustomTextStyle.buttonText(
                                            context,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Selling - outlined
                              OutlinedButton(
                                style: _outlinedButtonStyle(context),
                                onPressed: () {
                                  // context.push('/seller_login');
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SellerLogin(role: 'seller');
                                      },
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.storefront_outlined,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "I'm Selling",
                                          style:
                                              AppCustomTextStyle.buttonText(
                                                context,
                                              ).copyWith(
                                                color: AppColors.bluePrimary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: AppColors.bluePrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // small extra action (optional)
                          TextButton(
                            onPressed: () {},
                            child: const Text('Learn more'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
