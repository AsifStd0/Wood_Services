import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/profile/profile_provider.dart';
import 'package:wood_service/views/Buyer/profile/profile_widget.dart';
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
        appBar: CustomAppBar(title: 'Profile', showBackButton: false),
        body: Consumer<BuyerProfileViewProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.currentUser == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!provider.isLoggedIn) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = provider.currentUser!;
            return _buildProfileContent(context, provider, user);
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    BuyerProfileViewProvider provider,
    user,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.refreshProfile();
      },
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(user: user, provider: provider),
            const SizedBox(height: 20),

            // Menu Section
            ProfileMenuSection(context: context, provider: provider),
          ],
        ),
      ),
    );
  }
}
