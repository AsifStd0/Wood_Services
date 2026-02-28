import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/comman_widget.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/pending_order.dart' show OrderDetailsScreen;

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
        OutlinedButton.icon(
          onPressed: () => _viewDetails(context, order),
          icon: const Icon(Icons.info_outline_rounded, size: 18),
          label: const Text('Details'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ],
    );
  }

  void _viewDetails(BuildContext context, BuyerOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );
  }
}
