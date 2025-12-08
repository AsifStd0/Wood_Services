import 'package:flutter/material.dart';

class PaymentManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Payment Statistics
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaymentStat('Total Revenue', '\$45,670', Colors.green),
                _buildPaymentStat('Pending', '\$2,340', Colors.orange),
                _buildPaymentStat('Failed', '\$890', Colors.red),
              ],
            ),
          ),

          // Payment List
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => _buildPaymentItem(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStat(String title, String amount, Color color) {
    return Column(
      children: [
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPaymentItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.payment, color: Colors.green, size: 20),
        ),
        title: const Text('Payment #PAY12345'),
        subtitle: const Text('Order #ORD67890 • 15 Dec 2024'),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '\$1,200.00',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Completed',
                style: TextStyle(color: Colors.green, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
