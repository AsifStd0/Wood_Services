// lib/views/Seller/data/views/seller_prduct.dart/edit_product_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/tabs/edit_products/edit_product_content.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_services.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class EditProductScreen extends StatefulWidget {
  final UploadedProductModel productModel;
  final String productId;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.productModel,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final SellerProductProvider _provider;

  @override
  void initState() {
    super.initState();
    // Create provider instance
    _provider = SellerProductProvider(
      productService: locator<UploadedProductService>(),
    );

    // Load product data immediately from model (synchronously, before first build)
    // This ensures fields are populated when the UI first renders
    _provider.loadProductFromModel(widget.productModel);

    // Then, fetch full data from API in background (for salePrice, costPrice, etc.)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadProductForEditing(widget.productId);
    });
  }

  @override
  void dispose() {
    // Don't dispose the provider here as it's managed by Provider
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Edit Product',
          showBackButton: true,
          backgroundColor: Colors.white,
        ),
        body: Consumer<SellerProductProvider>(
          builder: (context, viewModel, child) {
            // Show loading only if we don't have any data yet
            if (viewModel.isLoading &&
                viewModel.product.title.isEmpty &&
                !viewModel.isEditMode) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error only if we failed to load and have no data
            if (viewModel.errorMessage != null &&
                !viewModel.isEditMode &&
                viewModel.product.title.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.loadProductForEditing(widget.productId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return EditProductContent(
              productId: widget.productId,
              productModel: widget.productModel,
            );
          },
        ),
      ),
    );
  }
}
