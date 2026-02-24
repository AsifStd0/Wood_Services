import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/constants/app_strings.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/models/order_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';

/// Orders List Widget
class OrdersList extends StatelessWidget {
  const OrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.orders.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (viewModel.hasError) {
          return _ErrorStateWidget(
            message: viewModel.errorMessage ?? 'An error occurred',
            onRetry: () => viewModel.loadOrders(),
          );
        }

        if (viewModel.filteredOrders.isEmpty) {
          return _EmptyStateWidget(
            selectedStatus: viewModel.selectedStatus,
            onViewAll: viewModel.selectedStatus != null
                ? () => viewModel.setStatusFilter(null)
                : null,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: viewModel.filteredOrders.length,
          itemBuilder: (context, index) {
            return OrderCard(order: viewModel.filteredOrders[index]);
          },
        );
      },
    );
  }
}

/// Order Card Widget
class OrderCard extends StatelessWidget {
  final OrderModelSeller order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetails(context, order),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#${order.orderId}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  order.buyerName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: order.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: order.status.color,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(order.status),
                            size: 12,
                            color: order.status.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.status.displayName,
                            style: TextStyle(
                              color: order.status.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),

                // Order Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.shopping_bag_rounded,
                          text: 'Items: ${order.itemCountText}',
                        ),
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          text: order.formattedDate,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        order.formattedAmount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                if (_shouldShowActions(order.status))
                  _buildActionButtons(context, order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowActions(OrderStatus status) {
    return status == OrderStatus.pending ||
        status == OrderStatus.accepted ||
        status == OrderStatus.inProgress;
  }

  Widget _buildActionButtons(BuildContext context, OrderModelSeller order) {
    return Column(
      children: [
        Row(
          children: [
            if (order.status == OrderStatus.pending) ...[
              Expanded(
                child: _ActionButton(
                  text: 'Accept',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  onPressed: () => _updateOrderStatus(
                    context,
                    order,
                    OrderStatus.accepted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  text: 'Reject',
                  icon: Icons.cancel_rounded,
                  color: AppColors.error,
                  onPressed: () => _updateOrderStatus(
                    context,
                    order,
                    OrderStatus.rejected,
                  ),
                ),
              ),
            ] else if (order.status == OrderStatus.accepted) ...[
              Expanded(
                child: _ActionButton(
                  text: 'Start Work',
                  icon: Icons.play_circle_rounded,
                  color: AppColors.info,
                  onPressed: () => _updateOrderStatus(
                    context,
                    order,
                    OrderStatus.inProgress,
                  ),
                ),
              ),
            ] else if (order.status == OrderStatus.inProgress) ...[
              Expanded(
                child: _ActionButton(
                  text: 'Complete',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  onPressed: () => _updateOrderStatus(
                    context,
                    order,
                    OrderStatus.completed,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                text: 'Details',
                icon: Icons.visibility_rounded,
                color: AppColors.textSecondary,
                onPressed: () => _showOrderDetails(context, order),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_rounded;
      case OrderStatus.accepted:
        return Icons.check_circle_rounded;
      case OrderStatus.inProgress:
        return Icons.autorenew_rounded;
      case OrderStatus.completed:
        return Icons.done_all_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      case OrderStatus.rejected:
        return Icons.close_rounded;
    }
  }

  void _updateOrderStatus(
    BuildContext context,
    OrderModelSeller order,
    OrderStatus newStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _getStatusIcon(newStatus),
              color: newStatus.color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Update to ${newStatus.displayName}?'),
            ),
          ],
        ),
        content: Text(
          'Update order #${order.orderId} to ${newStatus.displayName}?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final localContext = context;

              try {
                final viewModel = localContext.read<OrdersViewModel>();
                await viewModel.updateOrderStatus(order.id, newStatus);

                if (!localContext.mounted) return;

                ScaffoldMessenger.of(localContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order #${order.orderId} updated to ${newStatus.displayName}',
                    ),
                    backgroundColor: newStatus.color,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } catch (e) {
                if (!localContext.mounted) return;

                ScaffoldMessenger.of(localContext).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus.color,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModelSeller order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(order: order),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Order Details Bottom Sheet
class OrderDetailsSheet extends StatelessWidget {
  final OrderModelSeller order;

  const OrderDetailsSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderId}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.formattedDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: order.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: order.status.color),
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
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle('Customer Information'),
                      _DetailRow('Name', order.buyerName),
                      _DetailRow('Email', order.buyerEmail),
                      _DetailRow(
                        'Phone',
                        order.buyerPhone ?? 'Not provided',
                      ),
                      if (order.buyerAddress != null)
                        _DetailRow('Address', order.buyerAddress!),

                      const SizedBox(height: 24),

                      if (order.orderDetails != null) ...[
                        _SectionTitle('Order Details'),
                        if (order.orderDescription != null)
                          _DetailRow('Description', order.orderDescription!),
                        if (order.orderLocation != null)
                          _DetailRow('Location', order.orderLocation!),
                        if (order.preferredDate != null)
                          _DetailRow(
                            'Preferred Date',
                            _formatDate(order.preferredDate!),
                          ),
                        if (order.estimatedDuration != null)
                          _DetailRow(
                            'Estimated Duration',
                            order.estimatedDuration!,
                          ),
                        const SizedBox(height: 24),
                      ],

                      _SectionTitle('Order Summary'),
                      _DetailRow('Items', order.itemCountText),
                      if (order.pricing != null) ...[
                        if (order.unitPrice != null)
                          _DetailRow(
                            'Unit Price',
                            '${order.currency ?? 'USD'} ${order.unitPrice!.toStringAsFixed(2)}',
                          ),
                        if (order.useSalePrice && order.salePrice != null)
                          _DetailRow(
                            'Sale Price',
                            '${order.currency ?? 'USD'} ${order.salePrice!.toStringAsFixed(2)}',
                          ),
                      ],
                      _DetailRow(
                        'Subtotal',
                        '${order.currency ?? 'USD'} ${order.subtotal.toStringAsFixed(2)}',
                      ),
                      _DetailRow(
                        'Shipping',
                        '${order.currency ?? 'USD'} ${order.shippingFee.toStringAsFixed(2)}',
                      ),
                      _DetailRow(
                        'Tax',
                        '${order.currency ?? 'USD'} ${order.taxAmount.toStringAsFixed(2)}',
                      ),
                      Divider(color: AppColors.border, height: 24),
                      _DetailRow(
                        'Total',
                        '${order.currency ?? 'USD'} ${order.totalAmount.toStringAsFixed(2)}',
                        isTotal: true,
                      ),

                      const SizedBox(height: 24),

                      _SectionTitle('Payment Information'),
                      _DetailRow(
                        'Method',
                        order.paymentMethod.toUpperCase(),
                      ),
                      _DetailRow('Status', order.paymentStatus),

                      const SizedBox(height: 24),

                      _SectionTitle('Order Items (${order.items.length})'),
                      ...order.items.map(
                        (item) => _OrderItemCard(
                          item: item,
                          currency: order.currency,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Close Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _DetailRow(this.label, this.value, {this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final String? currency;

  const _OrderItemCard({
    required this.item,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (item.productImage != null)
            Container(
              width: 60,
              height: 60,
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image_rounded, color: AppColors.textSecondary),
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
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} × ${currency ?? 'USD'} ${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${currency ?? 'USD'} ${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error State Widget
class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty State Widget
class _EmptyStateWidget extends StatelessWidget {
  final OrderStatus? selectedStatus;
  final VoidCallback? onViewAll;

  const _EmptyStateWidget({
    required this.selectedStatus,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.extraLightGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                selectedStatus == null
                    ? 'No orders yet'
                    : 'No ${selectedStatus!.displayName.toLowerCase()} orders',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Orders will appear here when customers place them',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (onViewAll != null) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View all orders'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Status Filter Bar Widget
class StatusFilterBar extends StatelessWidget {
  const StatusFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        final selectedStatus = viewModel.selectedStatus;

        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: selectedStatus == null,
                  onSelected: () => viewModel.setStatusFilter(null),
                ),
                const SizedBox(width: 8),
                ...OrderStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: status.displayName,
                      isSelected: selectedStatus == status,
                      color: status.color,
                      onSelected: () => viewModel.setStatusFilter(status),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 40,
            maxHeight: 40,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.extraLightGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (color ?? AppColors.primary)
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
