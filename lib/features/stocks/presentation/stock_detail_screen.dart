import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/inline_empty_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/stocks/application/stock_detail_controller.dart';
import 'package:saveapenny/features/stocks/application/stock_financials_controller.dart';
import 'package:saveapenny/features/stocks/application/stock_indicators_controller.dart';
import 'package:saveapenny/features/stocks/domain/stock_daily_series.dart';
import 'package:saveapenny/features/stocks/domain/stock_financial_statement.dart';
import 'package:saveapenny/features/stocks/domain/stock_news.dart';
import 'package:saveapenny/features/stocks/domain/stock_overview.dart';
import 'package:saveapenny/features/stocks/domain/stock_quote.dart';
import 'package:saveapenny/features/stocks/domain/stock_technical_indicator.dart';
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
          onPressed: () => GoRouter.of(context).go('/stocks'),
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
                _QuoteCard(
                  quote: data.quote,
                  currencyCode: data.overview?.currency ?? 'USD',
                ),
                const SizedBox(height: AppSpacing.lg),
                _OverviewCard(overview: data.overview),
                const SizedBox(height: AppSpacing.xxl),
                _LazyIndicatorsSection(symbol: symbol),
                const SizedBox(height: AppSpacing.xxl),
                _LazyFinancialsSection(symbol: symbol),
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
                  ...data.dailySeries!.dataPoints
                      .take(5)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _DailyPointTile(
                            point: item,
                            currencyCode: data.overview?.currency ?? 'USD',
                          ),
                        ),
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
                          child: _NewsCard(article: article),
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

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.currencyCode});

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
            _InfoRow(
              label: l10n.stocksChangeLabel,
              value: change == null
                  ? l10n.commonNotAvailable
                  : '${change.text} (${_percentText(quote.changePercent)})',
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: l10n.stocksLatestTradingDayLabel,
              value: quote.latestTradingDay == null
                  ? l10n.commonNotAvailable
                  : _formatDate(context, quote.latestTradingDay!),
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.overview});

  final StockOverview? overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (overview == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.stocksOverviewTitle, style: context.textTheme.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.commonNotAvailable,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksOverviewTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.sm),
            if (overview!.name != null)
              Text(overview!.name!, style: context.textTheme.headline),
            if (overview!.exchange != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              _InfoRow(
                label: l10n.stocksExchangeLabel,
                value: overview!.exchange!,
              ),
            ],
            if (overview!.sector != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(label: l10n.stocksSectorLabel, value: overview!.sector!),
            ],
            if (overview!.industry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                label: l10n.stocksIndustryLabel,
                value: overview!.industry!,
              ),
            ],
            if (overview!.description != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.stocksDescriptionLabel,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(overview!.description!, style: context.textTheme.body),
            ],
          ],
        ),
      ),
    );
  }
}

class _LazyIndicatorsSection extends StatefulWidget {
  const _LazyIndicatorsSection({required this.symbol});

  final String symbol;

  @override
  State<_LazyIndicatorsSection> createState() => _LazyIndicatorsSectionState();
}

