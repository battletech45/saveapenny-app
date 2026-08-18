import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/swipe_action_row.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/categories/domain/category_glyph.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transaction_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.account,
    required this.category,
    required this.onDelete,
    this.onEdit,
    this.confirmDelete,
  });

  final Transaction transaction;
  final Account? account;
  final Category? category;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;
  final Future<bool> Function()? confirmDelete;

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
      _ => category?.name ?? transactionTypeLabel(l10n, transaction.type),
    };

    return SwipeActionRow(
      itemKey: ValueKey(transaction.id),
      onEdit: onEdit,
      onDelete: onDelete,
      confirmDelete: confirmDelete,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              TransactionIcon(type: transaction.type, category: category),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: context.textTheme.body),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _subtitle(
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
              Text(
                amount.text,
                textAlign: TextAlign.right,
                style: context.textTheme.money.copyWith(color: amount.color),
              ),
            ],
          ),
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

class TransactionIcon extends StatelessWidget {
  const TransactionIcon({super.key, required this.type, this.category});

  final TransactionType type;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final hasCategoryGlyph =
        type != TransactionType.transfer && category != null;
    final icon = hasCategoryGlyph
        ? parseCategoryIcon(category!.icon)
        : switch (type) {
            TransactionType.income => Icons.trending_up_rounded,
            TransactionType.expense => Icons.trending_down_rounded,
            TransactionType.transfer => Icons.swap_horiz_rounded,
          };
    final color = hasCategoryGlyph && category!.color != null
        ? parseCategoryColor(category!.color!)
        : switch (type) {
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
