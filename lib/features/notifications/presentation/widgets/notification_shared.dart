import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/notifications/application/notifications_controller.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class NotificationDismissBackground extends StatelessWidget {
  const NotificationDismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Icon(
          Icons.delete_outline_rounded,
          color: context.finance.expense,
        ),
      ),
    );
  }
}

Future<bool> confirmNotificationDelete(
  BuildContext context,
  WidgetRef ref,
  Notification notification,
) async {
  final l10n = AppLocalizations.of(context);
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

  if (confirmed != true || !context.mounted) {
    return false;
  }

  ref
      .read(notificationsControllerProvider.notifier)
      .deleteNotification(notification.id);
  showNotificationUndoSnackBar(context, ref, notification.title);

  return false;
}

void showNotificationUndoSnackBar(
  BuildContext context,
  WidgetRef ref,
  String title,
) {
  final l10n = AppLocalizations.of(context);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.notificationsUndoMessage(title)),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.notificationsUndoAction,
          onPressed: () {
            ref.read(notificationsControllerProvider.notifier).undoDelete();
          },
        ),
      ),
    );
}
