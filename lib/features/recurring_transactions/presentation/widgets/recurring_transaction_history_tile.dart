import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class RecurringTransactionHistoryTile extends StatelessWidget {
  const RecurringTransactionHistoryTile({super.key, required this.entry});

  final RecurringTransactionHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheduled = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(entry.scheduledDate);
    final executed = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(entry.executedAt);
    final color = switch (entry.status) {
      RecurringExecutionStatus.success => context.finance.income,
      RecurringExecutionStatus.failed => context.finance.expense,
      RecurringExecutionStatus.skipped => context.finance.warning,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(scheduled, style: context.textTheme.body)),
                Text(
                  recurringHistoryStatusLabel(l10n, entry.status),
                  style: context.textTheme.label.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              executed,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            if (entry.failureReason != null &&
                entry.failureReason!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                entry.failureReason!,
                style: context.textTheme.label.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
