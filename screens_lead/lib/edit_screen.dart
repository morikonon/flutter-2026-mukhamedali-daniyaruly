import 'package:flutter/material.dart';

import 'students.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.student});

  final Student student;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  // Draft value: starts as the current name, updated on every keystroke.
  late String _name = widget.student.name;

  // Derived, not stored: can never get out of sync with _name.
  bool get _dirty => _name != widget.student.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit name')),
      body: PopScope(
        // Clean form: back works as usual. Dirty form: back is blocked.
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) async {
          // The pop already happened (clean form or Save) - nothing to do.
          if (didPop) return;
          final discard = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text('The new name has not been saved.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          // Tapping outside the dialog returns null, which counts as "keep".
          if (discard == true && context.mounted) Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // No controller: the field starts empty, hint shows the old name.
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'New name',
                  hintText: widget.student.name,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _name = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                // An explicit pop() from our own code is never blocked.
                onPressed: () => Navigator.of(context).pop(_name),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
