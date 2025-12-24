import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_screen.dart';

import 'package:flutter/material.dart';

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

Widget buildEmptyCart(BuildContext context) {
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
            // context.go('/home'); // Navigate to home
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return BuyerHomeScreen();
                },
              ),
            );
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
