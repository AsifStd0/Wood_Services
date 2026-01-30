import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_model.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class PricingTab extends StatefulWidget {
  const PricingTab({super.key});

  @override
  State<PricingTab> createState() => _PricingTabState();
}

class _PricingTabState extends State<PricingTab> {
  late TextEditingController _priceController;
  late TextEditingController _salePriceController;
  late TextEditingController _costPriceController;
  late FocusNode _priceFocusNode;
  late FocusNode _salePriceFocusNode;
  late FocusNode _costPriceFocusNode;
  String _taxRate = '0';
  String _currency = 'USD';
  String? _lastProductId;
  bool _isInitialized = false;
  bool _lastLoadingState = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _salePriceController = TextEditingController();
    _costPriceController = TextEditingController();
    _priceFocusNode = FocusNode();
    _salePriceFocusNode = FocusNode();
    _costPriceFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _priceFocusNode.dispose();
    _salePriceFocusNode.dispose();
    _costPriceFocusNode.dispose();
    super.dispose();
  }

  void _updateControllers(SellerProduct product, {bool force = false}) {
    // Update product ID tracking
    final currentProductId = product.id ?? '';
    if (_lastProductId != currentProductId) {
      _lastProductId = currentProductId;
      _isInitialized = false;
    }

    // Only update controllers if:
    // 1. Product changed (new product loaded) - always update
    // 2. Initial load (not yet initialized) - always update
    // 3. Force update requested
    // AND field is not currently focused (user not typing)
    if (force || !_isInitialized) {
      // Update price controller only if not focused
      if (!_priceFocusNode.hasFocus) {
        final priceText = product.price.toString();
        if (_priceController.text != priceText) {
          _priceController.text = priceText;
        }
      }

      // Update sale price controller only if not focused
      if (!_salePriceFocusNode.hasFocus) {
        final salePriceText = product.salePrice?.toString() ?? '';
        if (_salePriceController.text != salePriceText) {
          _salePriceController.text = salePriceText;
        }
      }

      // Update cost price controller only if not focused
      if (!_costPriceFocusNode.hasFocus) {
        final costPriceText = product.costPrice?.toString() ?? '';
        if (_costPriceController.text != costPriceText) {
          _costPriceController.text = costPriceText;
        }
      }

      // Always update dropdowns (they don't interfere with typing)
      if (_taxRate != product.taxRate.toStringAsFixed(0)) {
        _taxRate = product.taxRate.toStringAsFixed(0);
      }
      if (_currency != product.currency) {
        _currency = product.currency;
      }

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<SellerProductProvider>();
    final product = productProvider.product;

    // Update controllers when:
    // 1. Product ID changes (new product loaded)
    // 2. Loading state changes from true to false (API data just loaded)
    final currentProductId = product.id ?? '';
    final currentLoadingState = productProvider.isLoading;
    final productIdChanged = _lastProductId != currentProductId;
    final loadingJustFinished = _lastLoadingState && !currentLoadingState;

    if (productIdChanged || loadingJustFinished) {
      if (productIdChanged) {
        _lastProductId = currentProductId;
        _isInitialized = false; // Reset initialization when product changes
      }
      if (loadingJustFinished) {
        _isInitialized = false; // Reset initialization when API data loads
      }
      _lastLoadingState = currentLoadingState;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateControllers(product, force: true);
        }
      });
    } else {
      _lastLoadingState = currentLoadingState;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Pricing Details',
            'Set your product pricing, discounts, and offers',
          ),

          // Base Price
          _buildPriceField(
            _priceController,
            _priceFocusNode,
            'Base Price *',
            'Set the regular price for your product',
            '0.00',
            Icons.attach_money_rounded,
            (value) {
              // Only update if value is valid or empty
              if (value.isEmpty) {
                productProvider.updatePrice(0.0);
              } else {
                final price = double.tryParse(value);
                if (price != null) {
                  productProvider.updatePrice(price);
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // Sale Price
          _buildPriceField(
            _salePriceController,
            _salePriceFocusNode,
            'Sale Price (Optional)',
            'Discounted price for promotions',
            '0.00',
            Icons.local_offer_rounded,
            (value) {
              if (value.isEmpty) {
                productProvider.updateSalePrice(null);
              } else {
                final price = double.tryParse(value);
                if (price != null) {
                  productProvider.updateSalePrice(price);
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // Cost Price
          _buildPriceField(
            _costPriceController,
            _costPriceFocusNode,
            'Cost Price (Optional)',
            'Your cost price for profit calculation',
            '0.00',
            Icons.account_balance_wallet_rounded,
            (value) {
              if (value.isEmpty) {
                productProvider.updateCostPrice(null);
              } else {
                final price = double.tryParse(value);
                if (price != null) {
                  productProvider.updateCostPrice(price);
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // Tax Rate
          _buildDropdownField(
            'Tax Rate',
            'Configure tax rates for this product',
            Icons.receipt_rounded,
            _taxRate,
            const ['0', '5', '10', '12', '15', '18', '20'],
            (value) {
              if (value != null) {
                final rate = double.tryParse(value) ?? 0.0;
                productProvider.updateTaxRate(rate);
              }
            },
          ),
          const SizedBox(height: 24),

          // Currency
          _buildDropdownField(
            'Currency *',
            'Select the currency for pricing (Required)',
            Icons.currency_exchange_rounded,
            _currency,
            const ['USD', 'EUR', 'GBP', 'INR', 'PKR', 'CAD', 'AUD'],
            (value) {
              if (value != null) {
                productProvider.updateCurrency(value);
              }
            },
          ),
          const SizedBox(height: 24),

          // Price Summary
          _buildPriceSummary(product),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPriceField(
    TextEditingController controller,
    FocusNode focusNode,
    String title,
    String subtitle,
    String hintText,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _buildLabelStyle()),
        const SizedBox(height: 4),
        Text(subtitle, style: _buildSubtitleStyle()),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: controller,
          focusNode: focusNode,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          textInputType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String title,
    String subtitle,
    IconData icon,
    String currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _buildLabelStyle()),
        const SizedBox(height: 4),
        Text(subtitle, style: _buildSubtitleStyle()),
        const SizedBox(height: 8),

        Container(
          key: ValueKey('${title}_$currentValue'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
          ),
          child: DropdownButtonFormField<String>(
            value: currentValue.isNotEmpty ? currentValue : null,
            decoration: InputDecoration(
              hintText: 'Select',
              prefixIcon: Icon(icon, color: Colors.grey[400]),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            items: options.map((option) {
              String displayText;
              switch (option) {
                case '0':
                  displayText = '0% - No Tax';
                  break;
                case '5':
                  displayText = '5%';
                  break;
                case '10':
                  displayText = '10%';
                  break;
                case '12':
                  displayText = '12%';
                  break;
                case '15':
                  displayText = '15%';
                  break;
                case '18':
                  displayText = '18%';
                  break;
                case '20':
                  displayText = '20%';
                  break;
                default:
                  displayText = option;
              }
              return DropdownMenuItem<String>(
                value: option,
                child: Text(displayText),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(SellerProduct product) {
    final sellingPrice =
        product.salePrice ?? product.price; // ✅ FIXED: product.price
    final taxAmount = sellingPrice * (product.taxRate / 100);
    final finalPrice = sellingPrice + taxAmount;
    final profit = product.costPrice != null
        ? sellingPrice - product.costPrice!
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF667EEA).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_rounded, color: Color(0xFF667EEA), size: 20),
              const SizedBox(width: 8),
              Text(
                'Price Summary',
                style: _buildLabelStyle(color: Color(0xFF667EEA)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Base Price',
            '\$${product.price.toStringAsFixed(2)}', // ✅ FIXED: product.price
          ),
          if (product.salePrice != null)
            _buildSummaryRow(
              'Sale Price',
              '\$${product.salePrice!.toStringAsFixed(2)}',
            ),
          _buildSummaryRow(
            'Tax (${product.taxRate}%)',
            '\$${taxAmount.toStringAsFixed(2)}',
          ),
          const Divider(height: 20),
          _buildSummaryRow(
            'Final Price',
            '\$${finalPrice.toStringAsFixed(2)}',
            isBold: true,
            color: Color(0xFF667EEA),
          ),
          if (profit != null)
            _buildSummaryRow(
              'Profit',
              '\$${profit.toStringAsFixed(2)}',
              isBold: true,
              color: profit >= 0 ? Colors.green : Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.grey[800],
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _buildLabelStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle, style: _buildSubtitleStyle()),
        ],
      ),
    );
  }

  TextStyle _buildLabelStyle({double fontSize = 16, Color? color}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.grey[800],
    );
  }

  TextStyle _buildSubtitleStyle() {
    return TextStyle(fontSize: 14, color: Colors.grey[600]);
  }
}
