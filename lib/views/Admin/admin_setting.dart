import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection('General Settings', [
            _buildSettingsItem('App Configuration', Icons.settings, () {}),
            _buildSettingsItem(
              'Notification Settings',
              Icons.notifications,
              () {},
            ),
            _buildSettingsItem('Commission Rates', Icons.percent, () {}),
          ]),

          const SizedBox(height: 24),

          _buildSettingsSection('Security', [
            _buildSettingsItem('Change Password', Icons.lock, () {}),
            _buildSettingsItem(
              'Admin Users',
              Icons.admin_panel_settings,
              () {},
            ),
            _buildSettingsItem('Activity Log', Icons.history, () {}),
          ]),

          const SizedBox(height: 24),

          _buildSettingsSection('Backup & Data', [
            _buildSettingsItem('Export Data', Icons.backup, () {}),
            _buildSettingsItem('Database Management', Icons.storage, () {}),
            _buildSettingsItem('Clear Cache', Icons.cleaning_services, () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Card(child: Column(children: items)),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
