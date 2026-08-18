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
import 'package:saveapenny/features/budgets/application/budgets_controller.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_card.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_form_sheet.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final budgetsState = ref.watch(budgetsControllerProvider);
    final limits = ref.watch(entitlementControllerProvider).value?.limits;

    return ScrollAwareFabVisibility(
      builder: (context, fabVisible) => Scaffold(
        appBar: AppBar(title: Text(l10n.budgetsTitle)),
        floatingActionButton: ScrollAwareFab(
          visible: fabVisible,
          child: FloatingActionButton.extended(
            heroTag: 'budgetsFab',
            onPressed: () => _showBudgetSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.budgetsAddCta),
          ),
        ),
        body: SafeArea(
          child: budgetsState.when(
            data: (data) {
              if (data.items.isEmpty) {
                return EmptyView(
                  title: l10n.budgetsEmptyTitle,
                  message: l10n.budgetsEmptyMessage,
                  action: ElevatedButton(
                    onPressed: () => _showBudgetSheet(context),
                    child: Text(l10n.budgetsAddFirstCta),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(budgetsControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: <Widget>[
                    PlanLimitBanner(
                      used: limits?.activeBudgets ?? 0,
                      max: limits?.maxActiveBudgets,
                      message: l10n.budgetsLimitReachedMessage,
                    ),
                    for (final item in data.items) ...<Widget>[
                      BudgetCard(
                        item: item,
                        onEdit: () =>
                            _showBudgetSheet(context, existing: item.budget),
                        onDelete: () =>
                            _confirmDelete(context, ref, item.budget),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (data.hasNext)
                      OutlinedButton(
                        onPressed: () => ref
                            .read(budgetsControllerProvider.notifier)
                            .loadMore(),
                        child: Text(l10n.budgetsLoadMoreCta),
                      ),
                  ],
                ),
              );
            },
            loading: () => const LoadingView(),
            error: (error, _) => FailureView(
              failure: error as Failure,
              onRetry: () =>
                  ref.read(budgetsControllerProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showBudgetSheet(BuildContext context, {Budget? existing}) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => BudgetFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.budgetsDeleteTitle),
          content: Text(l10n.budgetsDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.budgetsDeleteCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(budgetsControllerProvider.notifier)
          .deleteBudget(budget.id);
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(budgetFailureMessage(context, failure))),
      );
    }
  }
}
