// lib/views/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/widgets/advance_appbar.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/basic_tab_conent.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AddProductViewModel(Provider.of(context, listen: false)),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Add Product', showBackButton: false),
        body: const _AddProductContent(),
      ),
    );
  }
}

class _AddProductContent extends StatelessWidget {
  const _AddProductContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<AddProductViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            // Main Content
            Column(
              children: [
                // Tab Bar
                _buildTabBar(viewModel),
                // Content
                Expanded(child: _buildTabContent(viewModel)),
              ],
            ),

            // Bottom Actions - Positioned at the bottom without white background
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomActions(context, viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar(AddProductViewModel viewModel) {
    const tabs = ['Basic', 'Pricing', 'Inventory', 'Variants', 'Media'];

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white, // Keep white background only for tab bar
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            return GestureDetector(
              onTap: () => viewModel.setCurrentTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: viewModel.currentTabIndex == index
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: viewModel.currentTabIndex == index
                        ? Colors.blue
                        : Colors.grey[600],
                    fontWeight: viewModel.currentTabIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent(AddProductViewModel viewModel) {
    switch (viewModel.currentTabIndex) {
      case 0: // Basic
        return const BasicTab();
      case 1: // Pricing
        return const PricingTab();
      case 2: // Inventory
        return const InventoryTab();
      case 3: // Variants
        return const VariantsTab();
      case 4: // Media
        return const MediaTab();
      default:
        return const BasicTab();
    }
  }

  Widget _buildBottomActions(
    BuildContext context,
    AddProductViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent, // Remove white background
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _saveDraft(context, viewModel),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey[300]!),
                backgroundColor:
                    Colors.white, // Add white background to button only
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save Draft',
                      style: TextStyle(color: Colors.black87),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _publishProduct(context, viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightOrange,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Publish',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveDraft(BuildContext context, AddProductViewModel viewModel) async {
    final success = await viewModel.saveDraft();
    if (success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Draft saved successfully')));
    } else if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to save draft'),
        ),
      );
    }
  }

  void _publishProduct(
    BuildContext context,
    AddProductViewModel viewModel,
  ) async {
    final success = await viewModel.publishProduct();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product published successfully')),
      );
      Navigator.of(context).pop();
    } else if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to publish product'),
        ),
      );
    }
  }
}

class PricingTab extends StatelessWidget {
  const PricingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Pricing Tab - Under Development'));
  }
}

class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Inventory Tab - Under Development'));
  }
}

class MediaTab extends StatelessWidget {
  const MediaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Media Tab - Under Development'));
  }
}

class VariantsTab extends StatelessWidget {
  const VariantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Variants Tab - Under Development'));
  }
}
