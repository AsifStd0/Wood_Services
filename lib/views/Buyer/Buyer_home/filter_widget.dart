import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';
import 'package:wood_service/views/Buyer/Buyer_home/product_filter_model.dart';

/// Filter Widget with Dropdown
/// Shows filter options in a user-friendly dropdown
class ProductFilterWidget extends StatefulWidget {
  const ProductFilterWidget({super.key});

  @override
  State<ProductFilterWidget> createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  bool _isExpanded = false;

  // Controllers for TextFields (to prevent focus loss)
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  bool _controllersInitialized = false;
  ProductFilterModel? _lastFilter;

  void _initializeControllers(
    BuyerHomeViewProvider provider,
    ProductFilterModel filter,
  ) {
    // Re-initialize if filter changed (e.g., auto-removed filters)
    if (!_controllersInitialized || _lastFilter != filter) {
      _minPriceController.text = filter.minPrice != null
          ? filter.minPrice!.toInt().toString()
          : '';
      _maxPriceController.text = filter.maxPrice != null
          ? filter.maxPrice!.toInt().toString()
          : '';
      _locationController.text = filter.location ?? provider.userLocation ?? '';
      _tagsController.text = filter.tags?.join(', ') ?? '';

      _controllersInitialized = true;
      _lastFilter = filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerHomeViewProvider>(
      builder: (context, provider, child) {
        final filter = provider.currentFilter;
        final hasActiveFilters = filter.hasActiveFilters;

        // Initialize controllers once
        _initializeControllers(provider, filter);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasActiveFilters ? AppColors.primary : AppColors.lightGrey,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Filter Header (Always Visible)
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: hasActiveFilters
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: hasActiveFilters
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (hasActiveFilters)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Options (Expandable)
              if (_isExpanded)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.lightGrey, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Dropdown (First - cascading starts here)
                      _buildCategoryDropdown(provider, filter),
                      const SizedBox(height: 16),

                      // Price Range
                      _buildPriceRange(provider, filter),
                      const SizedBox(height: 16),

                      // Location Field
                      _buildLocationField(provider, filter),
                      const SizedBox(height: 16),

                      // Tags Field
                      _buildTagsField(provider, filter),
                      const SizedBox(height: 16),

                      // In Stock Toggle - COMMENTED OUT (uncomment when needed)
                      // _buildInStockToggle(provider, filter),
                      // const SizedBox(height: 16),

                      // Sort Dropdown
                      _buildSortDropdown(provider, filter),
                      const SizedBox(height: 20),

                      // Action Buttons
                      _buildActionButtons(provider, filter),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown(
    BuyerHomeViewProvider provider,
    ProductFilterModel filter,
  ) {
    // Get available categories from ALL products (not filtered by category)
    // This is the first filter, so it shows all available categories
    final availableCategories = provider.getAllAvailableCategories();
    final categories = ['All Categories', ...availableCategories];

    if (categories.length <= 1) {
      // No categories available, hide this field
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: filter.category ?? 'All Categories',
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.extraLightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value == 'All Categories') {
              provider.setCategory(null);
            } else {
              provider.setCategory(value);
              // When category changes, reset dependent filters (tags, etc.)
              provider.onCategoryChanged(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriceRange(
    BuyerHomeViewProvider provider,
    ProductFilterModel filter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Min',
                  prefixText: '\$ ',
                  filled: true,
                  fillColor: AppColors.extraLightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  // Don't update filter on every keystroke, only when field loses focus
                  // This prevents focus loss
                },
                onEditingComplete: () {
                  // Update filter when user finishes editing
                  final minPrice =
                      double.tryParse(_minPriceController.text) ?? 0;
                  final maxPrice =
                      double.tryParse(_maxPriceController.text) ?? 10000;
                  provider.setPriceRange(minPrice, maxPrice);
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'to',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Max',
                  prefixText: '\$ ',
                  filled: true,
                  fillColor: AppColors.extraLightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  // Don't update filter on every keystroke
                },
                onEditingComplete: () {
                  // Update filter when user finishes editing
                  final minPrice =
                      double.tryParse(_minPriceController.text) ?? 0;
                  final maxPrice =
                      double.tryParse(_maxPriceController.text) ?? 10000;
                  provider.setPriceRange(minPrice, maxPrice);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationField(
    BuyerHomeViewProvider provider,
    ProductFilterModel filter,
  ) {
    // Only show location field if user has location or it's already set
    final userLocation = provider.userLocation;
    if (userLocation == null && filter.location == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: userLocation ?? 'e.g., Houston, TX',
            prefixIcon: const Icon(Icons.location_on, size: 20),
            suffixIcon: _locationController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _locationController.clear();
                      provider.setLocation(null);
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.extraLightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            setState(() {}); // Update clear button visibility
            provider.setLocation(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }

  Widget _buildTagsField(
    BuyerHomeViewProvider provider,
    ProductFilterModel filter,
  ) {
    // Get tags based on selected category (cascading filter)
    // If category is selected, only show tags from that category
    final availableTags = provider.getAvailableTagsForCategory(filter.category);
    if (availableTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (comma-separated)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Show available tags as chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.take(10).map((tag) {
            final isSelected = filter.tags?.contains(tag) ?? false;
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                final currentTags = filter.tags ?? <String>[];
                if (selected) {
                  provider.setTags([...currentTags, tag]);
                } else {
                  provider.setTags(currentTags.where((t) => t != tag).toList());
                }
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tagsController,
          decoration: InputDecoration(
            hintText: 'Or type tags: e.g., rustic, modern, vintage',
            prefixIcon: const Icon(Icons.label, size: 20),
            suffixIcon: _tagsController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _tagsController.clear();
                      provider.setTags(null);
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.extraLightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            setState(() {}); // Update clear button visibility
            if (value.isEmpty) {
              provider.setTags(null);
            } else {
              final tags = value
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
              provider.setTags(tags.isEmpty ? null : tags);
            }
          },
        ),
      ],
    );
  }

  // In Stock Toggle - COMMENTED OUT (uncomment when needed)
  // Widget _buildInStockToggle(
  //   BuyerHomeViewProvider provider,
  //   ProductFilterModel filter,
  // ) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         'In Stock Only',
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w600,
  //           color: AppColors.textPrimary,
  //         ),
  //       ),
  //       Switch(
  //         value: filter.inStock ?? false,
  //         onChanged: (value) {
  //           provider.setInStock(value ? true : null);
  //         },
  //         activeColor: AppColors.primary,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSortDropdown(
    BuyerHomeViewProvider provider,
    ProductFilterModel filter,
  ) {
    final sortOptions = [
      'None',
      ProductSortOption.priceAsc.value,
      ProductSortOption.priceDesc.value,
      ProductSortOption.rating.value,
    ];

    final sortLabels = [
      'None',
      ProductSortOption.priceAsc.label,
      ProductSortOption.priceDesc.label,
      ProductSortOption.rating.label,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: filter.sort ?? 'None',
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.extraLightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: List.generate(sortOptions.length, (index) {
            return DropdownMenuItem<String>(
              value: sortOptions[index],
              child: Text(sortLabels[index]),
            );
          }),
          onChanged: (value) {
            if (value == 'None') {
              provider.setSort(null);
            } else {
              provider.setSort(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuyerHomeViewProvider provider,
    ProductFilterModel filter,
  ) {
    return Row(
      children: [
        // Reset Button
        Expanded(
          child: OutlinedButton(
            onPressed: filter.hasActiveFilters
                ? () {
                    provider.resetFilters();
                    setState(() {
                      _isExpanded = false;
                    });
                  }
                : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: filter.hasActiveFilters
                    ? AppColors.error
                    : AppColors.lightGrey,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Reset',
              style: TextStyle(
                color: filter.hasActiveFilters
                    ? AppColors.error
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Apply Button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              provider.applyFilters();
              setState(() {
                _isExpanded = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
