import 'package:flutter/material.dart';

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
  });

  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = MoneyFormatter.format(
      context: context,
      amount: account.balance,
      currencyCode: account.currency,
    );

    return Card(
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
          ],
        ),
      ),
    );
  }
}