class _LazyIndicatorsSectionState extends State<_LazyIndicatorsSection> {
  bool _enabled = false;
  StockIndicatorType _selected = StockIndicatorType.sma;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_enabled) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.stocksIndicatorsTitle, style: context.textTheme.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.stocksIndicatorsSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => setState(() => _enabled = true),
                child: Text(l10n.stocksIndicatorsLoadCta),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(
          stockIndicatorControllerProvider(widget.symbol, _selected),
        );

        return state.when(
          data: (data) => _IndicatorsCard(
            selected: _selected,
            onSelected: (value) => setState(() => _selected = value),
            indicator: data,
          ),
          loading: () => _SectionLoadingCard(title: l10n.stocksIndicatorsTitle),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.stocksIndicatorsTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _IndicatorSelector(
                    selected: _selected,
                    onSelected: (value) => setState(() => _selected = value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _stockFailureMessage(context, error as Failure),
                    style: context.textTheme.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LazyFinancialsSection extends StatefulWidget {
  const _LazyFinancialsSection({required this.symbol});

  final String symbol;

  @override
  State<_LazyFinancialsSection> createState() => _LazyFinancialsSectionState();
}

class _LazyFinancialsSectionState extends State<_LazyFinancialsSection> {
  bool _enabled = false;
  StockFinancialStatementType _selected =
      StockFinancialStatementType.incomeStatement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_enabled) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.stocksFinancialsTitle, style: context.textTheme.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.stocksFinancialsSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => setState(() => _enabled = true),
                child: Text(l10n.stocksFinancialsLoadCta),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(
          stockFinancialStatementControllerProvider(widget.symbol, _selected),
        );

        return state.when(
          data: (data) => _FinancialsCard(
            selected: _selected,
            onSelected: (value) => setState(() => _selected = value),
            statement: data,
          ),
          loading: () => _SectionLoadingCard(title: l10n.stocksFinancialsTitle),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.stocksFinancialsTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FinancialSelector(
                    selected: _selected,
                    onSelected: (value) => setState(() => _selected = value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _stockFailureMessage(context, error as Failure),
                    style: context.textTheme.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IndicatorsCard extends StatelessWidget {
  const _IndicatorsCard({
    required this.selected,
    required this.onSelected,
    required this.indicator,
  });

  final StockIndicatorType selected;
  final ValueChanged<StockIndicatorType> onSelected;
  final StockTechnicalIndicator indicator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksIndicatorsTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.md),
            _IndicatorSelector(selected: selected, onSelected: onSelected),
            const SizedBox(height: AppSpacing.lg),
            _IndicatorPill(
              label: _indicatorLabel(l10n, selected),
              value: _latestValue(indicator),
            ),
          ],
        ),
      ),
    );
  }

  String _latestValue(StockTechnicalIndicator indicator) {
    if (indicator.dataPoints.isEmpty ||
        indicator.dataPoints.first.value == null) {
      return '--';
    }
    return indicator.dataPoints.first.value!.toStringAsFixed(2);
  }
}

class _FinancialsCard extends StatelessWidget {
  const _FinancialsCard({
    required this.selected,
    required this.onSelected,
    required this.statement,
  });

  final StockFinancialStatementType selected;
  final ValueChanged<StockFinancialStatementType> onSelected;
  final StockFinancialStatement statement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksFinancialsTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.md),
            _FinancialSelector(selected: selected, onSelected: onSelected),
            const SizedBox(height: AppSpacing.lg),
            _StatementPreview(
              title: _financialLabel(l10n, selected),
              statement: statement,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementPreview extends StatelessWidget {
  const _StatementPreview({required this.title, required this.statement});

  final String title;
  final StockFinancialStatement statement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = statement.annualReports.isNotEmpty
        ? statement.annualReports.first
        : statement.quarterlyReports.isNotEmpty
        ? statement.quarterlyReports.first
        : null;

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
            Text(title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            if (report == null)
              Text(
                l10n.stocksFinancialsEmptyMessage,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              )
            else ...<Widget>[
              Text(
                report.fiscalDateEnding,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...report.fields.entries
                  .take(3)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _InfoRow(label: entry.key, value: entry.value),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLoadingCard extends StatelessWidget {
  const _SectionLoadingCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  AppLocalizations.of(context).commonLoading,
                  style: context.textTheme.body.copyWith(
                    color: context.colors.textSecondary,
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

class _DailyPointTile extends StatelessWidget {
  const _DailyPointTile({required this.point, required this.currencyCode});

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
        title: Text(_formatDate(context, point.date)),
        subtitle: Text(
          'O: ${point.open ?? '--'}  H: ${point.high ?? '--'}  L: ${point.low ?? '--'}',
        ),
        trailing: Text(close, style: context.textTheme.money),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article});

  final StockNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(article.title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              [article.source, article.timePublished]
                  .whereType<String>()
                  .where((item) => item.isNotEmpty)
                  .join(' · '),
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            if (article.summary != null &&
                article.summary!.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(article.summary!, style: context.textTheme.body),
            ],
          ],
        ),
      ),
    );
  }
}

class _IndicatorPill extends StatelessWidget {
  const _IndicatorPill({required this.label, required this.value});

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

class _IndicatorSelector extends StatelessWidget {
  const _IndicatorSelector({required this.selected, required this.onSelected});

  final StockIndicatorType selected;
  final ValueChanged<StockIndicatorType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<StockIndicatorType>(
        segments: <ButtonSegment<StockIndicatorType>>[
          ButtonSegment<StockIndicatorType>(
            value: StockIndicatorType.sma,
            label: Text(l10n.stocksIndicatorSmaLabel),
          ),
          ButtonSegment<StockIndicatorType>(
            value: StockIndicatorType.ema,
            label: Text(l10n.stocksIndicatorEmaLabel),
          ),
          ButtonSegment<StockIndicatorType>(
            value: StockIndicatorType.rsi,
            label: Text(l10n.stocksIndicatorRsiLabel),
          ),
        ],
        selected: <StockIndicatorType>{selected},
        onSelectionChanged: (selection) => onSelected(selection.first),
      ),
    );
  }
}

