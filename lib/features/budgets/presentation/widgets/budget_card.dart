import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/progress_meter.dart';
import 'package:saveapenny/core/ui/stat_pill.dart';
import 'package:saveapenny/core/ui/swipe_action_row.dart';
import 'package:saveapenny/features/budgets/application/budgets_controller.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_shared.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/categories/domain/category_glyph.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.item,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    this.confirmDelete,
  });

  final BudgetListItem item;
  final Category? category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<bool> Function()? confirmDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = budgetStatusColor(context, item.status.status);
    final dateRange = formatBudgetRange(context, item.budget);
    final categoryColor = category?.color != null
        ? parseCategoryColor(category!.color!)
        : context.colors.surfaceSubtle;

    return SwipeActionRow(
      itemKey: ValueKey(item.budget.id),
      onEdit: onEdit,
      onDelete: onDelete,
      confirmDelete: confirmDelete,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: SizedBox(
                      width: AppSpacing.huge,
                      height: AppSpacing.huge,
                      child: Center(
                        child: Icon(
                          parseCategoryIcon(category?.icon),
                          size: 20,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
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
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${item.status.usagePercentage.toStringAsFixed(0)}%',
                    style: context.textTheme.title.copyWith(color: statusColor),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    budgetStatusLabel(l10n, item.status.status),
                    style: context.textTheme.label.copyWith(color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ProgressMeter(
                value: item.status.usagePercentage / 100,
                color: statusColor,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatPill(
                      label: l10n.budgetsBudgetAmountLabel,
                      value: formatBudgetAmount(
                        context,
                        item.status.budgetAmount,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatPill(
                      label: l10n.budgetsSpentAmountLabel,
                      value: formatBudgetAmount(
                        context,
                        item.status.spentAmount,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatPill(
                      label: l10n.budgetsRemainingAmountLabel,
                      value: formatBudgetAmount(
                        context,
                        item.status.remainingAmount,
                      ),
                      tone: item.status.remainingAmount < 0
                          ? StatPillTone.expense
                          : StatPillTone.neutral,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
