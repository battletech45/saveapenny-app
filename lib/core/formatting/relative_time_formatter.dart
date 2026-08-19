/// Coarse "how long ago" bucket for [RelativeTimeFormatter.bucket], kept
/// deliberately imprecise (minutes/hours/days, no seconds) — this only
/// backs the offline cache staleness label, not a live-updating clock.
enum RelativeTimeUnit { justNow, minutes, hours, days }

class RelativeTime {
  const RelativeTime(this.unit, this.count);

  final RelativeTimeUnit unit;
  final int count;
}

abstract final class RelativeTimeFormatter {
  static RelativeTime bucket(DateTime dateTime, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(dateTime);

    if (diff.inMinutes < 1) {
      return const RelativeTime(RelativeTimeUnit.justNow, 0);
    }
    if (diff.inMinutes < 60) {
      return RelativeTime(RelativeTimeUnit.minutes, diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return RelativeTime(RelativeTimeUnit.hours, diff.inHours);
    }
    return RelativeTime(RelativeTimeUnit.days, diff.inDays);
  }
}
