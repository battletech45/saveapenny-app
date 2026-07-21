import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/presentation/widgets/plan_limit_banner.dart';
import 'package:saveapenny/features/reports/application/reports_controller.dart';
import 'package:saveapenny/features/reports/domain/cash_flow_point.dart';
import 'package:saveapenny/features/reports/domain/category_spending.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reportsState = ref.watch(reportsControllerProvider);
    final accounts =
        _readAsyncData(ref.watch(accountsControllerProvider)) ??
        const <Account>[];
    final currencyCode = accounts.isEmpty ? 'TRY' : accounts.first.currency;
    final entitlement = ref.watch(entitlementControllerProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: SafeArea(
        child: reportsState.when(
          data: (data) {
            final hasActivity =
                data.categorySpending.isNotEmpty || data.cashFlow.isNotEmpty;

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(reportsControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  PlanLockedFeatureBanner(
                    isUnlocked: entitlement?.features.reportExport ?? true,
                    message: l10n.reportsHistoryLimitedMessage(
                      entitlement?.limits.reportHistoryMonths ?? 3,
                    ),
                  ),
                  _MonthSwitcher(month: data.month),
                  const SizedBox(height: AppSpacing.lg),
                  _SummaryCard(state: data, currencyCode: currencyCode),
                  const SizedBox(height: AppSpacing.lg),
                  _NetWorthCard(state: data, currencyCode: currencyCode),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.reportsCashFlowTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (data.cashFlow.isEmpty)
                    _InlineEmptyState(
                      title: l10n.reportsCashFlowEmptyTitle,
                      message: l10n.reportsCashFlowEmptyMessage,
                    )
                  else
                    ...data.cashFlow.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CashFlowTile(
                          item: item,
                          currencyCode: currencyCode,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.reportsCategorySpendingTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (data.categorySpending.isEmpty)
                    _InlineEmptyState(
                      title: l10n.reportsCategorySpendingEmptyTitle,
                      message: l10n.reportsCategorySpendingEmptyMessage,
                    )
                  else
                    ...data.categorySpending.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CategorySpendingTile(
                          item: item,
                          currencyCode: currencyCode,
                        ),
                      ),
                    ),
                  if (!hasActivity) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxl),
                    _InlineEmptyState(
                      title: l10n.reportsEmptyTitle,
                      message: l10n.reportsEmptyMessage,
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () =>
                ref.read(reportsControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

class _MonthSwitcher extends ConsumerWidget {
  const _MonthSwitcher({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = DateFormat.yMMMM(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(month);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () =>
                  ref.read(reportsControllerProvider.notifier).previousMonth(),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.title,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(reportsControllerProvider.notifier).nextMonth(),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state, required this.currencyCode});

  final ReportsState state;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.reportsMonthlySummaryTitle,
              style: context.textTheme.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.reportsMonthlySummarySubtitle,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _MoneyRow(
              label: l10n.reportsIncomeLabel,
              amount: state.monthlySummary.totalIncome,
              currencyCode: currencyCode,
            ),
            const SizedBox(height: AppSpacing.md),
            _MoneyRow(
              label: l10n.reportsExpenseLabel,
              amount: -state.monthlySummary.totalExpense,
              currencyCode: currencyCode,
            ),
            const SizedBox(height: AppSpacing.md),
            _MoneyRow(
              label: l10n.reportsNetSavingsLabel,
              amount: state.monthlySummary.netSavings,
              currencyCode: currencyCode,
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard({required this.state, required this.currencyCode});

  final ReportsState state;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.reportsNetWorthTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.reportsNetWorthSubtitle,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _MoneyRow(
              label: l10n.reportsAssetsLabel,
              amount: state.currentNetWorth.totalAssets,
              currencyCode: currencyCode,
            ),
            const SizedBox(height: AppSpacing.md),
            _MoneyRow(
              label: l10n.reportsLiabilitiesLabel,
              amount: -state.currentNetWorth.totalLiabilities,
              currencyCode: currencyCode,
            ),
            const SizedBox(height: AppSpacing.md),
            _MoneyRow(
              label: l10n.reportsNetWorthLabel,
              amount: state.currentNetWorth.netWorth,
              currencyCode: currencyCode,
              emphasize: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.reportsTrendTitle, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.sm),
            ...state.netWorthTrend.map(
              (snapshot) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _NetWorthTrendTile(
                  snapshot: snapshot,
                  currencyCode: currencyCode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetWorthTrendTile extends StatelessWidget {
  const _NetWorthTrendTile({
    required this.snapshot,
    required this.currencyCode,
  });

  final NetWorthSnapshot snapshot;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMM(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(snapshot.snapshotDate);
    final amount = MoneyFormatter.format(
      context: context,
      amount: snapshot.netWorth,
      currencyCode: currencyCode,
    );

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
            Expanded(child: Text(label, style: context.textTheme.body)),
            Text(
              amount.text,
              style: context.textTheme.money.copyWith(color: amount.color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashFlowTile extends StatelessWidget {
  const _CashFlowTile({required this.item, required this.currencyCode});

  final CashFlowPoint item;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(item.date);
    final net = MoneyFormatter.format(
      context: context,
      amount: item.netAmount,
      currencyCode: currencyCode,
    );
    final income = MoneyFormatter.format(
      context: context,
      amount: item.incomeAmount,
      currencyCode: currencyCode,
    );
    final expense = MoneyFormatter.format(
      context: context,
      amount: -item.expenseAmount,
      currencyCode: currencyCode,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(dateLabel, style: context.textTheme.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${l10n.reportsIncomeLabel}: ${income.text} · ${l10n.reportsExpenseLabel}: ${expense.text}',
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              net.text,
              textAlign: TextAlign.right,
              style: context.textTheme.money.copyWith(color: net.color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySpendingTile extends StatelessWidget {
  const _CategorySpendingTile({required this.item, required this.currencyCode});

  final CategorySpending item;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final amount = MoneyFormatter.format(
      context: context,
      amount: -item.totalAmount,
      currencyCode: currencyCode,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.categoryName, style: context.textTheme.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${item.usagePercentage.toStringAsFixed(1)}%',
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              amount.text,
              textAlign: TextAlign.right,
              style: context.textTheme.money.copyWith(color: amount.color),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.amount,
    required this.currencyCode,
    this.emphasize = false,
  });

  final String label;
  final num amount;
  final String currencyCode;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final formatted = MoneyFormatter.format(
      context: context,
      amount: amount,
      currencyCode: currencyCode,
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: emphasize ? context.textTheme.body : context.textTheme.label,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          formatted.text,
          textAlign: TextAlign.right,
          style:
              (emphasize
                      ? context.textTheme.displayMoney
                      : context.textTheme.money)
                  .copyWith(color: formatted.color),
        ),
      ],
    );
  }
}

T? _readAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
