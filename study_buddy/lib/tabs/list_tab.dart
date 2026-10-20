import 'package:flutter/material.dart';

import '../config.dart';
import '../models/session.dart';
import '../models/subject.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_card.dart';

/// Tab 1. Owns only what it filters by; the sessions come from the shell.
class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<Session> onToggleFavourite;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final _search = TextEditingController();

  /// null means "All".
  Subject? _subject;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Session> get _visible {
    final query = _search.text.trim().toLowerCase();
    final filtered = widget.sessions.where(
      (s) =>
          s.title.toLowerCase().contains(query) &&
          (_subject == null || s.subject == _subject) &&
          (_showPast || !s.isPast),
    );
    // Sort a copy: the shell's list is never reordered in place.
    return [...filtered]..sort(_upcomingFirst);
  }

  /// By date, with past sessions (shown only on request) at the end.
  int _upcomingFirst(Session a, Session b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.startsAt.compareTo(b.startsAt);
  }

  void _clearSearch() => setState(() => _search.clear());

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: 'Search by title',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        // Scrolls sideways, so any number of subjects fits on any width.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _subject == null,
                onSelected: (_) => setState(() => _subject = null),
              ),
              for (final subject in Subject.values)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(subject.icon),
                    label: Text(subject.label),
                    selected: _subject == subject,
                    onSelected: (_) => setState(() => _subject = subject),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
              Text(
                '${visible.length} shown',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No sessions match',
                  actionLabel: 'Clear search',
                  onAction: _clearSearch,
                )
              // LayoutBuilder measures the space this tab really has,
              // not the whole screen: a list on phones, a grid when wide.
              : LayoutBuilder(
                  builder: (context, constraints) =>
                      constraints.maxWidth < gridBreakpoint
                      ? _buildList(visible)
                      : _buildGrid(visible, constraints.maxWidth),
                ),
        ),
      ],
    );
  }

  Widget _buildList(List<Session> visible) => ListView.separated(
    // Bottom padding keeps the last card clear of the FAB.
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
    itemCount: visible.length,
    separatorBuilder: (_, _) => const SizedBox(height: 4),
    itemBuilder: (_, i) => _card(visible[i]),
  );

  Widget _buildGrid(List<Session> visible, double width) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      // Rounding up keeps every cell at most maxCellWidth wide.
      crossAxisCount: (width / maxCellWidth).ceil(),
      // Tall enough for a two-line title plus the date line.
      mainAxisExtent: 128,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
    ),
    itemCount: visible.length,
    itemBuilder: (_, i) => _card(visible[i]),
  );

  Widget _card(Session session) => SessionCard(
    session: session,
    onTap: () => widget.onOpen(session),
    onToggleFavourite: () => widget.onToggleFavourite(session),
  );
}
