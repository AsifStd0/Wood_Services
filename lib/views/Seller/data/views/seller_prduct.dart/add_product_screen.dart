// lib/views/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/varients_tab.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/inventry.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/media_tab.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/pricing_price.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/basic_tab_conent.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AddProductViewModel(Provider.of(context, listen: false)),
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Add New Product',
          showBackButton: false,
          backgroundColor: Colors.white,
        ),
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
                // Progress Indicator
                _buildProgressIndicator(viewModel),

                // Tab Bar
                _buildTabBar(viewModel),

                // Content
                Expanded(child: _buildTabContent(viewModel)),
              ],
            ),

            // Bottom Actions
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

  Widget _buildProgressIndicator(AddProductViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Setup',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${viewModel.currentTabIndex + 1}/5',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedFractionallySizedBox(
              duration: Duration(milliseconds: 500),
              alignment: Alignment.centerLeft,
              widthFactor: (viewModel.currentTabIndex + 1) / 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AddProductViewModel viewModel) {
    const tabs = ['Basic', 'Pricing', 'Inventory', 'Variants', 'Media'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isActive = viewModel.currentTabIndex == index;
            final isCompleted = index < viewModel.currentTabIndex;

            return GestureDetector(
              onTap: () => viewModel.setCurrentTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? Color(0xFF667EEA) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (isCompleted)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xFF6BCF7F),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    else
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Color(0xFF667EEA)
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      tabs[index],
                      style: TextStyle(
                        color: isActive || isCompleted
                            ? Color(0xFF667EEA)
                            : Colors.grey[600],
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (viewModel.currentTabIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.setCurrentTab(
                        viewModel.currentTabIndex - 1,
                      ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (viewModel.currentTabIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: viewModel.currentTabIndex == 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _handleNextAction(context, viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: Color(0xFF667EEA).withOpacity(0.3),
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          viewModel.currentTabIndex == 4
                              ? 'Publish Product'
                              : 'Continue',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (viewModel.currentTabIndex < 4)
                          const SizedBox(width: 8),
                        if (viewModel.currentTabIndex < 4)
                          Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextAction(BuildContext context, AddProductViewModel viewModel) {
    if (viewModel.currentTabIndex < 4) {
      viewModel.setCurrentTab(viewModel.currentTabIndex + 1);
    } else {
      _publishProduct(context, viewModel);
    }
  }

  void _publishProduct(
    BuildContext context,
    AddProductViewModel viewModel,
  ) async {
    final success = await viewModel.publishProduct();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product published successfully'),
          backgroundColor: Color(0xFF6BCF7F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).pop();
    } else if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to publish product'),
          backgroundColor: Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
