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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Status indicator bar at top
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: order.statusColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header
                  _buildOrderHeader(),
                  const SizedBox(height: 16),

                  // Product Info Section
                  _buildProductInfo(),
                  const SizedBox(height: 16),

                  // Custom Content (timeline, progress, review, etc.)
                  if (customContent != null) ...[
                    customContent!,
                    const SizedBox(height: 16),
                  ],

                  // Progress Bar (for accepted orders)
                  if (showProgressBar) ...[
                    _buildProgressBar(),
                    const SizedBox(height: 16),
                  ],

                  // Review Section (for completed orders)
                  if (showReviewSection) ...[
                    _buildReviewSection(context),
                    const SizedBox(height: 16),
                  ],

                  // Decline Reason (for declined orders)
                  if (showDeclineReason) ...[
                    _buildDeclineReason(),
                    const SizedBox(height: 16),
                  ],

                  // Order Date & Price Row
                  _buildOrderDetailsRow(),
                  const SizedBox(height: 16),

                  // Divider
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Action Buttons
                  if (actionButtons != null && actionButtons!.isNotEmpty)
                    _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 14, color: Colors.brown[700]),
                  const SizedBox(width: 6),
                  Text(
                    '#${order.orderId}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.15),
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
              const SizedBox(width: 3),
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

  Widget _buildProductInfo() {
    if (order.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: order.items.first.productImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          order.items.first.productImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.image, color: Colors.grey[400]),
                        ),
                      )
                    : Icon(Icons.image, color: Colors.grey[400]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.items.first.productName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (order.items.length > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+ ${order.items.length - 1} more item${order.items.length > 2 ? 's' : ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.store, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Seller: ${order.items.first.sellerName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${order.itemsCount} item${order.itemsCount != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = 0.0;
    if (order.status == OrderStatusBuyer.accepted) progress = 0.3;
    if (order.processedAt != null) progress = 0.6;
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
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
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    final isReviewed = order.reviewed;

    if (isReviewed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.green[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[400],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thank you for your review!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[800],
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
                          Icons.star,
                          size: 14,
                          color: index < order.review!['rating']
                              ? Colors.amber[700]
                              : Colors.grey[300],
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
          gradient: LinearGradient(
            colors: [Colors.orange[50]!, Colors.orange[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[400],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_border,
                color: Colors.white,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rate this order to help other buyers',
                    style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onRateOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Rate Now', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDeclineReason() {
    final isCancelled = order.cancelledAt != null;
    final declinedDate = isCancelled ? order.cancelledAt! : order.rejectedAt!;
    final reason = isCancelled ? 'Cancelled by buyer' : 'Rejected by seller';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[50]!, Colors.red[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[400],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCancelled ? Icons.cancel : Icons.block,
              color: Colors.white,
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isCancelled ? 'Cancelled' : 'Rejected'} on: ${DateFormat('MMM dd, yyyy').format(declinedDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.red[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'Ordered: ${order.formattedDate}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Text(
            order.formattedTotal,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(spacing: 8, runSpacing: 8, children: actionButtons!);
  }
}

/// Empty state widget
class OrderEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const OrderEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your orders will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            'Order Placed',
            DateFormat('MMM dd, yyyy').format(order.requestedAt),
            Icons.shopping_cart,
            true,
          ),
          _buildTimelineItem(
            'Accepted',
            order.acceptedAt != null
                ? DateFormat('MMM dd, yyyy').format(order.acceptedAt!)
                : 'Pending',
            Icons.check_circle,
            order.acceptedAt != null,
          ),
          _buildTimelineItem(
            'Processing',
            order.processedAt != null
                ? DateFormat('MMM dd, yyyy').format(order.processedAt!)
                : 'Pending',
            Icons.settings,
            order.processedAt != null,
          ),
          _buildTimelineItem(
            'Shipped',
            order.shippedAt != null
                ? DateFormat('MMM dd, yyyy').format(order.shippedAt!)
                : 'Estimated: ${_getEstimatedDelivery(order.requestedAt)}',
            Icons.local_shipping,
            order.shippedAt != null,
          ),
          _buildTimelineItem(
            'Delivered',
            order.deliveredAt != null
                ? DateFormat('MMM dd, yyyy').format(order.deliveredAt!)
                : 'Estimated: ${_getEstimatedDelivery(order.requestedAt)}',
            Icons.home,
            order.deliveredAt != null,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    IconData icon,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[400] : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isCompleted ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isCompleted ? Colors.green[700] : Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isCompleted ? Colors.green[600] : Colors.grey[500],
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