class _FinancialSelector extends StatelessWidget {
  const _FinancialSelector({required this.selected, required this.onSelected});

  final StockFinancialStatementType selected;
  final ValueChanged<StockFinancialStatementType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<StockFinancialStatementType>(
        segments: <ButtonSegment<StockFinancialStatementType>>[
          ButtonSegment<StockFinancialStatementType>(
            value: StockFinancialStatementType.incomeStatement,
            label: Text(l10n.stocksIncomeStatementTitle),
          ),
          ButtonSegment<StockFinancialStatementType>(
            value: StockFinancialStatementType.balanceSheet,
            label: Text(l10n.stocksBalanceSheetTitle),
          ),
          ButtonSegment<StockFinancialStatementType>(
            value: StockFinancialStatementType.cashFlow,
            label: Text(l10n.stocksCashFlowTitle),
          ),
        ],
        selected: <StockFinancialStatementType>{selected},
        onSelectionChanged: (selection) => onSelected(selection.first),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: context.textTheme.label.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Text(value, style: context.textTheme.body)),
      ],
    );
  }
}

String _formatDate(BuildContext context, DateTime value) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String _stockFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure(message: final message) =>
      message != null && message.isNotEmpty
          ? message
          : l10n.failureGenericMessage,
    ApiFailure(
      code: final code,
      message: final message,
      details: final details,
    ) =>
      switch (code) {
        ApiErrorCode.invalidStockSymbol => l10n.stocksInvalidSymbolError,
        ApiErrorCode.stockQuoteNotAvailable => l10n.stocksQuoteUnavailableError,
        ApiErrorCode.stockHoldingNotFound =>
          l10n.failureResourceNotFoundMessage,
        ApiErrorCode.duplicateStockHolding => l10n.stocksDuplicateHoldingError,
        ApiErrorCode.stockProviderError => l10n.stocksProviderError,
        ApiErrorCode.validationFailed =>
          details.isNotEmpty
              ? details.first
              : l10n.failureValidationFailedMessage,
        _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
        _ => message.isNotEmpty ? message : l10n.failureValidationFailedMessage,
      },
  };
}

String _indicatorLabel(AppLocalizations l10n, StockIndicatorType type) {
  return switch (type) {
    StockIndicatorType.sma => l10n.stocksIndicatorSmaLabel,
    StockIndicatorType.ema => l10n.stocksIndicatorEmaLabel,
    StockIndicatorType.rsi => l10n.stocksIndicatorRsiLabel,
  };
}

String _financialLabel(
  AppLocalizations l10n,
  StockFinancialStatementType type,
) {
  return switch (type) {
    StockFinancialStatementType.incomeStatement =>
      l10n.stocksIncomeStatementTitle,
    StockFinancialStatementType.balanceSheet => l10n.stocksBalanceSheetTitle,
    StockFinancialStatementType.cashFlow => l10n.stocksCashFlowTitle,
  };
}
