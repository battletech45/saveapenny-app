import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AccountRow extends StatelessWidget {
  const AccountRow({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatted = MoneyFormatter.format(
      context: context,
      amount: account.balance,
      currencyCode: account.currency,
      isDebt: account.type == AccountType.credit,
    );

    final typeColor = _colorFor(context, account.type);

    return ListTile(
      onTap: () => unawaited(GoRouter.of(context).push('/accounts')),
      leading: CircleAvatar(
        backgroundColor: typeColor.withValues(alpha: 0.15),
        child: Icon(_iconFor(account.type), color: typeColor),
      ),
      title: Text(account.name, style: context.textTheme.body),
      subtitle: Text(
        '${_labelFor(l10n, account.type)} · ${account.currency}',
        style: context.textTheme.label.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
      trailing: Text(
        formatted.text,
        style: context.textTheme.money.copyWith(color: formatted.color),
      ),
    );
  }

  Color _colorFor(BuildContext context, AccountType type) {
    final palette = Theme.of(context).brightness == Brightness.dark
        ? ChartPalette.dark
        : ChartPalette.light;
    return switch (type) {
      AccountType.cash => palette[2],
      AccountType.bank => palette[0],
      AccountType.credit => palette[4],
      AccountType.savings => palette[1],
      AccountType.investment => palette[3],
    };
  }

  IconData _iconFor(AccountType type) {
    return switch (type) {
      AccountType.cash => Icons.payments_outlined,
      AccountType.bank => Icons.account_balance_outlined,
      AccountType.credit => Icons.credit_card_outlined,
      AccountType.savings => Icons.savings_outlined,
      AccountType.investment => Icons.trending_up_outlined,
    };
  }

  String _labelFor(AppLocalizations l10n, AccountType type) {
    return switch (type) {
      AccountType.cash => l10n.accountsTypeCash,
      AccountType.bank => l10n.accountsTypeBank,
      AccountType.credit => l10n.accountsTypeCredit,
      AccountType.savings => l10n.accountsTypeSavings,
      AccountType.investment => l10n.accountsTypeInvestment,
    };
  }
}
