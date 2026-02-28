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
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total :  ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${cartViewModel.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          onPressed: cartViewModel.cartItems.isEmpty
                              ? null
                              : () => proceedToCheckout(context, cartViewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cartViewModel.cartItems.isEmpty
                                ? Theme.of(context).colorScheme.onSurface
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Cart',
        showBackButton: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Consumer<BuyerCartViewModel>(
        builder: (context, cartViewModel, child) {
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
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: cartViewModel.cartItems.length,
              itemBuilder: (context, index) => buildCartItemCard(
                context,
                cartViewModel.cartItems[index],
                index,
              ),
            ),
          ),
        ),
        // Checkout bar inside body so list scrolls in the space above it (no overflow)
        if (cartViewModel.cartItems.isNotEmpty) _buildCheckoutSheet(cartViewModel),
      ],
    );
  }
}
