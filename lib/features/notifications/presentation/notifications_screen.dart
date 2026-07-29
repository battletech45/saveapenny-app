import 'dart:async';

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/notifications/application/notifications_controller.dart';
import 'package:saveapenny/features/notifications/presentation/widgets/notification_shared.dart';
import 'package:saveapenny/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationsState = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              unawaited(
                ref
                    .read(notificationsControllerProvider.notifier)
                    .markAllRead(),
              );
            },
            tooltip: l10n.notificationsMarkAllRead,
            icon: const Icon(Icons.done_all_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: notificationsState.when(
          data: (data) {
            if (data.items.isEmpty) {
              return EmptyView(
                title: l10n.notificationsEmptyTitle,
                message: l10n.notificationsEmptyMessage,
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(notificationsControllerProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.md,
                  bottom: AppSpacing.xxl,
                ),
                itemCount: data.items.length,
                itemBuilder: (context, index) {
                  final notification = data.items[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Dismissible(
                      key: ValueKey(notification.id),
                      direction: DismissDirection.endToStart,
                      background: const NotificationDismissBackground(),
                      confirmDismiss: (_) async {
                        return confirmNotificationDelete(
                          context,
                          ref,
                          notification,
                        );
                      },
                      child: NotificationTile(
                        notification: notification,
                        onTap: () {
                          if (!notification.read) {
                            unawaited(
                              ref
                                  .read(
                                    notificationsControllerProvider.notifier,
                                  )
                                  .markRead(notification.id),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () =>
                ref.read(notificationsControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}
