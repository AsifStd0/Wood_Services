import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/comman_widget.dart';

class DeclinedOrdersTab extends StatelessWidget {
  final List<BuyerOrder> orders;

  const DeclinedOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const OrderEmptyState(
        message: 'No declined orders',
        icon: Icons.cancel_outlined,
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
      status: OrderStatusBuyer.declined,
      showDeclineReason: true,
      actionButtons: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _viewDetails(context, order),
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  void _viewDetails(BuildContext context, BuyerOrder order) {
    // Navigate to order details
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );
  }
}

// Reuse OrderDetailsScreen from pending_order.dart
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
