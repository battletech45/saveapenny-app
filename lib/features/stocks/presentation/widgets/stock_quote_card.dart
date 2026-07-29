import 'package:flutter/material.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/stocks/domain/stock_quote.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_detail_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockQuoteCard extends StatelessWidget {
  const StockQuoteCard({
    super.key,
    required this.quote,
    required this.currencyCode,
  });

  final StockQuote quote;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final price = quote.price == null
        ? null
        : MoneyFormatter.format(
            context: context,
            amount: quote.price!,
            currencyCode: currencyCode,
          );
    final change = quote.change == null
        ? null
        : MoneyFormatter.format(
            context: context,
            amount: quote.change!,
            currencyCode: currencyCode,
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksQuoteTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.xl),
            Text(
              price?.text ?? l10n.commonNotAvailable,
              style: context.textTheme.displayMoney.copyWith(
                color: price?.color ?? context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InfoRow(
              label: l10n.stocksChangeLabel,
              value: change == null
                  ? l10n.commonNotAvailable
                  : '${change.text} (${_percentText(quote.changePercent)})',
            ),
            const SizedBox(height: AppSpacing.sm),
            InfoRow(
              label: l10n.stocksLatestTradingDayLabel,
              value: quote.latestTradingDay == null
                  ? l10n.commonNotAvailable
                  : formatStockDate(context, quote.latestTradingDay!),
            ),
          ],
        ),
      ),
    );
  }

  String _percentText(num? value) {
    if (value == null) {
      return '--';
    }
    return '${value.toStringAsFixed(2)}%';
  }
}
