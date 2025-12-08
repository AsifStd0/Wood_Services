import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/data/models/buyer_cart_Item.dart';
import 'package:wood_service/views/Buyer/Cart/cart_widget.dart';
import 'package:wood_service/widgets/custom_appbar.dart';
import 'package:wood_service/widgets/custom_button.dart';

class BuyerCartScreen extends StatefulWidget {
  const BuyerCartScreen({super.key});

  @override
  State<BuyerCartScreen> createState() => _BuyerCartScreenState();
}

class _BuyerCartScreenState extends State<BuyerCartScreen>
    with SingleTickerProviderStateMixin {
  double get _subtotal =>
      buyerCartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get _shipping => buyerCartItems.isEmpty ? 0.0 : 49.99;
  double get _tax => _subtotal * 0.08;
  double get _total => _subtotal + _shipping + _tax;

  late final AnimationController _sheetController;
  late final Animation<double> _sheetAnim;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sheetAnim = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    );

    // Show sheet if there are items at launch
    if (buyerCartItems.isNotEmpty) _sheetController.forward();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _updateQuantity(String id, int newQuantity) {
    setState(() {
      final item = buyerCartItems.firstWhere((el) => el.id == id);
      item.quantity = newQuantity.clamp(1, 99);
    });
  }

  void _removeItemWithUndo(BuyerCartItem removedItem, int index) {
    setState(() {
      buyerCartItems.removeWhere((i) => i.id == removedItem.id);
      if (buyerCartItems.isEmpty) _sheetController.reverse();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              buyerCartItems.insert(index, removedItem);
              if (buyerCartItems.isNotEmpty) _sheetController.forward();
            });
          },
          textColor: Colors.white,
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.brown,
      ),
    );
  }

  void clearCartConfirm() {
    if (buyerCartItems.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                buyerCartItems.clear();
                _sheetController.reverse();
              });
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    final outOfStock = buyerCartItems.where((i) => !i.inStock).toList();
    if (outOfStock.isNotEmpty) {
      _showOutOfStockDialog(outOfStock);
      return;
    }
    context.push('/checkout', extra: buyerCartItems);
  }

  void _showOutOfStockDialog(List<BuyerCartItem> outOfStockItems) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.orange.shade700,
                size: 44,
              ),
              const SizedBox(height: 5),
              Text(
                'Some items are out of stock',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...outOfStockItems.map(
                (i) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      i.imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    i.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Continue Shopping'),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          buyerCartItems.removeWhere((i) => !i.inStock);
                        });
                        Navigator.pop(ctx);
                        _proceedToCheckout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                      ),
                      child: const Text('Remove & Checkout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 86,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 18),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything yet. Browse our collection and add beautiful furniture to your cart.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => context.push('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brightOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Start Shopping'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(BuyerCartItem item, int index) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        // padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      onDismissed: (_) => _removeItemWithUndo(item, index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Image
              Stack(
                children: [
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
                  if (!item.inStock)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and stock
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.delete, size: 14, color: AppColors.grey),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),

                    // Price and quantity
                    Row(
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.brown,
                          ),
                        ),
                        const Spacer(),
                        QuantityStepper(
                          quantity: item.quantity,
                          onChanged: (q) => _updateQuantity(item.id, q),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Seller row
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.seller,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${buyerCartItems.length} ${buyerCartItems.length == 1 ? "Item" : "Items"}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: clearCartConfirm,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // animate sheet on items change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (buyerCartItems.isNotEmpty) {
        _sheetController.forward();
      } else {
        _sheetController.reverse();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'My Cart', showBackButton: false),
      body: buyerCartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                _buildHeaderBar(),
                Expanded(
                  child: ListView.builder(
                    itemCount: buyerCartItems.length,
                    itemBuilder: (context, i) =>
                        _buildCartItemCard(buyerCartItems[i], i),
                  ),
                ),
              ],
            ),

      // Sticky animated checkout sheet
      bottomSheet: AnimatedBuilder(
        animation: _sheetAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _sheetAnim.value) * 100),
            child: Opacity(opacity: _sheetAnim.value, child: child),
          );
        },
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Compact price row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SummaryLine(label: 'Subtotal', amount: _subtotal),
                          const SizedBox(height: 4),
                          SummaryLine(label: 'Shipping', amount: _shipping),
                          const SizedBox(height: 4),
                          SummaryLine(label: 'Tax', amount: _tax),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.brown,
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: _proceedToCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brightOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                            ),
                            child: const Text('Proceed to Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
