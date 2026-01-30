import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/comman_widget.dart';

class CompletedOrdersTab extends StatelessWidget {
  final List<BuyerOrder> orders;

  const CompletedOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const OrderEmptyState(
        message: 'No completed orders',
        icon: Icons.verified_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, BuyerOrder order) {
    return OrderCardWidget(
      order: order,
      status: OrderStatusBuyer.completed,
      showReviewSection: true,
      onRateOrder: () => _rateOrder(context, order),
      actionButtons: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _reorder(context, order),
            icon: const Icon(Icons.shopping_cart_outlined, size: 18),
            label: const Text('Reorder'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _downloadInvoice(context, order),
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Invoice'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  void _rateOrder(BuildContext context, BuyerOrder order) {
    int selectedRating = 0;
    final reviewTextController = TextEditingController();

    showDialog(
      // remove  padding etc rating star overflow to roght
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Rate Your Order'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${order.orderId}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order.items.isNotEmpty)
                    Text(
                      order.items.first.productName,
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),

                  // Star Rating
                  const Text('How would you rate this order?'),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons
                                  .star_rounded, // Use rounded star for modern look
                              size: 32,
                              color: index < selectedRating
                                  ? Colors.amber.shade600
                                  : Colors.grey,
                              shadows: index < selectedRating
                                  ? [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Review Text
                  const SizedBox(height: 16),
                  const Text('Add a review (optional):'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewTextController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedRating > 0
                    ? () {
                        // Submit review
                        final provider = context.read<BuyerOrderProvider>();
                        provider.submitReview(
                          order.orderId,
                          rating: selectedRating,
                          comment: reviewTextController.text.isNotEmpty
                              ? reviewTextController.text
                              : null,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for your review!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                child: const Text('Submit Review'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _reorder(BuildContext context, BuyerOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder'),
        content: Text(
          'Add ${order.itemsCount} item${order.itemsCount != 1 ? 's' : ''} from order #${order.orderId} to cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Items added to cart'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(BuildContext context, BuyerOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Invoice'),
        content: const Text('Invoice will be downloaded as PDF'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice downloaded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _viewDetails(BuildContext context, BuyerOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );
  }
}

// Reuse the OrderDetailsScreen from PendingOrdersTab
class OrderDetailsScreen extends StatelessWidget {
  final BuyerOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.orderId}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ... same as in PendingOrdersTab
        ],
      ),
    );
  }
}
