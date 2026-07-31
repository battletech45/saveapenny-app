import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

class ReportsMoneyRow extends StatelessWidget {
  const ReportsMoneyRow({
    super.key,
    required this.label,
    required this.amount,
    required this.currencyCode,
    this.emphasize = false,
  });

  final String label;
  final num amount;
  final String currencyCode;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final formatted = MoneyFormatter.format(
      context: context,
      amount: amount,
      currencyCode: currencyCode,
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: emphasize ? context.textTheme.body : context.textTheme.label,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          formatted.text,
          textAlign: TextAlign.right,
          style:
              (emphasize
                      ? context.textTheme.displayMoney
                      : context.textTheme.money)
                  .copyWith(color: formatted.color),
        ),
      ],
    );
  }
}

class ReportsInlineEmptyState extends StatelessWidget {
  const ReportsInlineEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

T? readReportsAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
