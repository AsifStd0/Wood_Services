import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';

class CompletedOrdersTab extends StatelessWidget {
  final List<BuyerOrder> orders;

  const CompletedOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _buildEmptyState('No completed orders');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, BuyerOrder order) {
    final deliveredDate = order.deliveredAt ?? order.updatedAt;
    final isReviewed = order.reviewed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.orderId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                Chip(
                  label: Text(
                    'Delivered',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Info
            if (order.items.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.items.first.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (order.items.length > 1)
                    Text(
                      '+ ${order.items.length - 1} more item${order.items.length > 2 ? 's' : ''}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            const SizedBox(height: 4),
            if (order.items.isNotEmpty)
              Text(
                'Seller: ${order.items.first.sellerName}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

            const SizedBox(height: 12),

            // Order Timeline
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Ordered: ${DateFormat('MMM dd, yyyy').format(order.requestedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Delivered: ${DateFormat('MMM dd, yyyy').format(deliveredDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Review Status
            if (isReviewed)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thank you for your review!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (order.review != null &&
                              order.review!['rating'] != null)
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: index < order.review!['rating']
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_border,
                      color: Colors.orange[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How was your experience?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Rate this order to help other buyers',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _rateOrder(context, order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Rate Now'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Price and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.formattedTotal,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${order.itemsCount} item${order.itemsCount != 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (!isReviewed)
                  ElevatedButton(
                    onPressed: () => _rateOrder(context, order),
                    child: const Text('Rate Product'),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reorder(context, order),
                    child: const Text('Reorder'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _downloadInvoice(context, order),
                    child: const Text('Download Invoice'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewDetails(context, order),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _rateOrder(BuildContext context, BuyerOrder order) {
    int selectedRating = 0;
    String reviewText = '';

    showDialog(
      context: context,
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
                      fontSize: 16,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          size: 30,
                          color: index < selectedRating
                              ? Colors.amber
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),

                  // Review Text
                  const SizedBox(height: 16),
                  const Text('Add a review (optional):'),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      reviewText = value;
                    },
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
