import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/presentation/widgets/billing_shared.dart';
import 'package:saveapenny/features/billing/presentation/widgets/plan_limit_banner.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/recurring_transactions/application/recurring_transactions_controller.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_cards.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_form_sheet.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_history_sheet.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recurringState = ref.watch(recurringTransactionsControllerProvider);
    final accounts =
        readRecurringAsyncData(ref.watch(accountsControllerProvider)) ??
        const <Account>[];
    final categories =
        readRecurringAsyncData(ref.watch(categoriesControllerProvider)) ??
        const <Category>[];
    final accountById = <String, Account>{
      for (final account in accounts) account.id: account,
    };
    final categoryById = <String, Category>{
      for (final category in categories) category.id: category,
    };
    final advancedRecurringUnlocked =
        ref
            .watch(entitlementControllerProvider)
            .asData
            ?.value
            .features
            .advancedRecurring ??
        false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTransactionsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recurringTransactionsFab',
        onPressed: () => _showFormSheet(
          context,
          advancedRecurringUnlocked: advancedRecurringUnlocked,
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.recurringTransactionsAddCta),
      ),
      body: SafeArea(
        child: recurringState.when(
          data: (data) {
            if (data.items.isEmpty) {
              return EmptyView(
                title: l10n.recurringTransactionsEmptyTitle,
                message: l10n.recurringTransactionsEmptyMessage,
                action: ElevatedButton(
                  onPressed: () => _showFormSheet(
                    context,
                    advancedRecurringUnlocked: advancedRecurringUnlocked,
                  ),
                  child: Text(l10n.recurringTransactionsAddFirstCta),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref
                  .read(recurringTransactionsControllerProvider.notifier)
                  .refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  PlanLockedFeatureBanner(
                    isUnlocked: advancedRecurringUnlocked,
                    message: l10n.recurringTransactionsAdvancedLockedMessage,
                  ),
                  if (advancedRecurringUnlocked &&
                      data.upcoming.isNotEmpty) ...[
                    Text(
                      l10n.recurringTransactionsUpcomingTitle,
                      style: context.textTheme.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...data.upcoming.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: UpcomingRunCard(item: item),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  Text(
                    l10n.recurringTransactionsListTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...data.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: RecurringTransactionCard(
                        item: item,
                        account: accountById[item.accountId],
                        category: categoryById[item.categoryId],
                        onEdit: item.status == RecurringStatus.expired
                            ? null
                            : () => _showFormSheet(
                                context,
                                existing: item,
                                advancedRecurringUnlocked:
                                    advancedRecurringUnlocked,
                              ),
                        onHistory: advancedRecurringUnlocked
                            ? () => _showHistorySheet(context, item.id)
                            : () => openUpgrade(context),
                        onPause: item.status == RecurringStatus.active
                            ? advancedRecurringUnlocked
                                  ? () => _runAction(
                                      context,
                                      ref,
                                      () => ref
                                          .read(
                                            recurringTransactionsControllerProvider
                                                .notifier,
                                          )
                                          .pause(item.id),
                                    )
                                  : () => openUpgrade(context)
                            : null,
                        onResume: item.status == RecurringStatus.paused
                            ? advancedRecurringUnlocked
                                  ? () => _runAction(
                                      context,
                                      ref,
                                      () => ref
                                          .read(
                                            recurringTransactionsControllerProvider
                                                .notifier,
                                          )
                                          .resume(item.id),
                                    )
                                  : () => openUpgrade(context)
                            : null,
                        onDelete: item.status == RecurringStatus.expired
                            ? null
                            : () => _confirmDelete(context, ref, item),
                      ),
                    ),
                  ),
                  if (data.hasNext)
                    OutlinedButton(
                      onPressed: () => ref
                          .read(
                            recurringTransactionsControllerProvider.notifier,
                          )
                          .loadMore(),
                      child: Text(l10n.recurringTransactionsLoadMoreCta),
                    ),
                ],
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref
                .read(recurringTransactionsControllerProvider.notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showFormSheet(
    BuildContext context, {
    RecurringTransaction? existing,
    required bool advancedRecurringUnlocked,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => RecurringTransactionFormSheet(
        existing: existing,
        advancedRecurringUnlocked: advancedRecurringUnlocked,
      ),
    );
  }

  Future<void> _showHistorySheet(
    BuildContext context,
    String recurringTransactionId,
  ) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => RecurringTransactionHistorySheet(
        recurringTransactionId: recurringTransactionId,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recurringTransactionsDeleteTitle),
        content: Text(l10n.recurringTransactionsDeleteMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.recurringTransactionsDeleteCta),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      ref,
      () => ref
          .read(recurringTransactionsControllerProvider.notifier)
          .deleteRecurringTransaction(item.id),
    );
  }

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(recurringFailureMessage(context, failure))),
      );
    }
  }
}
