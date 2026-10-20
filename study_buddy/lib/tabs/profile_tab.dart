import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/session.dart';

/// Two to four capital letters, a dash, four digits: IT-2301.
final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

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
  // One key per field, so each field can be validated on its own.
  final _nameField = GlobalKey<FormFieldState<String>>();
  final _groupField = GlobalKey<FormFieldState<String>>();
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

  /// Saves only a valid field; an invalid one keeps showing its error.
  void _save(GlobalKey<FormFieldState<String>> field, Profile updated) {
    if (!(field.currentState?.validate() ?? false)) return;
    widget.onProfileChanged(updated);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  String? _validateName(String? value) =>
      (value ?? '').trim().length < 2 ? 'At least 2 characters' : null;

  String? _validateGroup(String? value) =>
      _groupPattern.hasMatch((value ?? '').trim())
      ? null
      : 'Use the format IT-2301';

  void _hideKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final name = widget.profile.name;
    // Computed on every build from the shell's list, so it is never stale.
    final lists = widget.sessions.fold(
      0,
      (sum, s) => s.contains(name) ? sum + 1 : sum,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                key: _nameField,
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  helperText: 'Press Enter to save',
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                onFieldSubmitted: (value) => _save(
                  _nameField,
                  widget.profile.copyWith(name: value.trim()),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: _groupField,
                controller: _group,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'IT-2301',
                  helperText: 'Press Enter to save',
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onTapOutside: _hideKeyboard,
                onFieldSubmitted: (value) => _save(
                  _groupField,
                  widget.profile.copyWith(group: value.trim()),
                ),
                validator: _validateGroup,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          style: text.titleMedium,
        ),
      ],
    );
  }
}
