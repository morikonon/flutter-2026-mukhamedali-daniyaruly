import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';

  List<Book> get _visible => books
      .where((b) => '${b.title} ${b.author}'.toLowerCase().contains(_query))
      .toList();

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search by title or author',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (text) =>
                  setState(() => _query = text.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: visible.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView.builder(
              itemCount: visible.length,
              itemBuilder: (context, i) => _BookTile(visible[i]),
            ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile(this.book);

  final Book book;

  void _add(BuildContext context) {
    if (!context.read<Cart>().add(book)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added: ${book.title}'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final added = context.select<Cart, bool>((c) => c.contains(book));
    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author} · ${book.price} ₸'),
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => _add(context),
              child: const Text('Add'),
            ),
    );
  }
}
