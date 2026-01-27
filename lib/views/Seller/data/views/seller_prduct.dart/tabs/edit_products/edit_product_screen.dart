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
  @override
  void initState() {
    super.initState();
    // Load product data immediately from model, then fetch full data from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerProductProvider>();
      // First, load data from model immediately (so tabs show data right away)
      provider.loadProductFromModel(widget.productModel);
      // Then, fetch full data from API in background (for salePrice, costPrice, etc.)
      provider.loadProductForEditing(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerProductProvider(
        productService: locator<UploadedProductService>(),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Edit Product',
          showBackButton: true,
          backgroundColor: Colors.white,
        ),
        body: Consumer<SellerProductProvider>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.product.title.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null && !viewModel.isEditMode) {
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
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
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
