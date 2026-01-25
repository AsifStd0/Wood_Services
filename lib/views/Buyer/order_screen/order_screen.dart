import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/order_screen/accepted_orders_tab.dart';
import 'package:wood_service/views/Buyer/Model/buyer_order_model.dart';
import 'package:wood_service/views/Buyer/order_screen/buyer_order_provider.dart';
import 'package:wood_service/views/Buyer/order_screen/completed_orders_tab.dart';
import 'package:wood_service/views/Buyer/order_screen/declined_orders_tab.dart';
import 'package:wood_service/views/Buyer/order_screen/pending_order.dart';

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

    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final provider = context.read<BuyerOrderProvider>();
    provider.loadOrderSummary(); // Load summary counts

    // Load initial tab orders
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
    return Consumer<BuyerOrderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('My Orders'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Pending (${provider.summary['pending']})'),
                Tab(text: 'Accepted (${provider.summary['accepted']})'),
                Tab(text: 'Declined (${provider.summary['declined']})'),
                Tab(text: 'Completed (${provider.summary['completed']})'),
              ],
              onTap: _loadTabOrders,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // 👈 IMPORTANT

            children: [
              // Pending Tab
              RefreshIndicator(
                onRefresh: () async {
                  await provider.loadOrders(status: OrderStatusBuyer.pending);
                  await provider.loadOrderSummary();
                },
                child:
                    provider.isLoading &&
                        provider.currentFilter == OrderStatusBuyer.pending
                    ? const Center(child: CircularProgressIndicator())
                    : PendingOrdersTab(
                        orders: provider.getFilteredOrders(
                          OrderStatusBuyer.pending,
                        ),
                        provider: provider,
                      ),
              ),

              // Accepted Tab
              RefreshIndicator(
                onRefresh: () async {
                  await provider.loadOrders(status: OrderStatusBuyer.accepted);
                  await provider.loadOrderSummary();
                },
                child:
                    provider.isLoading &&
                        provider.currentFilter == OrderStatusBuyer.accepted
                    ? const Center(child: CircularProgressIndicator())
                    : AcceptedOrdersTab(
                        orders: provider.getFilteredOrders(
                          OrderStatusBuyer.accepted,
                        ),
                      ),
              ),

              // Declined Tab
              RefreshIndicator(
                onRefresh: () async {
                  await provider.loadOrders(status: OrderStatusBuyer.declined);
                  await provider.loadOrderSummary();
                },
                child:
                    provider.isLoading &&
                        provider.currentFilter == OrderStatusBuyer.declined
                    ? const Center(child: CircularProgressIndicator())
                    : DeclinedOrdersTab(
                        orders: provider.getFilteredOrders(
                          OrderStatusBuyer.declined,
                        ),
                      ),
              ),

              // Completed Tab
              RefreshIndicator(
                onRefresh: () async {
                  await provider.loadOrders(status: OrderStatusBuyer.completed);
                  await provider.loadOrderSummary();
                },
                child:
                    provider.isLoading &&
                        provider.currentFilter == OrderStatusBuyer.completed
                    ? const Center(child: CircularProgressIndicator())
                    : CompletedOrdersTab(
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
