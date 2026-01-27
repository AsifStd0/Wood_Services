import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/widgets/custom_button.dart';

class PendingOrdersTab extends StatelessWidget {
  final List<BuyerOrder> orders;
  final BuyerOrderProvider provider;
  const PendingOrdersTab({
    super.key,
    required this.orders,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No pending orders',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(context, orders[index], provider);
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    BuyerOrder order,
    BuyerOrderProvider provider,
  ) {
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
            Text(
              'Items: ${order.itemsCount}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // Order Details
            // In your _buildOrderCard method - Row with calendar and chat icon
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Ordered: ${order.formattedDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Price and Actions
            // Price and Actions Row - Add chat button here
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Row(
                  children: [
                    // Chat Button
                    IconButton(
                      onPressed: () => provider.startChat(context, order),
                      icon: Icon(Icons.chat, color: Colors.blue),
                      tooltip: 'Chat with seller',
                    ),
                    const SizedBox(width: 8),
                    CustomButtonUtils.login(
                      width: 80,
                      height: 40,
                      onPressed: () => _cancelOrder(context, order),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _viewDetails(context, order),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _cancelOrder(BuildContext context, BuyerOrder order) async {
    // Check if order can be cancelled
    if (!order.canCancel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot cancel order with status: ${order.statusText}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Cancel Order'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you Want to cancelling this order?'),
                const SizedBox(height: 12),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Order'),
              ),
              ElevatedButton(
                onPressed: () => _confirmCancelOrder(context, order),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Cancel Order'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmCancelOrder(BuildContext context, BuyerOrder order) async {
    Navigator.pop(context); // Close dialog

    final provider = context.read<BuyerOrderProvider>();

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Cancelling order...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 30),
        ),
      );

      // Call API to cancel order
      final success = await provider.cancelOrder(order.orderId);

      // Remove loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Note: The provider already updates the list and summary
        // No need to reload if you're using real-time updates
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // Remove loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewDetails(BuildContext context, BuyerOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );
  }
}

// Create a simple order details screen
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Order ID', order.orderId),
                  _buildDetailRow('Status', order.statusText),
                  _buildDetailRow('Order Date', order.formattedDate),
                  _buildDetailRow('Total Amount', order.formattedTotal),
                  _buildDetailRow('Payment Method', order.paymentMethod),
                  _buildDetailRow('Payment Status', order.paymentStatus),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...order.items.map((item) => _buildOrderItem(item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return ListTile(
      leading: item.productImage != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(item.productImage!),
              radius: 24,
            )
          : const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 24,
              child: Icon(Icons.image, color: Colors.white),
            ),
      title: Text(item.productName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seller: ${item.sellerName}'),
          Text('Qty: ${item.quantity} × ${item.formattedUnitPrice}'),
        ],
      ),
      trailing: Text(item.formattedSubtotal),
    );
  }
}
