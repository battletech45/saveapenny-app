import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/stat_pill.dart';
import 'package:saveapenny/features/stocks/application/stock_indicators_controller.dart';
import 'package:saveapenny/features/stocks/domain/stock_technical_indicator.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_detail_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockIndicatorsSection extends StatefulWidget {
  const StockIndicatorsSection({super.key, required this.symbol});

  final String symbol;

  @override
  State<StockIndicatorsSection> createState() => _StockIndicatorsSectionState();
}

class _StockIndicatorsSectionState extends State<StockIndicatorsSection> {
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
          loading: () => SectionLoadingCard(title: l10n.stocksIndicatorsTitle),
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
                    stockFailureMessage(context, error as Failure),
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
              icon: _trendIcon(indicator),
              tone: _trendTone(indicator),
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

  IconData _trendIcon(StockTechnicalIndicator indicator) {
    final trend = _latestTrend(indicator);
    if (trend > 0) {
      return Icons.trending_up_rounded;
    }
    if (trend < 0) {
      return Icons.trending_down_rounded;
    }
    return Icons.trending_flat_rounded;
  }

  StatPillTone _trendTone(StockTechnicalIndicator indicator) {
    final trend = _latestTrend(indicator);
    if (trend > 0) {
      return StatPillTone.income;
    }
    if (trend < 0) {
      return StatPillTone.expense;
    }
    return StatPillTone.neutral;
  }

  num _latestTrend(StockTechnicalIndicator indicator) {
    if (indicator.dataPoints.length < 2 ||
        indicator.dataPoints.first.value == null ||
        indicator.dataPoints[1].value == null) {
      return 0;
    }
    return indicator.dataPoints.first.value! - indicator.dataPoints[1].value!;
  }
}

class _IndicatorPill extends StatelessWidget {
  const _IndicatorPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final StatPillTone tone;

  @override
  Widget build(BuildContext context) {
    return StatPill(label: label, value: value, icon: icon, tone: tone);
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

String _indicatorLabel(AppLocalizations l10n, StockIndicatorType type) {
  return switch (type) {
    StockIndicatorType.sma => l10n.stocksIndicatorSmaLabel,
    StockIndicatorType.ema => l10n.stocksIndicatorEmaLabel,
    StockIndicatorType.rsi => l10n.stocksIndicatorRsiLabel,
  };
}
