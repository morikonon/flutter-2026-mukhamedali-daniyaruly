import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_screen.dart';
import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    final n = context.select<Cart, int>((c) => c.count);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: 'Cart',
        onPressed: () => Navigator.of(context).pushNamed(CartScreen.route),
        icon: Badge(
          label: Text('$n'),
          child: const Icon(Icons.shopping_cart_outlined),
        ),
      ),
    );
  }
}
