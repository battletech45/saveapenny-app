import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
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
  });

  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

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

    return Card(
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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                        return;
                      }
                      onDelete();
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(l10n.accountsEditCta),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(l10n.accountsDeleteCta),
                      ),
                    ],
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
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AccountInfoPill(
                      label: l10n.accountsCurrencyLabel,
                      value: account.currency,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AccountInfoPill(
                      label: l10n.accountsStatusLabel,
                      value: account.active
                          ? l10n.accountsStatusActive
                          : l10n.accountsStatusArchived,
                    ),
                  ),
                ],
              ),
              if (_isCredit && creditCard != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AccountInfoPill(
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
                      child: AccountInfoPill(
                        label: l10n.accountsPaymentDueLabel,
                        value: creditCard.paymentDueDate == null
                            ? l10n.accountsPaymentDueNoneValue
                            : DateFormat.yMMMd(
                                Localizations.localeOf(context).toLanguageTag(),
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
    );
  }
}
