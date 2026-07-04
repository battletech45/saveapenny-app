import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/notifications/data/dto/notification_response.dart';
import 'package:saveapenny/features/notifications/data/notifications_api.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';
import 'package:saveapenny/features/notifications/domain/notifications_repository.dart';

part 'notifications_repository.g.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._notificationsApi);

  final NotificationsApi _notificationsApi;

  @override
  Future<PaginatedData<Notification>> list({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    final response = await _notificationsApi.list(
      page: page,
      size: size,
      sort: sort,
    );

    return PaginatedData<Notification>(
      items: response.items
          .map((NotificationResponse item) => item.toDomain())
          .toList(growable: false),
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  @override
  Future<int> unreadCount() async {
    final response = await _notificationsApi.unreadCount();
    return response.unreadCount;
  }

  @override
  Future<Notification> markRead(String notificationId) async {
    final response = await _notificationsApi.markRead(notificationId);
    return response.toDomain();
  }

  @override
  Future<void> markAllRead() {
    return _notificationsApi.markAllRead();
  }

  @override
  Future<void> delete(String notificationId) {
    return _notificationsApi.delete(notificationId);
  }
}

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepositoryImpl(ref.watch(notificationsApiProvider));
}
