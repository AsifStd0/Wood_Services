import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'Premium Teak Wood Planks',
      description: 'Grade A Teak, 2" x 4" x 8ft',
      price: 299.99,
      quantity: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1596541223130-5ccd06ed6e78?w=150&h=150&fit=crop',
      seller: 'Premium Timber Co.',
      inStock: true,
      deliveryDate: 'Jan 20-22',
    ),
    CartItem(
      id: '2',
      name: 'Mahogany Dining Table',
      description: 'Solid Mahogany, 72" x 36"',
      price: 899.99,
      quantity: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=150&h=150&fit=crop',
      seller: 'Luxury Furniture',
      inStock: true,
      deliveryDate: 'Jan 25-28',
    ),
    CartItem(
      id: '3',
      name: 'Oak Wood Chairs (Set of 4)',
      description: 'Solid Oak, Upholstered Seats',
      price: 349.99,
      quantity: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1503602642458-232111445657?w=150&h=150&fit=crop',
      seller: 'Wood Crafts',
      inStock: false,
      deliveryDate: 'Out of Stock',
    ),
  ];

  double get _subtotal {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double get _shipping {
    return 49.99;
  }

  double get _tax {
    return _subtotal * 0.08;
  }

  double get _total {
    return _subtotal + _shipping + _tax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              label: Text(_cartItems.length.toString()),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartWithItems(),
      bottomNavigationBar: _cartItems.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add some quality wood products to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/home'); // Navigate to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text(
              'Start Shopping',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems() {
    return Column(
      children: [
        // Header with item count
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_cartItems.length} ${_cartItems.length == 1 ? 'Item' : 'Items'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              TextButton.icon(
                onPressed: _clearCart,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Clear Cart'),
              ),
            ],
          ),
        ),

        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_cartItems[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Item Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stock Status
                      if (!item.inStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Product Name
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Description
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Seller
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.seller,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Price and Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),

                          // Quantity Selector
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () => _updateQuantity(
                                    item.id,
                                    item.quantity - 1,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () => _updateQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Price Summary
          _buildPriceRow('Subtotal', _subtotal),
          _buildPriceRow('Shipping', _shipping),
          _buildPriceRow('Tax', _tax),
          const Divider(height: 20),
          _buildPriceRow('Total', _total, isTotal: true),

          const SizedBox(height: 16),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Security Note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security_outlined, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Secure checkout • SSL encrypted',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.brown : Colors.grey[700],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.brown : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Cart Actions
  void _updateQuantity(String itemId, int newQuantity) {
    if (newQuantity < 1) {
      _removeItem(itemId);
      return;
    }

    setState(() {
      final item = _cartItems.firstWhere((item) => item.id == itemId);
      item.quantity = newQuantity;
    });
  }

  void _removeItem(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Remove Item'),
          content: const Text(
            'Are you sure you want to remove this item from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _cartItems.removeWhere((item) => item.id == itemId);
                });
                Navigator.pop(context);
                _showSnackBar('Item removed from cart');
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _saveForLater(String itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == itemId);
    });
    _showSnackBar('Item saved for later');
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Clear Cart'),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _cartItems.clear();
                });
                Navigator.pop(context);
                _showSnackBar('Cart cleared');
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout() {
    // Check if any items are out of stock
    final outOfStockItems = _cartItems.where((item) => !item.inStock).toList();

    if (outOfStockItems.isNotEmpty) {
      _showOutOfStockDialog(outOfStockItems);
      return;
    }

    // Navigate to checkout
    context.push('/checkout', extra: _cartItems);
  }

  void _showOutOfStockDialog(List<CartItem> outOfStockItems) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Items Out of Stock',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${outOfStockItems.length} item(s) in your cart are currently out of stock:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ...outOfStockItems
                    .take(3)
                    .map(
                      (item) => ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Continue Shopping'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Remove out of stock items and proceed
                          setState(() {
                            _cartItems.removeWhere((item) => !item.inStock);
                          });
                          Navigator.pop(context);
                          _proceedToCheckout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Remove & Checkout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.brown,
      ),
    );
  }
}

// Cart Item Model
class CartItem {
  final String id;
  final String name;
  final String description;
  final double price;
  int quantity;
  final String imageUrl;
  final String seller;
  final bool inStock;
  final String deliveryDate;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.seller,
    required this.inStock,
    required this.deliveryDate,
  });
}
