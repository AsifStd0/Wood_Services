import 'package:flutter/material.dart';

class DeclinedOrdersTab extends StatelessWidget {
  const DeclinedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderCard(
          orderId: '#WOOD118',
          productName: 'Teak Wood Bench',
          sellerName: 'Garden Furniture',
          price: 199.99,
          orderDate: '2024-01-05',
          declinedDate: '2024-01-06',
          reason: 'Out of stock',
          status: 'Declined',
          statusColor: Colors.red,
        ),
        _buildOrderCard(
          orderId: '#WOOD119',
          productName: 'Pine Wood Cabinet',
          sellerName: 'Storage Solutions',
          price: 299.99,
          orderDate: '2024-01-07',
          declinedDate: '2024-01-08',
          reason: 'Payment failed',
          status: 'Declined',
          statusColor: Colors.red,
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
    required String declinedDate,
    required String reason,
    required String status,
    required Color statusColor,
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

            // Decline Reason
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.red[400], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reason: $reason',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Declined on: $declinedDate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ordered: $orderDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                // Reorder or find similar
              },
              child: const Text('Find Similar Products'),
            ),
          ],
        ),
      ),
    );
  }
}
