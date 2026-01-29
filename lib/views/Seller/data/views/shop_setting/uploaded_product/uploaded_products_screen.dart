// screens/uploaded_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/my_product_widget.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/uploaded_product_provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class UploadedProductsScreen extends StatefulWidget {
  const UploadedProductsScreen({super.key});

  @override
  State<UploadedProductsScreen> createState() => _UploadedProductsScreenState();
}

class _UploadedProductsScreenState extends State<UploadedProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _initialLoadTriggered = false;

  @override
  void initState() {
    super.initState();

    // Load more on scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (mounted) {
        final provider = context.read<UploadedProductProvider>();
        if (provider.hasMore && !provider.isLoading) {
          provider.loadMore();
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => locator<UploadedProductProvider>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: 'My Uploaded Products',
          showBackButton: true,
          backgroundColor: Colors.white,
        ),
        body: Consumer<UploadedProductProvider>(
          builder: (context, provider, child) {
            // Load products automatically when screen is first shown
            if (!_initialLoadTriggered &&
                provider.products.isEmpty &&
                !provider.isLoading) {
              _initialLoadTriggered = true;
              // Use Future.microtask to avoid calling setState during build
              Future.microtask(() {
                if (mounted) {
                  provider.loadProducts(status: null);
                }
              });
            }

            return RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: Column(
                children: [
                  // Products list
                  Expanded(child: _buildContent(provider)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(UploadedProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.isEmpty) {
      return buildEmptyState(provider);
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.60,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        return buildProductUploadCard(
          provider.products[index],
          provider,
          context,
        );
      },
    );
  }
}
