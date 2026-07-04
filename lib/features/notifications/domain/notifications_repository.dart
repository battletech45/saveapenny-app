import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';

abstract interface class NotificationsRepository {
  Future<PaginatedData<Notification>> list({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  });

  Future<int> unreadCount();

  Future<Notification> markRead(String notificationId);

  Future<void> markAllRead();

  Future<void> delete(String notificationId);
}
