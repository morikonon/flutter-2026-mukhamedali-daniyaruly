import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/session.dart';

/// Tab 3. Edits the profile and reports it up to the shell.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.onProfileChanged,
  });

  final Profile profile;
  final List<Session> sessions;
  final ValueChanged<Profile> onProfileChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  // The shell may hand us a new profile (Reset data): show its values.
  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.profile, widget.profile)) {
      _name.text = widget.profile.name;
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  void _saveName() =>
      widget.onProfileChanged(widget.profile.copyWith(name: _name.text.trim()));

  void _saveGroup() => widget.onProfileChanged(
    widget.profile.copyWith(group: _group.text.trim()),
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final name = widget.profile.name;
    // Computed on every build, so it can never be stale.
    final lists = widget.sessions.fold(
      0,
      (sum, s) => s.contains(name) ? sum + 1 : sum,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Press Enter to save',
          ),
          onFieldSubmitted: (_) => _saveName(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _group,
          decoration: const InputDecoration(
            labelText: 'Group',
            helperText: 'Press Enter to save',
          ),
          onFieldSubmitted: (_) => _saveGroup(),
        ),
        const SizedBox(height: 24),
        Text('You are on $lists lists', style: text.titleMedium),
      ],
    );
  }
}
