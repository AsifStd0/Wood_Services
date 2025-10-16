import 'package:flutter/material.dart';

class CompletedOrdersTab extends StatelessWidget {
  const CompletedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderCard(
          orderId: '#WOOD115',
          productName: 'Oak Wood Dining Table',
          sellerName: 'Premium Furniture',
          price: 499.99,
          orderDate: '2024-01-01',
          completedDate: '2024-01-08',
          status: 'Completed',
          statusColor: Colors.blue,
          isRated: true,
          rating: 5,
        ),
        _buildOrderCard(
          orderId: '#WOOD116',
          productName: 'Maple Wood Chairs (Set of 2)',
          sellerName: 'Home Comfort',
          price: 129.99,
          orderDate: '2024-01-03',
          completedDate: '2024-01-09',
          status: 'Completed',
          statusColor: Colors.blue,
          isRated: false,
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
    required String completedDate,
    required String status,
    required Color statusColor,
    required bool isRated,
    int rating = 0,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Text(
              productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Seller: $sellerName',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 12),

            // Order Timeline
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Ordered: $orderDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Completed: $completedDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 12),

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

                if (isRated) ...[
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 20,
                          color: index < rating
                              ? Colors.amber
                              : Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      // Rate product
                    },
                    child: const Text('Rate Product'),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reorder
                    },
                    child: const Text('Reorder'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Download invoice
                    },
                    child: const Text('Invoice'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
