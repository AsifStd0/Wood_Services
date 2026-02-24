import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Admin/admin_ad_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Admin/admin_ad_widgets.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class AdminAdsScreen extends StatelessWidget {
  const AdminAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminAdProvider(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Ads Management',
          showBackButton: true,
          backgroundColor: AppColors.white,
        ),
        body: Consumer<AdminAdProvider>(
          builder: (context, provider, child) {
            // Load ads on first build
            if (provider.ads.isEmpty && !provider.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.loadAds();
              });
            }

            return Column(
              children: [
                // Statistics Bar
                AdminAdsStatisticsBar(provider: provider),

                // Filter Tabs
                AdminAdsFilterBar(provider: provider),

                // Ads List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.refresh(),
                    color: AppColors.primary,
                    child: _buildContent(provider),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(AdminAdProvider provider) {
    if (provider.isLoading && provider.ads.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.hasError && provider.ads.isEmpty) {
      return AdminAdsErrorState(
        message: provider.errorMessage ?? 'An error occurred',
        onRetry: () => provider.loadAds(),
      );
    }

    if (provider.filteredAds.isEmpty) {
      return AdminAdsEmptyState(
        statusFilter: provider.statusFilter,
        onViewAll: provider.statusFilter != null
            ? () => provider.setStatusFilter(null)
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.filteredAds.length,
      itemBuilder: (context, index) {
        return AdminAdCard(ad: provider.filteredAds[index]);
      },
    );
  }
}
