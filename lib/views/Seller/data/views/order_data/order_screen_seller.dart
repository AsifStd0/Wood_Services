import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/custom_textfield.dart';
import 'package:wood_service/views/Seller/data/models/order_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';

class OrdersScreenSeller extends StatefulWidget {
  const OrdersScreenSeller({super.key});

  @override
  State<OrdersScreenSeller> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreenSeller> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final viewModel = context.read<OrdersViewModel>();
    viewModel.loadOrders();
  }

  void _onSearchChanged() {
    final viewModel = context.read<OrdersViewModel>();
    viewModel.searchOrders(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Orders Management',
        showBackButton: false,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final viewModel = context.read<OrdersViewModel>();
          await viewModel.loadOrders();
        },
        child: Column(
          children: [
            // Statistics Bar
            const _StatisticsBar(),

            // Search Bar
            _SearchBar(searchController: _searchController),

            // Status Filter Bar
            const _StatusFilterBar(),

            // Orders List
            const Expanded(child: _OrdersList()),
          ],
        ),
      ),
    );
  }
}

class _StatisticsBar extends StatelessWidget {
  const _StatisticsBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total',
                '${viewModel.totalOrders}',
                Colors.blue,
                Icons.inventory_2_rounded,
              ),
              _buildStatItem(
                'Pending',
                '${viewModel.pendingOrders}',
                Colors.orange,
                Icons.pending_rounded,
              ),
              _buildStatItem(
                'Accepted',
                '${viewModel.acceptedOrders}',
                Colors.green,
                Icons.check_circle_rounded,
              ),
              _buildStatItem(
                'Completed',
                '${viewModel.completedOrders}',
                Colors.purple,
                Icons.verified_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController searchController;

  const _SearchBar({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: CustomTextFormField(
        controller: searchController,
        hintText: 'Search by name or order #',
        prefixIcon: const Icon(Icons.search_sharp, size: 24),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            searchController.clear();
            final viewModel = context.read<OrdersViewModel>();
            viewModel.searchOrders('');
          },
        ),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<OrdersViewModel>();
    final selectedStatus = viewModel.selectedStatus;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              label: 'All',
              isSelected: selectedStatus == null,
              onSelected: () => viewModel.setStatusFilter(null),
            ),
            ...OrderStatus.values.map((status) {
              return _buildFilterChip(
                context,
                label: status.displayName,
                isSelected: selectedStatus == status,
                color: status.color,
                onSelected: () => viewModel.setStatusFilter(status),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
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
}

class _OrdersList extends StatelessWidget {
  const _OrdersList();

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
                  viewModel.errorMessage,
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
            if (order.status == OrderStatus.requested ||
                order.status == OrderStatus.pending ||
                order.status == OrderStatus.accepted ||
                order.status == OrderStatus.processing)
              Row(
                children: [
                  if (order.status == OrderStatus.requested ||
                      order.status == OrderStatus.pending)
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

                  if (order.status == OrderStatus.requested ||
                      order.status == OrderStatus.pending)
                    const SizedBox(width: 8),

                  if (order.status == OrderStatus.requested ||
                      order.status == OrderStatus.pending)
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

                  if (order.status == OrderStatus.accepted)
                    Expanded(
                      child: _buildActionButton(
                        'Process',
                        Colors.blue,
                        Icons.settings_rounded,
                        () => _updateOrderStatus(
                          context,
                          order,
                          OrderStatus.processing,
                        ),
                      ),
                    ),

                  if (order.status == OrderStatus.processing)
                    Expanded(
                      child: _buildActionButton(
                        'Ship',
                        Colors.purple,
                        Icons.local_shipping_rounded,
                        () => _updateOrderStatus(
                          context,
                          order,
                          OrderStatus.shipped,
                        ),
                      ),
                    ),

                  if (order.status == OrderStatus.shipped)
                    Expanded(
                      child: _buildActionButton(
                        'Deliver',
                        Colors.green,
                        Icons.verified_rounded,
                        () => _updateOrderStatus(
                          context,
                          order,
                          OrderStatus.delivered,
                        ),
                      ),
                    ),

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
              try {
                final viewModel = context.read<OrdersViewModel>();
                // Pass order.id (MongoDB _id) - the ViewModel will convert it
                await viewModel.updateOrderStatus(order.id, newStatus);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order #${order.orderId} updated to ${newStatus.displayName}',
                    ),
                    backgroundColor: newStatus.color,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
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

                      // Order Summary
                      _buildSectionTitle('Order Summary'),
                      _buildDetailRow('Items', order.itemCountText),
                      _buildDetailRow(
                        'Subtotal',
                        '₹${order.subtotal.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Shipping',
                        '₹${order.shippingFee.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Tax',
                        '₹${order.taxAmount.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow('Total', order.formattedAmount),

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
