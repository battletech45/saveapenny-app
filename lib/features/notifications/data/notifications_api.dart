import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/notifications/data/dto/notification_response.dart';
import 'package:saveapenny/features/notifications/data/dto/unread_count_response.dart';

part 'notifications_api.g.dart';

class NotificationsApi {
  NotificationsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedData<NotificationResponse>> list({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) {
    return _apiClient.send<PaginatedData<NotificationResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/notifications',
        queryParameters: <String, Object?>{
          'read': 'false',
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) => PaginatedData<NotificationResponse>.fromJson(
        _readJsonMap(data),
        (item) => NotificationResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<UnreadNotificationCountResponse> unreadCount() {
    return _apiClient.send<UnreadNotificationCountResponse>(
      call: (dio) => dio.get<dynamic>('/notifications/unread-count'),
      fromData: (data) =>
          UnreadNotificationCountResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<NotificationResponse> markRead(String notificationId) {
    return _apiClient.send<NotificationResponse>(
      call: (dio) => dio.put<dynamic>(
        '/notifications/$notificationId',
        data: <String, bool>{'read': true},
      ),
      fromData: (data) => NotificationResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> markAllRead() {
    return _apiClient.send<void>(
      call: (dio) => dio.patch<dynamic>('/notifications/mark-all-read'),
      fromData: (_) {},
    );
  }

  Future<void> delete(String notificationId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>('/notifications/$notificationId'),
      fromData: (_) {},
    );
  }
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
NotificationsApi notificationsApi(Ref ref) {
  return NotificationsApi(ref.watch(apiClientProvider));
}
