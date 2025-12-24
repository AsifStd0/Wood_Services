import 'package:flutter/material.dart';

Widget buildSwitchTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          activeTrackColor: color.withOpacity(0.3),
        ),
      ),
      onTap: () => onChanged(!value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}

// Enhanced Dialog Methods
showLanguageDialog(context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.language, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Language',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ...['English', 'Spanish', 'French', 'German', 'Chinese', 'Arabic']
                .map(
                  (language) => ListTile(
                    title: Text(language),
                    trailing:
                        //  _language == language
                        // ?
                        const Icon(Icons.check, color: Colors.green),
                    // : null,
                    onTap: () {
                      // setState(() => _language = language);
                      // Navigator.pop(context);
                      // _showSnackBar('Language changed to $language');
                    },
                  ),
                )
                .toList(),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
