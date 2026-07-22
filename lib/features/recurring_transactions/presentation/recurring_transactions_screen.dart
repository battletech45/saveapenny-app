import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/presentation/widgets/plan_limit_banner.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/recurring_transactions/application/recurring_transactions_controller.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_form_sheet.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_history_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recurringState = ref.watch(recurringTransactionsControllerProvider);
    final accounts =
        _readAsyncData(ref.watch(accountsControllerProvider)) ??
        const <Account>[];
    final categories =
        _readAsyncData(ref.watch(categoriesControllerProvider)) ??
        const <Category>[];
    final accountById = <String, Account>{
      for (final account in accounts) account.id: account,
    };
    final categoryById = <String, Category>{
      for (final category in categories) category.id: category,
    };
    final advancedRecurringUnlocked =
        ref.watch(entitlementControllerProvider).value?.features.advancedRecurring ??
        true;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTransactionsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recurringTransactionsFab',
        onPressed: () => _showFormSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.recurringTransactionsAddCta),
      ),
      body: SafeArea(
        child: recurringState.when(
          data: (data) {
            if (data.items.isEmpty) {
              return EmptyView(
                title: l10n.recurringTransactionsEmptyTitle,
                message: l10n.recurringTransactionsEmptyMessage,
                action: ElevatedButton(
                  onPressed: () => _showFormSheet(context),
                  child: Text(l10n.recurringTransactionsAddFirstCta),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref
                  .read(recurringTransactionsControllerProvider.notifier)
                  .refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  PlanLockedFeatureBanner(
                    isUnlocked: advancedRecurringUnlocked,
                    message: l10n.recurringTransactionsAdvancedLockedMessage,
                  ),
                  if (data.upcoming.isNotEmpty) ...[
                    Text(
                      l10n.recurringTransactionsUpcomingTitle,
                      style: context.textTheme.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...data.upcoming.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _UpcomingRunCard(item: item),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  Text(
                    l10n.recurringTransactionsListTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...data.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _RecurringTransactionCard(
                        item: item,
                        account: accountById[item.accountId],
                        category: categoryById[item.categoryId],
                        onEdit: item.status == RecurringStatus.expired
                            ? null
                            : () => _showFormSheet(context, existing: item),
                        onHistory: () => _showHistorySheet(context, item.id),
                        onPause: item.status == RecurringStatus.active
                            ? () => _runAction(
                                context,
                                ref,
                                () => ref
                                    .read(
                                      recurringTransactionsControllerProvider
                                          .notifier,
                                    )
                                    .pause(item.id),
                              )
                            : null,
                        onResume: item.status == RecurringStatus.paused
                            ? () => _runAction(
                                context,
                                ref,
                                () => ref
                                    .read(
                                      recurringTransactionsControllerProvider
                                          .notifier,
                                    )
                                    .resume(item.id),
                              )
                            : null,
                        onDelete: item.status == RecurringStatus.expired
                            ? null
                            : () => _confirmDelete(context, ref, item),
                      ),
                    ),
                  ),
                  if (data.hasNext)
                    OutlinedButton(
                      onPressed: () => ref
                          .read(
                            recurringTransactionsControllerProvider.notifier,
                          )
                          .loadMore(),
                      child: Text(l10n.recurringTransactionsLoadMoreCta),
                    ),
                ],
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref
                .read(recurringTransactionsControllerProvider.notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showFormSheet(
    BuildContext context, {
    RecurringTransaction? existing,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => RecurringTransactionFormSheet(existing: existing),
    );
  }

  Future<void> _showHistorySheet(
    BuildContext context,
    String recurringTransactionId,
  ) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => RecurringTransactionHistorySheet(
        recurringTransactionId: recurringTransactionId,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recurringTransactionsDeleteTitle),
        content: Text(l10n.recurringTransactionsDeleteMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.recurringTransactionsDeleteCta),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      ref,
      () => ref
          .read(recurringTransactionsControllerProvider.notifier)
          .deleteRecurringTransaction(item.id),
    );
  }

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_failureMessage(context, failure))),
      );
    }
  }
}

