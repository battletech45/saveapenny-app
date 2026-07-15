import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';

class AttentionStrip extends StatelessWidget {
  const AttentionStrip({super.key, required this.budgets});

  /// Pre-filtered by [DashboardController] to warning/exceeded only.
  final List<BudgetStatus> budgets;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: budgets.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final exceeded = budget.status == BudgetHealth.exceeded;
          final background = exceeded
              ? context.finance.expenseSurface
              : context.finance.warningSurface;
          final foreground = exceeded
              ? context.finance.expense
              : context.finance.warning;

          return ActionChip(
            backgroundColor: background,
            side: BorderSide.none,
            avatar: Icon(
              exceeded ? Icons.error_rounded : Icons.warning_rounded,
              size: 16,
              color: foreground,
            ),
            label: Text(
              '${budget.category} ${budget.usagePercentage.round()}%',
              style: context.textTheme.label.copyWith(color: foreground),
            ),
            onPressed: () => GoRouter.of(context).go('/budgets'),
          );
        },
      ),
    );
  }
}
