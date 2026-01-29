import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/comman_widget.dart';

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
      return const OrderEmptyState(
        message: 'No pending orders',
        icon: Icons.pending_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadOrders(status: OrderStatusBuyer.pending);
        await provider.loadOrderSummary();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(context, orders[index]);
        },
      ),
    );
  }

  // ! ?? Chats Cancel Details Button
  Widget _buildOrderCard(BuildContext context, BuyerOrder order) {
    return OrderCardWidget(
      order: order,
      status: OrderStatusBuyer.pending,
      actionButtons: [
        // Chat Button
        IconButton(
          onPressed: () => provider.startChat(context, order),
          icon: const Icon(Icons.chat_bubble_outline, size: 20),
          color: Colors.blue,
          tooltip: 'Chat with seller',
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue[50],
            padding: const EdgeInsets.all(12),
          ),
        ),
        // Cancel Button
        if (order.canCancel)
          OutlinedButton.icon(
            onPressed: () => _cancelOrder(context, order),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red[300]!),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        // Details Button
        OutlinedButton.icon(
          onPressed: () => _viewDetails(context, order),
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Details'),
        ),
      ],
    );
  }

  // ! ?? Cancel Order Dialog
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

  // ! ?? Confirm Cancel Order
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

  // ! ?? View Details Order Detail screen
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
      padding: const EdgeInsets.symmetric(vertical: 5),
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
