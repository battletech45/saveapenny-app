import 'package:freezed_annotation/freezed_annotation.dart';

part 'unread_count_response.freezed.dart';
part 'unread_count_response.g.dart';

@freezed
abstract class UnreadNotificationCountResponse
    with _$UnreadNotificationCountResponse {
  const factory UnreadNotificationCountResponse({required int unreadCount}) =
      _UnreadNotificationCountResponse;

  factory UnreadNotificationCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadNotificationCountResponseFromJson(json);
}
