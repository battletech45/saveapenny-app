import 'dart:async';

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/notifications/application/notifications_controller.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationsState = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
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
                      background: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: context.finance.expense,
                          ),
                        ),
                      ),
                      confirmDismiss: (_) async {
                        return _confirmDelete(context, ref, notification, l10n);
                      },
                      child: _NotificationTile(
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final Notification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metadata = notification.metadata;
    final formattedDate = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(notification.createdAt);
    final formattedTime = DateFormat.Hm(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(notification.createdAt);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _NotificationIcon(type: notification.type),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      notification.title,
                      style: context.textTheme.body.copyWith(
                        fontWeight: notification.read
                            ? AppFontWeight.regular
                            : AppFontWeight.semibold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.message,
                      style: context.textTheme.label.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (metadata != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        metadata.toString(),
                        style: context.textTheme.label.copyWith(
                          color: context.colors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$formattedDate $formattedTime',
                      style: context.textTheme.label.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: AppSpacing.sm,
                  height: AppSpacing.sm,
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color surface, Color foreground) = switch (type) {
      NotificationType.budgetWarning || NotificationType.budgetExceeded => (
        Icons.account_balance_wallet_outlined,
        context.finance.warningSurface,
        context.finance.warning,
      ),
      NotificationType.recurringTransactionCreated => (
        Icons.repeat_rounded,
        context.finance.incomeSurface,
        context.finance.income,
      ),
      NotificationType.goalOffTrack => (
        Icons.flag_outlined,
        context.finance.expenseSurface,
        context.finance.expense,
      ),
      NotificationType.insightGenerated => (
        Icons.lightbulb_outline_rounded,
        context.finance.info,
        context.colors.textPrimary,
      ),
      NotificationType.system => (
        Icons.info_outline_rounded,
        context.colors.surfaceSubtle,
        context.colors.textSecondary,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, size: 20, color: foreground),
      ),
    );
  }
}

Future<bool> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Notification notification,
  AppLocalizations l10n,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.notificationsDeleteMessage(notification.title)),
        content: Text(notification.message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.notificationsDeleteDialogCancelCta),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.notificationsDeleteDialogRemoveCta),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return false;
  }

  if (!context.mounted) {
    return false;
  }

  ref
      .read(notificationsControllerProvider.notifier)
      .deleteNotification(notification.id);

  _showUndoSnackBar(context, ref, notification.title);

  return false;
}

void _showUndoSnackBar(BuildContext context, WidgetRef ref, String title) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        AppLocalizations.of(context).notificationsUndoMessage(title),
      ),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: AppLocalizations.of(context).notificationsUndoAction,
        onPressed: () {
          ref.read(notificationsControllerProvider.notifier).undoDelete();
        },
      ),
    ),
  );
}
