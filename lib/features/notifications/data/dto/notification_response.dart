import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/notifications/domain/notification.dart';

part 'notification_response.freezed.dart';
part 'notification_response.g.dart';

@freezed
abstract class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
    required bool read,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}

extension NotificationResponseX on NotificationResponse {
  Notification toDomain() {
    return Notification(
      id: id,
      userId: userId,
      type: _notificationTypeFromWire(type),
      title: title,
      message: message,
      metadata: metadata,
      read: read,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

NotificationType _notificationTypeFromWire(String value) {
  return switch (value.toUpperCase()) {
    'BUDGET_WARNING' => NotificationType.budgetWarning,
    'BUDGET_EXCEEDED' => NotificationType.budgetExceeded,
    'RECURRING_TRANSACTION_CREATED' =>
      NotificationType.recurringTransactionCreated,
    'GOAL_OFF_TRACK' => NotificationType.goalOffTrack,
    'INSIGHT_GENERATED' => NotificationType.insightGenerated,
    'SYSTEM' => NotificationType.system,
    _ => throw FormatException('Unsupported notification type: $value'),
  };
}
