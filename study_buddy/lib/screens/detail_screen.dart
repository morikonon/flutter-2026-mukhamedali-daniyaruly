import 'dart:async';

import 'package:flutter/material.dart';

import '../models/session.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { delete }

/// Pushed from a card. Works on a local copy and reports every change
/// to the shell through the callbacks in [DetailArgs].
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Session _session = widget.args.session;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // Rebuild once a minute so the countdown moves.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    // Without this the timer would call setState on a dead screen.
    _timer.cancel();
    super.dispose();
  }

  String get _me => widget.args.profileName.trim();

  bool get _joined => _session.contains(_me);

  /// Tell the shell first, then refresh our own copy.
  void _update(Session updated) {
    widget.args.onChanged(updated);
    setState(() => _session = updated);
  }

  Future<void> _join() async {
    if (_me.isEmpty) {
      _askForName();
      return;
    }
    final ok = await confirm(
      context,
      title: 'Join this session?',
      message: _session.title,
      action: 'Join',
    );
    if (!mounted || !ok) return;
    _update(_session.copyWith(participants: [..._session.participants, _me]));
  }

  void _leave() {
    final others = _session.participants
        .where((p) => p.trim().toLowerCase() != _me.toLowerCase())
        .toList();
    _update(_session.copyWith(participants: others));
  }

  void _askForName() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Set your name in the profile first'),
        persist: false,
        action: SnackBarAction(
          label: 'Set name',
          onPressed: () {
            // The detail may already be closed when the action is tapped.
            if (mounted) Navigator.of(context).pop();
            widget.args.onOpenProfile();
          },
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: "Delete '${_session.title}'?",
      message: 'This cannot be undone.',
      action: 'Delete',
    );
    if (!mounted || !ok) return;
    widget.args.onDelete(_session.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_session.subject.label),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) {
                switch (action) {
                  case _MenuAction.delete:
                    _delete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(session: _session),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                // Live: the label is rebuilt with the current count.
                Tab(text: 'Participants (${_session.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(children: [_buildAbout(), _buildPeople()]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbout() {
    final text = Theme.of(context).textTheme;
    final (:taken, :free) = _session.places;
    // A local, so the null check below promotes it.
    final description = _session.description;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_session.title, style: text.headlineSmall),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDateTime(_session.startsAt)),
          subtitle: const Text('Date'),
        ),
        ListTile(
          leading: Icon(_session.isOnline ? Icons.link : Icons.place),
          title: Text(_session.location),
          subtitle: Text(_session.isOnline ? 'Meeting link' : 'Location'),
        ),
        ListTile(
          leading: const Icon(Icons.event_seat),
          title: Text('$taken of ${_session.seats} taken'),
          subtitle: Text('$free free'),
        ),
        if (description != null)
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(description),
            subtitle: const Text('Description'),
          ),
        const SizedBox(height: 16),
        _buildPrimaryAction(),
      ],
    );
  }

  /// Leave when you are on the list; Join otherwise, greyed out when
  /// the session is full or over.
  Widget _buildPrimaryAction() {
    if (_joined) {
      return OutlinedButton.icon(
        onPressed: _leave,
        icon: const Icon(Icons.logout),
        label: const Text('Leave'),
      );
    }
    final canJoin = !_session.isFull && !_session.isPast;
    return FilledButton.icon(
      onPressed: canJoin ? _join : null,
      icon: const Icon(Icons.login),
      label: Text(
        _session.isPast
            ? 'Join (ended)'
            : _session.isFull
            ? 'Join (full)'
            : 'Join',
      ),
    );
  }

  Widget _buildPeople() {
    final names = _session.participants;
    if (names.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody here yet',
      );
    }
    final colors = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (_, i) {
        final name = names[i];
        final isMe = name.trim().toLowerCase() == _me.toLowerCase();
        return ListTile(
          leading: CircleAvatar(child: Text(name.characters.first)),
          title: Text(isMe ? 'You' : name),
          tileColor: isMe ? colors.primaryContainer : null,
          textColor: isMe ? colors.onPrimaryContainer : null,
        );
      },
    );
  }
}

/// The photo with the subject in one corner and the countdown in another.
class _Header extends StatelessWidget {
  const _Header({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subject = session.subject;
    // Capped, so the header never eats a landscape screen.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/header.jpg', fit: BoxFit.cover),
            Center(
              child: CircleAvatar(
                radius: 32,
                backgroundColor: subject.colorOf(colors),
                foregroundColor: subject.onColorOf(colors),
                child: Icon(subject.icon, size: 32),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Chip(
                avatar: Icon(subject.icon),
                label: Text(subject.label),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Chip(
                avatar: const Icon(Icons.schedule),
                label: Text(formatCountdown(session.countdown(DateTime.now()))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
