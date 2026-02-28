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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(context, orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, BuyerOrder order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OrderCardWidget(
      order: order,
      status: OrderStatusBuyer.pending,
      actionButtons: [
        IconButton(
          onPressed: () => provider.startChat(context, order),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
          tooltip: 'Chat with seller',
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
            foregroundColor: colorScheme.primary,
            padding: const EdgeInsets.all(12),
          ),
        ),
        if (order.canCancel)
          OutlinedButton.icon(
            onPressed: () => _cancelOrder(context, order),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error.withOpacity(0.6)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
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

  // ! ?? Cancel Order Dialog
  void _cancelOrder(BuildContext context, BuyerOrder order) async {
    // Check if order can be cancelled
    if (!order.canCancel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot cancel order with status: ${order.statusText}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () => _confirmCancelOrder(context, order),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  // ! ?? Confirm Cancel Order
  void _confirmCancelOrder(BuildContext context, BuyerOrder order) async {
    Navigator.pop(context); // Close dialog

    final provider = context.read<BuyerOrderProvider>();

    try {
      // Show loading
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Cancelling order...'),
            ],
          ),
          backgroundColor: colorScheme.primary,
          duration: const Duration(seconds: 30),
        ),
      );

      // Call API to cancel order
      final success = await provider.cancelOrder(order.orderId);

      // Remove loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order cancelled successfully'),
            backgroundColor: colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Note: The provider already updates the list and summary
        // No need to reload if you're using real-time updates
      } else {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to cancel order'),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
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

/// Order details screen – theme-aware and user-friendly
class OrderDetailsScreen extends StatelessWidget {
  final BuyerOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderId}'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard(
            context,
            title: 'Order details',
            icon: Icons.receipt_long_rounded,
            child: Column(
              children: [
                _buildDetailRow(context, 'Order ID', order.orderId),
                _buildDetailRow(context, 'Status', order.statusText),
                _buildDetailRow(context, 'Order date', order.formattedDate),
                _buildDetailRow(context, 'Total amount', order.formattedTotal),
                _buildDetailRow(context, 'Payment method', order.paymentMethod),
                _buildDetailRow(context, 'Payment status', order.paymentStatus),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            title: 'Items',
            icon: Icons.shopping_bag_outlined,
            child: Column(
              children: order.items.map((item) => _buildOrderItem(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.productImage != null
                ? Image.network(
                    item.productImage!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderIcon(colorScheme),
                  )
                : _placeholderIcon(colorScheme),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seller: ${item.sellerName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity} × ${item.formattedUnitPrice}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.formattedSubtotal,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderIcon(ColorScheme colorScheme) {
    return Container(
      width: 56,
      height: 56,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant),
    );
  }
}
