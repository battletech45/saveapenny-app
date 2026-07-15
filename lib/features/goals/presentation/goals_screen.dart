import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/goals/application/goals_controller.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goalsState = ref.watch(goalsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.goalsAddCta),
      ),
      body: SafeArea(
        child: goalsState.when(
          data: (data) {
            if (data.items.isEmpty) {
              return EmptyView(
                title: l10n.goalsEmptyTitle,
                message: l10n.goalsEmptyMessage,
                action: ElevatedButton(
                  onPressed: () => _showGoalSheet(context),
                  child: Text(l10n.goalsAddFirstCta),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(goalsControllerProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: data.items.length + (data.hasNext ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  if (index == data.items.length) {
                    return OutlinedButton(
                      onPressed: () =>
                          ref.read(goalsControllerProvider.notifier).loadMore(),
                      child: Text(l10n.goalsLoadMoreCta),
                    );
                  }

                  final goal = data.items[index];
                  return _GoalCard(goal: goal);
                },
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref.read(goalsControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showGoalSheet(BuildContext context) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => const GoalFormSheet(),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(goal.targetDate);

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
                    _goalStatusLabel(l10n, goal.status),
                    style: context.textTheme.label.copyWith(
                      color: _statusColor(context, goal.status),
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
                    child: _GoalMetricPill(
                      label: l10n.goalsTargetAmountLabel,
                      value: '${goal.targetAmount} ${goal.currency}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _GoalMetricPill(
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

  Color _statusColor(BuildContext context, GoalStatus status) {
    return switch (status) {
      GoalStatus.draft => context.colors.textSecondary,
      GoalStatus.active => Theme.of(context).colorScheme.primary,
      GoalStatus.achieved => context.finance.income,
      GoalStatus.abandoned => context.finance.expense,
    };
  }
}

class _GoalMetricPill extends StatelessWidget {
  const _GoalMetricPill({required this.label, required this.value});

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

String _goalStatusLabel(AppLocalizations l10n, GoalStatus status) {
  return switch (status) {
    GoalStatus.draft => l10n.goalsStatusDraft,
    GoalStatus.active => l10n.goalsStatusActive,
    GoalStatus.achieved => l10n.goalsStatusAchieved,
    GoalStatus.abandoned => l10n.goalsStatusAbandoned,
  };
}
