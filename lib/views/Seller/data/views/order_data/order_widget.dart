import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/models/order_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';

class OrdersList extends StatelessWidget {
  const OrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage ?? 'An error occurred',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  viewModel.selectedStatus == null
                      ? 'No orders yet'
                      : 'No ${viewModel.selectedStatus?.displayName.toLowerCase()} orders',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (viewModel.selectedStatus != null)
                  TextButton(
                    onPressed: () => viewModel.setStatusFilter(null),
                    child: const Text('View all orders'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: viewModel.filteredOrders.length,
          itemBuilder: (context, index) {
            return _OrderCard(order: viewModel.filteredOrders[index]);
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModelSeller order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.buyerName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: order.status.color.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: order.status.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Order Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items: ${order.itemCountText}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  order.formattedAmount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            if ( // order.status == OrderStatus.requested ||
            order.status == OrderStatus.pending ||
                order.status == OrderStatus.accepted
            // ||
            // order.status == OrderStatus.processing
            )
              Column(
                children: [
                  Row(
                    children: [
                      if (order.status == OrderStatus.pending) ...[
                        Expanded(
                          child: _buildActionButton(
                            'Accept',
                            Colors.green,
                            Icons.check_circle_rounded,
                            () => _updateOrderStatus(
                              context,
                              order,
                              OrderStatus.accepted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionButton(
                            'Reject',
                            Colors.red,
                            Icons.cancel_rounded,
                            () => _updateOrderStatus(
                              context,
                              order,
                              OrderStatus.rejected,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(width: 8),

                      Expanded(
                        child: _buildActionButton(
                          'Details',
                          Colors.grey,
                          Icons.visibility_rounded,
                          () => _showOrderDetails(context, order),
                        ),
                      ),
                    ],
                  ),

                  // Add Note button for active orders
                  if (order.status == OrderStatus.accepted)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildActionButton(
                          'Add Note',
                          Colors.orange,
                          Icons.note_add_rounded,
                          () => _showAddNoteDialog(context, order),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Update all button calls to use order.orderId instead of order.id
  void _updateOrderStatus(
    BuildContext context,
    OrderModelSeller order,
    OrderStatus newStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update to ${newStatus.displayName}?'),
        content: Text(
          'Update order #${order.orderId} to ${newStatus.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Store context locally since we'll use it after async operation
              final localContext = context;

              try {
                final viewModel = localContext.read<OrdersViewModel>();
                // Pass order.id (MongoDB _id) - the ViewModel will convert it
                await viewModel.updateOrderStatus(order.id, newStatus);

                // Check if widget is still mounted
                if (!localContext.mounted) return;

                ScaffoldMessenger.of(localContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order #${order.orderId} updated to ${newStatus.displayName}',
                    ),
                    backgroundColor: newStatus.color,
                  ),
                );
              } catch (e) {
                // Check if widget is still mounted
                if (!localContext.mounted) return;

                ScaffoldMessenger.of(localContext).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: newStatus.color),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModelSeller order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _OrderDetailsSheet(order: order),
    );
  }

  void _showAddNoteDialog(BuildContext context, OrderModelSeller order) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note to Order'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter note message...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteController.text.trim().isEmpty) {
                // Check mounted before showing snackbar
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a note'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Store context for async operation
              final localContext = context;

              try {
                final viewModel = localContext.read<OrdersViewModel>();
                await viewModel.addOrderNote(
                  order.id,
                  noteController.text.trim(),
                );

                if (localContext.mounted) {
                  ScaffoldMessenger.of(localContext).showSnackBar(
                    const SnackBar(
                      content: Text('Note added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (localContext.mounted) {
                  ScaffoldMessenger.of(localContext).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add note: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final OrderModelSeller order;

  const _OrderDetailsSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: TextStyle(
                        color: order.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Info
                      _buildSectionTitle('Customer Information'),
                      _buildDetailRow('Name', order.buyerName),
                      _buildDetailRow('Email', order.buyerEmail),
                      _buildDetailRow(
                        'Phone',
                        order.buyerPhone ?? 'Not provided',
                      ),
                      if (order.buyerAddress != null)
                        _buildDetailRow('Address', order.buyerAddress!),

                      const SizedBox(height: 20),

                      // Order Details (if available)
                      if (order.orderDetails != null) ...[
                        _buildSectionTitle('Order Details'),
                        if (order.orderDescription != null)
                          _buildDetailRow(
                            'Description',
                            order.orderDescription!,
                          ),
                        if (order.orderLocation != null)
                          _buildDetailRow('Location', order.orderLocation!),
                        if (order.preferredDate != null)
                          _buildDetailRow(
                            'Preferred Date',
                            _formatDate(order.preferredDate!),
                          ),
                        if (order.estimatedDuration != null)
                          _buildDetailRow(
                            'Estimated Duration',
                            order.estimatedDuration!,
                          ),
                        if (order.specialRequirements != null)
                          _buildDetailRow(
                            'Special Requirements',
                            order.specialRequirements!,
                          ),
                        const SizedBox(height: 20),
                      ],

                      // Order Summary
                      _buildSectionTitle('Order Summary'),
                      _buildDetailRow('Items', order.itemCountText),
                      if (order.pricing != null) ...[
                        if (order.unitPrice != null)
                          _buildDetailRow(
                            'Unit Price',
                            '${order.currency ?? 'USD'} ${order.unitPrice!.toStringAsFixed(2)}',
                          ),
                        if (order.useSalePrice && order.salePrice != null)
                          _buildDetailRow(
                            'Sale Price',
                            '${order.currency ?? 'USD'} ${order.salePrice!.toStringAsFixed(2)}',
                          ),
                      ],
                      _buildDetailRow(
                        'Subtotal',
                        '${order.currency ?? 'USD'} ${order.subtotal.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Shipping',
                        '${order.currency ?? 'USD'} ${order.shippingFee.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Tax',
                        '${order.currency ?? 'USD'} ${order.taxAmount.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Total',
                        '${order.currency ?? 'USD'} ${order.totalAmount.toStringAsFixed(2)}',
                      ),

                      const SizedBox(height: 20),

                      // Payment Info
                      _buildSectionTitle('Payment Information'),
                      _buildDetailRow(
                        'Method',
                        order.paymentMethod.toUpperCase(),
                      ),
                      _buildDetailRow('Status', order.paymentStatus),

                      const SizedBox(height: 20),

                      // Order Items
                      _buildSectionTitle('Order Items (${order.items.length})'),
                      ...order.items.map((item) => _buildOrderItem(item)),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          if (item.productImage != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.productImage!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            '₹${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildFilterChip(
  BuildContext context, {
  required String label,
  required bool isSelected,
  Color? color,
  required VoidCallback onSelected,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) => onSelected(),
      backgroundColor: Colors.grey[100],
      selectedColor: color ?? Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

class StatusFilterBar extends StatelessWidget {
  const StatusFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Use Consumer to listen for changes
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        final selectedStatus = viewModel.selectedStatus;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildFilterChip(
                  context,
                  label: 'All',
                  isSelected: selectedStatus == null,
                  onSelected: () => viewModel.setStatusFilter(null),
                ),
                ...OrderStatus.values.map((status) {
                  return buildFilterChip(
                    context,
                    label: status.displayName,
                    isSelected: selectedStatus == status,
                    color: status.color,
                    onSelected: () => viewModel.setStatusFilter(status),
                  );
                }), // Add .toList() here
              ],
            ),
          ),
        );
      },
    );
  }
}
