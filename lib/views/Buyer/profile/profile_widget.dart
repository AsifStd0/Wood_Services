import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_test_style.dart';

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

// Quick Actions Section
Widget buildQuickActions() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    margin: EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText('Quick Actions', type: CustomTextType.activityHeading),

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(Icons.add_card, 'Add Payment', Colors.green),
            _buildQuickActionItem(
              Icons.location_on,
              'Add Address',
              Colors.blue,
            ),

            _buildQuickActionItem(Icons.help_center, 'Support', Colors.purple),
          ],
        ),
      ],
    ),
  );
}

Widget _buildQuickActionItem(IconData icon, String label, Color color) {
  return Column(
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[700],
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
}) {
  return Container(
    // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      trailing: showBadge
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
            ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
