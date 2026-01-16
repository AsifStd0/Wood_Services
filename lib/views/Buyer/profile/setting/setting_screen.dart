import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Buyer/profile/setting/setting_widget.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _language = 'English';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: locator<BuyerProfileViewProvider>(),
      child: Consumer<BuyerProfileViewProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: CustomAppBar(title: 'Settings'),

            body: CustomScrollView(
              slivers: [
                // Account Settings
                buildSettingsSection('Account Settings', [
                  buildSettingsTile(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    subtitle: 'View & Edit your profile',
                    onTap: () => _viewAndEditProfile(context, provider),
                    color: Colors.blue,
                  ),
                ]),

                // App Preferences
                buildSettingsSection('App Preferences', [
                  buildSettingsTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: _language,
                    onTap: () => _showLanguageDialog(context),
                    color: Colors.blue,
                  ),
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                    },
                    color: Colors.purple,
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // View and Edit Profile Function
  void _viewAndEditProfile(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) {
    final user = provider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No profile data available')),
      );
      return;
    }

    // Create text editing controllers with current data
    final TextEditingController fullNameController = TextEditingController(
      text: provider.fullName,
    );
    final TextEditingController emailController = TextEditingController(
      text: provider.email,
    );
    final TextEditingController businessNameController = TextEditingController(
      text: provider.businessName,
    );
    final TextEditingController addressController = TextEditingController(
      text: provider.address,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: provider.description,
    );
    final TextEditingController ibanController = TextEditingController(
      text: provider.iban,
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
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
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
                              onPressed: () async {
                                if (isEditing) {
                                  // Save data using provider
                                  await _saveProfileData(
                                    context,
                                    provider,
                                    fullName: fullNameController.text,
                                    email: emailController.text,
                                    businessName: businessNameController.text,
                                    address: addressController.text,
                                    description: descriptionController.text,
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

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Image
                              Center(
                                child: GestureDetector(
                                  onTap: isEditing
                                      ? () async {
                                          final XFile? image =
                                              await _imagePicker.pickImage(
                                                source: ImageSource.gallery,
                                                imageQuality: 85,
                                                maxWidth: 800,
                                                maxHeight: 800,
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
                                            : provider.profileImagePath != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  provider.profileImagePath!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return CircleAvatar(
                                                          backgroundColor:
                                                              Colors
                                                                  .brown
                                                                  .shade100,
                                                          child: Text(
                                                            provider
                                                                    .fullName
                                                                    .isNotEmpty
                                                                ? provider
                                                                      .fullName
                                                                      .substring(
                                                                        0,
                                                                        1,
                                                                      )
                                                                      .toUpperCase()
                                                                : 'U',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 36,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .brown,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                ),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.brown.shade100,
                                                child: Text(
                                                  provider.fullName.isNotEmpty
                                                      ? provider.fullName
                                                            .substring(0, 1)
                                                            .toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.brown,
                                                  ),
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
                                    controller: fullNameController,
                                    isEditing: isEditing,
                                  ),
                                  _buildProfileField(
                                    label: 'Email',
                                    controller: emailController,
                                    isEditing: isEditing,
                                    keyboardType: TextInputType.emailAddress,
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
                                    controller: businessNameController,
                                    isEditing: isEditing,
                                  ),
                                  _buildProfileField(
                                    label: 'Address',
                                    controller: addressController,
                                    isEditing: isEditing,
                                    maxLines: 2,
                                  ),
                                  _buildProfileField(
                                    label: 'Description',
                                    controller: descriptionController,
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
                                    label: 'IBAN',
                                    controller: ibanController,
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
    required TextEditingController controller,
    required bool isEditing,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          isEditing
              ? TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.text.isNotEmpty
                        ? controller.text
                        : 'Not provided',
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.text.isNotEmpty
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _saveProfileData(
    BuildContext context,
    BuyerProfileViewProvider provider, {
    required String fullName,
    required String email,
    required String businessName,
    required String address,
    required String description,
    required String iban,
    File? profileImage,
  }) async {
    try {
      // If there's a new profile image, set it first
      if (profileImage != null) {
        provider.setNewProfileImage(profileImage);
      }

      // Call provider to update profile
      final success = await provider.updateProfileData(
        fullName: fullName,
        email: email,
        businessName: businessName,
        address: address,
        description: description,
        iban: iban,
      );

      if (success) {
        // Refresh profile data after update
        await provider.refreshProfile();

        // Show success message and pop back
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Pop back to previous screen
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage ?? 'Failed to update profile',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Language dialog
  Future<void> _showLanguageDialog(BuildContext context) async {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(languages[index]),
                trailing: _language == languages[index]
                    ? const Icon(Icons.check, color: Colors.brown)
                    : null,
                onTap: () {
                  setState(() {
                    _language = languages[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper function to build switch tile
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
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
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.brown,
        ),
        onTap: () => onChanged(!value),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
