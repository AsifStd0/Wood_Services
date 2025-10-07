import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        _buildCircleButton(
          imageUrl:
              'https://static.vecteezy.com/system/resources/previews/046/861/647/non_2x/google-logo-transparent-background-free-png.png',
          onTap: () {
            Navigator.pushNamed(context, '/googleLogin'); // 👈 your route
          },
        ),
        const SizedBox(width: 20),
        // Apple Button
        _buildCircleButton(
          icon: Icons.apple,
          iconColor: Colors.black,
          onTap: () {
            Navigator.pushNamed(context, '/appleLogin'); // 👈 your route
          },
        ),
      ],
    );
  }

  // 🔹 Private reusable circle button builder
  Widget _buildCircleButton({
    String? imageUrl,
    IconData? icon,
    Color iconColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.socialOrange,
        child: imageUrl != null
            ? Image.network(imageUrl, height: 26, width: 26)
            : Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}
