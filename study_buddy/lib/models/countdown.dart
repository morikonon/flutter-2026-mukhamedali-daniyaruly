/// Where "now" is relative to a session. Sealed, so a switch over it
/// must handle all three cases.
sealed class Countdown {
  const Countdown();
}

/// Before the start: [left] is the time until it begins.
final class Upcoming extends Countdown {
  const Upcoming(this.left);

  final Duration left;
}

/// Running now: [ago] is the time since it began.
final class Started extends Countdown {
  const Started(this.ago);

  final Duration ago;
}

/// The session is over.
final class Ended extends Countdown {
  const Ended();
}
