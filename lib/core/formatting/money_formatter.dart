import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/theme/app_theme.dart';

class FormattedMoney {
  const FormattedMoney({required this.text, required this.color});

  final String text;
  final Color color;
}

abstract final class MoneyFormatter {
  /// Formats [amount] as a signed, localized currency string.
  ///
  /// Set [isDebt] for balances that represent money owed (e.g. a CREDIT
  /// account balance) rather than funds on hand: the sign and color flip, so
  /// a positive balance (debt) reads as `-` in the expense color instead of
  /// `+` in the income color.
  static FormattedMoney format({
    required BuildContext context,
    required num amount,
    required String currencyCode,
    bool isDebt = false,
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = NumberFormat.currency(locale: locale, name: currencyCode);
    final displayAmount = isDebt ? -amount : amount;
    final prefix = displayAmount > 0
        ? '+'
        : displayAmount < 0
        ? '-'
        : '';

    return FormattedMoney(
      text: '$prefix${formatter.format(displayAmount.abs())}',
      color: context.finance.forAmount(displayAmount),
    );
  }
}
