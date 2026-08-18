import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/charts.dart';
import 'package:saveapenny/core/ui/stat_pill.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/categories/domain/category_glyph.dart';
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
    this.delta,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final Widget? delta;
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: context.textTheme.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (delta != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    delta!,
                  ],
                ],
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

class ReportsNetWorthDeltaBadge extends StatelessWidget {
  const ReportsNetWorthDeltaBadge({super.key, required this.trend});

  final List<NetWorthSnapshot> trend;

  @override
  Widget build(BuildContext context) {
    if (trend.length < 2) {
      return const SizedBox.shrink();
    }

    final previous = trend[trend.length - 2].netWorth;
    final current = trend.last.netWorth;
    if (previous == 0) {
      return const SizedBox.shrink();
    }

    final percent = (current - previous) / previous.abs() * 100;
    final l10n = AppLocalizations.of(context);
    final percentLabel = percent.abs().toStringAsFixed(1);
    final label = percent >= 0
        ? l10n.reportsNetWorthChangeUp(percentLabel)
        : l10n.reportsNetWorthChangeDown(percentLabel);
    final tone = percent >= 0 ? StatPillTone.income : StatPillTone.expense;
    final (Color fg, Color bg) = tone == StatPillTone.income
        ? (context.finance.income, context.finance.incomeSurface)
        : (context.finance.expense, context.finance.expenseSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              percent >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              size: 14,
              color: fg,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: context.textTheme.label.copyWith(color: fg)),
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
            LineTrendChart(
              points: _netWorthPoints(state.netWorthTrend),
              color: Theme.of(context).colorScheme.primary,
              leftLabel: _compactNumber,
              bottomLabel: (value) =>
                  _monthLabel(context, state.netWorthTrend, value),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportsCashFlowChartCard extends StatelessWidget {
  const ReportsCashFlowChartCard({
    super.key,
    required this.items,
    required this.currencyCode,
  });

  final List<CashFlowPoint> items;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sorted = [...items]..sort((a, b) => a.date.compareTo(b.date));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.reportsCashFlowTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.lg),
            MultiLineTrendChart(
              series: <TrendSeries>[
                TrendSeries(
                  points: _cashFlowPoints(sorted, (item) => item.incomeAmount),
                  color: context.finance.income,
                ),
                TrendSeries(
                  points: _cashFlowPoints(sorted, (item) => item.expenseAmount),
                  color: context.finance.expense,
                ),
                TrendSeries(
                  points: _cashFlowPoints(sorted, (item) => item.netAmount),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
              leftLabel: _compactNumber,
              bottomLabel: (value) => _dayLabel(context, sorted, value),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                _LegendItem(
                  label: l10n.reportsIncomeLabel,
                  color: context.finance.income,
                ),
                _LegendItem(
                  label: l10n.reportsExpenseLabel,
                  color: context.finance.expense,
                ),
                _LegendItem(
                  label: l10n.reportsNetSavingsLabel,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReportsCategorySpendingCard extends StatelessWidget {
  const ReportsCategorySpendingCard({
    super.key,
    required this.items,
    required this.categories,
    required this.currencyCode,
  });

  final List<CategorySpending> items;
  final List<Category> categories;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryById = {
      for (final category in categories) category.id: category,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.reportsCategorySpendingTitle,
              style: context.textTheme.title,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: CategoryDonutChart(
                slices: <DonutSlice>[
                  for (final item in items)
                    DonutSlice(
                      label: item.categoryName,
                      value: item.totalAmount.abs().toDouble(),
                      color: _categoryColor(categoryById[item.categoryId]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ReportsCategorySpendingTile(
                  item: item,
                  category: categoryById[item.categoryId],
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
            Expanded(
              child: Text(
                label,
                style: context.textTheme.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  amount.text,
                  style: context.textTheme.money.copyWith(color: amount.color),
                ),
              ),
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
                  Text(
                    dateLabel,
                    style: context.textTheme.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${l10n.reportsIncomeLabel}: ${income.text} · ${l10n.reportsExpenseLabel}: ${expense.text}',
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  net.text,
                  textAlign: TextAlign.right,
                  style: context.textTheme.money.copyWith(color: net.color),
                ),
              ),
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
    this.category,
    required this.currencyCode,
  });

  final CategorySpending item;
  final Category? category;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final amount = MoneyFormatter.format(
      context: context,
      amount: -item.totalAmount,
      currencyCode: currencyCode,
    );
    final color = _categoryColor(category) ?? context.chart.forIndex(0);

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
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  parseCategoryIcon(category?.icon),
                  color: color,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.categoryName,
                    style: context.textTheme.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  amount.text,
                  textAlign: TextAlign.right,
                  style: context.textTheme.money.copyWith(color: amount.color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: AppSpacing.sm,
          height: AppSpacing.sm,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: context.textTheme.label.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

List<TrendPoint> _netWorthPoints(List<NetWorthSnapshot> items) {
  return <TrendPoint>[
    for (var i = 0; i < items.length; i++)
      TrendPoint(i.toDouble(), items[i].netWorth.toDouble()),
  ];
}

List<TrendPoint> _cashFlowPoints(
  List<CashFlowPoint> items,
  num Function(CashFlowPoint item) valueOf,
) {
  return <TrendPoint>[
    for (var i = 0; i < items.length; i++)
      TrendPoint(i.toDouble(), valueOf(items[i]).toDouble()),
  ];
}

String _compactNumber(double value) {
  return NumberFormat.compact().format(value);
}

String _monthLabel(
  BuildContext context,
  List<NetWorthSnapshot> items,
  double value,
) {
  final index = value.round();
  if (index < 0 || index >= items.length || value != index) {
    return '';
  }
  return DateFormat.MMM(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(items[index].snapshotDate);
}

String _dayLabel(
  BuildContext context,
  List<CashFlowPoint> items,
  double value,
) {
  final index = value.round();
  if (index < 0 || index >= items.length || value != index) {
    return '';
  }
  return DateFormat.d(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(items[index].date);
}

Color? _categoryColor(Category? category) {
  final color = category?.color;
  if (color == null || color.isEmpty) {
    return null;
  }
  try {
    return parseCategoryColor(color);
  } on FormatException {
    return null;
  }
}
