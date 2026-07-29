import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class UpcomingRunCard extends StatelessWidget {
  const UpcomingRunCard({super.key, required this.item});

  final UpcomingRecurringTransaction item;

  @override
  Widget build(BuildContext context) {
    final scheduled = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(item.scheduledDate);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name ??
                        AppLocalizations.of(
                          context,
                        ).recurringTransactionsUnnamed,
                    style: context.textTheme.body,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    scheduled,
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              NumberFormat.decimalPatternDigits(
                locale: Localizations.localeOf(context).toLanguageTag(),
                decimalDigits: 2,
              ).format(item.amount),
              style: context.textTheme.money,
            ),
          ],
        ),
      ),
    );
  }
}

class RecurringTransactionCard extends StatelessWidget {
  const RecurringTransactionCard({
    super.key,
    required this.item,
    required this.account,
    required this.category,
    required this.onHistory,
    this.onEdit,
    this.onPause,
    this.onResume,
    this.onDelete,
  });

  final RecurringTransaction item;
  final Account? account;
  final Category? category;
  final VoidCallback onHistory;
  final VoidCallback? onEdit;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nextRun = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(item.nextRunDate);
    final title =
        item.name ??
        category?.name ??
        recurringTransactionTypeLabel(l10n, item.type);
    final statusColor = recurringStatusColor(context, item.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: context.textTheme.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${recurringFrequencyLabel(l10n, item.frequency)} · ${account?.name ?? l10n.commonNotAvailable}',
                        style: context.textTheme.label.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                      case 'pause':
                        onPause?.call();
                      case 'resume':
                        onResume?.call();
                      case 'history':
                        onHistory();
                      case 'delete':
                        onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    if (onEdit != null)
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(l10n.recurringTransactionsEditCta),
                      ),
                    if (onPause != null)
                      PopupMenuItem<String>(
                        value: 'pause',
                        child: Text(l10n.recurringTransactionsPauseCta),
                      ),
                    if (onResume != null)
                      PopupMenuItem<String>(
                        value: 'resume',
                        child: Text(l10n.recurringTransactionsResumeCta),
                      ),
                    PopupMenuItem<String>(
                      value: 'history',
                      child: Text(l10n.recurringTransactionsHistoryCta),
                    ),
                    if (onDelete != null)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(l10n.recurringTransactionsDeleteCta),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: RecurringInfoPill(
                    label: l10n.recurringTransactionsNextRunDateLabel,
                    value: nextRun,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: RecurringInfoPill(
                    label: l10n.recurringTransactionsStatusLabel,
                    value: recurringStatusLabel(l10n, item.status),
                    valueColor: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: RecurringInfoPill(
                    label: l10n.recurringTransactionsAmountLabel,
                    value: NumberFormat.decimalPatternDigits(
                      locale: Localizations.localeOf(context).toLanguageTag(),
                      decimalDigits: 2,
                    ).format(item.amount),
                    valueColor: item.type == RecurringTransactionType.income
                        ? context.finance.income
                        : context.finance.expense,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: RecurringInfoPill(
                    label: l10n.recurringTransactionsClassificationLabel,
                    value: item.classification == null
                        ? l10n.recurringTransactionsClassificationNone
                        : recurringClassificationLabel(
                            l10n,
                            item.classification!,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
