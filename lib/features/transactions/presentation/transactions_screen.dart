import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/core/ui/scroll_aware_fab.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/transactions/application/transactions_controller.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transaction_shared.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transfer_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsState = ref.watch(transactionsControllerProvider);
    final accounts =
        readTransactionsAsyncData(ref.watch(accountsControllerProvider)) ??
        const <Account>[];
    final categories =
        readTransactionsAsyncData(ref.watch(categoriesControllerProvider)) ??
        const <Category>[];
    final accountById = <String, Account>{
      for (final account in accounts) account.id: account,
    };
    final categoryById = <String, Category>{
      for (final category in categories) category.id: category,
    };

    return ScrollAwareFabVisibility(
      builder: (context, fabVisible) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.transactionsTitle),
          actions: <Widget>[
            IconButton(
              onPressed: () => _showTransferSheet(context),
              tooltip: l10n.transactionsTransferCta,
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
          ],
        ),
        floatingActionButton: ScrollAwareFab(
          visible: fabVisible,
          child: FloatingActionButton.extended(
            heroTag: 'transactionsFab',
            onPressed: () => _showTransactionSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.transactionsAddCta),
          ),
        ),
        body: SafeArea(
          child: transactionsState.when(
            data: (data) {
              if (data.items.isEmpty) {
                return EmptyView(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.transactionsEmptyTitle,
                  message: l10n.transactionsEmptyMessage,
                  action: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => _showTransactionSheet(context),
                        child: Text(l10n.transactionsAddFirstCta),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => _showTransferSheet(context),
                        child: Text(l10n.transactionsTransferCta),
                      ),
                    ],
                  ),
                );
              }

              final rows = _groupByDate(context, data.items);

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(transactionsControllerProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: rows.length + (data.hasNext ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == rows.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: OutlinedButton(
                          onPressed: () => ref
                              .read(transactionsControllerProvider.notifier)
                              .loadMore(),
                          child: Text(l10n.transactionsLoadMoreCta),
                        ),
                      );
                    }

                    final row = rows[index];
                    if (row is String) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : AppSpacing.lg,
                          bottom: AppSpacing.sm,
                        ),
                        child: Text(
                          row,
                          style: context.textTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      );
                    }

                    final transaction = row as Transaction;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: TransactionTile(
                        transaction: transaction,
                        account: accountById[transaction.accountId],
                        category: categoryById[transaction.categoryId],
                        onEdit: transaction.type == TransactionType.transfer
                            ? null
                            : () => _showTransactionSheet(
                                context,
                                existing: transaction,
                              ),
                        confirmDelete: () => _confirmDeleteDialog(context),
                        onDelete: () =>
                            _deleteTransaction(context, ref, transaction),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const LoadingView(),
            error: (error, _) => FailureView(
              failure: error as Failure,
              onRetry: () =>
                  ref.read(transactionsControllerProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }

  /// Interleaves date-section labels (Today / Yesterday / formatted date)
  /// ahead of each run of same-day transactions. Assumes [items] is already
  /// sorted newest-first, as the backend returns it.
  List<Object> _groupByDate(BuildContext context, List<Transaction> items) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    final rows = <Object>[];
    DateTime? lastDay;
    for (final transaction in items) {
      final day = DateUtils.dateOnly(transaction.transactionDate);
      if (day != lastDay) {
        rows.add(switch (day) {
          _ when day == today => l10n.transactionsDateToday,
          _ when day == yesterday => l10n.transactionsDateYesterday,
          _ => dateFormat.format(day),
        });
        lastDay = day;
      }
      rows.add(transaction);
    }
    return rows;
  }

  Future<void> _showTransactionSheet(
    BuildContext context, {
    Transaction? existing,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => TransactionFormSheet(existing: existing),
    );
  }

  Future<void> _showTransferSheet(BuildContext context) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => const TransferFormSheet(),
    );
  }

  /// Shown by [SwipeActionRow.confirmDelete] *before* the swipe commits, so a
  /// cancelled swipe animates back instead of leaving a dismissed
  /// [Dismissible] still mounted in the tree.
  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.transactionsDeleteTitle),
          content: Text(l10n.transactionsDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.transactionsDeleteCta),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    try {
      await ref
          .read(transactionsControllerProvider.notifier)
          .deleteTransaction(transaction.id);
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(transactionFailureMessage(context, failure))),
      );
    }
  }
}
