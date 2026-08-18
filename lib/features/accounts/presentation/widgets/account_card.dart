import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/progress_meter.dart';
import 'package:saveapenny/core/ui/stat_pill.dart';
import 'package:saveapenny/core/ui/swipe_action_row.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/presentation/widgets/account_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.confirmDelete,
  });

  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final Future<bool> Function()? confirmDelete;

  bool get _isCredit => account.type == AccountType.credit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final creditCard = account.creditCard;
    final balance = MoneyFormatter.format(
      context: context,
      amount: account.balance,
      currencyCode: account.currency,
      isDebt: _isCredit,
    );
    final typeColor = accountTypeColor(context, account.type);

    return SwipeActionRow(
      itemKey: ValueKey(account.id),
      onEdit: onEdit,
      onDelete: onDelete,
      confirmDelete: confirmDelete,
      child: Card(
        child: InkWell(
          onTap: _isCredit ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: SizedBox(
                        width: AppSpacing.huge,
                        height: AppSpacing.huge,
                        child: Center(
                          child: Icon(
                            accountTypeIcon(account.type),
                            color: typeColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(account.name, style: context.textTheme.title),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            accountTypeLabel(l10n, account.type),
                            style: context.textTheme.label.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.accountsBalanceLabel,
                  style: context.textTheme.label.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    balance.text,
                    textAlign: TextAlign.right,
                    style: context.textTheme.displayMoney.copyWith(
                      color: balance.color,
                    ),
                  ),
                ),
                if (_isCredit && creditCard != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  _CreditUtilization(
                    creditCard: creditCard,
                    currencyCode: account.currency,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatPill(
                        label: l10n.accountsCurrencyLabel,
                        value: account.currency,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatPill(
                        label: l10n.accountsStatusLabel,
                        value: account.active
                            ? l10n.accountsStatusActive
                            : l10n.accountsStatusArchived,
                        tone: account.active
                            ? StatPillTone.income
                            : StatPillTone.neutral,
                      ),
                    ),
                  ],
                ),
                if (_isCredit && creditCard != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: StatPill(
                          label: l10n.accountsAvailableCreditLabel,
                          value: MoneyFormatter.format(
                            context: context,
                            amount: creditCard.availableCredit,
                            currencyCode: account.currency,
                          ).text,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatPill(
                          label: l10n.accountsPaymentDueLabel,
                          value: creditCard.paymentDueDate == null
                              ? l10n.accountsPaymentDueNoneValue
                              : DateFormat.yMMMd(
                                  Localizations.localeOf(
                                    context,
                                  ).toLanguageTag(),
                                ).format(creditCard.paymentDueDate!),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreditUtilization extends StatelessWidget {
  const _CreditUtilization({
    required this.creditCard,
    required this.currencyCode,
  });

  final CreditCardSummary creditCard;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final used = creditCard.creditLimit - creditCard.availableCredit;
    final ratio = creditCard.creditLimit > 0
        ? (used / creditCard.creditLimit).clamp(0.0, 1.0)
        : 0.0;
    final color = ratio >= 0.9
        ? context.finance.expense
        : ratio >= 0.7
        ? context.finance.warning
        : Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              l10n.accountsCreditUtilizationLabel,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}%',
              style: context.textTheme.label.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ProgressMeter(value: ratio, color: color),
      ],
    );
  }
}
