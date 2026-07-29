import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = formatGoalDate(context, goal.targetDate);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => GoRouter.of(context).go('/goals/${goal.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(goal.title, style: context.textTheme.title),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    goalStatusLabel(l10n, goal.status),
                    style: context.textTheme.label.copyWith(
                      color: goalStatusColor(context, goal.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                goalTypeLabel(l10n, goal.type),
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GoalMetricPill(
                      label: l10n.goalsTargetAmountLabel,
                      value: '${goal.targetAmount} ${goal.currency}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GoalMetricPill(
                      label: l10n.goalsTargetDateLabel,
                      value: dateLabel,
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

class GoalMetricPill extends StatelessWidget {
  const GoalMetricPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

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
            Text(value, style: context.textTheme.body),
          ],
        ),
      ),
    );
  }
}
