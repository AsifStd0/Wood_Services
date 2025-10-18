enum OrderStatus { active, cancelled, completed }

class Order {
  final String id;
  final String productName;
  final String customerName;
  final double amount;
  final DateTime orderDate;
  final OrderStatus status;

  Order({
    required this.id,
    required this.productName,
    required this.customerName,
    required this.amount,
    required this.orderDate,
    required this.status,
  });
}
