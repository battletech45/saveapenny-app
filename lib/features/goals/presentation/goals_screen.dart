import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/core/ui/scroll_aware_fab.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/presentation/widgets/plan_limit_banner.dart';
import 'package:saveapenny/features/goals/application/goals_controller.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_card.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goalsState = ref.watch(goalsControllerProvider);
    final limits = ref.watch(entitlementControllerProvider).value?.limits;

    return ScrollAwareFabVisibility(
      builder: (context, fabVisible) => Scaffold(
        appBar: AppBar(title: Text(l10n.goalsTitle)),
        floatingActionButton: ScrollAwareFab(
          visible: fabVisible,
          child: FloatingActionButton.extended(
            heroTag: 'goalsFab',
            onPressed: () => _showGoalSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.goalsAddCta),
          ),
        ),
        body: SafeArea(
          child: goalsState.when(
            data: (data) {
              if (data.items.isEmpty) {
                return EmptyView(
                  icon: Icons.flag_outlined,
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
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: <Widget>[
                    PlanLimitBanner(
                      used: limits?.activeGoals ?? 0,
                      max: limits?.maxActiveGoals,
                      message: l10n.goalsLimitReachedMessage,
                    ),
                    for (final goal in data.items) ...<Widget>[
                      GoalCard(goal: goal),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (data.hasNext)
                      OutlinedButton(
                        onPressed: () => ref
                            .read(goalsControllerProvider.notifier)
                            .loadMore(),
                        child: Text(l10n.goalsLoadMoreCta),
                      ),
                  ],
                ),
              );
            },
            loading: () => const LoadingView(),
            error: (error, _) => FailureView(
              failure: error as Failure,
              onRetry: () =>
                  ref.read(goalsControllerProvider.notifier).refresh(),
            ),
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
