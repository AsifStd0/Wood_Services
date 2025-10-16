// Data Models
class Order {
  final String orderNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String deliveryDate;

  Order({
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.deliveryDate,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final String seller;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.seller,
  });
}
