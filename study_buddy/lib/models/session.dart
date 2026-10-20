import 'dart:collection';

import '../config.dart';
import 'countdown.dart';
import 'subject.dart';

/// One peer tutoring session. Immutable: every change goes through copyWith.
class Session {
  const Session({
    required this.id,
    required this.title,
    required this.subject,
    required this.startsAt,
    required this.seats,
    required this.location,
    // Callers pass `participants:`; the field itself stays private.
    this._participants = const [],
    this.isOnline = false,
    this.description,
    this.isFavourite = false,
  });

  /// Defaults for the "new session" form.
  Session.empty()
    : id = '',
      title = '',
      subject = Subject.math,
      startsAt = DateTime.now().add(const Duration(days: 1)),
      seats = 20,
      location = '',
      _participants = const [],
      isOnline = false,
      description = null,
      isFavourite = false;

  final String id;
  final String title;
  final Subject subject;
  final DateTime startsAt;
  final int seats;

  /// A room when [isOnline] is false, a meeting link when it is true.
  final String location;
  final List<String> _participants;
  final bool isOnline;
  final String? description;
  final bool isFavourite;

  // Read-only view: callers cannot add or remove names.
  List<String> get participants => UnmodifiableListView(_participants);

  // Derived values are getters, so they can never go out of sync.
  int get count => _participants.length;

  int get free => count >= seats ? 0 : seats - count;

  bool get isFull => count >= seats;

  DateTime get endsAt => startsAt.add(sessionLength);

  bool get isPast => DateTime.now().isAfter(endsAt);

  ({int taken, int free}) get places => (taken: count, free: free);

  bool contains(String name) {
    final wanted = name.trim().toLowerCase();
    if (wanted.isEmpty) return false;
    return _participants.any((p) => p.trim().toLowerCase() == wanted);
  }

  Countdown countdown(DateTime now) {
    if (now.isBefore(startsAt)) return Upcoming(startsAt.difference(now));
    if (now.isBefore(endsAt)) return Started(now.difference(startsAt));
    return const Ended();
  }

  /// [clearDescription] exists because `description: null` means "keep".
  Session copyWith({
    String? id,
    String? title,
    Subject? subject,
    DateTime? startsAt,
    int? seats,
    String? location,
    List<String>? participants,
    bool? isOnline,
    String? description,
    bool clearDescription = false,
    bool? isFavourite,
  }) => Session(
    id: id ?? this.id,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    startsAt: startsAt ?? this.startsAt,
    seats: seats ?? this.seats,
    location: location ?? this.location,
    participants: participants == null
        ? _participants
        : List.unmodifiable(participants),
    isOnline: isOnline ?? this.isOnline,
    description: clearDescription ? null : description ?? this.description,
    isFavourite: isFavourite ?? this.isFavourite,
  );
}
