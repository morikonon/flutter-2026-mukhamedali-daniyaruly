import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // A copy: the screen owns its list, seed stays untouched.
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((b) => b.read).toList(),
  };

  Future<void> _open(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
    );
    if (!mounted) return;
    switch (action) {
      case null:
        // Back arrow: the detail screen gave no answer.
        break;
      case BookAction.toggleRead:
        setState(() => book.read = !book.read);
      case BookAction.delete:
        setState(() => _books.remove(book));
    }
  }

  Future<void> _add() async {
    final book = await Navigator.of(context)
        .push<Book>(MaterialPageRoute(builder: (_) => const AddBookScreen()));
    if (!mounted) return;
    if (book == null) return;
    setState(() => _books.add(book));
  }

  Widget _stat(TextTheme text, int value, String label) => Expanded(
    child: Column(
      children: [
        Text('$value', style: text.headlineSmall),
        Text(label, style: text.bodySmall),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visible.length})')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: 'Add book',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Header counts the whole library, not the filtered view.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _stat(text, _books.length, 'Books'),
                  _stat(text, totalPages(_books), 'Pages'),
                  _stat(text, unread(_books).length, 'Unread'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (final f in Filter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(switch (f) {
                        Filter.all => 'All',
                        Filter.unread => 'Unread',
                        Filter.read => 'Read',
                      }),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              // Room at the bottom so the FAB never hides the last tile.
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final book = visible[i];
                return BookTile(
                  book: book,
                  onToggle: () => setState(() => book.read = !book.read),
                  onTap: () => _open(book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
