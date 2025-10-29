import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';

class PricingTab extends StatelessWidget {
  const PricingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddProductViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pricing Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set your product pricing, discounts, and offers',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Base Price
          _buildSectionHeader(
            'Base Price',
            'Set the regular price for your product',
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            hintText: '0.00',
            prefixIcon: Icon(
              Icons.attach_money_rounded,
              color: Colors.grey[400],
            ),
            // keyboardType: TextInputType.number,
            onChanged: (value) {
              final price = double.tryParse(value) ?? 0.0;
              viewModel.setBasePrice(price);
            },
          ),
          const SizedBox(height: 24),

          // Sale Price
          _buildSectionHeader(
            'Sale Price',
            'Optional discounted price for promotions',
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            hintText: '0.00 (Optional)',
            prefixIcon: Icon(
              Icons.local_offer_rounded,
              color: Colors.grey[400],
            ),
            // keyboardType: TextInputType.number,
            onChanged: (value) {
              final salePrice = double.tryParse(value);
              viewModel.setSalePrice(salePrice);
            },
          ),
          const SizedBox(height: 24),

          // Cost Price
          _buildSectionHeader(
            'Cost Price',
            'Your cost price for profit calculation',
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            hintText: '0.00 (Optional)',
            prefixIcon: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.grey[400],
            ),
            // keyboardType: TextInputType.number,
            onChanged: (value) {
              final costPrice = double.tryParse(value);
              viewModel.setCostPrice(costPrice);
            },
          ),
          const SizedBox(height: 24),

          // Tax Settings
          _buildSectionHeader(
            'Tax Settings',
            'Configure tax rates for this product',
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),

              border: Border.all(color: AppColors.lightGrey.withOpacity(0.1)),
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select tax rate',

                // border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                fillColor: AppColors.white,
                focusedBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),

                prefixIcon: Icon(
                  Icons.receipt_rounded,
                  color: Colors.grey[400],
                ),
              ),
              items: const [
                DropdownMenuItem(value: '0', child: Text('0% - No Tax')),
                DropdownMenuItem(value: '5', child: Text('5% - Standard')),
                DropdownMenuItem(value: '12', child: Text('12% - Reduced')),
                DropdownMenuItem(value: '18', child: Text('18% - Standard')),
                DropdownMenuItem(value: '28', child: Text('28% - Luxury')),
              ],
              onChanged: (value) {
                if (value != null) {
                  final taxRate = double.tryParse(value) ?? 0.0;
                  viewModel.setTaxRate(taxRate);
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Currency
          _buildSectionHeader('Currency', 'Select the currency for pricing'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey.withOpacity(0.1)),
            ),
            child: DropdownButtonFormField<String>(
              value: 'USD',
              decoration: InputDecoration(
                hintText: 'Select currency',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                focusedBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),

                fillColor: AppColors.white,
                prefixIcon: Icon(
                  Icons.currency_exchange_rounded,
                  color: Colors.grey[400],
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                DropdownMenuItem(
                  value: 'GBP',
                  child: Text('GBP - British Pound'),
                ),
                DropdownMenuItem(
                  value: 'INR',
                  child: Text('INR - Indian Rupee'),
                ),
                DropdownMenuItem(
                  value: 'CAD',
                  child: Text('CAD - Canadian Dollar'),
                ),
              ],
              onChanged: (value) {
                if (value != null) viewModel.setCurrency(value);
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
