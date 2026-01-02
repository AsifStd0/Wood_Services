import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/theme/app_colors.dart';
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
                        buildSummaryLine('Subtotal', _cartViewModel.subtotal),
                        const SizedBox(height: 4),
                        buildSummaryLine('Shipping', _cartViewModel.shipping),
                        const SizedBox(height: 4),
                        buildSummaryLine('Tax', _cartViewModel.tax),
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

    if (cartViewModel.cartItems.isEmpty || cartViewModel.hasError) {
      return emptyCart(context);
    }

    return Column(
      children: [
        buildHeaderBar(cartViewModel, context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cartViewModel.refreshCart(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: cartViewModel.cartItems.length,
              itemBuilder: (context, index) => buildCartItemCard(
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
}
