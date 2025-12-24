import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_screen.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_model.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Cart/cart_widget.dart';
import 'package:wood_service/views/Buyer/payment/checkout.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class BuyerCartScreen extends StatefulWidget {
  const BuyerCartScreen({super.key});

  @override
  State<BuyerCartScreen> createState() => _BuyerCartScreenState();
}

class _BuyerCartScreenState extends State<BuyerCartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheetController;
  late final Animation<double> _sheetAnim;
  StreamSubscription? _cartSubscription;
  late final BuyerCartViewModel _cartViewModel;

  @override
  void initState() {
    super.initState();
    _cartViewModel = locator<BuyerCartViewModel>(); // Get from locator

    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sheetAnim = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    );

    // Initialize and load cart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCart();
    });
  }

  Future<void> _initializeCart() async {
    final cartViewModel = Provider.of<BuyerCartViewModel>(
      context,
      listen: false,
    );

    try {
      await cartViewModel.loadCart();

      // Show sheet if there are items
      if (cartViewModel.cartItems.isNotEmpty) {
        _sheetController.forward();
      }

      // Listen for cart changes
      _cartSubscription = cartViewModel.cartStream?.listen((cart) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (cart?.items.isNotEmpty == true) {
            _sheetController.forward();
          } else {
            _sheetController.reverse();
          }
        });
      });
    } catch (error) {
      print('Failed to initialize cart: $error');
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  void _updateQuantity(
    BuildContext context,
    String itemId,
    int newQuantity,
  ) async {
    final cartViewModel = Provider.of<BuyerCartViewModel>(
      context,
      listen: false,
    );

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

  void _removeItemWithUndo(
    BuildContext context,
    BuyerCartItem removedItem,
    int index,
  ) async {
    final cartViewModel = Provider.of<BuyerCartViewModel>(
      context,
      listen: false,
    );
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

  void clearCartConfirm(BuildContext context) {
    final cartViewModel = Provider.of<BuyerCartViewModel>(
      context,
      listen: false,
    );

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

  Widget _buildCartItemCard(
    BuildContext context,
    BuyerCartItem item,
    int index,
  ) {
    final cartViewModel = Provider.of<BuyerCartViewModel>(context);
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
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        QuantityStepper(
                          quantity: item.quantity,
                          maxQuantity: product?.stockQuantity ?? 99,
                          onChanged: (q) =>
                              _updateQuantity(context, item.id, q),
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

  Widget _buildHeaderBar(BuyerCartViewModel cartViewModel) {
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
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
                : () => _clearCartConfirm(context, cartViewModel),
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: cartViewModel.cartItems.isEmpty ? Colors.grey : Colors.red,
            ),
            label: Text(
              'Clear',
              style: TextStyle(
                color: cartViewModel.cartItems.isEmpty
                    ? Colors.grey
                    : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildHeaderBar(BuildContext context) {
  //   final cartViewModel = Provider.of<BuyerCartViewModel>(context);

  //   return Container(
  //     color: Colors.white,
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: Row(
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               '${cartViewModel.cartCount} ${cartViewModel.cartCount == 1 ? "Item" : "Items"}',
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.w700,
  //                 fontSize: 14,
  //               ),
  //             ),
  //             if (cartViewModel.outOfStockItems.isNotEmpty)
  //               Text(
  //                 '${cartViewModel.outOfStockItems.length} out of stock',
  //                 style: const TextStyle(fontSize: 11, color: Colors.red),
  //               ),
  //           ],
  //         ),
  //         const Spacer(),
  //         TextButton.icon(
  //           onPressed: cartViewModel.cartItems.isEmpty
  //               ? null
  //               : () => clearCartConfirm(context),
  //           icon: Icon(
  //             Icons.delete_outline,
  //             size: 18,
  //             color: cartViewModel.cartItems.isEmpty ? Colors.grey : Colors.red,
  //           ),
  //           label: Text(
  //             'Clear',
  //             style: TextStyle(
  //               color: cartViewModel.cartItems.isEmpty
  //                   ? Colors.grey
  //                   : Colors.red,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCheckoutSheet() {
    return AnimatedBuilder(
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
                        _buildSummaryLine('Subtotal', _cartViewModel.subtotal),
                        const SizedBox(height: 4),
                        _buildSummaryLine('Shipping', _cartViewModel.shipping),
                        const SizedBox(height: 4),
                        _buildSummaryLine('Tax', _cartViewModel.tax),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${_cartViewModel.total.toStringAsFixed(2)}',
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
                          onPressed: _cartViewModel.cartItems.isEmpty
                              ? null
                              : _proceedToCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cartViewModel.cartItems.isEmpty
                                ? Colors.grey
                                : AppColors.brightOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: Text(
                            _cartViewModel.cartItems.isEmpty
                                ? 'Cart Empty'
                                : 'Proceed to Checkout',
                          ),
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
    );
  }

  void _proceedToCheckout() {
    final outOfStockItems = _cartViewModel.outOfStockItems;

    if (outOfStockItems.isNotEmpty) {
      _showOutOfStockDialog(outOfStockItems);
      return;
    }

    if (_cartViewModel.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _cartViewModel,
          child: CheckoutScreen(),
        ),
      ),
    );
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
                (item) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product?.featuredImage ??
                          item.product?.imageGallery.firstOrNull ??
                          'https://via.placeholder.com/44',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 44,
                        height: 44,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    item.product?.title ?? 'Unknown Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Available: ${item.product?.stockQuantity ?? 0}',
                    style: TextStyle(color: Colors.red),
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
                      onPressed: () async {
                        try {
                          // Remove all out of stock items
                          for (final item in outOfStockItems) {
                            await _cartViewModel.removeFromCart(item.id);
                          }
                          Navigator.pop(ctx);

                          // Proceed to checkout if items remain
                          if (_cartViewModel.cartItems.isNotEmpty) {
                            _proceedToCheckout();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All items were out of stock'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to remove items: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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

  Widget _buildSummaryLine(String label, double amount) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'My Cart', showBackButton: false),
      body: Consumer<BuyerCartViewModel>(
        builder: (context, cartViewModel, child) {
          // Update sheet animation based on cart items
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (cartViewModel.cartItems.isNotEmpty &&
                _sheetController.status != AnimationStatus.forward) {
              _sheetController.forward();
            } else if (cartViewModel.cartItems.isEmpty &&
                _sheetController.status != AnimationStatus.dismissed) {
              _sheetController.reverse();
            }
          });

          return _buildBody(cartViewModel);
        },
      ),
      bottomSheet: Consumer<BuyerCartViewModel>(
        builder: (context, cartViewModel, child) {
          return cartViewModel.cartItems.isNotEmpty
              ? _buildCheckoutSheet()
              : const SizedBox.shrink();
        },
      ),
      // bottomSheet: cartViewModel.cartItems.isNotEmpty
      //     ? _buildCheckoutSheet()
      //     : null,
    );
  }

  Widget _buildBody(BuyerCartViewModel cartViewModel) {
    if (cartViewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brightOrange),
        ),
      );
    }

    if (cartViewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              cartViewModel.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => cartViewModel.loadCart(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (cartViewModel.cartItems.isEmpty) {
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

    return Column(
      children: [
        _buildHeaderBar(cartViewModel),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cartViewModel.refreshCart(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: cartViewModel.cartItems.length,
              itemBuilder: (context, index) => _buildCartItemCard(
                context,
                cartViewModel.cartItems[index],
                index,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _clearCartConfirm(
    BuildContext context,
    BuyerCartViewModel cartViewModel,
  ) {
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
}
