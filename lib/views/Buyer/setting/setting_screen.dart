import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  bool _darkMode = false;
  bool _biometricAuth = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.brown.shade100, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'App Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customize your WoodMart experience',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.brown.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Account Settings
          _buildSettingsSection('Account Settings', [
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update personal information',
              onTap: _navigateToEditProfile,
              color: Colors.blue,
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update login credentials',
              onTap: _navigateToChangePassword,
              color: Colors.green,
            ),
          ]),

          // Notification Settings
          _buildSettingsSection('Notifications', [
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Enable Notifications',
              subtitle: 'Receive app notifications',
              value: _notificationsEnabled,
              onChanged: (value) =>
                  setState(() => _notificationsEnabled = value),
              color: Colors.purple,
            ),
          ]),

          // App Preferences
          _buildSettingsSection('App Preferences', [
            _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: _language,
              onTap: _showLanguageDialog,
              color: Colors.blue,
            ),

            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Switch to dark theme',
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
              color: Colors.purple,
            ),
          ]),

          // Security & Privacy
          _buildSettingsSection('Security & Privacy', [
            _buildSwitchTile(
              icon: Icons.fingerprint_outlined,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint/Face ID',
              value: _biometricAuth,
              onChanged: (value) => setState(() => _biometricAuth = value),
              color: Colors.blue,
            ),
            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: 'Privacy Settings',
              subtitle: 'Manage data and privacy',
              onTap: _navigateToPrivacySettings,
              color: Colors.green,
            ),
          ]),

          // Data Management
          _buildSettingsSection('Data Management', [
            _buildSettingsTile(
              icon: Icons.delete_outline,
              title: 'Clear Cache',
              subtitle: 'Clear temporary files (124 MB)',
              onTap: _clearCache,
              color: Colors.blue,
            ),
          ]),

          // Account Actions
          _buildSettingsSection('Account Actions', [
            _buildSettingsTile(
              icon: Icons.logout_outlined,
              title: 'Sign Out',
              subtitle: 'Logout from your account',
              onTap: _showLogoutDialog,
              color: Colors.red,
              textColor: Colors.red,
            ),
            _buildSettingsTile(
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              subtitle: 'Permanently remove account',
              onTap: _showDeleteAccountDialog,
              color: Colors.red,
              textColor: Colors.red,
            ),
          ]),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSettingsSection(
    String title,
    List<Widget> children,
  ) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
                letterSpacing: -0.3,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    Color textColor = Colors.black,
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
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildSwitchTile({
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
  void _showLanguageDialog() {
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...['English', 'Spanish', 'French', 'German', 'Chinese', 'Arabic']
                  .map(
                    (language) => ListTile(
                      title: Text(language),
                      trailing: _language == language
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() => _language = language);
                        Navigator.pop(context);
                        _showSnackBar('Language changed to $language');
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.brown,
      ),
    );
  }

  // Placeholder methods
  void _navigateToEditProfile() {}
  void _navigateToChangePassword() {}
  void _navigateToPrivacySettings() {}

  void _clearCache() {}

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAdvancedDialog(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          content: 'Are you sure you want to sign out of your account?',
          confirmText: 'Sign Out',
          confirmColor: Colors.red,
          onConfirm: () {
            Navigator.pop(context);
            _showSnackBar('Signed out successfully');
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAdvancedDialog(
          icon: Icons.delete_forever_rounded,
          title: 'Delete Account',
          content:
              'This will permanently delete your account and all data. This action cannot be undone.',
          confirmText: 'Delete',
          confirmColor: Colors.red,
          onConfirm: () {
            Navigator.pop(context);
            _showSnackBar('Account deletion requested');
          },
        );
      },
    );
  }

  Widget _buildAdvancedDialog({
    required IconData icon,
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: confirmColor, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.brown.shade400, Colors.orange.shade400],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.forest,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'WoodMart',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Premium Wood Marketplace',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                _buildAboutInfo('Version', '1.0.0'),
                _buildAboutInfo('Build', '245'),
                _buildAboutInfo('Release Date', 'Jan 15, 2024'),
                const SizedBox(height: 20),
                const Text(
                  'Your trusted platform for buying and selling\nquality wood products worldwide.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
