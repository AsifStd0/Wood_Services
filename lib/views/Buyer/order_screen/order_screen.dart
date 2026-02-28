import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/accepted_orders_tab.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/completed_orders_tab.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/declined_orders_tab.dart';
import 'package:wood_service/views/Buyer/order_screen/order_status/pending_order.dart';

class OrdersScreen extends StatefulWidget {
  final int initialTab;

  const OrdersScreen({super.key, this.initialTab = 0});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final provider = context.read<BuyerOrderProvider>();
    provider.loadOrderSummary();
    _loadTabOrders(widget.initialTab);
  }

  void _loadTabOrders(int index) {
    final provider = context.read<BuyerOrderProvider>();
    OrderStatusBuyer status;
    switch (index) {
      case 0:
        status = OrderStatusBuyer.pending;
        break;
      case 1:
        status = OrderStatusBuyer.accepted;
        break;
      case 2:
        status = OrderStatusBuyer.declined;
        break;
      case 3:
        status = OrderStatusBuyer.completed;
        break;
      default:
        status = OrderStatusBuyer.pending;
    }
    provider.loadOrders(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<BuyerOrderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_bag_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'My Orders',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withOpacity(0.12),
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: _loadTabOrders,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerHeight: 0,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: [
                    Tab(text: 'Pending (${provider.summary['pending']})'),
                    Tab(text: 'Accepted (${provider.summary['accepted']})'),
                    Tab(text: 'Declined (${provider.summary['declined']})'),
                    Tab(text: 'Completed (${provider.summary['completed']})'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildTab(
                provider,
                OrderStatusBuyer.pending,
                () async {
                  await provider.loadOrders(status: OrderStatusBuyer.pending);
                  await provider.loadOrderSummary();
                },
                PendingOrdersTab(
                  orders: provider.getFilteredOrders(OrderStatusBuyer.pending),
                  provider: provider,
                ),
              ),
              _buildTab(
                provider,
                OrderStatusBuyer.accepted,
                () async {
                  await provider.loadOrders(status: OrderStatusBuyer.accepted);
                  await provider.loadOrderSummary();
                },
                AcceptedOrdersTab(
                  orders: provider.getFilteredOrders(OrderStatusBuyer.accepted),
                ),
              ),
              _buildTab(
                provider,
                OrderStatusBuyer.declined,
                () async {
                  await provider.loadOrders(status: OrderStatusBuyer.declined);
                  await provider.loadOrderSummary();
                },
                DeclinedOrdersTab(
                  orders: provider.getFilteredOrders(OrderStatusBuyer.declined),
                ),
              ),
              _buildTab(
                provider,
                OrderStatusBuyer.completed,
                () async {
                  await provider.loadOrders(status: OrderStatusBuyer.completed);
                  await provider.loadOrderSummary();
                },
                CompletedOrdersTab(
                  orders: provider.getFilteredOrders(
                    OrderStatusBuyer.completed,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
    BuyerOrderProvider provider,
    OrderStatusBuyer filter,
    Future<void> Function() onRefresh,
    Widget tabChild,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = provider.isLoading && provider.currentFilter == filter;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colorScheme.primary,
      child: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading orders...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : tabChild,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
