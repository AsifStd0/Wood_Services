import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_produdt_widget.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/basic_tab_conent.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/inventry.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/media_tab.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/pricing_price.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/varients_tab.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart';

class EditProductContent extends StatelessWidget {
  final String productId;
  final UploadedProductModel productModel;

  const EditProductContent({
    super.key,
    required this.productId,
    required this.productModel,
  });

  List<Widget> get _tabs => [
    BasicTab(key: ValueKey('basic_${productModel.id}')),
    PricingTab(key: ValueKey('pricing_${productModel.id}')),
    InventoryTab(key: ValueKey('inventory_${productModel.id}')),
    VariantsTab(key: ValueKey('variants_${productModel.id}')),
    MediaTab(key: ValueKey('media_${productModel.id}')),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProductProvider>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            // Main Content
            Column(
              children: [
                _buildTabBar(viewModel),
                Expanded(
                  child: IndexedStack(
                    index: viewModel.currentTabIndex,
                    children: _tabs,
                  ),
                ),
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

  Widget _buildTabBar(SellerProductProvider viewModel) {
    const tabs = ['Basic', 'Pricing', 'Inventory', 'Variants', 'Media'];
    const primaryColor = Color(0xFF667EEA);
    const completedColor = Color(0xFF6BCF7F);

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
          children: List.generate(
            tabs.length,
            (index) => _buildTabItem(
              viewModel,
              tabs[index],
              index,
              primaryColor,
              completedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    SellerProductProvider viewModel,
    String title,
    int index,
    Color primaryColor,
    Color completedColor,
  ) {
    final isActive = viewModel.currentTabIndex == index;
    final isCompleted = index < viewModel.currentTabIndex;

    return GestureDetector(
      onTap: () => viewModel.setCurrentTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildTabIndicator(
              isActive,
              isCompleted,
              index,
              primaryColor,
              completedColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive || isCompleted
                    ? primaryColor
                    : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabIndicator(
    bool isActive,
    bool isCompleted,
    int index,
    Color primaryColor,
    Color completedColor,
  ) {
    if (isCompleted) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: completedColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.grey[300],
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
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    SellerProductProvider viewModel,
  ) {
    const primaryColor = Color(0xFF667EEA);

    return Container(
      padding: const EdgeInsets.all(10),
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
            Expanded(child: buildPreviousButton(viewModel)),
          if (viewModel.currentTabIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: viewModel.currentTabIndex == 0 ? 2 : 1,
            child: viewModel.currentTabIndex == 4
                ? buildUpdateButton(context, viewModel, primaryColor)
                : buildContinueButton(context, viewModel, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget buildUpdateButton(
    BuildContext context,
    SellerProductProvider viewModel,
    Color primaryColor,
  ) {
    return ElevatedButton(
      onPressed: viewModel.isLoading
          ? null
          : () async {
              log('Data is here ${viewModel.product.toJson()}');

              // Validate media tab before updating
              if (viewModel.selectedImages.isEmpty &&
                  viewModel.existingImageUrls.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please upload at least one product image'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final success = await viewModel.updateProduct();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Product updated successfully'
                          : viewModel.errorMessage ??
                                'Failed to update product',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) {
                  Navigator.pop(
                    context,
                    true,
                  ); // Return true to indicate refresh needed
                }
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: viewModel.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Update Product',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
    );
  }
}
