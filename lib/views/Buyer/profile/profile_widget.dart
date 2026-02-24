import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Buyer/order_screen/order_screen.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';
import 'package:wood_service/views/splash/splash_screen.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_screen.dart';

/// Profile Header Widget
/// Displays user avatar, name, email, and status badge
class ProfileHeaderWidget extends StatelessWidget {
  final UserModel user;
  final BuyerProfileViewProvider provider;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = provider.profileImagePath ?? user.profileImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAvatarPlaceholder(user.name);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.extraLightGrey,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : _buildAvatarPlaceholder(user.name),
              ),
              // Status Badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: user.isActive == true
                        ? AppColors.success
                        : AppColors.warning,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(
                    user.isActive == true
                        ? Icons.verified_rounded
                        : Icons.pending_rounded,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        provider.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (provider.businessName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          provider.businessName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                // Status Badge Text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isActive == true
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive == true ? 'Active' : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: user.isActive == true
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Menu Section Widget
/// Displays organized menu items
class ProfileMenuSection extends StatelessWidget {
  final BuildContext context;
  final BuyerProfileViewProvider provider;

  const ProfileMenuSection({
    super.key,
    required this.context,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Orders & Requests
          _buildMenuHeader('Orders & Requests'),
          _buildMenuTile(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'Track your purchases',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const OrdersScreen()));
            },
          ),
          _buildMenuTile(
            icon: Icons.calendar_today_outlined,
            title: 'Visit Requests',
            subtitle: 'Manage your visit requests',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BuyerVisitRequestScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          // Account Settings
          _buildMenuHeader('Account Settings'),
          _buildMenuTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => EditProfileSheet(provider: provider),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            subtitle: 'Manage delivery addresses',
            onTap: () {},
          ),
          _buildMenuTile(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Cards and payment options',
            onTap: () {},
          ),
          const Divider(height: 1),
          // Preferences
          _buildMenuHeader('Preferences'),
          _buildMenuTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: provider.language,
            onTap: () {
              _showLanguageDialog(context, provider);
            },
          ),
          _buildMenuTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: provider.darkMode ? 'Enabled' : 'Disabled',
            onTap: null,
            onChanged: (value) => provider.setDarkMode(value),
            isToggle: true,
          ),
          const Divider(height: 1),
          // Support
          _buildMenuHeader('Support'),
          _buildMenuTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'FAQs and support',
            onTap: () {},
          ),
          _buildMenuTile(
            icon: Icons.contact_support_outlined,
            title: 'Contact Us',
            subtitle: 'Get in touch with us',
            onTap: () {},
          ),
          const Divider(height: 1),
          // Account Actions
          _buildMenuHeader('Account'),
          _buildMenuTile(
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            subtitle: 'Logout from your account',
            onTap: () => _showLogoutDialog(context, provider),
            iconColor: AppColors.error,
            textColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    ValueChanged<bool>? onChanged,
    bool isToggle = false,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: isToggle
            ? Switch(
                value: subtitle == 'Enabled',
                onChanged: onChanged,
                activeColor: AppColors.primary,
              )
            : Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
        onTap: isToggle ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to sign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.lightGrey),
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
                          Navigator.of(context).pop();
                          await _performLogout(context, provider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
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

  Future<void> _performLogout(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await provider.logout();
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
      }

      if (success && context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Logout failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(languages[index]),
                trailing: provider.language == languages[index]
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  provider.setLanguage(languages[index]);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${languages[index]}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Edit Profile Bottom Sheet Widget
class EditProfileSheet extends StatefulWidget {
  final BuyerProfileViewProvider provider;

  const EditProfileSheet({super.key, required this.provider});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _ibanController;

  bool _isEditing = false;
  File? _tempProfileImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final provider = widget.provider;
    _nameController = TextEditingController(text: provider.fullName);
    _emailController = TextEditingController(text: provider.email);
    _businessNameController = TextEditingController(
      text: provider.businessName,
    );
    _addressController = TextEditingController(text: provider.address);
    _descriptionController = TextEditingController(text: provider.description);
    _ibanController = TextEditingController(text: provider.iban);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.2),
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
                  color: AppColors.lightGrey,
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
                          _isEditing ? Icons.edit : Icons.person,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isEditing ? 'Edit Profile' : 'My Profile',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: AppColors.primary,
                      ),
                      onPressed: () async {
                        if (_isEditing) {
                          await _saveProfile(context);
                        } else {
                          setState(() {
                            _isEditing = true;
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
                      _buildProfileImage(),
                      const SizedBox(height: 24),
                      _buildSection(
                        'Personal Information',
                        Icons.person_outline,
                        [
                          _buildField('Full Name', _nameController),
                          _buildField(
                            'Email',
                            _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                      _buildSection(
                        'Business Information',
                        Icons.business_outlined,
                        [
                          _buildField('Business Name', _businessNameController),
                          _buildField(
                            'Address',
                            _addressController,
                            maxLines: 2,
                          ),
                          _buildField(
                            'Description',
                            _descriptionController,
                            maxLines: 3,
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
  }

  Widget _buildProfileImage() {
    final provider = widget.provider;
    final profileImageUrl = provider.profileImagePath;

    return Center(
      child: GestureDetector(
        onTap: _isEditing ? _pickImage : null,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primaryLight.withOpacity(0.2),
                  ],
                ),
              ),
              child: _tempProfileImage != null
                  ? ClipOval(
                      child: Image.file(_tempProfileImage!, fit: BoxFit.cover),
                    )
                  : profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                  : _buildImagePlaceholder(),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.provider.fullName.isNotEmpty
              ? widget.provider.fullName.substring(0, 1).toUpperCase()
              : 'U',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
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
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          _isEditing
              ? TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
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
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Text(
                    controller.text.isNotEmpty
                        ? controller.text
                        : 'Not provided',
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.text.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _tempProfileImage = File(image.path);
        });
      }
    } catch (e) {
      log('❌ Error picking image: $e');
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    try {
      // Set profile image if selected
      if (_tempProfileImage != null) {
        widget.provider.setNewProfileImage(_tempProfileImage!);
      }

      // Update profile data (includes image if set)
      final success = await widget.provider.updateProfileData(
        fullName: _nameController.text,
        email: _emailController.text,
        businessName: _businessNameController.text,
        address: _addressController.text,
        description: _descriptionController.text,
        iban: _ibanController.text,
      );

      if (context.mounted) {
        if (success) {
          await widget.provider.refreshProfile();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.provider.errorMessage ?? 'Failed to update profile',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
