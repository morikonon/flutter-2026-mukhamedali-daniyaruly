import 'package:flutter/material.dart';

import '../config.dart';
import '../models/session.dart';
import '../utils/format.dart';

/// The one reusable card, used by the list, the grid and the favourites.
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Session session;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final past = session.isPast;
    return Card(
      clipBehavior: Clip.antiAlias,
      // Past sessions look subdued: a flatter surface and muted text.
      color: past ? colors.surfaceContainerHighest : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(session: session),
              const SizedBox(width: 12),
              // Expanded: the text gets what is left between avatar and heart.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        color: past ? colors.onSurfaceVariant : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateTime(session.startsAt)} · '
                      '${session.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: session.isFavourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                color: session.isFavourite ? colors.primary : null,
                icon: Icon(
                  session.isFavourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The subject icon with a "FULL" or "N left" badge on top of it.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final free = session.free;
    final badge = session.isFull
        ? 'FULL'
        : free <= fewSeatsLeft
        ? '$free left'
        : null;
    final badgeColor = session.isFull ? colors.error : colors.tertiary;
    final onBadgeColor = session.isFull ? colors.onError : colors.onTertiary;
    return Stack(
      // The badge may hang slightly below the avatar.
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: session.subject.colorOf(colors),
          foregroundColor: session.subject.onColorOf(colors),
          child: Icon(session.subject.icon),
        ),
        if (badge != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: -6,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    badge,
                    style: text.labelSmall?.copyWith(color: onBadgeColor),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
