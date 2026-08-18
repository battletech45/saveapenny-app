import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

/// A horizontal progress bar for percentage-of-total values (budget usage,
/// credit utilization, goal progress). [value] is 0-1; values above 1 clamp
/// the fill but keep [label]/[valueLabel] showing the true (over-100%)
/// figure so overspend is visible.
class ProgressMeter extends StatelessWidget {
  const ProgressMeter({
    super.key,
    required this.value,
    this.color,
    this.trackColor,
    this.height = 8,
  });

  final double value;
  final Color? color;
  final Color? trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fillColor = color ?? Theme.of(context).colorScheme.primary;
    final backgroundColor = trackColor ?? context.colors.surfaceSubtle;
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(color: backgroundColor),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: clamped),
              duration: AppDuration.slow,
              curve: Curves.easeInOutCubic,
              builder: (context, animatedValue, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedValue,
                  child: ColoredBox(color: fillColor),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A circular progress ring for hero-level progress display (goal progress,
/// credit utilization detail). [value] is 0-1; the [center] widget (usually
/// a percentage or amount) is rendered in the middle of the ring.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.color,
    this.trackColor,
    this.size = 96,
    this.strokeWidth = 8,
    this.center,
  });

  final double value;
  final Color? color;
  final Color? trackColor;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final fillColor = color ?? Theme.of(context).colorScheme.primary;
    final backgroundColor = trackColor ?? context.colors.surfaceSubtle;
    final clamped = value.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: clamped),
        duration: AppDuration.slow,
        curve: Curves.easeInOutCubic,
        builder: (context, animatedValue, _) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: strokeWidth,
                  color: backgroundColor,
                ),
              ),
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: strokeWidth,
                  color: fillColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              ?center,
            ],
          );
        },
      ),
    );
  }
}
