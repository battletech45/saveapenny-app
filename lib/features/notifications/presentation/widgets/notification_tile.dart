import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final Notification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metadata = notification.metadata;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formattedDate = DateFormat.yMMMd(
      locale,
    ).format(notification.createdAt);
    final formattedTime = DateFormat.Hm(locale).format(notification.createdAt);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NotificationIcon(type: notification.type),
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

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key, required this.type});

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
      NotificationType.feedbackStatusUpdated => (
        Icons.feedback_outlined,
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
