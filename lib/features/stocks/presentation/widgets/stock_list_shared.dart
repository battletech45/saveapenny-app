import 'package:flutter/material.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class MoneyRow extends StatelessWidget {
  const MoneyRow({
    super.key,
    required this.label,
    required this.amount,
    required this.currencyCode,
  });

  final String label;
  final num? amount;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final money = amount == null
        ? null
        : MoneyFormatter.format(
            context: context,
            amount: amount!,
            currencyCode: currencyCode,
          );

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: context.textTheme.label.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Text(
          money?.text ?? AppLocalizations.of(context).commonNotAvailable,
          style: context.textTheme.money.copyWith(
            color: money?.color ?? context.colors.textSecondary,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: context.textTheme.body),
          ],
        ),
      ),
    );
  }
}
