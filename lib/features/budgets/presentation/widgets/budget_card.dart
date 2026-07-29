import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/budgets/application/budgets_controller.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
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
    final statusColor = budgetStatusColor(context, item.status.status);
    final dateRange = formatBudgetRange(context, item.budget);

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
                        '${budgetPeriodLabel(l10n, item.budget.period)} · $dateRange',
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
                  child: BudgetMetricPill(
                    label: l10n.budgetsBudgetAmountLabel,
                    value: formatBudgetAmount(
                      context,
                      item.status.budgetAmount,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BudgetMetricPill(
                    label: l10n.budgetsSpentAmountLabel,
                    value: formatBudgetAmount(context, item.status.spentAmount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: BudgetMetricPill(
                    label: l10n.budgetsRemainingAmountLabel,
                    value: formatBudgetAmount(
                      context,
                      item.status.remainingAmount,
                    ),
                    valueColor: statusColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BudgetStatusPill(
                    label: l10n.budgetsStatusLabel,
                    value: budgetStatusLabel(l10n, item.status.status),
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
}

class BudgetMetricPill extends StatelessWidget {
  const BudgetMetricPill({
    super.key,
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

class BudgetStatusPill extends StatelessWidget {
  const BudgetStatusPill({
    super.key,
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
