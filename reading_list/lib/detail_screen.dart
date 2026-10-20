import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    // Cancel (false) and a tap outside (null) both keep the book.
    if (confirmed == true) Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // No leading: the AppBar draws the back arrow itself.
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(book.title, style: text.headlineSmall),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(book.author),
            subtitle: const Text('Author'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text('${book.pages} pp.'),
            subtitle: const Text('Pages'),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: Text(book.year?.toString() ?? 'Year unknown'),
            subtitle: const Text('Year'),
          ),
          ListTile(
            leading: Icon(
              book.read ? Icons.check_circle : Icons.radio_button_unchecked,
            ),
            title: Text(book.read ? 'Read' : 'Unread'),
            subtitle: const Text('Status'),
          ),
          const SizedBox(height: 24),
          // The screen only answers; the list decides what to do.
          FilledButton(
            onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: colors.error),
            onPressed: () => _delete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
