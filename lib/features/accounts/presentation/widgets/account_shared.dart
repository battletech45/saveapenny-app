import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String accountTypeLabel(AppLocalizations l10n, AccountType type) {
  return switch (type) {
    AccountType.cash => l10n.accountsTypeCash,
    AccountType.bank => l10n.accountsTypeBank,
    AccountType.credit => l10n.accountsTypeCredit,
    AccountType.savings => l10n.accountsTypeSavings,
    AccountType.investment => l10n.accountsTypeInvestment,
  };
}

IconData accountTypeIcon(AccountType type) {
  return switch (type) {
    AccountType.cash => Icons.payments_outlined,
    AccountType.bank => Icons.account_balance_outlined,
    AccountType.credit => Icons.credit_card_outlined,
    AccountType.savings => Icons.savings_outlined,
    AccountType.investment => Icons.trending_up_outlined,
  };
}

Color accountTypeColor(BuildContext context, AccountType type) {
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
