import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/SellerAds/create_ad_screen.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/SellerAds/seller_ad_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/SellerAds/seller_ad_widgets.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerAdsScreen extends StatelessWidget {
  const SellerAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerAdProvider(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'My Ads',
          showBackButton: true,
          backgroundColor: AppColors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              tooltip: 'Create Ad',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateAdScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<SellerAdProvider>(
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
                AdsStatisticsBar(provider: provider),

                // Filter Tabs
                AdsFilterBar(provider: provider),

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

  Widget _buildContent(SellerAdProvider provider) {
    if (provider.isLoading && provider.ads.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.hasError && provider.ads.isEmpty) {
      return AdsErrorState(
        message: provider.errorMessage ?? 'An error occurred',
        onRetry: () => provider.loadAds(),
      );
    }

    if (provider.filteredAds.isEmpty) {
      return AdsEmptyState(
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
        return AdsCard(ad: provider.filteredAds[index]);
      },
    );
  }
}
