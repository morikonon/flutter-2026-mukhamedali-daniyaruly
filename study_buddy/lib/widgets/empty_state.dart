import 'package:flutter/material.dart';

/// The one empty-state widget: an icon, a message and an optional button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // Locals, so the null checks below promote them to non-null.
    final label = actionLabel;
    final action = onAction;
    return Center(
      // Scrolls instead of overflowing when the space is short (landscape).
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colors.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (label != null && action != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: action, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
