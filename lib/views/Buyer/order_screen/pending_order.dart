import 'package:flutter/material.dart';

class PendingOrdersTab extends StatelessWidget {
  const PendingOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderCard(
          orderId: '#WOOD123',
          productName: 'Teak Wood Planks - 10 pieces',
          sellerName: 'Premium Timber Co.',
          price: 299.99,
          orderDate: '2024-01-15',
          estimatedDelivery: '2024-01-20',
          status: 'Pending',
          statusColor: Colors.orange,
          showActions: true,
          context: context,
        ),
        _buildOrderCard(
          orderId: '#WOOD124',
          productName: 'Mahogany Dining Table',
          sellerName: 'Luxury Furniture',
          price: 599.99,
          orderDate: '2024-01-16',
          estimatedDelivery: '2024-01-25',
          status: 'Pending',
          statusColor: Colors.orange,
          showActions: true,
          context: context,
        ),
        _buildOrderCard(
          orderId: '#WOOD125',
          productName: 'Oak Wood Chairs (Set of 4)',
          sellerName: 'Wood Crafts',
          price: 199.99,
          orderDate: '2024-01-14',
          estimatedDelivery: '2024-01-22',
          status: 'Pending',
          statusColor: Colors.orange,
          showActions: true,
          context: context,
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String productName,
    required String sellerName,
    required double price,
    required String orderDate,
    required String estimatedDelivery,
    required String status,
    required Color statusColor,
    bool showActions = false,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                Chip(
                  label: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Info
            Text(
              productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Seller: $sellerName',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // Order Details
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Ordered: $orderDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Est: $estimatedDelivery',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Price and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                if (showActions) ...[
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showOrderAction(context, orderId, 'accepted');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          _showOrderAction(context, orderId, 'declined');
                        },
                        child: const Text('Decline'),
                      ),
                    ],
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () {
                      // View order details
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderAction(BuildContext context, String orderId, String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${action.capitalize()} Order'),
          content: Text('Are you sure you want to $action order $orderId?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle order action
                Navigator.of(context).pop();
                _showActionSuccess(context, orderId, action);
              },
              child: Text(
                action.capitalize(),
                style: TextStyle(
                  color: action == 'accepted' ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showActionSuccess(BuildContext context, String orderId, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order $orderId ${action} successfully!'),
        backgroundColor: action == 'accepted' ? Colors.green : Colors.orange,
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
