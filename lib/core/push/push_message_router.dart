/// Maps a push message's `data` payload to an in-app route.
///
/// Mirrors the wire values in `NotificationResponse`'s `type` field
/// (`_notificationTypeFromWire`), but stays defensive: an unrecognized or
/// missing type never throws, it falls back to the notifications list. This
/// is deliberately independent of that stricter parser — a malformed push
/// payload must never crash message handling.
String resolvePushRoute(Map<String, Object?> data) {
  final type = (data['type'] as String?)?.toUpperCase();

  switch (type) {
    case 'GOAL_OFF_TRACK':
      return _detailRoute(base: '/goals', id: data['goalId']);
    case 'INSIGHT_GENERATED':
      return _detailRoute(base: '/insights', id: data['insightId']);
    case 'BUDGET_WARNING':
    case 'BUDGET_EXCEEDED':
      return '/budgets';
    case 'RECURRING_TRANSACTION_CREATED':
      return '/recurring-transactions';
    default:
      return '/notifications';
  }
}

String _detailRoute({required String base, required Object? id}) {
  return id is String && id.isNotEmpty ? '$base/$id' : base;
}
