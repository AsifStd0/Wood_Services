import 'package:flutter/material.dart';
import 'package:wood_service/chats/Buyer/buyer_chating.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/favorite_button.dart';

import '../../../app/index.dart';

Widget buildPriceFilter(BuyerHomeViewModel viewModel) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText('Price Range', type: CustomTextType.bodySmall),
      const SizedBox(height: 8),
      RangeSlider(
        values: RangeValues(viewModel.minPrice, viewModel.maxPrice),
        min: 0,
        max: 10000,
        divisions: 100,
        labels: RangeLabels(
          '\$${viewModel.minPrice.toInt()}',
          '\$${viewModel.maxPrice.toInt()}',
        ),
        onChanged: (values) {
          viewModel.setPriceRange(values.start, values.end);
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('\$${viewModel.minPrice.toInt()}'),
          Text('\$${viewModel.maxPrice.toInt()}'),
        ],
      ),
    ],
  );
}

Widget buildDeliveryFilter(BuyerHomeViewModel viewModel) {
  return Row(
    children: [
      Checkbox(
        value: viewModel.freeDelivery,
        onChanged: (value) => viewModel.setFreeDelivery(value ?? false),
      ),
      const SizedBox(width: 8),
      CustomText('Free Delivery', type: CustomTextType.bodyMedium),
    ],
  );
}

Widget buildSalesFilter(BuyerHomeViewModel viewModel) {
  return Row(
    children: [
      Checkbox(
        value: viewModel.onSale,
        onChanged: (value) => viewModel.setOnSale(value ?? false),
      ),
      const SizedBox(width: 8),
      CustomText('On Sale', type: CustomTextType.bodyMedium),
    ],
  );
}

Widget buildProviderFilter(BuyerHomeViewModel viewModel) {
  final providers = [
    'IKEA',
    'Ashley Furniture',
    'Wayfair',
    'Local Stores',

    'All Providers',
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText('Provider', type: CustomTextType.bodySmall),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: viewModel.selectedProvider,
        decoration: InputDecoration(
          fillColor: AppColors.border,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: providers.map((provider) {
          return DropdownMenuItem(value: provider, child: Text(provider));
        }).toList(),
        onChanged: viewModel.setProvider,
        hint: Text('Select Provider'),
      ),
    ],
  );
}

Widget buildColorFilter(BuyerHomeViewModel viewModel) {
  final colors = {
    'Black': Colors.black,
    'White': Colors.white,
    'Brown': Colors.brown,
    'Gray': Colors.grey,
    'Blue': Colors.blue,
    'Red': Colors.red,
  };

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText('Color', type: CustomTextType.bodySmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: colors.entries.map((entry) {
          final isSelected = viewModel.selectedColor == entry.key;
          return ChoiceChip(
            label: Text(entry.key),
            selected: isSelected,
            onSelected: (selected) {
              viewModel.setColor(selected ? entry.key : null);
            },
          );
        }).toList(),
      ),
    ],
  );
}

Widget buildFilterActions(BuyerHomeViewModel viewModel) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: viewModel.resetAllFilters,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text('Reset All'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: () {
            // Apply filters logic here
            viewModel.toggleMoreFilters();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brightOrange,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text('Apply Filters', style: TextStyle(color: Colors.white)),
        ),
      ),
    ],
  );
}

Widget buildCategoryChip(
  String text, {
  bool isSelected = false,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xffEDC064) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Color(0xffEDC064) : Colors.black,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget buildNewSection() {
  return Consumer<BuyerHomeViewModel>(
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
            child: CustomText('NEW', type: CustomTextType.subtitleMedium15bold),
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
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.yellowLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
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

Widget buildCityFilter(BuyerHomeViewModel viewModel) {
  final cities = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Miami',
    'Dallas',
    'All Cities',
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText('City', type: CustomTextType.bodySmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: cities.map((city) {
          final isSelected = viewModel.selectedCity == city;
          return FilterChip(
            label: Text(city),
            selected: isSelected,
            onSelected: (selected) {
              viewModel.setCity(selected ? city : null);
            },
          );
        }).toList(),
      ),
    ],
  );
}

// ! Products Actual Data
// ! Products Actual Data
Widget buildProductCard(BuyerProductModel product, BuildContext context) {
  // final viewModel = Provider.of<BuyerHomeViewModel>(context, listen: false);
  final bool hasDiscount = product.hasDiscount;
  final double discount = product.hasDiscount
      ? ((product.basePrice - product.finalPrice) / product.basePrice * 100)
            .roundToDouble()
      : 0;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image with Badges
        Stack(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 90,
                color: Colors.grey[200],
                child: Center(
                  child: product.featuredImage != null
                      ? Image.network(
                          product.featuredImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        )
                      : CircleAvatar(radius: 60),
                ),
              ),
            ),
            // 🔥 FAVORITE & CHAT BUTTONS - Stacked Vertically
            Positioned(
              top: 8,
              right: 8,
              child: Column(
                children: [
                  // Favorite Button
                  FavoriteButton(
                    productId: product.id,
                    initialIsFavorited: product.isFavorited,
                  ),

                  const SizedBox(height: 8), // Space between buttons
                  // Chat Button
                  _buildChatButton(product, context),
                ],
              ),
            ),

            // Discount Badge
            if (hasDiscount && discount > 0)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${discount.toInt()}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Product Details
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                product.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                product.shortDescription,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),

              // Price and Stock
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${product.finalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      if (product.hasDiscount &&
                          product.basePrice > product.finalPrice)
                        Text(
                          '\$${product.basePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  // Stock Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: product.inStock ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.inStock ? 'In Stock' : 'Out of Stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Rating
              if (product.rating != null)
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviewCount ?? 0})',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomButton(
                  backgroundColor: AppColors.yellowButton,
                  height: 30,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return ProductDetailScreen(product: product);
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Order Now',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// 🔥 CHAT BUTTON WIDGET
Widget _buildChatButton(BuyerProductModel product, BuildContext context) {
  return GestureDetector(
    onTap: () {
      _startChatWithSeller(product, context);
    },
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.chat_outlined, size: 16, color: Colors.blue),
      ),
    ),
  );
}

// 🔥 START CHAT FUNCTION
void _startChatWithSeller(BuyerProductModel product, BuildContext context) {
  // Check if seller info is available
  if (product.sellerId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seller information not available'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // In your current onTap function
  print('🔍 Debug:');
  print('SellerId: ${product.sellerId}');
  print('SellerId type: ${product.sellerId.runtimeType}');

  String sellerIdString;
  String sellerNameString;

  // Handle the Map case
  if (product.sellerId is Map) {
    final sellerMap = product.sellerId as Map;
    sellerIdString = sellerMap['id']?.toString() ?? 'unknown';
    sellerNameString =
        sellerMap['businessName']?.toString() ??
        sellerMap['shopName']?.toString() ??
        'Unknown Seller';
  } else {
    sellerIdString = product.sellerId.toString();
    sellerNameString = product.sellerName;
  }

  print('✅ Extracted:');
  print('   Seller ID: $sellerIdString');
  print('   Seller Name: $sellerNameString');

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BuyerChatScreen(
        sellerId: sellerIdString,
        sellerName: sellerNameString,
        productId: product.id,
        productName: product.title,
        // ✅ Remove orderId or set it to null
        // orderId: null, // Or don't pass this parameter at all
      ),
    ),
  );
}
