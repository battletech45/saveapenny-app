import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/charts.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/inline_empty_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/stocks/application/stock_detail_controller.dart';
import 'package:saveapenny/features/stocks/domain/stock_daily_series.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_financials_section.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_indicators_section.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_news_card.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_overview_card.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_quote_card.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockDetailScreen extends ConsumerWidget {
  const StockDetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(stockDetailControllerProvider(symbol));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('${l10n.stocksDetailsTitle} · ${symbol.toUpperCase()}'),
      ),
      body: SafeArea(
        child: detailState.when(
          data: (data) => RefreshIndicator(
            onRefresh: () => ref
                .read(stockDetailControllerProvider(symbol).notifier)
                .refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                StockQuoteCard(
                  quote: data.quote,
                  currencyCode: data.overview?.currency ?? 'USD',
                ),
                const SizedBox(height: AppSpacing.lg),
                StockOverviewCard(overview: data.overview),
                const SizedBox(height: AppSpacing.xxl),
                StockIndicatorsSection(symbol: symbol),
                const SizedBox(height: AppSpacing.xxl),
                StockFinancialsSection(symbol: symbol),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l10n.stocksDailySeriesTitle,
                  style: context.textTheme.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (data.dailySeries == null ||
                    data.dailySeries!.dataPoints.isEmpty)
                  InlineEmptyView(
                    title: l10n.stocksDailySeriesEmptyTitle,
                    message: l10n.stocksDailySeriesEmptyMessage,
                  )
                else
                  _StockDailySeriesChartCard(
                    points: data.dailySeries!.dataPoints,
                    currencyCode: data.overview?.currency ?? 'USD',
                  ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.stocksNewsTitle, style: context.textTheme.title),
                const SizedBox(height: AppSpacing.sm),
                if (data.news == null || data.news!.articles.isEmpty)
                  InlineEmptyView(
                    title: l10n.stocksNewsEmptyTitle,
                    message: l10n.stocksNewsEmptyMessage,
                  )
                else
                  ...data.news!.articles
                      .take(5)
                      .map(
                        (article) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: StockNewsCard(article: article),
                        ),
                      ),
              ],
            ),
          ),
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref
                .read(stockDetailControllerProvider(symbol).notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }
}

class _StockDailySeriesChartCard extends StatelessWidget {
  const _StockDailySeriesChartCard({
    required this.points,
    required this.currencyCode,
  });

  final List<StockDailyPoint> points;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final chartPoints = <TrendPoint>[];
    for (var i = 0; i < sorted.length; i++) {
      final close = sorted[i].close;
      if (close != null) {
        chartPoints.add(TrendPoint(i.toDouble(), close.toDouble()));
      }
    }
    final latestClose = sorted.last.close;
    final previousClose = sorted.length > 1
        ? sorted[sorted.length - 2].close
        : null;
    final color = latestClose != null && previousClose != null
        ? context.finance.forAmount(latestClose - previousClose)
        : Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (latestClose != null) ...<Widget>[
              Text(
                MoneyFormatter.format(
                  context: context,
                  amount: latestClose,
                  currencyCode: currencyCode,
                ).text,
                style: context.textTheme.displayMoney.copyWith(color: color),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            LineTrendChart(
              points: chartPoints,
              color: color,
              leftLabel: (value) => NumberFormat.compact().format(value),
              bottomLabel: (value) =>
                  _stockChartDateLabel(context, sorted, value),
            ),
          ],
        ),
      ),
    );
  }
}

String _stockChartDateLabel(
  BuildContext context,
  List<StockDailyPoint> points,
  double value,
) {
  final index = value.round();
  if (index < 0 || index >= points.length || value != index) {
    return '';
  }
  return DateFormat.MMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(points[index].date);
}
