import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/views/seller_prduct.dart/seller_product_provider.dart';

Widget buildPreviousButton(SellerProductProvider viewModel) {
  return OutlinedButton(
    onPressed: viewModel.isLoading
        ? null
        : () => viewModel.setCurrentTab(viewModel.currentTabIndex - 1),
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      side: BorderSide(color: Colors.grey[300]!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.arrow_back_rounded, size: 18),
        const SizedBox(width: 8),
        Text(
          'Previous',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget buildContinueButton(
  BuildContext context,
  SellerProductProvider viewModel,
  Color primaryColor,
) {
  return ElevatedButton(
    onPressed: viewModel.isLoading
        ? null
        : () => handleNextAction(context, viewModel),
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: primaryColor.withOpacity(0.3),
    ),
    child: viewModel.isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.currentTabIndex == 4 ? 'Publish Product' : 'Continue',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (viewModel.currentTabIndex < 4) const SizedBox(width: 8),
              if (viewModel.currentTabIndex < 4)
                const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
  );
}

void handleNextAction(BuildContext context, SellerProductProvider viewModel) {
  if (viewModel.currentTabIndex < 4) {
    viewModel.setCurrentTab(viewModel.currentTabIndex + 1);
  } else {
    _publishProduct(context, viewModel);
  }
}

Future<void> _publishProduct(
  BuildContext context,
  SellerProductProvider viewModel,
) async {
  log('Data is here ${viewModel.product.toJson()}');
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // ! *******
  // Validate media tab before publishing
  if (viewModel.selectedImages.isEmpty) {
    showSnackBar(
      context,
      'Please upload at least one product image',
      Colors.orange,
    );
    return;
  }

  final success = await viewModel.publishProduct();
  if (context.mounted) {
    showSnackBar(
      context,
      success
          ? 'Product published successfully'
          : viewModel.errorMessage ?? 'Failed to publish product',
      success ? const Color(0xFF6BCF7F) : const Color(0xFFFF6B6B),
    );
  }
}

void showSnackBar(BuildContext context, String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
