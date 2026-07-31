import 'package:flutter/material.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/stocks/domain/stock_daily_series.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_detail_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockDailyPointTile extends StatelessWidget {
  const StockDailyPointTile({
    super.key,
    required this.point,
    required this.currencyCode,
  });

  final StockDailyPoint point;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final close = point.close == null
        ? AppLocalizations.of(context).commonNotAvailable
        : MoneyFormatter.format(
            context: context,
            amount: point.close!,
            currencyCode: currencyCode,
          ).text;

    return Card(
      child: ListTile(
        title: Text(formatStockDate(context, point.date)),
        subtitle: Text(
          'O: ${point.open ?? '--'}  H: ${point.high ?? '--'}  L: ${point.low ?? '--'}',
        ),
        trailing: Text(close, style: context.textTheme.money),
      ),
    );
  }
}
