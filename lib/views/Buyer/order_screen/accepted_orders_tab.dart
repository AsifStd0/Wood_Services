import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_model.dart';

class AcceptedOrdersTab extends StatelessWidget {
  final List<BuyerOrder> orders;

  const AcceptedOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _buildEmptyState('No accepted orders');
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
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
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
    // Calculate progress based on order status
    double progress = 0.0;
    if (order.status == OrderStatusBuyer.accepted) progress = 0.3;
    if (order.processedAt != null) progress = 0.6;
    if (order.shippedAt != null) progress = 0.8;
    if (order.deliveredAt != null) progress = 1.0;

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
                    order.statusText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: order.statusColor,
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
            const SizedBox(height: 8),

            // Order Timeline
            _buildTimelineRow(
              'Order Placed',
              DateFormat('MMM dd, yyyy').format(order.requestedAt),
              Icons.shopping_cart,
              isCompleted: true,
            ),
            _buildTimelineRow(
              'Accepted',
              order.acceptedAt != null
                  ? DateFormat('MMM dd, yyyy').format(order.acceptedAt!)
                  : 'Pending',
              Icons.check_circle,
              isCompleted: order.acceptedAt != null,
            ),
            _buildTimelineRow(
              order.processedAt != null ? 'Processing' : 'Processing',
              order.processedAt != null
                  ? DateFormat('MMM dd, yyyy').format(order.processedAt!)
                  : 'Pending',
              Icons.settings,
              isCompleted: order.processedAt != null,
            ),
            _buildTimelineRow(
              order.shippedAt != null ? 'Shipped' : 'Shipping',
              order.shippedAt != null
                  ? DateFormat('MMM dd, yyyy').format(order.shippedAt!)
                  : 'Estimated: ${_getEstimatedDelivery(order.requestedAt)}',
              Icons.local_shipping,
              isCompleted: order.shippedAt != null,
            ),
            _buildTimelineRow(
              'Delivered',
              order.deliveredAt != null
                  ? DateFormat('MMM dd, yyyy').format(order.deliveredAt!)
                  : 'Estimated: ${_getEstimatedDelivery(order.requestedAt)}',
              Icons.home,
              isCompleted: order.deliveredAt != null,
            ),

            const SizedBox(height: 12),

            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // Estimated Delivery & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Est. Delivery: ${_getEstimatedDelivery(order.requestedAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (order.shippedAt != null)
                      Text(
                        'Shipped on: ${DateFormat('MMM dd').format(order.shippedAt!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
                Text(
                  order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _trackOrder(context, order),
                    child: const Text('Track Order'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _contactSeller(context, order),
                    child: const Text('Contact Seller'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(
    String title,
    String subtitle,
    IconData icon, {
    bool isCompleted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isCompleted ? Colors.green : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEstimatedDelivery(DateTime orderDate) {
    final estimatedDate = orderDate.add(const Duration(days: 7));
    return DateFormat('MMM dd, yyyy').format(estimatedDate);
  }

  void _trackOrder(BuildContext context, BuyerOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Order #${order.orderId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.statusText}'),
            if (order.acceptedAt != null)
              Text(
                'Accepted: ${DateFormat('MMM dd, yyyy').format(order.acceptedAt!)}',
              ),
            if (order.processedAt != null)
              Text(
                'Processing: ${DateFormat('MMM dd, yyyy').format(order.processedAt!)}',
              ),
            if (order.shippedAt != null)
              Text(
                'Shipped: ${DateFormat('MMM dd, yyyy').format(order.shippedAt!)}',
              ),
            if (order.deliveredAt != null)
              Text(
                'Delivered: ${DateFormat('MMM dd, yyyy').format(order.deliveredAt!)}',
              ),
            const SizedBox(height: 16),
            const Text('Estimated delivery in 3-5 business days'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactSeller(BuildContext context, BuyerOrder order) {
    if (order.items.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Seller'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seller: ${order.items.first.sellerName}'),
            if (order.items.first.sellerEmail != null)
              Text('Email: ${order.items.first.sellerEmail}'),
            if (order.items.first.sellerPhone != null)
              Text('Phone: ${order.items.first.sellerPhone}'),
            const SizedBox(height: 16),
            const Text('You can contact the seller regarding:'),
            const Text('• Order updates'),
            const Text('• Delivery inquiries'),
            const Text('• Product questions'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement contact functionality
              Navigator.pop(context);
            },
            child: const Text('Contact Now'),
          ),
        ],
      ),
    );
  }
}
