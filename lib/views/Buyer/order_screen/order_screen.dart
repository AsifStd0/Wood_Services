import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/order_screen/accepted_orders_tab.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Declined'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PendingOrdersTab(),
            AcceptedOrdersTab(),
            DeclinedOrdersTab(),
            CompletedOrdersTab(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
