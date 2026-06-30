import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/theme/app_theme.dart';

class FormattedMoney {
  const FormattedMoney({required this.text, required this.color});

  final String text;
  final Color color;
}

abstract final class MoneyFormatter {
  static FormattedMoney format({
    required BuildContext context,
    required num amount,
    required String currencyCode,
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = NumberFormat.currency(locale: locale, name: currencyCode);
    final prefix = amount > 0
        ? '+'
        : amount < 0
        ? '-'
        : '';

    return FormattedMoney(
      text: '$prefix${formatter.format(amount.abs())}',
      color: context.finance.forAmount(amount),
    );
  }
}
