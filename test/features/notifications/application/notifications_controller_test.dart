import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/notifications/application/notifications_controller.dart';
import 'package:saveapenny/features/notifications/data/notifications_repository.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';
import 'package:saveapenny/features/notifications/domain/notifications_repository.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({
    this.onList,
    this.onUnreadCount,
    this.onMarkRead,
    this.onMarkAllRead,
    this.onDelete,
  });

  final Future<PaginatedData<Notification>> Function()? onList;
  final Future<int> Function()? onUnreadCount;
  final Future<Notification> Function(String notificationId)? onMarkRead;
  final Future<void> Function()? onMarkAllRead;
  final Future<void> Function(String notificationId)? onDelete;

  @override
  Future<PaginatedData<Notification>> list({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) {
    return onList!();
  }

  @override
  Future<int> unreadCount() {
    return onUnreadCount!();
  }

  @override
  Future<Notification> markRead(String notificationId) {
    return onMarkRead!(notificationId);
  }

  @override
  Future<void> markAllRead() {
    return onMarkAllRead!();
  }

  @override
  Future<void> delete(String notificationId) {
    return onDelete!(notificationId);
  }
}

Notification _notification({
  required String id,
  bool read = false,
  NotificationType type = NotificationType.budgetWarning,
}) {
  return Notification(
    id: id,
    userId: 'u-1',
    type: type,
    title: 'Budget alert',
    message: 'You are nearing your limit.',
    read: read,
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

PaginatedData<Notification> _page(
  List<Notification> items, {
  int page = 0,
  bool hasNext = false,
  bool hasPrevious = false,
}) {
  return PaginatedData<Notification>(
    items: items,
    page: page,
    size: 20,
    totalItems: items.length,
    totalPages: hasNext ? page + 2 : page + 1,
    hasNext: hasNext,
    hasPrevious: hasPrevious,
  );
}

void main() {
  test('build loads the first page with unread count', () async {
    final existing = _notification(id: 'n-1');

    final container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWith(
          (ref) => _FakeNotificationsRepository(
            onList: () async => _page(<Notification>[existing]),
            onUnreadCount: () async => 3,
            onMarkRead: (_) async => existing,
            onMarkAllRead: () async {},
            onDelete: (_) async {},
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(notificationsControllerProvider.future);

    expect(state.items, hasLength(1));
    expect(state.items.single, existing);
    expect(state.unreadCount, 3);
  });

  test('markRead updates unread count optimistically', () async {
    final notification = _notification(id: 'n-1', read: false);

    final container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWith(
          (ref) => _FakeNotificationsRepository(
            onList: () async => _page(<Notification>[notification]),
            onUnreadCount: () async => 1,
            onMarkRead: (_) async => _notification(id: 'n-1', read: true),
            onMarkAllRead: () async {},
            onDelete: (_) async {},
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationsControllerProvider.future);

    await container
        .read(notificationsControllerProvider.notifier)
        .markRead('n-1');

    final state = container.read(notificationsControllerProvider).value!;
    expect(state.items.single.read, true);
    expect(state.unreadCount, 0);
  });

  test('markRead preserves state when mutation fails', () async {
    final notification = _notification(id: 'n-1', read: false);

    final container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWith(
          (ref) => _FakeNotificationsRepository(
            onList: () async => _page(<Notification>[notification]),
            onUnreadCount: () async => 1,
            onMarkRead: (_) async {
              throw const Failure.api(
                code: ApiErrorCode.resourceNotFound,
                message: 'Not found.',
              );
            },
            onMarkAllRead: () async {},
            onDelete: (_) async {},
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationsControllerProvider.future);

    await expectLater(
      container.read(notificationsControllerProvider.notifier).markRead('n-1'),
      throwsA(isA<ApiFailure>()),
    );

    final state = container.read(notificationsControllerProvider).value!;
    expect(state.items.single.read, false);
    expect(state.unreadCount, 1);
  });

  test('polls the unread count on an interval while the provider is alive', () {
    fakeAsync((async) {
      final notification = _notification(id: 'n-1');
      var unreadCount = 1;

      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWith(
            (ref) => _FakeNotificationsRepository(
              onList: () async => _page(<Notification>[notification]),
              onUnreadCount: () async => unreadCount,
              onMarkRead: (_) async => notification,
              onMarkAllRead: () async {},
              onDelete: (_) async {},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        notificationsControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      async.elapse(Duration.zero);

      unreadCount = 5;
      async.elapse(const Duration(seconds: 60));

      final state = container.read(notificationsControllerProvider).value!;
      expect(state.unreadCount, 5);
    });
  });
}
