import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  // Created once, here, never in build().
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final c in [_title, _author, _pages, _year]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    // The only null assertion: the Form is on screen when Save runs.
    if (_formKey.currentState!.validate()) {
      final book = Book(
        title: _title.text.trim(),
        author: _author.text.trim(),
        // Safe: the pages validator already proved it is a number.
        pages: int.parse(_pages.text),
        // Empty text gives null, which means "year unknown".
        year: int.tryParse(_year.text),
        read: false,
      );
      Navigator.of(context).pop(book);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add book')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'At least 2 characters' : null,
            ),
            TextFormField(
              controller: _author,
              decoration: const InputDecoration(labelText: 'Author'),
              textInputAction: TextInputAction.next,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Enter the author' : null,
            ),
            TextFormField(
              controller: _pages,
              decoration: const InputDecoration(labelText: 'Pages'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'A whole number above 0';
                return null;
              },
            ),
            TextFormField(
              controller: _year,
              decoration: const InputDecoration(labelText: 'Year (optional)'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) {
                final text = v ?? '';
                // Empty is fine: the year is optional.
                if (text.trim().isEmpty) return null;
                final year = int.tryParse(text);
                final now = DateTime.now().year;
                if (year == null || year < 1450 || year > now) {
                  return 'A year between 1450 and $now';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    ),
  );
}
