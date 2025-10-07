import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/data/models/product_feature.dart';
import 'package:wood_service/views/home/home_widgets.dart';

class FurniHomeScreen extends StatelessWidget {
  const FurniHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const AppLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PromoBanner(),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Categories', actionText: 'view all'),
            const SizedBox(height: 12),
            const CategoriesList(),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Featured Products',
              actionText: 'view all',
            ),
            const SizedBox(height: 12),
            //     ProductsHorizontalList(
            //   products: AppData.featuredProducts,
            //   context: context, // Pass the context here
            // ),
            ProductsHorizontalList(
              products: AppData.featuredProducts,
              onProductTap: (productId) {
                context.push('/productDetail/$productId');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
