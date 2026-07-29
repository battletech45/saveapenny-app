import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
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

    return Scaffold(
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'transactionsFab',
        onPressed: () => _showTransactionSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.transactionsAddCta),
      ),
      body: SafeArea(
        child: transactionsState.when(
          data: (data) {
            if (data.items.isEmpty) {
              return EmptyView(
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

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(transactionsControllerProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: data.items.length + (data.hasNext ? 1 : 0),
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  if (index == data.items.length) {
                    return OutlinedButton(
                      onPressed: () => ref
                          .read(transactionsControllerProvider.notifier)
                          .loadMore(),
                      child: Text(l10n.transactionsLoadMoreCta),
                    );
                  }

                  final transaction = data.items[index];
                  return TransactionTile(
                    transaction: transaction,
                    account: accountById[transaction.accountId],
                    category: categoryById[transaction.categoryId],
                    onEdit: transaction.type == TransactionType.transfer
                        ? null
                        : () => _showTransactionSheet(
                            context,
                            existing: transaction,
                          ),
                    onDelete: () => _confirmDelete(context, ref, transaction),
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
    );
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
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

    if (confirmed != true || !context.mounted) {
      return;
    }

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
