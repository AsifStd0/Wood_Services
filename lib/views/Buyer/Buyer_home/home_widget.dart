import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/favorite_button.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
import 'package:wood_service/views/Buyer/product_detail/product_detail.dart';
import 'package:wood_service/widgets/custom_button.dart';

Widget buildCategoryChip(
  String text, {
  bool isSelected = false,
  VoidCallback? onTap,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xffEDC064) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Color(0xffEDC064)
              : Theme.of(context).colorScheme.onSurface,
          // color: isSelected ? Color(0xffEDC064) : Colors.black,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          // color: Colors.black,
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget buildNewSection() {
  return Consumer<BuyerHomeViewProvider>(
    builder: (context, viewModel, child) {
      List<List<String>> chunks = [];
      for (int i = 0; i < viewModel.allOptions.length; i += 2) {
        chunks.add(
          viewModel.allOptions.sublist(
            i,
            i + 2 > viewModel.allOptions.length
                ? viewModel.allOptions.length
                : i + 2,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: CustomText(
              'NEW',
              color: Theme.of(context).colorScheme.onSurface,
              type: CustomTextType.subtitleMedium15bold,
            ),
          ),
          _buildImagesRow(),

          // const SizedBox(height: 3),
          Column(
            children: chunks.map((chunk) {
              return Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 3),
                child: Row(
                  children: chunk.map((option) {
                    return Expanded(
                      child: Padding(
                        padding: chunk.indexOf(option) == 0
                            ? const EdgeInsets.only(right: 5)
                            : const EdgeInsets.only(left: 5),
                        child: _buildProductCategoryChip(
                          option,
                          isSelected: viewModel.isSelected(option),
                          onTap: () => viewModel.selectOption(option),
                          context: context,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      );
    },
  );
}

Widget _buildProductCategoryChip(
  String text, {
  bool isSelected = false,
  VoidCallback? onTap,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.yellowLight
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: 1,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget _buildImagesRow() {
  return Row(
    children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10), // circular shape
          child: Container(
            height: 70,
            color: Colors.grey[300],
            child: Image.asset('assets/images/sofa.jpg', fit: BoxFit.cover),
          ),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 70,
            color: Colors.grey[300],
            child: Image.asset('assets/images/table2.jpg', fit: BoxFit.cover),
          ),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 70,
            color: Colors.grey[300],
            child: Image.asset('assets/images/sofa.jpg', fit: BoxFit.cover),
          ),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 70,
            color: Colors.grey[300],
            child: Image.asset('assets/images/table2.jpg', fit: BoxFit.cover),
          ),
        ),
      ),
    ],
  );
}

// ! Products Actual Data
Widget buildProductCard(BuyerProductModel product, BuildContext context) {
  final bool hasDiscount = product.hasDiscount;
  final double discount = product.hasDiscount
      ? ((product.basePrice - product.finalPrice) / product.basePrice * 100)
            .roundToDouble()
      : 0;

  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ Add this
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              // Product Image
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: product.featuredImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          product.featuredImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          child: Icon(
                            Icons.image,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
              ),

              // 🔥 FAVORITE & CHAT BUTTONS
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  children: [
                    FavoriteButton(
                      productId: product.id,
                      initialIsFavorited: product.isFavorited,
                    ),
                    const SizedBox(height: 8),
                    // _buildChatButton(product, context),
                  ],
                ),
              ),

              // ✅ CORRECTED: Discount Badge (direct Positioned widget)
              if (hasDiscount && discount > 0)
                Positioned(
                  top: 10,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${discount.toInt()}% OFF',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Product Details (fixed height section)
        Expanded(
          flex: 3, // Details take 4 parts
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 5,
              bottom: 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // ✅ Space between
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Short Description
                    Text(
                      product.shortDescription,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Price and Stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${product.finalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                if (product.hasDiscount &&
                                    product.basePrice > product.finalPrice)
                                  Text(
                                    '\$${product.basePrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),

                            // ✅ Rating moved here (next to price)
                            if (product.rating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${product.rating}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // Order Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    backgroundColor: AppColors.yellowButton,
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () {
                      log('🔍 Debug: Order ID: ${product.toJson()}');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Text(
                      'Order Now',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,

                        //                         fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
