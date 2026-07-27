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
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/presentation/widgets/plan_limit_banner.dart';
import 'package:saveapenny/features/budgets/application/budgets_controller.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final budgetsState = ref.watch(budgetsControllerProvider);
    final limits = ref.watch(entitlementControllerProvider).value?.limits;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.budgetsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budgetsFab',
        onPressed: () => _showBudgetSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.budgetsAddCta),
      ),
      body: SafeArea(
        child: budgetsState.when(
          data: (data) {
            if (data.items.isEmpty) {
              return EmptyView(
                title: l10n.budgetsEmptyTitle,
                message: l10n.budgetsEmptyMessage,
                action: ElevatedButton(
                  onPressed: () => _showBudgetSheet(context),
                  child: Text(l10n.budgetsAddFirstCta),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(budgetsControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  PlanLimitBanner(
                    used: limits?.activeBudgets ?? 0,
                    max: limits?.maxActiveBudgets,
                    message: l10n.budgetsLimitReachedMessage,
                  ),
                  for (final item in data.items) ...<Widget>[
                    _BudgetCard(
                      item: item,
                      onEdit: () =>
                          _showBudgetSheet(context, existing: item.budget),
                      onDelete: () => _confirmDelete(context, ref, item.budget),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (data.hasNext)
                    OutlinedButton(
                      onPressed: () => ref
                          .read(budgetsControllerProvider.notifier)
                          .loadMore(),
                      child: Text(l10n.budgetsLoadMoreCta),
                    ),
                ],
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () =>
                ref.read(budgetsControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showBudgetSheet(BuildContext context, {Budget? existing}) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => BudgetFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.budgetsDeleteTitle),
          content: Text(l10n.budgetsDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.budgetsDeleteCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(budgetsControllerProvider.notifier)
          .deleteBudget(budget.id);
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

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetListItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(context, item.status.status);
    final dateRange = _dateRangeLabel(context, item.budget);

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
                      Text(
                        item.status.category,
                        style: context.textTheme.title,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${_periodLabel(l10n, item.budget.period)} · $dateRange',
                        style: context.textTheme.label.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                      return;
                    }
                    onDelete();
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(l10n.budgetsEditCta),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(l10n.budgetsDeleteCta),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricPill(
                    label: l10n.budgetsBudgetAmountLabel,
                    value: _formatAmount(context, item.status.budgetAmount),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricPill(
                    label: l10n.budgetsSpentAmountLabel,
                    value: _formatAmount(context, item.status.spentAmount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricPill(
                    label: l10n.budgetsRemainingAmountLabel,
                    value: _formatAmount(context, item.status.remainingAmount),
                    valueColor: statusColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatusPill(
                    label: l10n.budgetsStatusLabel,
                    value: _statusLabel(l10n, item.status.status),
                    color: statusColor,
                    detail:
                        '${item.status.usagePercentage.toStringAsFixed(2)}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dateRangeLabel(BuildContext context, Budget budget) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.yMMMd(locale);
    return '${formatter.format(budget.startDate)} - ${formatter.format(budget.endDate)}';
  }

  String _formatAmount(BuildContext context, num value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    ).format(value);
  }

  Color _statusColor(BuildContext context, BudgetHealth status) {
    return switch (status) {
      BudgetHealth.onTrack => context.colors.textPrimary,
      BudgetHealth.warning => context.finance.warning,
      BudgetHealth.exceeded => context.finance.expense,
    };
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    this.valueColor,
  });

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
              style: context.textTheme.money.copyWith(
                color: valueColor ?? context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.value,
    required this.color,
    required this.detail,
  });

  final String label;
  final String value;
  final Color color;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color),
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
            Text(value, style: context.textTheme.body.copyWith(color: color)),
            const SizedBox(height: AppSpacing.xs),
            Text(detail, style: context.textTheme.money.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

String _periodLabel(AppLocalizations l10n, BudgetPeriod period) {
  return switch (period) {
    BudgetPeriod.monthly => l10n.budgetsPeriodMonthly,
    BudgetPeriod.yearly => l10n.budgetsPeriodYearly,
  };
}

String _statusLabel(AppLocalizations l10n, BudgetHealth status) {
  return switch (status) {
    BudgetHealth.onTrack => l10n.budgetsStatusOnTrack,
    BudgetHealth.warning => l10n.budgetsStatusWarning,
    BudgetHealth.exceeded => l10n.budgetsStatusExceeded,
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
      ApiErrorCode.budgetNotFound => l10n.failureResourceNotFoundMessage,
      ApiErrorCode.budgetAlreadyExists => l10n.budgetsDuplicateError,
      ApiErrorCode.invalidBudgetDateRange => l10n.budgetsDateRangeError,
      _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
      _ => l10n.failureValidationFailedMessage,
    },
  };
}
