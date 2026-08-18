import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

/// A single point in a time-ordered trend series.
class TrendPoint {
  const TrendPoint(this.x, this.y);

  final double x;
  final double y;
}

class TrendSeries {
  const TrendSeries({required this.points, required this.color});

  final List<TrendPoint> points;
  final Color color;
}

/// A minimal, axis-less line trend — for compact inline use (dashboard hero,
/// insight tiles). No gridlines, no labels, just the shape of the trend.
class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.points,
    this.color,
    this.height = 40,
  });

  final List<TrendPoint> points;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(height: height);
    }
    final lineColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: points.map((p) => p.y).reduce((a, b) => a < b ? a : b),
          maxY: points.map((p) => p.y).reduce((a, b) => a > b ? a : b),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: <FlSpot>[for (final p in points) FlSpot(p.x, p.y)],
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labeled line trend chart with hairline gridlines and tabular-figure
/// axis labels, styled to the theme — for Reports (net worth, cash flow) and
/// Stocks (price history).
class LineTrendChart extends StatelessWidget {
  const LineTrendChart({
    super.key,
    required this.points,
    this.color,
    this.height = 180,
    this.leftLabel,
    this.bottomLabel,
  });

  final List<TrendPoint> points;
  final Color? color;
  final double height;
  final String Function(double value)? leftLabel;
  final String Function(double value)? bottomLabel;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(height: height);
    }
    final lineColor = color ?? Theme.of(context).colorScheme.primary;
    final chartColors = context.chart;
    final axisStyle = context.textTheme.label.copyWith(
      color: chartColors.axisLabel,
      fontFeatures: kTabularFigures,
    );

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: chartColors.gridline, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: leftLabel != null,
                reservedSize: 44,
                getTitlesWidget: (value, meta) =>
                    Text(leftLabel?.call(value) ?? '', style: axisStyle),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: bottomLabel != null,
                reservedSize: 24,
                getTitlesWidget: (value, meta) =>
                    Text(bottomLabel?.call(value) ?? '', style: axisStyle),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.colors.surface,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    spot.y.toStringAsFixed(2),
                    context.textTheme.label.copyWith(
                      color: context.colors.textPrimary,
                      fontFeatures: kTabularFigures,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: <FlSpot>[for (final p in points) FlSpot(p.x, p.y)],
              isCurved: true,
              color: lineColor,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiLineTrendChart extends StatelessWidget {
  const MultiLineTrendChart({
    super.key,
    required this.series,
    this.height = 180,
    this.leftLabel,
    this.bottomLabel,
  });

  final List<TrendSeries> series;
  final double height;
  final String Function(double value)? leftLabel;
  final String Function(double value)? bottomLabel;

  @override
  Widget build(BuildContext context) {
    final visibleSeries = series
        .where((item) => item.points.length >= 2)
        .toList(growable: false);
    if (visibleSeries.isEmpty) {
      return SizedBox(height: height);
    }

    final chartColors = context.chart;
    final axisStyle = context.textTheme.label.copyWith(
      color: chartColors.axisLabel,
      fontFeatures: kTabularFigures,
    );

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: chartColors.gridline, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: leftLabel != null,
                reservedSize: 44,
                getTitlesWidget: (value, meta) =>
                    Text(leftLabel?.call(value) ?? '', style: axisStyle),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: bottomLabel != null,
                reservedSize: 24,
                getTitlesWidget: (value, meta) =>
                    Text(bottomLabel?.call(value) ?? '', style: axisStyle),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.colors.surface,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    spot.y.toStringAsFixed(2),
                    context.textTheme.label.copyWith(
                      color: context.colors.textPrimary,
                      fontFeatures: kTabularFigures,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: <LineChartBarData>[
            for (final item in visibleSeries)
              LineChartBarData(
                spots: <FlSpot>[for (final p in item.points) FlSpot(p.x, p.y)],
                isCurved: true,
                color: item.color,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single slice of a [CategoryDonutChart].
class DonutSlice {
  const DonutSlice({required this.label, required this.value, this.color});

  final String label;
  final double value;
  final Color? color;
}

/// A donut chart for categorical breakdowns (category spending). Falls back
/// to the theme's [ChartColors.categorical] sequence when a slice has no
/// explicit color.
class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({super.key, required this.slices, this.size = 160});

  final List<DonutSlice> slices;
  final double size;

  @override
  Widget build(BuildContext context) {
    final chartColors = context.chart;
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    if (total <= 0) {
      return SizedBox(height: size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: size / 3.2,
          sections: <PieChartSectionData>[
            for (var i = 0; i < slices.length; i++)
              PieChartSectionData(
                value: slices[i].value,
                color: slices[i].color ?? chartColors.forIndex(i),
                title: '',
                radius: size / 6,
              ),
          ],
        ),
      ),
    );
  }
}
