import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';

/// Common widget for displaying order cards across all order status tabs
class OrderCardWidget extends StatelessWidget {
  final BuyerOrder order;
  final OrderStatusBuyer status;
  final Widget? customContent; // For status-specific content
  final List<Widget>? actionButtons; // Custom action buttons
  final bool showProgressBar; // Show progress bar for accepted orders
  final bool showReviewSection; // Show review section for completed orders
  final bool showDeclineReason; // Show decline reason for declined orders
  final VoidCallback? onRateOrder; // Callback for rating order

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.status,
    this.customContent,
    this.actionButtons,
    this.showProgressBar = false,
    this.showReviewSection = false,
    this.showDeclineReason = false,
    this.onRateOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 4, color: order.statusColor),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(context),
                const SizedBox(height: 16),

                _buildProductInfo(context),
                const SizedBox(height: 16),

                // Custom Content (timeline, progress, review, etc.)
                if (customContent != null) ...[
                  customContent!,
                  const SizedBox(height: 16),
                ],

                if (showProgressBar) ...[
                  _buildProgressBar(context),
                  const SizedBox(height: 16),
                ],

                // Review Section (for completed orders)
                if (showReviewSection) ...[
                  _buildReviewSection(context),
                  const SizedBox(height: 16),
                ],

                if (showDeclineReason) ...[
                  _buildDeclineReason(context),
                  const SizedBox(height: 16),
                ],

                _buildOrderDetailsRow(context),
                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                const SizedBox(height: 14),

                if (actionButtons != null && actionButtons!.isNotEmpty)
                  _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '#${order.orderId}',

                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: order.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                order.statusText,
                style: TextStyle(
                  color: order.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    if (order.items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 52,
                  height: 52,
                  color: colorScheme.surfaceContainerHighest,
                  child: order.items.first.productImage != null
                      ? Image.network(
                          order.items.first.productImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Icon(
                          Icons.image_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.items.first.productName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (order.items.length > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+ ${order.items.length - 1} more item${order.items.length > 2 ? 's' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.store_outlined, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                order.items.first.sellerName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.shopping_bag_outlined,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${order.itemsCount} item${order.itemsCount != 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    double progress = 0.0;
    if (order.status == OrderStatusBuyer.accepted) progress = 0.3;
    if (order.processedAt != null && order.deliveredAt == null) progress = 0.6;
    if (order.shippedAt != null) progress = 0.8;
    if (order.deliveredAt != null) progress = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order Progress',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReviewed = order.reviewed;

    if (isReviewed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thank you for your review!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (order.review != null &&
                      order.review!['rating'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: index < order.review!['rating']
                              ? colorScheme.tertiary
                              : colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.tertiary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_border_rounded,
                color: colorScheme.onTertiary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How was your experience?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rate this order to help other buyers',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onRateOrder,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Rate Now'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDeclineReason(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCancelled = order.status == OrderStatusBuyer.cancelled;
    final declinedDate = isCancelled
        ? (order.cancelledAt ?? order.requestedAt)
        : (order.rejectedAt ?? order.requestedAt);
    final reason = isCancelled ? 'Cancelled by buyer' : 'Rejected by seller';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCancelled ? Icons.cancel_rounded : Icons.block_rounded,
              color: colorScheme.onError,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason: $reason',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isCancelled ? 'Cancelled' : 'Rejected'} on: ${DateFormat('MMM dd, yyyy').format(declinedDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Ordered: ${order.formattedDate}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          ),
          child: Text(
            order.formattedTotal,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: actionButtons!,
    );
  }
}

/// Empty state widget
class OrderEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const OrderEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Orders in this tab will show up here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Timeline widget for accepted orders
class OrderTimelineWidget extends StatelessWidget {
  final BuyerOrder order;

  const OrderTimelineWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            context,
            'Order Placed',
            DateFormat('MMM dd, yyyy').format(order.requestedAt),
            Icons.shopping_cart_rounded,
            true,
          ),
          _buildTimelineItem(
            context,
            'Accepted',
            order.acceptedAt != null
                ? DateFormat('MMM dd, yyyy').format(order.acceptedAt!)
                : 'Pending',
            Icons.check_circle_rounded,
            order.acceptedAt != null,
          ),
          _buildTimelineItem(
            context,
            order.processedAt != null && order.deliveredAt == null
                ? 'In Progress'
                : 'Processing',
            order.processedAt != null
                ? DateFormat('MMM dd, yyyy').format(order.processedAt!)
                : 'Pending',
            order.processedAt != null && order.deliveredAt == null
                ? Icons.build_rounded
                : Icons.settings_rounded,
            order.processedAt != null,
          ),
          if (order.shippedAt != null)
            _buildTimelineItem(
              context,
              'Shipped',
              DateFormat('MMM dd, yyyy').format(order.shippedAt!),
              Icons.local_shipping_rounded,
              true,
            ),
          _buildTimelineItem(
            context,
            order.deliveredAt != null ? 'Completed' : 'Delivered',
            order.deliveredAt != null
                ? DateFormat('MMM dd, yyyy').format(order.deliveredAt!)
                : 'Estimated: ${_getEstimatedDelivery(order.requestedAt)}',
            order.deliveredAt != null
                ? Icons.check_circle_rounded
                : Icons.home_rounded,
            order.deliveredAt != null,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isCompleted,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isCompleted
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEstimatedDelivery(DateTime orderDate) {
    final estimatedDate = orderDate.add(const Duration(days: 7));
    return DateFormat('MMM dd, yyyy').format(estimatedDate);
  }
}
