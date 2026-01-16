import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/payment/rating/review_provider.dart';
import 'package:wood_service/widgets/custom_button.dart';

class OrderRatingScreen extends StatefulWidget {
  final String orderId;
  final String orderItemId;
  final List<String> items;
  final BuyerProductModel buyerProduct;
  final String? cartItemId;
  final int quantity;
  final String? productId;
  final double? totalPrice;

  const OrderRatingScreen({
    super.key,
    required this.orderId,
    required this.orderItemId,
    required this.items,
    required this.buyerProduct,
    this.cartItemId,
    this.quantity = 1,
    this.productId,
    this.totalPrice,
  });

  @override
  State<OrderRatingScreen> createState() => _OrderRatingScreenState();
}

class _OrderRatingScreenState extends State<OrderRatingScreen> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;

  final List<String> _ratingTitles = [
    'Very Dissatisfied',
    'Dissatisfied',
    'Neutral',
    'Satisfied',
    'Very Satisfied',
  ];

  final List<Color> _ratingColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rate Your Order'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeaderSection(),
            const SizedBox(height: 15),

            // Order Info
            _buildOrderInfo(),
            const SizedBox(height: 15),

            // Rating Section
            _buildRatingSection(),
            const SizedBox(height: 15),

            // Review Section
            _buildReviewSection(),
            const SizedBox(height: 10),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: _isLoading
          ? CustomButtonUtils.login(
              backgroundColor: AppColors.brightOrange.withOpacity(0.7),
              title: 'Submitting...',
              onPressed: null,
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : CustomButtonUtils.login(
              backgroundColor: _selectedRating > 0
                  ? AppColors.brightOrange
                  : Colors.grey.shade400,
              title: 'Submit Review',
              onPressed: () {},
              // onPressed: _selectedRating > 0 ? _submitReview : null,
            ),
    );
  }

  // Future<void> _submitReview() async {
  //   debugPrint('================ SUBMIT REVIEW START ================');

  //   if (_selectedRating == 0) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Please select a rating')));
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     final reviewProvider = Provider.of<ReviewProvider>(
  //       context,
  //       listen: false,
  //     );
  //     final result = await reviewProvider.submitReview(
  //       orderId: widget.orderId,
  //       orderItemId: widget.orderItemId,
  //       productId: widget.buyerProduct.id,
  //       rating: _selectedRating,
  //       title: _reviewController.text.isNotEmpty
  //           ? _reviewController.text.substring(
  //               0,
  //               min(_reviewController.text.length, 50),
  //             )
  //           : 'Rating for ${widget.buyerProduct.title}',
  //       comment: _reviewController.text,
  //     );

  //     setState(() => _isLoading = false);

  //     if (result['success'] == true) {
  //       _showSuccessDialog();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(result['message']),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('🔥 ERROR: $e');
  //     setState(() => _isLoading = false);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error submitting review: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }

  //   debugPrint('================ SUBMIT REVIEW END =================');
  // }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How was your order?',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Share your experience to help us improve',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${widget.orderItemId}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items: ${widget.items.join(', ')}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Rating',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),

        // Star Rating
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: _selectedRating > 0
                        ? AppColors.brightOrange
                        : Colors.grey.shade400,
                    size: 30,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),

        // Rating Title
        if (_selectedRating > 0)
          Center(
            child: Text(
              _ratingTitles[_selectedRating - 1],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _ratingColors[_selectedRating - 1],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Your Experience',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tell us more about your experience with this order',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 5),

        CustomTextFormField(
          controller: _reviewController,
          hintText:
              'What did you like? What could be improved?\n\nYou can write about:\n• Product quality\n• Delivery experience\n• Seller communication\n• Overall satisfaction',
          maxLines: 8,
          fillcolor: Colors.grey.shade50,
          onChanged: (value) {
            print('Review: $value');
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Your review will help other buyers make better decisions',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Also update the initialization to fetch reviewable orders
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final reviewProvider = Provider.of<ReviewProvider>(
  //       context,
  //       listen: false,
  //     );
  //     reviewProvider.fetchReviewableOrders();
  //   });
  // }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            const Text('Thank You!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your review has been submitted successfully.'),
            const SizedBox(height: 8),
            if (_reviewController.text.isNotEmpty)
              const Text(
                'Your feedback helps us improve our service!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // context.push('/order_confirmation');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return BuyerMainScreen();
                  },
                ),
              );
            },
            child: const Text('Order Review'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
