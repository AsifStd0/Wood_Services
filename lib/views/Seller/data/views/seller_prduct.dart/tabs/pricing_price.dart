import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_model.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class PricingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<SellerProductProvider>();
    final product = productProvider.product;

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
            'Base Price *',
            'Set the regular price for your product',
            '0.00',
            Icons.attach_money_rounded,
            product.price
                .toString(), // ✅ FIXED: product.price not product.basePrice
            (value) {
              final price = double.tryParse(value) ?? 0.0;
              productProvider.updatePrice(
                price,
              ); // ✅ FIXED: updatePrice() not updateBasePrice()
            },
          ),
          const SizedBox(height: 24),

          // Sale Price
          _buildPriceField(
            'Sale Price (Optional)',
            'Discounted price for promotions',
            '0.00',
            Icons.local_offer_rounded,
            product.salePrice?.toString() ?? '',
            (value) {
              final price = value.isEmpty ? null : double.tryParse(value);
              productProvider.updateSalePrice(price);
            },
          ),
          const SizedBox(height: 24),

          // Cost Price
          _buildPriceField(
            'Cost Price (Optional)',
            'Your cost price for profit calculation',
            '0.00',
            Icons.account_balance_wallet_rounded,
            product.costPrice?.toString() ?? '',
            (value) {
              final price = value.isEmpty ? null : double.tryParse(value);
              productProvider.updateCostPrice(price);
            },
          ),
          const SizedBox(height: 24),

          // Tax Rate
          _buildDropdownField(
            'Tax Rate',
            'Configure tax rates for this product',
            Icons.receipt_rounded,
            product.taxRate.toStringAsFixed(0), // Convert double to String
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
            'Currency',
            'Select the currency for pricing',
            Icons.currency_exchange_rounded,
            product.currency,
            const ['USD', 'EUR', 'GBP', 'INR', 'PKR', 'CAD', 'AUD'],
            (value) {
              if (value != null) productProvider.updateCurrency(value);
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
    String title,
    String subtitle,
    String hintText,
    IconData icon,
    String initialValue,
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
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          textInputType: TextInputType.numberWithOptions(decimal: true),
          initialValue: initialValue == '0.0' ? '' : initialValue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String title,
    String subtitle,
    IconData icon,
    String currentValue, // Change from dynamic to String
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
          ),
          child: DropdownButtonFormField<String>(
            value: currentValue, // Now this will match String values
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
