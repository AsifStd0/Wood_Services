import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/profile/profile_widget.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_model.dart';
import 'package:wood_service/views/visit_request_buyer_resp/visit_screen.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class ProfileScreenBuyer extends StatefulWidget {
  const ProfileScreenBuyer({super.key});

  @override
  State<ProfileScreenBuyer> createState() => _ProfileScreenBuyerState();
}

class _ProfileScreenBuyerState extends State<ProfileScreenBuyer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      _refreshData();
    }
  }

  void _refreshData() {
    final provider = context.read<BuyerProfileViewProvider>();
    provider.refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => locator<BuyerProfileViewProvider>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(title: 'Profile', showBackButton: false),
        body: Consumer<BuyerProfileViewProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!provider.isLoggedIn) {
              return CircularProgressIndicator();
            }

            return _buildProfileContent(context, provider);
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) {
    final user = provider.currentUser!;
    return RefreshIndicator(
      onRefresh: () async {
        await provider.refreshProfile();
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              // User Header Section with REAL DATA
              _buildUserHeader(user, provider),
              const SizedBox(height: 20),

              // // Stats Section
              // _buildStatsSection(provider),
              // const SizedBox(height: 20),

              // Main Menu Section
              _buildMenuSection(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  // BuyerProfileViewProvider
  Widget _buildUserHeader(UserModel user, BuyerProfileViewProvider provider) {
    // Use provider's profileImagePath for consistency with settings screen
    final profileImageUrl = provider.profileImagePath ?? user.profileImage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.brown.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Avatar
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.brown.shade400, Colors.orange.shade400],
                      ),
                    ),
                    child:
                        (profileImageUrl != null && profileImageUrl.isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.brown.shade100,
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.brown.shade100,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                            ),
                          )
                        : CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.brown.shade100,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                  ),

                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pending,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      provider.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    if (provider.businessName.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            provider.businessName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // // Enhanced Stats Section
  // Widget _buildStatsSection(BuyerProfileViewProvider provider) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           blurRadius: 15,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         const Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             CustomText('Activity ', type: CustomTextType.activityHeading),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             buildStatItem('12', 'Orders', Icons.shopping_bag),
  //             buildStatItem('8', 'Favorites', Icons.favorite),
  //             buildStatItem('4', 'Reviews', Icons.star),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Enhanced Main Menu Section
  Widget _buildMenuSection(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) {
    return Container(
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
        children: [
          // BuyerVisitRequestScreen
          // Orders & Purchases
          buildMenuHeader('Orders & Visit Requests Management'),
          buildMenuTile(
            context: context,
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'Track purchases and returns',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return OrdersScreen();
                  },
                ),
              );
            },
            // ! *******
          ),
          buildMenuTile(
            context: context,
            icon: Icons.shopping_bag_outlined,
            title: 'My Visit Requests',
            subtitle: 'Track visit requests and status',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return BuyerVisitRequestScreen();
                  },
                ),
              );
            },
          ),

          buildMenuTile(
            context: context,
            icon: Icons.assignment_return_outlined,
            title: 'Returns & Refunds',
            subtitle: 'Manage returns and refund requests',
            onTap: () {},
            // gradient: [Colors.orange.shade400, Colors.orange.shade600],
          ),

          const Divider(height: 20),

          // Account & Preferences
          buildMenuHeader('Account & Preferences'),

          buildMenuTile(
            context: context,
            icon: Icons.person_outline,
            title: 'My Profile',
            subtitle: 'View & Edit your profile',
            onTap: () => _viewAndEditProfile(context, provider),
          ),
          buildMenuTile(
            context: context,
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Cards, wallets, and payment options',
            onTap: () {},
            // gradient: [Colors.teal.shade400, Colors.teal.shade600],
          ),
          buildMenuTile(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            subtitle: 'Delivery and billing addresses',
            onTap: () {},
            // gradient: [Colors.red.shade400, Colors.red.shade600],
          ),

          const Divider(height: 20),

          // App Preferences
          buildMenuHeader('App Preferences'),
          buildMenuTile(
            context: context,
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: provider.language,
            onTap: () => _showLanguageDialog(context, provider),
          ),
          buildMenuTile(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: provider.darkMode ? 'Enabled' : 'Disabled',
            onTap: () => provider.setDarkMode(!provider.darkMode),
            onChanged: (value) => provider.setDarkMode(value),
          ),

          const Divider(height: 20),

          // Support & Information
          buildMenuHeader('Support & Information'),
          buildMenuTile(
            context: context,
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'FAQs and support articles',
            onTap: () {},
            // gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
          ),
          buildMenuTile(
            context: context,
            icon: Icons.contact_support_outlined,
            title: 'Contact Support',
            subtitle: '24/7 customer service',
            onTap: () {},
            // gradient: [Colors.pink.shade400, Colors.pink.shade600],
          ),
          buildMenuTile(
            context: context,
            icon: Icons.info_outline,
            title: 'About WoodMart',
            subtitle: 'App version 1.0.0',
            onTap: () {},
            // gradient: [Colors.cyan.shade400, Colors.cyan.shade600],
          ),

          const Divider(height: 20),

          // Account Actions
          buildMenuHeader('Account Actions'),
          buildMenuTile(
            context: context,
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            subtitle: 'Logout from your account',
            onTap: () => showLogoutDialog(context, provider),
            iconColor: Colors.red,
            textColor: Colors.red,
            // gradient: [Colors.red.shade400, Colors.red.shade600],
          ),
          buildMenuTile(
            context: context,
            icon: Icons.logout_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently remove account',
            onTap: () => showLogoutDialog(context, provider),
            iconColor: Colors.red,
            textColor: Colors.red,
            // gradient: [Colors.red.shade400, Colors.red.shade600],
          ),
        ],
      ),
    );
  }

  // View and Edit Profile Function (from settings screen)
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
    final ImagePicker _imagePicker = ImagePicker();

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

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
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
  Future<void> _showLanguageDialog(
    BuildContext context,
    BuyerProfileViewProvider provider,
  ) async {
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
                trailing: provider.language == languages[index]
                    ? const Icon(Icons.check, color: Colors.brown)
                    : null,
                onTap: () {
                  provider.setLanguage(languages[index]);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${languages[index]}'),
                      backgroundColor: Colors.green,
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
