import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/comman_widget.dart';

class AcceptedOrdersTab extends StatelessWidget {
  final List<BuyerOrder> orders;

  const AcceptedOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const OrderEmptyState(
        message: 'No accepted orders',
        icon: Icons.check_circle_outline,
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
    final provider = context.read<BuyerOrderProvider>();

    return OrderCardWidget(
      order: order,
      status: OrderStatusBuyer.accepted,
      showProgressBar: true,
      customContent: OrderTimelineWidget(order: order),
      actionButtons: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _trackOrder(context, order),
            icon: const Icon(Icons.track_changes, size: 18),
            label: const Text('Track'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => provider.startChat(context, order),
            icon: const Icon(Icons.chat, size: 18),
            label: const Text('Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
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
                order.deliveredAt == null
                    ? 'Started: ${DateFormat('MMM dd, yyyy').format(order.processedAt!)}'
                    : 'Processing: ${DateFormat('MMM dd, yyyy').format(order.processedAt!)}',
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
