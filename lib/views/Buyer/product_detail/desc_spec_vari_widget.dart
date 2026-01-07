import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';

class ProductTabsSection extends StatefulWidget {
  final BuyerProductModel product;

  const ProductTabsSection({super.key, required this.product});

  @override
  State<ProductTabsSection> createState() => _ProductTabsSectionState();
}

class _ProductTabsSectionState extends State<ProductTabsSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // Get selected variant from Provider
    final selectedVariant = context.select<BuyerCartViewModel, String?>(
      (viewModel) => viewModel.selectedVariant,
    );

    final cartViewModel = Provider.of<BuyerCartViewModel>(
      context,
      listen: false,
    );

    return Column(
      children: [
        // Tab Headers
        Row(
          children: [
            _buildTab('Description', 0),
            _buildTab('Specifications', 1),
            _buildTab('Variants', 2),
          ],
        ),
        const SizedBox(height: 16),

        // Tab Content with REAL DATA from your model
        _buildTabContent(cartViewModel, selectedVariant),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: _selectedTab == index
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _selectedTab == index ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuyerCartViewModel cartViewModel,
    String? selectedVariant,
  ) {
    switch (_selectedTab) {
      case 0: // Description
        return _buildDescriptionTab();

      case 1: // Specifications
        return _buildSpecificationsTab(widget.product);

      case 2: // Variants
        return _buildVariantsTab(
          cartViewModel,
          selectedVariant,
          widget.product,
        );

      default:
        return const SizedBox();
    }
  }

  // ========== DESCRIPTION TAB (Using your model data) ==========
  Widget _buildDescriptionTab() {
    final shortDescription = widget.product.shortDescription.trim();
    final longDescription = widget.product.longDescription.trim();

    // Check if both descriptions are empty
    if (shortDescription.isEmpty && longDescription.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No description available',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Short Description
          if (shortDescription.isNotEmpty) ...[
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              shortDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Long Description
          if (longDescription.isNotEmpty) ...[
            Text(
              'Detailed Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            _buildFormattedText(longDescription),
          ],

          // Tags (if available)
          if (widget.product.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.product.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmedLine = line.trim();

        if (trimmedLine.isEmpty) {
          return const SizedBox(height: 12);
        }

        // Check for bullet points
        if (trimmedLine.startsWith('- ') ||
            trimmedLine.startsWith('• ') ||
            trimmedLine.startsWith('* ')) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 6, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trimmedLine.substring(2).trim(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ),
            ],
          );
        }
        // Check for numbered list
        else if (RegExp(r'^\d+\.\s').hasMatch(trimmedLine)) {
          final match = RegExp(r'^(\d+)\.\s+(.*)').firstMatch(trimmedLine);
          if (match != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.group(1)}.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      match.group(2)!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }

        // Regular paragraph
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            trimmedLine,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ========== SPECIFICATIONS TAB (Using your model data) ==========
Widget _buildSpecificationsTab(product) {
  final dimensions = product.dimensions;
  final weight = product.weight;
  final dimensionSpec = product.dimensionSpec;

  // Check if any specification data is available
  final hasDimensions =
      dimensions != null &&
      (dimensions.length != null ||
          dimensions.width != null ||
          dimensions.height != null);

  final hasWeight = weight != null && weight > 0;
  final hasDimensionSpec = dimensionSpec != null && dimensionSpec.isNotEmpty;

  if (!hasDimensions && !hasWeight && !hasDimensionSpec) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'No specifications available',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Specifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),

        // Stock Information
        _buildSpecItem(
          label: 'Stock Status',
          value: product.stockStatus,
          valueColor: product.isInStock ? Colors.green : Colors.red,
        ),

        _buildSpecItem(
          label: 'Available Quantity',
          value: '${product.stockQuantity} units',
        ),

        if (product.lowStockAlert != null) ...[
          _buildSpecItem(
            label: 'Low Stock Alert',
            value: '${product.lowStockAlert} units',
          ),
        ],

        // SKU
        if (product.sku != null && product.sku!.isNotEmpty) ...[
          _buildSpecItem(label: 'SKU', value: product.sku!),
        ],

        // Dimensions
        if (hasDimensions) ...[
          const SizedBox(height: 8),
          Text(
            'Dimensions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),

          if (dimensions!.length != null) ...[
            _buildSpecItem(
              label: 'Length',
              value: '${dimensions.length!.toStringAsFixed(1)} cm',
            ),
          ],

          if (dimensions.width != null) ...[
            _buildSpecItem(
              label: 'Width',
              value: '${dimensions.width!.toStringAsFixed(1)} cm',
            ),
          ],

          if (dimensions.height != null) ...[
            _buildSpecItem(
              label: 'Height',
              value: '${dimensions.height!.toStringAsFixed(1)} cm',
            ),
          ],

          if (dimensions.formatted != null) ...[
            _buildSpecItem(label: 'Formatted', value: dimensions.formatted!),
          ],
        ],

        // Weight
        if (hasWeight) ...[
          _buildSpecItem(
            label: 'Weight',
            value: '${weight!.toStringAsFixed(2)} kg',
          ),
        ],

        // Dimension Spec (additional dimension info)
        if (hasDimensionSpec) ...[
          _buildSpecItem(
            label: 'Dimension Specification',
            value: dimensionSpec!,
          ),
        ],

        // Additional Product Info
        const SizedBox(height: 8),
        Text(
          'Product Information',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        _buildSpecItem(label: 'Category', value: product.category),

        if (product.currency.isNotEmpty) ...[
          _buildSpecItem(label: 'Currency', value: product.currency),
        ],

        if (product.taxRate != null && product.taxRate! > 0) ...[
          _buildSpecItem(
            label: 'Tax Rate',
            value: '${product.taxRate!.toStringAsFixed(2)}%',
          ),
        ],

        // Performance Metrics
        const SizedBox(height: 8),
        Text(
          'Performance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        _buildSpecItem(label: 'Views', value: '${product.views}'),

        _buildSpecItem(label: 'Total Sales', value: '${product.salesCount}'),

        if (product.rating != null) ...[
          _buildSpecItem(
            label: 'Average Rating',
            value: '${product.rating!.toStringAsFixed(1)} / 5.0',
            valueColor: Colors.amber,
          ),
        ],

        if (product.reviewCount != null) ...[
          _buildSpecItem(
            label: 'Total Reviews',
            value: '${product.reviewCount}',
          ),
        ],

        _buildSpecItem(label: 'Created', value: _formatDate(product.createdAt)),

        if (product.updatedAt != product.createdAt) ...[
          _buildSpecItem(
            label: 'Last Updated',
            value: _formatDate(product.updatedAt),
          ),
        ],
      ],
    ),
  );
}

Widget _buildSpecItem({
  required String label,
  required String value,
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else {
    return 'Today';
  }
}

// ========== VARIANTS TAB (Using your model data) ==========
Widget _buildVariantsTab(
  BuyerCartViewModel cartViewModel,
  String? selectedVariant,
  BuyerProductModel product,
) {
  if (product.variants.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No variants available',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This product comes in standard configuration only',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header
      Row(
        children: [
          Text(
            'Available Variants',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${product.variants.length} options',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      // Variant types summary
      if (product.variantTypes.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: product.variantTypes.map((type) {
            return Chip(
              label: Text(type, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.grey[100],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],

      // Variants list
      ...product.variants.map((variant) {
        final isSelected = selectedVariant == variant.value;
        final variantStock = variant.stock ?? product.stockQuantity;
        final isVariantInStock = variant.isActive && variantStock > 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  variant.type[0].toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              '${variant.type}: ${variant.name}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue : Colors.grey[800],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stock status
                Text(
                  isVariantInStock ? '$variantStock in stock' : 'Out of stock',
                  style: TextStyle(
                    color: isVariantInStock ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),

                // Price adjustment
                if (variant.priceAdjustment != 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    variant.priceAdjustment > 0
                        ? 'Extra: +\$${variant.priceAdjustment.toStringAsFixed(2)}'
                        : 'Discount: -\$${(variant.priceAdjustment * -1).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: variant.priceAdjustment > 0
                          ? Colors.red
                          : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Selection indicator
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: Colors.green),

                // SKU if available
                if (variant.sku != null && variant.sku!.isNotEmpty)
                  Text(
                    variant.sku!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
            onTap: () {
              if (isVariantInStock) {
                cartViewModel.updateVariant(isSelected ? null : variant.value);
              }
            },
          ),
        );
      }),

      // Selected variant info
      if (selectedVariant != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[100]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Variant selected',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Price will be adjusted accordingly',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  cartViewModel.updateVariant(null);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