class _UpcomingRunCard extends StatelessWidget {
  const _UpcomingRunCard({required this.item});

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

class _RecurringTransactionCard extends StatelessWidget {
  const _RecurringTransactionCard({
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
    final title = item.name ?? category?.name ?? _typeLabel(l10n, item.type);
    final statusColor = _statusColor(context, item.status);

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
                        '${_frequencyLabel(l10n, item.frequency)} · ${account?.name ?? l10n.commonNotAvailable}',
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
                  child: _InfoPill(
                    label: l10n.recurringTransactionsNextRunDateLabel,
                    value: nextRun,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _InfoPill(
                    label: l10n.recurringTransactionsStatusLabel,
                    value: _statusLabel(l10n, item.status),
                    valueColor: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: _InfoPill(
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
                  child: _InfoPill(
                    label: l10n.recurringTransactionsClassificationLabel,
                    value: item.classification == null
                        ? l10n.recurringTransactionsClassificationNone
                        : _classificationLabel(l10n, item.classification!),
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
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
            Text(
              label,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: context.textTheme.body.copyWith(
                color: valueColor ?? context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _typeLabel(AppLocalizations l10n, RecurringTransactionType type) {
  return switch (type) {
    RecurringTransactionType.income => l10n.recurringTransactionsTypeIncome,
    RecurringTransactionType.expense => l10n.recurringTransactionsTypeExpense,
  };
}

String _frequencyLabel(AppLocalizations l10n, RecurringFrequency frequency) {
  return switch (frequency) {
    RecurringFrequency.daily => l10n.recurringTransactionsFrequencyDaily,
    RecurringFrequency.weekly => l10n.recurringTransactionsFrequencyWeekly,
    RecurringFrequency.monthly => l10n.recurringTransactionsFrequencyMonthly,
    RecurringFrequency.yearly => l10n.recurringTransactionsFrequencyYearly,
  };
}

String _statusLabel(AppLocalizations l10n, RecurringStatus status) {
  return switch (status) {
    RecurringStatus.active => l10n.recurringTransactionsStatusActive,
    RecurringStatus.paused => l10n.recurringTransactionsStatusPaused,
    RecurringStatus.expired => l10n.recurringTransactionsStatusExpired,
    RecurringStatus.failed => l10n.recurringTransactionsStatusFailed,
  };
}

String _classificationLabel(
  AppLocalizations l10n,
  RecurringClassification classification,
) {
  return switch (classification) {
    RecurringClassification.paycheck =>
      l10n.recurringTransactionsClassificationPaycheck,
    RecurringClassification.subscription =>
      l10n.recurringTransactionsClassificationSubscription,
    RecurringClassification.rent =>
      l10n.recurringTransactionsClassificationRent,
    RecurringClassification.utility =>
      l10n.recurringTransactionsClassificationUtility,
    RecurringClassification.loanPayment =>
      l10n.recurringTransactionsClassificationLoanPayment,
    RecurringClassification.savingsContribution =>
      l10n.recurringTransactionsClassificationSavingsContribution,
    RecurringClassification.other =>
      l10n.recurringTransactionsClassificationOther,
  };
}

Color _statusColor(BuildContext context, RecurringStatus status) {
  return switch (status) {
    RecurringStatus.active => context.finance.income,
    RecurringStatus.paused => context.finance.warning,
    RecurringStatus.expired => context.colors.textTertiary,
    RecurringStatus.failed => context.finance.expense,
  };
}

String _failureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);
  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      ApiErrorCode.recurringTransactionNotFound =>
        l10n.failureResourceNotFoundMessage,
      ApiErrorCode.recurringTransactionDependencyNotFound =>
        l10n.failureResourceNotFoundMessage,
      ApiErrorCode.invalidRecurringTransactionNextRunDate =>
        l10n.recurringTransactionsNextRunDateError,
      ApiErrorCode.invalidRecurringTransactionType =>
        l10n.recurringTransactionsTypeError,
      ApiErrorCode.invalidRecurringTransactionStatusTransition =>
        l10n.recurringTransactionsStatusTransitionError,
      _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
      _ => l10n.failureValidationFailedMessage,
    },
  };
}

T? _readAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
