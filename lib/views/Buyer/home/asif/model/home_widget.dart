import 'package:flutter/material.dart';

import '../../../../../app/index.dart';

Widget buildPriceFilter(HomeViewModel viewModel) {
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

Widget buildDeliveryFilter(HomeViewModel viewModel) {
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

Widget buildSalesFilter(HomeViewModel viewModel) {
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

Widget buildProviderFilter(HomeViewModel viewModel) {
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

Widget buildColorFilter(HomeViewModel viewModel) {
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

Widget buildFilterActions(HomeViewModel viewModel) {
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
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
  return Consumer<HomeViewModel>(
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
            padding: const EdgeInsets.only(top: 5),
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

Widget buildCityFilter(HomeViewModel viewModel) {
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
