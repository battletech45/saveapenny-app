import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
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
import 'package:saveapenny/features/transactions/presentation/widgets/transfer_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsState = ref.watch(transactionsControllerProvider);
    final accounts =
        _readAsyncData(ref.watch(accountsControllerProvider)) ??
        const <Account>[];
    final categories =
        _readAsyncData(ref.watch(categoriesControllerProvider)) ??
        const <Category>[];
    final accountById = <String, Account>{
      for (final account in accounts) account.id: account,
    };
    final categoryById = <String, Category>{
      for (final category in categories) category.id: category,
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
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
                  return _TransactionTile(
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
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TransactionFormSheet(existing: existing),
    );
  }

  Future<void> _showTransferSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
        SnackBar(content: Text(_failureMessage(context, failure))),
      );
    }
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.account,
    required this.category,
    required this.onDelete,
    this.onEdit,
  });

  final Transaction transaction;
  final Account? account;
  final Category? category;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = MoneyFormatter.format(
      context: context,
      amount: _signedAmount(transaction),
      currencyCode: transaction.currency,
    );
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(transaction.transactionDate);
    final title = switch (transaction.type) {
      TransactionType.transfer => l10n.transactionsTypeTransfer,
      _ => category?.name ?? _transactionTypeLabel(l10n, transaction.type),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            _TransactionIcon(type: transaction.type, category: category),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: context.textTheme.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _subtitle(
                      l10n: l10n,
                      accountName: account?.name,
                      dateLabel: dateLabel,
                      description: transaction.description,
                    ),
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  amount.text,
                  textAlign: TextAlign.right,
                  style: context.textTheme.money.copyWith(color: amount.color),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                      return;
                    }
                    onDelete();
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    if (onEdit != null)
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(l10n.transactionsEditCta),
                      ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(l10n.transactionsDeleteCta),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  num _signedAmount(Transaction transaction) {
    return switch (transaction.type) {
      TransactionType.income => transaction.amount,
      TransactionType.expense ||
      TransactionType.transfer => -transaction.amount,
    };
  }

  String _subtitle({
    required AppLocalizations l10n,
    required String? accountName,
    required String dateLabel,
    required String? description,
  }) {
    final values = <String>[
      if (accountName != null && accountName.isNotEmpty) accountName,
      dateLabel,
      if (description != null && description.isNotEmpty) description,
    ];
    return values.join(' · ');
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({required this.type, required this.category});

  final TransactionType type;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      TransactionType.income => Icons.trending_up_rounded,
      TransactionType.expense => Icons.trending_down_rounded,
      TransactionType.transfer => Icons.swap_horiz_rounded,
    };
    final color = switch (type) {
      TransactionType.income => context.finance.income,
      TransactionType.expense => context.finance.expense,
      TransactionType.transfer => Theme.of(context).colorScheme.primary,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: SizedBox(
        width: AppSpacing.huge,
        height: AppSpacing.huge,
        child: Center(child: Icon(icon, color: color)),
      ),
    );
  }
}

String _transactionTypeLabel(AppLocalizations l10n, TransactionType type) {
  return switch (type) {
    TransactionType.income => l10n.transactionsTypeIncome,
    TransactionType.expense => l10n.transactionsTypeExpense,
    TransactionType.transfer => l10n.transactionsTypeTransfer,
  };
}

String _failureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      ApiErrorCode.insufficientBalance =>
        l10n.transactionsInsufficientBalanceError,
      ApiErrorCode.invalidTransfer => l10n.transactionsInvalidTransferError,
      ApiErrorCode.invalidTransactionCurrency =>
        l10n.transactionsCurrencyMismatchError,
      ApiErrorCode.transactionNotFound => l10n.failureResourceNotFoundMessage,
      _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
      _ => l10n.failureValidationFailedMessage,
    },
  };
}

T? _readAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
