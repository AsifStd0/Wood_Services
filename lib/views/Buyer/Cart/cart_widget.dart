import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_model.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';

class QuantityStepper extends StatefulWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;
  final bool disabled;

  const QuantityStepper({
    super.key,
    required this.quantity,
    this.maxQuantity = 99,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
  }

  void _decrement() {
    if (_quantity > 1 && !widget.disabled) {
      setState(() {
        _quantity--;
      });
      widget.onChanged(_quantity);
    }
  }

  void _increment() {
    if (_quantity < widget.maxQuantity && !widget.disabled) {
      setState(() {
        _quantity++;
      });
      widget.onChanged(_quantity);
    }
  }

  @override
  void didUpdateWidget(covariant QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      setState(() {
        _quantity = widget.quantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.disabled ? Colors.grey[100] : const Color(0xffF6DCC9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: widget.disabled ? Colors.grey[300]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          _buildButton(
            icon: Icons.remove,
            isEnabled: _quantity > 1 && !widget.disabled,
            onTap: _decrement,
            isLeft: true,
          ),

          // Quantity display
          Container(
            width: 40,
            height: 36,
            color: Colors.transparent,
            child: Center(
              child: Text(
                '$_quantity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.disabled ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ),

          // Increment button
          _buildButton(
            icon: Icons.add,
            isEnabled: _quantity < widget.maxQuantity && !widget.disabled,
            onTap: _increment,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(25) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(25) : Radius.zero,
            topRight: !isLeft ? const Radius.circular(25) : Radius.zero,
            bottomRight: !isLeft ? const Radius.circular(25) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? Colors.brown : Colors.grey,
        ),
      ),
    );
  }
}

Widget buildCartItemCard(BuildContext context, BuyerCartItem item, int index) {
  final product = item.product;
  final isOutOfStock = !item.isInStock;

  return Dismissible(
    key: ValueKey('${item.id}_$index'),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_forever, color: Colors.white),
      ),
    ),
    onDismissed: (_) => _removeItemWithUndo(context, item, index),
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
        border: isOutOfStock
            ? Border.all(color: Colors.red.shade200, width: 1)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // image: DecorationImage(
                    //   image: NetworkImage(
                    //     product?.featuredImage
                    //         ? product!.featuredImage
                    //         : (product?.featuredImage is Map
                    //             ? (product?.featuredImage['url']?.toString() ?? '')
                    //             : 'https://via.placeholder.com/80'),
                    //   ),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
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
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?.title ?? 'Unknown Product',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (product?.shortDescription != null)
                              Text(
                                product!.shortDescription,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final cartVM = Provider.of<BuyerCartViewModel>(
                            context,
                            listen: false,
                          );

                          await cartVM.removeFromCart(item.id);
                        },
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price and Quantity
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.brown,
                            ),
                          ),
                          if (isOutOfStock)
                            Text(
                              'Only ${product?.stockQuantity ?? 0} available',
                              style: TextStyle(fontSize: 10, color: Colors.red),
                            ),
                        ],
                      ),
                      const Spacer(),
                      QuantityStepper(
                        quantity: item.quantity,
                        maxQuantity: product?.stockQuantity ?? 99,
                        onChanged: (q) => updateQuantity(context, item.id, q),
                        disabled: isOutOfStock,
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

void _removeItemWithUndo(
  BuildContext context,
  BuyerCartItem removedItem,
  int index,
) async {
  final cartViewModel = Provider.of<BuyerCartViewModel>(context, listen: false);
  final itemId = removedItem.id;
  final productTitle = removedItem.product?.title ?? 'Item';

  try {
    // Store the item for undo BEFORE removing
    final itemToRestore = BuyerCartItem(
      id: removedItem.id,
      productId: removedItem.productId,
      quantity: removedItem.quantity,
      selectedVariant: removedItem.selectedVariant,
      selectedSize: removedItem.selectedSize,
      price: removedItem.price,
      subtotal: removedItem.subtotal,
      product: removedItem.product,
      addedAt: removedItem.addedAt,
    );

    // Remove from ViewModel immediately
    await cartViewModel.removeFromCart(itemId);

    // Show undo snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      content: Text('$productTitle removed'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          try {
            await cartViewModel.addToCart(
              productId: itemToRestore.productId,
              quantity: itemToRestore.quantity,
              selectedVariant: itemToRestore.selectedVariant,
              selectedSize: itemToRestore.selectedSize,
            );
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to undo: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        textColor: Colors.white,
      ),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.brown,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to remove item: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ! *******

void updateQuantity(
  BuildContext context,
  String itemId,
  int newQuantity,
) async {
  final cartViewModel = Provider.of<BuyerCartViewModel>(context, listen: false);

  try {
    await cartViewModel.updateCartItem(itemId, newQuantity);
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update quantity: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Widget buildSummaryLine(String label, double amount) {
  return Row(
    children: [
      Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      const Spacer(),
      Text(
        '\$${amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

void clearCartConfirm(BuildContext context, BuyerCartViewModel cartViewModel) {
  if (cartViewModel.cartItems.isEmpty) return;

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
          onPressed: () async {
            Navigator.pop(context);
            try {
              await cartViewModel.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to clear cart: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Clear', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

Center emptyCart(context) {
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
        ],
      ),
    ),
  );
}

Widget buildHeaderBar(BuyerCartViewModel cartViewModel, context) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${cartViewModel.cartCount} ${cartViewModel.cartCount == 1 ? "Item" : "Items"}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            if (cartViewModel.outOfStockItems.isNotEmpty)
              Text(
                '${cartViewModel.outOfStockItems.length} out of stock',
                style: const TextStyle(fontSize: 11, color: Colors.red),
              ),
          ],
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: cartViewModel.cartItems.isEmpty
              ? null
              : () => clearCartConfirm(context, cartViewModel),
          icon: Icon(
            Icons.delete_outline,
            size: 18,
            color: cartViewModel.cartItems.isEmpty ? Colors.grey : Colors.red,
          ),
          label: Text(
            'Clear',
            style: TextStyle(
              color: cartViewModel.cartItems.isEmpty ? Colors.grey : Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}
