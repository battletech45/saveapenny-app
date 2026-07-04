import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';

enum NotificationType {
  budgetWarning,
  budgetExceeded,
  recurringTransactionCreated,
  goalOffTrack,
  insightGenerated,
  system,
}

@freezed
abstract class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
    required bool read,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Notification;
}
