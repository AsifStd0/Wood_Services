import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Service/profile_service.dart';
import 'package:wood_service/views/splash/splash_screen.dart';

Widget buildStatItem(String value, String label, IconData icon) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.brown, size: 20),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// ! *****

Widget buildMenuTile({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  bool showBadge = false,
  int badgeCount = 0,
  Color iconColor = Colors.white,
  Color textColor = Colors.black,
  List<Color>? gradient,
  ValueChanged<bool>? onChanged, // Added for Dark Mode toggle
}) {
  // Check if it's a toggle tile (like Dark Mode)
  bool isToggleTile = onChanged != null;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: gradient != null
          ? LinearGradient(
              colors: gradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
          : null,
      color: gradient == null ? Colors.grey[50] : null,
      boxShadow: gradient == null
          ? [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    ),
    child: ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: gradient != null
              ? Colors.white.withOpacity(0.2)
              : Colors.brown.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: gradient != null ? Colors.white : Colors.brown,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: gradient != null ? Colors.white : textColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: gradient != null
              ? Colors.white.withOpacity(0.8)
              : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: isToggleTile
          ? Switch(
              value: subtitle == 'Enabled', // Assuming subtitle indicates state
              onChanged: onChanged,
              activeColor: Colors.brown,
              activeTrackColor: Colors.brown.withOpacity(0.3),
            )
          : (showBadge
                ? Badge(
                    label: Text(
                      badgeCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: gradient != null ? Colors.white : Colors.grey,
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: gradient != null ? Colors.white : Colors.grey,
                  )),
      onTap: isToggleTile ? null : onTap, // Disable onTap for toggle tiles
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}

Widget buildMenuHeader(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
          letterSpacing: -0.2,
        ),
      ),
    ),
  );
}

Future<void> _performLogout(BuildContext context) async {
  try {
    // Show loading
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Create service instance
    final profileService = BuyerProfileService();

    // 1. Logout via service (clears local storage)
    await profileService.logout();

    // 2. Navigate to login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
      (route) => false,
    );

    print('✅ Logout successful via ProfileService');
  } catch (e) {
    // Close loading
    Navigator.of(context).pop();

    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to sign out?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close dialog first
                        await _performLogout(context); // Call logout function
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
