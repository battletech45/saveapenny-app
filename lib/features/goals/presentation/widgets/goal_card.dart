import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/stat_pill.dart';
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
    final statusColor = goalStatusColor(context, goal.status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => unawaited(GoRouter.of(context).push('/goals/${goal.id}')),
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
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: SizedBox(
                      width: AppSpacing.huge,
                      height: AppSpacing.huge,
                      child: Center(
                        child: Icon(
                          goalTypeIcon(goal.type),
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(goal.title, style: context.textTheme.title),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          goalTypeLabel(l10n, goal.type),
                          style: context.textTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    goalStatusLabel(l10n, goal.status),
                    style: context.textTheme.label.copyWith(color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatPill(
                      label: l10n.goalsTargetAmountLabel,
                      value: '${goal.targetAmount} ${goal.currency}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatPill(
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
