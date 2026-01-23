import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Buyer/Cart/buyer_cart_provider.dart';
import 'package:wood_service/views/Buyer/Cart/cart_widget.dart';
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
      //! Load Cart
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

  Widget _buildCheckoutSheet(BuyerCartViewModel cartViewModel) {
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
                        buildSummaryLine('Subtotal', cartViewModel.subtotal),
                        const SizedBox(height: 4),
                        buildSummaryLine('Shipping', cartViewModel.shipping),
                        const SizedBox(height: 4),
                        buildSummaryLine('Tax', cartViewModel.tax),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${cartViewModel.total.toStringAsFixed(2)}',
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
                          onPressed: cartViewModel.cartItems.isEmpty
                              ? null
                              : () => proceedToCheckout(context, cartViewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cartViewModel.cartItems.isEmpty
                                ? Colors.grey
                                : AppColors.brightOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: Text(
                            cartViewModel.cartItems.isEmpty
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
              ? _buildCheckoutSheet(cartViewModel)
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
