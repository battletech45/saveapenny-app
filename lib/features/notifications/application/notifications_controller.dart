import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/notifications/data/notifications_repository.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';

part 'notifications_controller.freezed.dart';
part 'notifications_controller.g.dart';

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    required List<Notification> items,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    required int unreadCount,
  }) = _NotificationsState;
}

@Riverpod(keepAlive: true)
class NotificationsController extends _$NotificationsController {
  static const int _pageSize = 20;
  static const Duration _undoWindow = Duration(seconds: 5);

  bool _isLoadingMore = false;
  Timer? _undoTimer;
  (Notification, List<Notification>)? _pendingDelete;

  @override
  Future<NotificationsState> build() async {
    final unreadCount = await ref
        .read(notificationsRepositoryProvider)
        .unreadCount();
    return _fetchPage(page: 0, unreadCount: unreadCount);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final unreadCount = await ref
          .read(notificationsRepositoryProvider)
          .unreadCount();
      return _fetchPage(page: 0, unreadCount: unreadCount);
    });
  }

  Future<void> loadMore() async {
    final current = _readAsyncData(state);
    if (current == null || !current.hasNext || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = await _fetchPage(
        page: current.page + 1,
        unreadCount: current.unreadCount,
      );
      state = AsyncData(
        nextPage.copyWith(
          items: <Notification>[...current.items, ...nextPage.items],
        ),
      );
    } on Failure {
      state = AsyncData(current);
    } on Object {
      state = AsyncData(current);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> markRead(String notificationId) async {
    final current = _readAsyncData(state);
    final oldUnreadCount = current?.unreadCount ?? 0;

    _optimisticMarkSingleRead(notificationId);

    try {
      await ref.read(notificationsRepositoryProvider).markRead(notificationId);
    } on Failure {
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncData(
          NotificationsState(
            items: const <Notification>[],
            page: 0,
            size: _pageSize,
            totalItems: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            unreadCount: oldUnreadCount,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    final current = _readAsyncData(state);

    _optimisticMarkAllRead();

    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } on Failure {
      if (current != null) {
        state = AsyncData(current);
      }
      rethrow;
    }
  }

  void deleteNotification(String notificationId) {
    final current = _readAsyncData(state);
    if (current == null) {
      return;
    }

    final index = current.items.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      return;
    }

    final deletedItem = current.items[index];
    final remaining = <Notification>[
      ...current.items.sublist(0, index),
      ...current.items.sublist(index + 1),
    ];

    state = AsyncData(
      current.copyWith(
        items: remaining,
        totalItems: current.totalItems - 1,
        unreadCount: deletedItem.read
            ? current.unreadCount
            : current.unreadCount - 1,
      ),
    );

    _cancelPendingDelete();

    _pendingDelete = (deletedItem, current.items);

    _undoTimer = Timer(_undoWindow, () {
      unawaited(_executeBackgroundDelete(notificationId));
    });
  }

  void undoDelete() {
    final pending = _pendingDelete;
    if (pending == null) {
      return;
    }

    _cancelPendingDelete();

    final current = _readAsyncData(state);
    if (current == null) {
      return;
    }

    final (deletedItem, originalItems) = pending;
    final restoredUnreadCount = deletedItem.read
        ? current.unreadCount
        : current.unreadCount + 1;

    state = AsyncData(
      current.copyWith(
        items: originalItems,
        totalItems: current.totalItems + 1,
        unreadCount: restoredUnreadCount,
      ),
    );
  }

  void _optimisticMarkSingleRead(String notificationId) {
    final current = _readAsyncData(state);
    if (current == null) {
      return;
    }

    final items = [...current.items];
    var unreadCount = current.unreadCount;

    for (var i = 0; i < items.length; i++) {
      if (items[i].id == notificationId && !items[i].read) {
        items[i] = items[i].copyWith(read: true);
        unreadCount -= 1;
        break;
      }
    }

    state = AsyncData(current.copyWith(items: items, unreadCount: unreadCount));
  }

  void _optimisticMarkAllRead() {
    final current = _readAsyncData(state);
    if (current == null) {
      return;
    }

    final items = current.items
        .map((n) => n.copyWith(read: true))
        .toList(growable: false);

    state = AsyncData(current.copyWith(items: items, unreadCount: 0));
  }

  Future<NotificationsState> _fetchPage({
    required int page,
    int? unreadCount,
  }) async {
    final response = await ref
        .read(notificationsRepositoryProvider)
        .list(page: page, size: _pageSize);

    final effectiveUnreadCount =
        unreadCount ??
        await ref.read(notificationsRepositoryProvider).unreadCount();

    return NotificationsState(
      items: response.items,
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
      unreadCount: effectiveUnreadCount,
    );
  }

  NotificationsState? _readAsyncData(AsyncValue<NotificationsState> value) {
    return value is AsyncData<NotificationsState> ? value.value : null;
  }

  void _cancelPendingDelete() {
    _undoTimer?.cancel();
    _undoTimer = null;
    _pendingDelete = null;
  }

  Future<void> _executeBackgroundDelete(String notificationId) async {
    _pendingDelete = null;

    try {
      await ref.read(notificationsRepositoryProvider).delete(notificationId);
    } on Failure {
      unawaited(refresh());
    }
  }
}
