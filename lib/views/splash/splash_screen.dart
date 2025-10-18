import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(title: "Giga Home", image: "assets/images/sofa.jpg"),
    OnboardingItem(title: "Quality Furniture", image: "assets/images/sofa.jpg"),
    OnboardingItem(
      title: "Explore Curated\nCollection",
      image: "assets/images/sofa.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ IMAGE + SKIP (Stack)
            Expanded(
              flex: 22,
              child: Stack(
                children: [
                  // Image Slider - Fills entire Stack
                  Positioned.fill(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _onboardingItems.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            _onboardingItems[index].image,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),

                  // Skip Button - Top Right
                  Positioned(
                    top: 16,
                    right: 16,
                    child: TextButton(
                      onPressed: () {
                        context.push('/selction_screen');
                        // Navigate to next screen
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ✅ Title Text
            CustomText(
              _onboardingItems[_currentPage].title,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              fontSize: 25,
              letterSpacing: 0.2,
            ),

            const SizedBox(height: 4),

            // ✅ Page Indicator
            SizedBox(
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildAnimatedPageIndicator(),
              ),
            ),

            const Spacer(),

            // ✅ Bottom Button
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: CustomButtonUtils.login(
                backgroundColor: AppColors.brightOrange,
                onPressed: () {
                  context.push('/selction_screen');
                },
                title: 'Get Started',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page Indicators - FIXED VERSION
  // Page Indicators - Rectangular active, circular inactive
  List<Widget> _buildAnimatedPageIndicator() {
    return List.generate(_onboardingItems.length, (i) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 25.0,
        height: 6.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          // shape: BoxShape.circle,
          color: _currentPage == i
              ? AppColors.brightOrange
              : AppColors.lightGrey.withOpacity(0.5),
        ),
      );
    });
  }
}

class OnboardingItem {
  final String title;
  final String image;
  OnboardingItem({required this.title, required this.image});
}
