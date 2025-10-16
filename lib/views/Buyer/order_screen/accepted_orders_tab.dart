import 'package:flutter/material.dart';

class AcceptedOrdersTab extends StatelessWidget {
  const AcceptedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderCard(
          orderId: '#WOOD120',
          productName: 'Walnut Coffee Table',
          sellerName: 'Modern Furniture',
          price: 349.99,
          orderDate: '2024-01-10',
          acceptedDate: '2024-01-11',
          estimatedDelivery: '2024-01-18',
          status: 'Accepted',
          statusColor: Colors.green,
          trackingNumber: 'TRACK123456',
          progress: 0.6,
        ),
        _buildOrderCard(
          orderId: '#WOOD121',
          productName: 'Maple Wood Shelves',
          sellerName: 'Home Decor Co.',
          price: 149.99,
          orderDate: '2024-01-12',
          acceptedDate: '2024-01-12',
          estimatedDelivery: '2024-01-19',
          status: 'Accepted',
          statusColor: Colors.green,
          trackingNumber: 'TRACK123457',
          progress: 0.3,
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
    required String acceptedDate,
    required String estimatedDelivery,
    required String status,
    required Color statusColor,
    String? trackingNumber,
    double progress = 0.0,
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

            // Order Timeline
            _buildTimelineRow('Order Placed', orderDate, Icons.shopping_cart),
            _buildTimelineRow(
              'Accepted',
              acceptedDate,
              Icons.check_circle,
              isCompleted: true,
            ),
            _buildTimelineRow(
              'Shipped',
              'In progress',
              Icons.local_shipping,
              isCompleted: progress > 0.5,
            ),
            _buildTimelineRow(
              'Delivered',
              estimatedDelivery,
              Icons.home,
              isCompleted: progress == 1.0,
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

            // Tracking & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trackingNumber != null) ...[
                      Text(
                        'Tracking: $trackingNumber',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'Est. Delivery: $estimatedDelivery',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  '\$$price',
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
                    onPressed: () {
                      // Track order
                    },
                    child: const Text('Track Order'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Contact seller
                    },
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
}
