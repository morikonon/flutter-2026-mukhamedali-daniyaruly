import '../models/countdown.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _twoDigits(int n) => n.toString().padLeft(2, '0');

/// 18 Oct
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// 09:05
String formatTime(DateTime d) => formatClock(d.hour, d.minute);

/// 09:05 from an hour and a minute (the time picker gives these).
String formatClock(int hour, int minute) =>
    '${_twoDigits(hour)}:${_twoDigits(minute)}';

/// 18 Oct, 09:05
String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

/// 2 d 3 h, 1 h 20 min, 45 min
String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays} d ${d.inHours % 24} h';
  if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes % 60} min';
  return '${d.inMinutes} min';
}

// Exhaustive: adding a fourth Countdown case breaks this until it is handled.
String formatCountdown(Countdown c) => switch (c) {
  Upcoming(:final left) => 'in ${formatDuration(left)}',
  Started(:final ago) => 'started ${formatDuration(ago)} ago',
  Ended() => 'ended',
};
