import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const route = '/cart';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cart'), actions: const [_ClearButton()]),
    body: Column(
      children: [
        Expanded(
          child: Consumer<Cart>(
            builder: (context, cart, _) => cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView(
                    children: [
                      for (final b in cart.items)
                        ListTile(
                          title: Text(b.title),
                          subtitle: Text('${b.price} ₸'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '×${cart.qtyOf(b)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                tooltip: 'One more',
                                icon: const Icon(Icons.add),
                                onPressed: () => cart.increment(b),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                icon: const Icon(Icons.close),
                                onPressed: () => cart.remove(b),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const Divider(height: 1),
        Consumer<Cart>(
          builder: (context, cart, child) => ListTile(
            title: child!,
            trailing: Text(
              '${cart.total} ₸',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Built once: the label never depends on the cart.
          child: const Row(
            children: [
              Icon(Icons.receipt_long_outlined),
              SizedBox(width: 12),
              Text('Total'),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ClearButton extends StatelessWidget {
  const _ClearButton();

  // The question lives here; the clearing lives in the model.
  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Every book will be removed from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final empty = context.select<Cart, bool>((c) => c.count == 0);
    return IconButton(
      tooltip: 'Clear cart',
      icon: const Icon(Icons.remove_shopping_cart_outlined),
      onPressed: empty ? null : () => _confirm(context),
    );
  }
}
