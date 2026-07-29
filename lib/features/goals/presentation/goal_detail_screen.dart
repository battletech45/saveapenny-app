import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/goals/application/goal_detail_controller.dart';
import 'package:saveapenny/features/goals/application/goals_controller.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_detail.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_detail_sections.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_shared.dart';
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
          onPressed: () => GoRouter.of(context).pop(),
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
                          GoalDetailRow(
                            label: l10n.goalsStatusLabel,
                            value: goalStatusLabel(l10n, goal.status),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GoalDetailRow(
                            label: l10n.goalsCurrencyLabel,
                            value: goal.currency,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GoalDetailRow(
                            label: l10n.goalsTargetAmountLabel,
                            value: goal.targetAmount.toString(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GoalDetailRow(
                            label: l10n.goalsTargetDateLabel,
                            value: formatGoalDate(context, goal.targetDate),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GoalDetailRow(
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
                  GoalJsonCard(value: goal.inputs),
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
                    GoalInlineEmptyState(
                      title: l10n.goalsScenariosEmptyTitle,
                      message: l10n.goalsScenariosEmptyMessage,
                    )
                  else
                    ...goal.scenarios.map(
                      (scenario) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: GoalScenarioCard(scenario: scenario),
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
                    GoalRunCard(run: goal.latestRun!),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (data.runs.isEmpty)
                    GoalInlineEmptyState(
                      title: l10n.goalsRunsEmptyTitle,
                      message: l10n.goalsRunsEmptyMessage,
                    )
                  else
                    ...data.runs.map(
                      (run) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: GoalRunCard(run: run),
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
    return showAppModalBottomSheet<void>(
      context: context,
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
    return showAppModalBottomSheet<void>(
      context: context,
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
    final selectedStatus = await showAppModalBottomSheet<GoalStatus>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: GoalStatus.values
                  .where((status) => status != currentStatus)
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

    try {
      await ref
          .read(goalDetailControllerProvider(goalId).notifier)
          .updateStatus(selectedStatus);
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(goalFailureMessage(context, failure))),
        );
    }
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
    GoRouter.of(context).pop();
  }
}
