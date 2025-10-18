// lib/presentation/views/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/models/order.dart';
import 'package:wood_service/views/Seller/data/repository/order_repo.dart';
import 'package:wood_service/widgets/advance_appbar.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';

class OrdersScreenSeller extends StatefulWidget {
  const OrdersScreenSeller({super.key});

  @override
  State<OrdersScreenSeller> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreenSeller> {
  final _viewModel = OrdersViewModel(MockOrderRepository());
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.loadOrders();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _viewModel.searchOrders(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: CustomAppBar(title: 'Orders', showBackButton: false),
        body: const Column(
          children: [_SearchBar(), _StatusFilterBar(), _OrdersList()],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: TextEditingController(text: viewModel.searchQuery),
            onChanged: viewModel.searchOrders,
            decoration: InputDecoration(
              hintText: 'Search orders...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('Completed', OrderStatus.completed, viewModel),
              const SizedBox(width: 8),
              _buildFilterChip('Processing', OrderStatus.processing, viewModel),
              const SizedBox(width: 8),
              _buildFilterChip('Shipped', OrderStatus.shipped, viewModel),
              const SizedBox(width: 8),
              _buildFilterChip('Cancelled', OrderStatus.cancelled, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    OrderStatus status,
    OrdersViewModel viewModel,
  ) {
    final isSelected = viewModel.statusFilter == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        viewModel.filterByStatus(selected ? status : null);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: status.color.withOpacity(0.2),
      checkmarkColor: status.color,
      labelStyle: TextStyle(
        color: isSelected ? status.color : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? status.color : Colors.grey[300]!),
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
        if (viewModel.isLoading) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.hasError) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.filteredOrders.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text(
                'No orders found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.filteredOrders.length,
            itemBuilder: (context, index) {
              return _OrderCard(order: viewModel.filteredOrders[index]);
            },
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderDataModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: order.status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Customer Name
            Text(
              order.customerName,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                      order.itemCountText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.formattedAmount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                // Action Buttons
                Row(
                  children: [
                    _buildActionButton(
                      'Update',
                      Colors.blue,
                      Icons.edit,
                      () => _showUpdateDialog(context, order),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      'Details',
                      Colors.grey,
                      Icons.visibility,
                      () => _showOrderDetails(context, order),
                    ),
                  ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(text)],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, OrderDataModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values.map((status) {
            return ListTile(
              leading: Icon(Icons.circle, color: status.color, size: 12),
              title: Text(status.displayName),
              onTap: () {
                final viewModel = context.read<OrdersViewModel>();
                viewModel.updateOrderStatus(order.id, status);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderDataModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderNumber}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Customer: ${order.customerName}'),
            Text('Items: ${order.itemCountText}'),
            Text('Total: ${order.formattedAmount}'),
            Text('Status: ${order.status.displayName}'),
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
}
