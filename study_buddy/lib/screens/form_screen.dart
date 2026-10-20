import 'package:flutter/material.dart';

import '../models/session.dart';
import '../models/subject.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

/// Everything the user can change, in one record. Records compare field
/// by field, so "is the form dirty?" is a single `!=`.
typedef _Snapshot = ({
  String title,
  Subject? subject,
  bool isOnline,
  String location,
  String seats,
  DateTime? day,
  TimeOfDay? time,
  String description,
});

/// New and edit in one screen. Never touches the list: it answers with
/// the finished Session through Navigator.pop.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Session _base;
  late final bool _isNew;

  // Created once here and disposed in dispose(), never in build().
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _seats;
  late final TextEditingController _description;
  final _date = TextEditingController();
  final _time = TextEditingController();

  // A new session starts with these empty, so "required" means something.
  Subject? _subject;
  DateTime? _day;
  TimeOfDay? _timeOfDay;
  late bool _isOnline;
  bool _saving = false;

  /// What the form opened with; [_dirty] compares against it.
  late final _Snapshot _initial;

  @override
  void initState() {
    super.initState();
    final session = widget.args.session;
    _isNew = session == null;
    _base = session ?? Session.empty();
    _title = TextEditingController(text: _base.title);
    _location = TextEditingController(text: _base.location);
    _seats = TextEditingController(text: '${_base.seats}');
    _description = TextEditingController(text: _base.description ?? '');
    _isOnline = _base.isOnline;
    if (session != null) {
      final start = session.startsAt;
      _subject = session.subject;
      _day = DateTime(start.year, start.month, start.day);
      _timeOfDay = TimeOfDay(hour: start.hour, minute: start.minute);
      _date.text = formatDate(start);
      _time.text = formatTime(start);
    }
    _initial = _snapshot;
  }

  @override
  void dispose() {
    for (final c in [_title, _location, _seats, _description, _date, _time]) {
      c.dispose();
    }
    super.dispose();
  }

  _Snapshot get _snapshot => (
    title: _title.text,
    subject: _subject,
    isOnline: _isOnline,
    location: _location.text,
    seats: _seats.text,
    day: _day,
    time: _timeOfDay,
    description: _description.text,
  );

  bool get _dirty => _snapshot != _initial;

  /// The picked date and time as one DateTime, or null if either is missing.
  DateTime? get _startsAt {
    final day = _day;
    final time = _timeOfDay;
    if (day == null || time == null) return null;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    // Cancel gives null: the old value stays.
    if (!mounted || picked == null) return;
    setState(() {
      _day = picked;
      _date.text = formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _timeOfDay = picked;
      _time.text = formatClock(picked.hour, picked.minute);
    });
  }

  Future<void> _save() async {
    // A second tap while saving must not save twice.
    if (_saving) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    // The validators already rejected a missing subject, date or time.
    final subject = _subject;
    final startsAt = _startsAt;
    if (subject == null || startsAt == null) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final title = _title.text.trim();
    final location = _location.text.trim();
    // Safe: the seats validator proved it is a whole number.
    final seats = int.parse(_seats.text.trim());
    final text = _description.text.trim();
    final description = text.isEmpty ? null : text;
    final session = _isNew
        ? Session(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            subject: subject,
            startsAt: startsAt,
            seats: seats,
            location: location,
            isOnline: _isOnline,
            description: description,
          )
        // Editing keeps id, participants and favourite.
        : _base.copyWith(
            title: title,
            subject: subject,
            startsAt: startsAt,
            seats: seats,
            location: location,
            isOnline: _isOnline,
            description: description,
            clearDescription: description == null,
          );
    // pop() skips PopScope's question: Save never asks.
    Navigator.of(context).pop(session);
  }

  String? _validateTitle(String? value) =>
      (value ?? '').trim().isEmpty ? 'Enter a title' : null;

  String? _validateLocation(String? value) =>
      (value ?? '').trim().isEmpty ? 'Enter a location' : null;

  String? _validateSeats(String? value) =>
      int.tryParse((value ?? '').trim()) == null ? 'A whole number' : null;

  String? _validateTime(String? _) =>
      _timeOfDay == null ? 'Choose a time' : null;

  @override
  Widget build(BuildContext context) {
    return PopScope<Session>(
      // Clean form: back just works. Dirty form: back asks first.
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await confirm(
          context,
          title: 'Discard changes?',
          message: 'Your edits will be lost.',
          action: 'Discard',
        );
        if (!context.mounted) return;
        if (discard) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New session' : 'Edit session')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            // Rebuild on every edit so canPop follows _dirty.
            onChanged: () => setState(() {}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: _validateTitle,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Subject>(
                  initialValue: _subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: [
                    for (final subject in Subject.values)
                      DropdownMenuItem(
                        value: subject,
                        child: Text(subject.label),
                      ),
                  ],
                  onChanged: (subject) => setState(() => _subject = subject),
                  validator: (subject) =>
                      subject == null ? 'Choose a subject' : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online session'),
                  subtitle: const Text('The location becomes a meeting link'),
                  value: _isOnline,
                  onChanged: (value) => setState(() => _isOnline = value),
                ),
                TextFormField(
                  controller: _location,
                  decoration: InputDecoration(
                    labelText: _isOnline ? 'Meeting link' : 'Location',
                  ),
                  validator: _validateLocation,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _seats,
                  decoration: const InputDecoration(labelText: 'Seats'),
                  validator: _validateSeats,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _date,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: _pickDate,
                        validator: (_) => _day == null ? 'Choose a date' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _time,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.schedule),
                        ),
                        onTap: _pickTime,
                        validator: _validateTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
