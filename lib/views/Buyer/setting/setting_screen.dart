import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:wood_service/widgets/custom_appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _language = 'English';

  // Add variables for user data
  Map<String, dynamic> _userData = {};
  String? _profileImageBase64;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: 'Settings'),

      body: CustomScrollView(
        slivers: [
          // Add Profile Summary Section (from signup data)
          _buildProfileSummarySection(),

          // Account Settings - REMOVED "Edit Profile" and "View Profile" - combined into one
          _buildSettingsSection('Account Settings', [
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'My Profile',
              subtitle: 'View & Edit your profile',
              onTap: _viewAndEditProfile, // Combined function
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

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // Add Profile Summary Section
  SliverToBoxAdapter _buildProfileSummarySection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _viewAndEditProfile, // Tap profile image to edit
                  child: Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.brown.shade300,
                              Colors.orange.shade300,
                            ],
                          ),
                        ),
                        child: _profileImageBase64 != null
                            ? ClipOval(
                                child: Image.memory(
                                  base64Decode(_profileImageBase64!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.brown.shade100,
                                child: _userData['fullName'] != null
                                    ? Text(
                                        _userData['fullName']
                                            .toString()
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.brown,
                                      ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 12,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData['fullName'] ?? 'John Cena',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      if (_userData['email'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _userData['email']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      if (_userData['businessName'] != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            _userData['businessName']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_note, color: Colors.brown),
                  onPressed: _viewAndEditProfile,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick Info Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                if (_userData['contactName'] != null)
                  _buildInfoChip(
                    icon: Icons.contact_page,
                    label: 'Contact',
                    value: _userData['contactName']!,
                  ),
                if (_userData['address'] != null &&
                    _userData['address']!.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: _userData['address']!.length > 20
                        ? '${_userData['address']!.substring(0, 20)}...'
                        : _userData['address']!,
                  ),
                if (_userData['bankName'] != null)
                  _buildInfoChip(
                    icon: Icons.account_balance,
                    label: 'Bank',
                    value: _userData['bankName']!,
                  ),
                if (_userData['iban'] != null)
                  _buildInfoChip(
                    icon: Icons.credit_card,
                    label: 'IBAN',
                    value:
                        '****${_userData['iban']!.substring(_userData['iban']!.length - 4)}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return GestureDetector(
      onTap: _viewAndEditProfile, // Tap any info chip to edit
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.brown),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.brown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
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
    bool showData = false,
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
          style: TextStyle(
            color: showData ? Colors.brown : Colors.grey[600],
            fontSize: showData ? 13 : 12,
            fontWeight: showData ? FontWeight.w500 : FontWeight.normal,
          ),
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

  // COMBINED: View and Edit Profile Function
  void _viewAndEditProfile() {
    // Create text editing controllers with current data
    final TextEditingController fullNameController = TextEditingController(
      text: _userData['fullName'] ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: _userData['email'] ?? '',
    );
    final TextEditingController contactNameController = TextEditingController(
      text: _userData['contactName'] ?? '',
    );
    final TextEditingController businessNameController = TextEditingController(
      text: _userData['businessName'] ?? '',
    );
    final TextEditingController addressController = TextEditingController(
      text: _userData['address'] ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: _userData['description'] ?? '',
    );
    final TextEditingController bankNameController = TextEditingController(
      text: _userData['bankName'] ?? '',
    );
    final TextEditingController ibanController = TextEditingController(
      text: _userData['iban'] ?? '',
    );

    bool isEditing = false;
    File? tempProfileImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isEditing ? Icons.edit : Icons.person,
                                  color: Colors.brown,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isEditing ? 'Edit Profile' : 'My Profile',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                isEditing ? Icons.save : Icons.edit,
                                color: Colors.brown,
                              ),
                              onPressed: () {
                                if (isEditing) {
                                  // Save data
                                  _saveProfileData(
                                    fullName: fullNameController.text,
                                    email: emailController.text,
                                    contactName: contactNameController.text,
                                    businessName: businessNameController.text,
                                    address: addressController.text,
                                    description: descriptionController.text,
                                    bankName: bankNameController.text,
                                    iban: ibanController.text,
                                    profileImage: tempProfileImage,
                                  );
                                  Navigator.pop(context);
                                } else {
                                  setModalState(() {
                                    isEditing = true;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Image with Edit Option
                              Center(
                                child: GestureDetector(
                                  onTap: isEditing
                                      ? () async {
                                          final XFile? image =
                                              await _imagePicker.pickImage(
                                                source: ImageSource.gallery,
                                              );
                                          if (image != null) {
                                            setModalState(() {
                                              tempProfileImage = File(
                                                image.path,
                                              );
                                            });
                                          }
                                        }
                                      : null,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.brown.shade300,
                                              Colors.orange.shade300,
                                            ],
                                          ),
                                        ),
                                        child: tempProfileImage != null
                                            ? ClipOval(
                                                child: Image.file(
                                                  tempProfileImage!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : _profileImageBase64 != null
                                            ? ClipOval(
                                                child: Image.memory(
                                                  base64Decode(
                                                    _profileImageBase64!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.brown.shade100,
                                                child:
                                                    _userData['fullName'] !=
                                                        null
                                                    ? Text(
                                                        _userData['fullName']
                                                            .toString()
                                                            .substring(0, 1)
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                          fontSize: 36,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.brown,
                                                        ),
                                                      )
                                                    : const Icon(
                                                        Icons.person,
                                                        size: 40,
                                                        color: Colors.brown,
                                                      ),
                                              ),
                                      ),
                                      if (isEditing)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              size: 18,
                                              color: Colors.brown,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Personal Information
                              _buildProfileSection(
                                'Personal Information',
                                Icons.person_outline,
                                isEditing,
                                [
                                  _buildProfileField(
                                    label: 'Full Name',
                                    value: fullNameController,
                                    isEditing: isEditing,
                                  ),
                                  _buildProfileField(
                                    label: 'Email',
                                    value: emailController,
                                    isEditing: isEditing,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  _buildProfileField(
                                    label: 'Contact Name',
                                    value: contactNameController,
                                    isEditing: isEditing,
                                  ),
                                ],
                              ),

                              // Business Information
                              _buildProfileSection(
                                'Business Information',
                                Icons.business_outlined,
                                isEditing,
                                [
                                  _buildProfileField(
                                    label: 'Business Name',
                                    value: businessNameController,
                                    isEditing: isEditing,
                                  ),
                                  _buildProfileField(
                                    label: 'Address',
                                    value: addressController,
                                    isEditing: isEditing,
                                    maxLines: 2,
                                  ),
                                  _buildProfileField(
                                    label: 'Description',
                                    value: descriptionController,
                                    isEditing: isEditing,
                                    maxLines: 3,
                                  ),
                                ],
                              ),

                              // Bank Details
                              _buildProfileSection(
                                'Bank Details',
                                Icons.account_balance_outlined,
                                isEditing,
                                [
                                  _buildProfileField(
                                    label: 'Bank Name',
                                    value: bankNameController,
                                    isEditing: isEditing,
                                  ),
                                  _buildProfileField(
                                    label: 'IBAN',
                                    value: ibanController,
                                    isEditing: isEditing,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProfileSection(
    String title,
    IconData icon,
    bool isEditing,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.brown, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController value,
    required bool isEditing,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          isEditing
              ? TextFormField(
                  controller: value,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                )
              : Text(
                  value.text.isEmpty ? 'Not set' : value.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _saveProfileData({
    required String fullName,
    required String email,
    required String contactName,
    required String businessName,
    required String address,
    required String description,
    required String bankName,
    required String iban,
    File? profileImage,
  }) async {
    // Update user data
    final updatedData = {
      'fullName': fullName,
      'email': email,
      'contactName': contactName,
      'businessName': businessName,
      'address': address,
      'description': description,
      'bankName': bankName,
      'iban': iban,
    };

    // Update local state
    setState(() {
      _userData = updatedData;
      if (profileImage != null) {}
    });

    _showSnackBar('Profile updated successfully');
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

  // Placeholder method
  void _navigateToChangePassword() {}
}
