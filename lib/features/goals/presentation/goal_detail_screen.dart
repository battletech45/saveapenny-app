import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/goals/application/goal_detail_controller.dart';
import 'package:saveapenny/features/goals/application/goals_controller.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_detail.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';
import 'package:saveapenny/features/goals/domain/goal_scenario.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:saveapenny/features/goals/presentation/widgets/scenario_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(goalDetailControllerProvider(goalId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/goals'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.goalsDetailTitle),
      ),
      body: SafeArea(
        child: detailState.when(
          data: (data) {
            final goal = data.goal;
            return RefreshIndicator(
              onRefresh: () => ref
                  .read(goalDetailControllerProvider(goalId).notifier)
                  .refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(goal.title, style: context.textTheme.headline),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            goalTypeLabel(l10n, goal.type),
                            style: context.textTheme.label.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _DetailRow(
                            label: l10n.goalsStatusLabel,
                            value: goalStatusLabel(l10n, goal.status),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _DetailRow(
                            label: l10n.goalsCurrencyLabel,
                            value: goal.currency,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _DetailRow(
                            label: l10n.goalsTargetAmountLabel,
                            value: goal.targetAmount.toString(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _DetailRow(
                            label: l10n.goalsTargetDateLabel,
                            value: _formatDate(context, goal.targetDate),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _DetailRow(
                            label: l10n.goalsLinkedAccountLabel,
                            value:
                                goal.linkedAccountId ??
                                l10n.goalsNoLinkedAccount,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showEditGoalSheet(context, goal),
                          child: Text(l10n.goalsEditCta),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _showStatusSheet(context, ref, goal.status),
                          child: Text(l10n.goalsChangeStatusCta),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => _confirmDelete(context, ref),
                    child: Text(l10n.goalsDeleteCta),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.goalsInputsSectionTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _JsonCard(value: goal.inputs),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l10n.goalsScenariosSectionTitle,
                          style: context.textTheme.title,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _showScenarioSheet(context, goal.type),
                        child: Text(l10n.goalsScenarioAddCta),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (goal.scenarios.isEmpty)
                    _InlineEmptyState(
                      title: l10n.goalsScenariosEmptyTitle,
                      message: l10n.goalsScenariosEmptyMessage,
                    )
                  else
                    ...goal.scenarios.map(
                      (scenario) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ScenarioCard(scenario: scenario),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.goalsRunsSectionTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (goal.latestRun != null) ...<Widget>[
                    Text(
                      l10n.goalsLatestRunLabel,
                      style: context.textTheme.label.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _RunCard(run: goal.latestRun!),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (data.runs.isEmpty)
                    _InlineEmptyState(
                      title: l10n.goalsRunsEmptyTitle,
                      message: l10n.goalsRunsEmptyMessage,
                    )
                  else
                    ...data.runs.map(
                      (run) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _RunCard(run: run),
                      ),
                    ),
                  if (data.hasNext) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => ref
                          .read(goalDetailControllerProvider(goalId).notifier)
                          .loadMoreRuns(),
                      child: Text(l10n.goalsRunsLoadMoreCta),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref
                .read(goalDetailControllerProvider(goalId).notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditGoalSheet(BuildContext context, GoalDetail goal) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => GoalFormSheet(
        existing: Goal(
          id: goal.id,
          type: goal.type,
          title: goal.title,
          targetAmount: goal.targetAmount,
          currency: goal.currency,
          targetDate: goal.targetDate,
          linkedAccountId: goal.linkedAccountId,
          status: goal.status,
          inputs: goal.inputs,
          createdAt: goal.createdAt,
          updatedAt: goal.updatedAt,
        ),
        goalId: goalId,
      ),
    );
  }

  Future<void> _showScenarioSheet(BuildContext context, GoalType goalType) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          ScenarioFormSheet(goalId: goalId, goalType: goalType),
    );
  }

  Future<void> _showStatusSheet(
    BuildContext context,
    WidgetRef ref,
    GoalStatus currentStatus,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selectedStatus = await showModalBottomSheet<GoalStatus>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: GoalStatus.values
                  .map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(status),
                        child: Text(goalStatusLabel(l10n, status)),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );

    if (selectedStatus == null || selectedStatus == currentStatus) {
      return;
    }

    await ref
        .read(goalDetailControllerProvider(goalId).notifier)
        .updateStatus(selectedStatus);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.goalsDeleteTitle),
          content: Text(l10n.goalsDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.goalsDeleteCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(goalsControllerProvider.notifier).deleteGoal(goalId);
    if (!context.mounted) {
      return;
    }
    GoRouter.of(context).go('/goals');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.scenario});

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
            _JsonCard(value: scenario.inputs),
          ],
        ),
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({required this.run});

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
              _formatDateTime(context, run.createdAt),
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
              _JsonCard(value: run.outputSummary),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              l10n.goalsRunInputsLabel,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _JsonCard(value: run.inputsSnapshot),
          ],
        ),
      ),
    );
  }
}

class _JsonCard extends StatelessWidget {
  const _JsonCard({required this.value});

  final Object? value;

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
        child: SelectableText(
          _pretty(value),
          style: context.textTheme.label.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
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

String goalStatusLabel(AppLocalizations l10n, GoalStatus status) {
  return switch (status) {
    GoalStatus.draft => l10n.goalsStatusDraft,
    GoalStatus.active => l10n.goalsStatusActive,
    GoalStatus.achieved => l10n.goalsStatusAchieved,
    GoalStatus.abandoned => l10n.goalsStatusAbandoned,
  };
}

String goalFeasibilityLabel(AppLocalizations l10n, GoalFeasibility value) {
  return switch (value) {
    GoalFeasibility.onTrack => l10n.goalsFeasibilityOnTrack,
    GoalFeasibility.tight => l10n.goalsFeasibilityTight,
    GoalFeasibility.atRisk => l10n.goalsFeasibilityAtRisk,
    GoalFeasibility.infeasible => l10n.goalsFeasibilityInfeasible,
  };
}

String goalRunTriggerLabel(AppLocalizations l10n, GoalRunTrigger value) {
  return switch (value) {
    GoalRunTrigger.user => l10n.goalsRunTriggerUser,
    GoalRunTrigger.agent => l10n.goalsRunTriggerAgent,
    GoalRunTrigger.progressJob => l10n.goalsRunTriggerProgressJob,
    GoalRunTrigger.whatIf => l10n.goalsRunTriggerWhatIf,
  };
}

String _pretty(Object? value) {
  if (value == null) {
    return '';
  }

  if (value is! Map<String, dynamic> && value is! List<Object?>) {
    return value.toString();
  }

  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(value);
}

String _formatDate(BuildContext context, DateTime value) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String _formatDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final date = DateFormat.yMMMd(locale).format(value);
  final time = DateFormat.Hm(locale).format(value);
  return '$date $time';
}
