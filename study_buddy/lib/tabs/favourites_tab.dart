import 'package:flutter/material.dart';

import '../models/session.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_card.dart';

/// Tab 2. Gets the whole list and shows the favourites, soonest first.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowseAll,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<Session> onToggleFavourite;
  final VoidCallback onBrowseAll;

  @override
  Widget build(BuildContext context) {
    final favourites = sessions.where((s) => s.isFavourite).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse all',
        onAction: onBrowseAll,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: favourites.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final session = favourites[i];
        return SessionCard(
          session: session,
          onTap: () => onOpen(session),
          onToggleFavourite: () => onToggleFavourite(session),
        );
      },
    );
  }
}
