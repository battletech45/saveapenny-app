import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/reports/application/reports_controller.dart';
import 'package:saveapenny/features/reports/domain/cash_flow_point.dart';
import 'package:saveapenny/features/reports/domain/category_spending.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';
import 'package:saveapenny/features/reports/presentation/widgets/reports_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ReportsMonthSwitcher extends StatelessWidget {
  const ReportsMonthSwitcher({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMMM(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(month);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onPrevious,
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
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportsSummaryCard extends StatelessWidget {
  const ReportsSummaryCard({
    super.key,
    required this.state,
    required this.currencyCode,
  });

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
            ReportsMoneyRow(
              label: l10n.reportsIncomeLabel,
              amount: state.monthlySummary.totalIncome,
              currencyCode: currencyCode,
            ),
            const SizedBox(height: AppSpacing.md),
            ReportsMoneyRow(
              label: l10n.reportsExpenseLabel,
              amount: -state.monthlySummary.totalExpense,
              currencyCode: currencyCode,
            ),
            const SizedBox(height: AppSpacing.md),
            ReportsMoneyRow(
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

class ReportsNetWorthCard extends StatelessWidget {
  const ReportsNetWorthCard({
    super.key,
    required this.state,
    required this.currencyCode,
  });

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
            ReportsMoneyRow(
              label: l10n.reportsAssetsLabel,
              amount: state.currentNetWorth.totalAssets,
              currencyCode: currencyCode,
            ),
            const SizedBox(height: AppSpacing.md),
            ReportsMoneyRow(
              label: l10n.reportsLiabilitiesLabel,
              amount: -state.currentNetWorth.totalLiabilities,
              currencyCode: currencyCode,
            ),
            const SizedBox(height: AppSpacing.md),
            ReportsMoneyRow(
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
                child: ReportsNetWorthTrendTile(
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

class ReportsNetWorthTrendTile extends StatelessWidget {
  const ReportsNetWorthTrendTile({
    super.key,
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

class ReportsCashFlowTile extends StatelessWidget {
  const ReportsCashFlowTile({
    super.key,
    required this.item,
    required this.currencyCode,
  });

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

class ReportsCategorySpendingTile extends StatelessWidget {
  const ReportsCategorySpendingTile({
    super.key,
    required this.item,
    required this.currencyCode,
  });

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
