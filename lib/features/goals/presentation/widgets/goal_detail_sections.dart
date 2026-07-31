import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';
import 'package:saveapenny/features/goals/domain/goal_scenario.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class GoalDetailRow extends StatelessWidget {
  const GoalDetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class GoalScenarioCard extends StatelessWidget {
  const GoalScenarioCard({super.key, required this.scenario});

  final GoalScenario scenario;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(scenario.name, style: context.textTheme.body),
                ),
                if (scenario.isBaseline)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      l10n.goalsScenarioBaselineBadge,
                      style: context.textTheme.label,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GoalJsonCard(value: scenario.inputs),
          ],
        ),
      ),
    );
  }
}

class GoalRunCard extends StatelessWidget {
  const GoalRunCard({super.key, required this.run});

  final GoalRun run;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    goalFeasibilityLabel(l10n, run.feasibility),
                    style: context.textTheme.body,
                  ),
                ),
                Text(
                  goalRunTriggerLabel(l10n, run.triggeredBy),
                  style: context.textTheme.label.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              formatGoalDateTime(context, run.createdAt),
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (run.outputSummary != null) ...<Widget>[
              Text(
                l10n.goalsRunSummaryLabel,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              GoalJsonCard(value: run.outputSummary),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              l10n.goalsRunInputsLabel,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            GoalJsonCard(value: run.inputsSnapshot),
          ],
        ),
      ),
    );
  }
}

class GoalJsonCard extends StatelessWidget {
  const GoalJsonCard({super.key, required this.value});

  final Object? value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SelectableText(
            prettyGoalJson(value),
            style: context.textTheme.label.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class GoalInlineEmptyState extends StatelessWidget {
  const GoalInlineEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

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
