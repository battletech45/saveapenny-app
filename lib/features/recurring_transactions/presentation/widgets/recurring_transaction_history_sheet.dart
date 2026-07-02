import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/recurring_transactions/application/recurring_transactions_controller.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class RecurringTransactionHistorySheet extends ConsumerWidget {
  const RecurringTransactionHistorySheet({
    required this.recurringTransactionId,
    super.key,
  });

  final String recurringTransactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyState = ref.watch(
      recurringTransactionHistoryControllerProvider(recurringTransactionId),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.recurringTransactionsHistoryTitle,
              style: context.textTheme.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.recurringTransactionsHistorySubtitle,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: historyState.when(
                data: (data) {
                  if (data.items.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.recurringTransactionsHistoryEmpty,
                        style: context.textTheme.body.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: data.items.length + (data.hasNext ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == data.items.length) {
                        return OutlinedButton(
                          onPressed: () => ref
                              .read(
                                recurringTransactionHistoryControllerProvider(
                                  recurringTransactionId,
                                ).notifier,
                              )
                              .loadMore(),
                          child: Text(
                            l10n.recurringTransactionsLoadMoreHistoryCta,
                          ),
                        );
                      }

                      return _HistoryTile(entry: data.items[index]);
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (error, _) => FailureView(
                  failure: error as Failure,
                  onRetry: () => ref
                      .read(
                        recurringTransactionHistoryControllerProvider(
                          recurringTransactionId,
                        ).notifier,
                      )
                      .refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

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
                  _historyStatusLabel(l10n, entry.status),
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

String _historyStatusLabel(
  AppLocalizations l10n,
  RecurringExecutionStatus status,
) {
  return switch (status) {
    RecurringExecutionStatus.success =>
      l10n.recurringTransactionsHistorySuccess,
    RecurringExecutionStatus.failed => l10n.recurringTransactionsHistoryFailed,
    RecurringExecutionStatus.skipped =>
      l10n.recurringTransactionsHistorySkipped,
  };
}
