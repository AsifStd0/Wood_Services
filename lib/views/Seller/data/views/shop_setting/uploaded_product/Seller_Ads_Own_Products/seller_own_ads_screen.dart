import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Seller_Ads_Own_Products/seller_own_ad_provider.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Seller_Ads_Own_Products/seller_own_ad_widgets.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class SellerOwnAdsScreen extends StatefulWidget {
  const SellerOwnAdsScreen({super.key});

  @override
  State<SellerOwnAdsScreen> createState() => _SellerOwnAdsScreenState();
}

class _SellerOwnAdsScreenState extends State<SellerOwnAdsScreen> {
  bool _initialLoadTriggered = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerOwnAdProvider(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'My Product Ads',
          showBackButton: true,
          backgroundColor: AppColors.white,
        ),
        body: Consumer<SellerOwnAdProvider>(
          builder: (context, provider, child) {
            // Load ads on first build only
            if (!_initialLoadTriggered &&
                provider.ads.isEmpty &&
                !provider.isLoading) {
              _initialLoadTriggered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && context.mounted) {
                  provider.loadAds();
                }
              });
            }

            return Column(
              children: [
                // Statistics Bar
                ProductAdsStatisticsBar(provider: provider),

                // Filter Tabs
                ProductAdsFilterBar(provider: provider),

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

  Widget _buildContent(SellerOwnAdProvider provider) {
    if (provider.isLoading && provider.ads.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.hasError && provider.ads.isEmpty) {
      return ProductAdsErrorState(
        message: provider.errorMessage ?? 'An error occurred',
        onRetry: () => provider.loadAds(),
      );
    }

    if (provider.filteredAds.isEmpty) {
      return ProductAdsEmptyState(
        statusFilter: provider.statusFilter,
        onViewAll: provider.statusFilter != null
            ? () => provider.setStatusFilter(null)
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.filteredAds.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.filteredAds.length) {
          // Load more trigger
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                context.mounted &&
                provider.hasMore &&
                !provider.isLoading) {
              provider.loadMore();
            }
          });
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ProductAdCard(ad: provider.filteredAds[index]);
      },
    );
  }
}
